import io
import torch
import torch.nn as nn
from fastapi import FastAPI, File, UploadFile
from torchvision import models, transforms
from PIL import Image, ImageChops
import google.generativeai as genai

app = FastAPI(title="Lung Cancer Detection API")

# Configure the Gemini API with your new key
genai.configure(api_key="AIzaSyDGjoN-6WqgTaV5HNj6Z_-s-lVbIBD2AJU")
# Try using the 'v1' stable version name
gemini_model = genai.GenerativeModel('gemini-1.5-flash-latest')

# 1. Define Model Architecture (Must match your training)
def load_model():
    model = models.resnet18()
    # Your code had 3 classes: Benign, Malignant, Normal
    num_ftrs = model.fc.in_features
    model.fc = nn.Linear(num_ftrs, 3) 
    
    # Load weights
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model.load_state_dict(torch.load('model_weights.pth', map_location=device))
    model.to(device)
    model.eval()
    return model, device

model, device = load_model()

# 2. Define Image Transformations
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], 
                         std=[0.229, 0.224, 0.225])
])

# 3. Class Names
CLASS_NAMES = ["Benign", "Malignant", "Normal"]

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    # Read uploaded image
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    
    # --- STEP 1: GRAYSCALE VALIDATION (Integrity Check) ---
    # Medical CT/X-ray images are grayscale. We check if R, G, and B are different.
    r, g, b = image.split()
    # Compare Red to Green and Red to Blue
    diff_rg = ImageChops.difference(r, g)
    diff_rb = ImageChops.difference(r, b)
    
    # getbbox() returns None if the images are exactly the same
    if diff_rg.getbbox() or diff_rb.getbbox():
        return {
            "prediction": "Invalid Image Type",
            "status": "error",
            "message": "Color detected. Please upload a valid Black & White Lung CT scan."
        }
    
    # --- STEP 2: PREPROCESSING ---
    input_tensor = transform(image).unsqueeze(0).to(device)
    
    # --- STEP 3: INFERENCE ---
    with torch.no_grad():
        outputs = model(input_tensor)
        probabilities = torch.nn.functional.softmax(outputs[0], dim=0)
        confidence, index = torch.max(probabilities, 0)
    
    conf_value = float(confidence)

    # --- STEP 4: CONFIDENCE THRESHOLD (0.85) ---
    if conf_value < 0.85:
        return {
            "prediction": "Uncertain",
            "confidence": conf_value,
            "status": "error",
            "message": "Model confidence is low. Please ensure this is a clear Lung CT Scan."
        }

    # --- STEP 5: SUCCESSFUL RESPONSE ---
    return {
        "prediction": CLASS_NAMES[index],
        "confidence": conf_value,
        "status": "success",
        "disclaimer": "AI prediction for screening only. Please consult a radiologist.",
        "all_probabilities": {
            CLASS_NAMES[i]: float(probabilities[i]) for i in range(len(CLASS_NAMES))
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

@app.post("/chat")
async def medical_chat(user_message: str):
    try:
        # We use a more direct way to call the model to avoid version errors
        model = genai.GenerativeModel(model_name="gemini-1.5-flash")
        
        # We add a safety instruction directly to the message
        safe_message = f"Answer as a medical assistant: {user_message}"
        
        response = model.generate_content(safe_message)
        return {"reply": response.text}
        
    except Exception as e:
        # This will tell us if it's an Auth error, a Model error, or a Network error
        return {"error_type": type(e).__name__, "details": str(e)}