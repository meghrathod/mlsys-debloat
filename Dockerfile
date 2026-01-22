FROM quay.io/jupyter/pytorch-notebook:cuda11-pytorch-2.4.1

USER root

# Install dependencies
RUN apt-get update && \
    apt-get install -y python3-pip libspdlog-dev cmake build-essential curl pkg-config libssl-dev ocl-icd-opencl-dev && \
    apt-get clean

# Install CUDA toolkit and create /usr/local/cuda symlink
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends cuda-nvcc-11-8 cuda-command-line-tools-11-8 cuda-cudart-dev-11-8 2>/dev/null || true && \
    rm -f cuda-keyring_1.1-1_all.deb && \
    ln -sf /usr/local/cuda-11.8 /usr/local/cuda && \
    apt-get clean

# Switch to non-root user and install Rust for them
USER ${NB_UID}
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    mkdir -p /home/jovyan/.cargo/registry/cache && \
    chmod -R u+w /home/jovyan/.cargo

# Set up environment variables
ENV PATH="/home/jovyan/.cargo/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/nvidia/lib64:/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}"
ENV LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs:/usr/local/nvidia/lib64:/usr/lib/x86_64-linux-gnu:${LIBRARY_PATH}"
ENV RUSTFLAGS="-L /usr/local/cuda/lib64 -L /usr/local/cuda/lib64/stubs -L /usr/lib/x86_64-linux-gnu"