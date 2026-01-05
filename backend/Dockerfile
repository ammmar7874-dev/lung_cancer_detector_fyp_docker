# 1. Use a lightweight Python base image
FROM python:3.9-slim

# 2. Set the working directory
WORKDIR /app

# 3. Install modern system libraries for PyTorch and OpenCV
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 4. Copy your requirements file first
COPY requirements.txt .

# 5. Install libraries (This will be the largest step)
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copy your main.py and model_weights.pth
COPY . .

# 7. Expose the port FastAPI runs on
EXPOSE 8000

# 8. Start the FastAPI server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]