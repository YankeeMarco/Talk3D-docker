# Use a CUDA base image
FROM nvidia/cuda:11.6-cudnn8-runtime-ubuntu20.04

# Set working directory
WORKDIR /app

# Install necessary packages
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

# Update PATH
ENV PATH=/opt/conda/bin:$PATH

# Create conda environment
RUN conda create -n talk3d python=3.8 -y && \
    conda clean -afy

# Copy requirements.txt first to leverage Docker cache
COPY requirements.txt ./

# Activate the conda environment and install Python dependencies
RUN /bin/bash -c "source activate talk3d && \
    pip install torch==1.13.1+cu116 torchvision==0.14.1+cu116 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu116 && \
    pip install -r requirements.txt"

# Copy the rest of the project files into the container
COPY . .

# Specify the command to run your application
CMD ["/bin/bash"]
