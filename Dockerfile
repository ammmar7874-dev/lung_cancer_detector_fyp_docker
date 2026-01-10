# 1. Use a lightweight Python base image
FROM python:3.9-slim

# 2. Set the working directory
WORKDIR /app

# 3. Install modern system libraries for PyTorch and OpenCV
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 4. Copy backend requirements from the subdirectory
COPY backend/requirements.txt .

# 5. Install libraries
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copy the rest of the backend code
COPY backend/ .

# 7. Expose the port (Hugging Face Spaces uses 7860)
EXPOSE 7860

# 8. Start the FastAPI server on port 7860
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
