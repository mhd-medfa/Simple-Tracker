FROM nvidia/cuda:10.2-base-ubuntu18.04

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    screen \
    ffmpeg \
    libsm6 \
    libxext6  \
 && rm -rf /var/lib/apt/lists/*

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user
# && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
#ENV HOME=/home/user
#RUN chmod 777 /home/user

# Install Miniconda and Python 3.8
ENV CONDA_AUTO_UPDATE_CONDA=false
ENV PATH=/home/user/miniconda/bin:$PATH
RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py38_4.8.2-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh \
 && conda install -y python==3.8.1 \
 && conda clean -ya

# CUDA 10.2-specific steps
RUN conda install -y -c pytorch \
    cudatoolkit=10.2 \
    "pytorch=1.5.0=py3.8_cuda10.2.89_cudnn7.6.5_0" \
    "torchvision=0.6.0=py38_cu102" \
 && conda clean -ya
RUN conda install -y -c conda-forge opencv && conda clean -ya
RUN pip uninstall gdown -y && pip install gdown
RUN cd ~/ && git clone https://github.com/mhd-medfa/Simple-Tracker.git
RUN cd ~/'Simple-Tracker' && pip install -qr requirements.txt && gdown https://drive.google.com/uc?id=1SPFiokuoq7iJZH6oIZacvCNLRviNJaAx -O video.mkv

RUN chown -R user:user ~/'Simple-Tracker'
# Create a working directory
WORKDIR /home/user/'Simple-Tracker'


# Set the default command to python3
#CMD ["python3"]
# Run colorful prompt
CMD ["/bin/bash", "-l" ]
