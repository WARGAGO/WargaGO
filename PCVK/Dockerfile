FROM python:3.12-slim

ARG USE_CUDA=true

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements-docker.txt .

RUN echo "USE_CUDA is set to: $USE_CUDA" && \
    if [ "$USE_CUDA" = "true" ]; then \
        echo "Installing CUDA version..." && \
        pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cu130 && \
        pip install onnxruntime-gpu; \
    else \
        echo "Installing CPU version..." && \
        pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cpu && \
        pip install onnxruntime; \
    fi

RUN pip install --no-cache-dir -r requirements-docker.txt

COPY . .

EXPOSE 8000
ENV PYTHONUNBUFFERED=1

CMD ["python", "app.py"]