FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu16.04
ARG PYTHON_VERSION=3.7

LABEL maintainer="Maryan Morel <maryan.morel@polytechnique.edu>"

# Needed for string substitution 
SHELL ["/bin/bash", "-c"]
COPY bashrc /etc/bash.bashrc

# Setup env. conda, python and install basic libs
RUN chmod a+rwx /etc/bash.bashrc &&\
    apt-get update && apt-get install -y --no-install-recommends --fix-missing \
        build-essential \
        cmake \
        curl \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        software-properties-common \
        unzip \
        git \
        vim \
        ca-certificates \
        libjpeg-dev \
        libpng-dev && \
    curl -sL https://deb.nodesource.com/setup_13.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda install -y python=$PYTHON_VERSION \
        setuptools \
        ninja \
        cmake \
        cffi \
        numpy \
        pyyaml \
        scipy \
        numpy \
        pandas \
        jupyter \
        dill \
        h5py \
        protobuf \
        scikit-learn \
        matplotlib \
        seaborn \
        ipython \
        mkl \
        mkl-include \
        cython \
        typing \
        dask && \
    /opt/conda/bin/conda install -c pytorch -y \
        pytorch \
        torchvision \
        cudatoolkit=10.2 \
        magma-cuda102 \
        ignite \
        captum && \
    /opt/conda/bin/conda install -c conda-forge -y \
        ninja \
        jedi \
        jupyterlab \
        pyarrow \
        fastparquet && \
    /opt/conda/bin/pip install \
        pytorch-lightning \
        tensorflow-gpu \
        tensorboardx \
        jupyterlab-nvdashboard \
        jupyter-tensorboard \
        keras-tuner && \
    /opt/conda/bin/jupyter labextension install jupyterlab-nvdashboard && \
    /opt/conda/bin/conda clean -ya && \
    mkdir /.local && chmod a+rwx /.local

# Update ENV
ENV PATH /opt/conda/bin:$PATH

WORKDIR /workspace
EXPOSE 8888 6006
CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter lab --notebook-dir=/io --ip 0.0.0.0 --no-browser --allow-root"]
