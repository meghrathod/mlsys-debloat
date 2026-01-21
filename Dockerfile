FROM quay.io/jupyter/pytorch-notebook:cuda11-pytorch-2.4.1

USER root

# Install the curl and build-essential packages
RUN apt-get update && \
    apt-get install -y python3-pip libspdlog-dev cmake build-essential curl pkg-config libssl-dev && \
    apt-get clean

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

USER ${NB_UID}