FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04
ARG PYTHON_VERSION=3.6

LABEL maintainer="Maryan Morel <maryan.morel@polytechnique.edu>"

# Needed for string substitution 
SHELL ["/bin/bash", "-c"]
COPY bashrc /etc/bash.bashrc

# Setup env. conda, python and install basic libs
RUN chmod a+rwx /etc/bash.bashrc &&\
     apt-get update && apt-get install -y --no-install-recommends \
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
         libpng-dev &&\
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
        pyyaml \
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
        dask  && \
     /opt/conda/bin/conda install -y -c pytorch pytorch torchvision cudatoolkit=10.0 magma-cuda100 ignite && \
     /opt/conda/bin/pip install pytorch-lightning tensorflow-gpu && \
     /opt/conda/bin/conda install -y -c conda-forge ninja jedi jupyterlab tensorboardx pyarrow fastparquet && \
     /opt/conda/bin/conda clean -ya && \
     mkdir /.local && chmod a+rwx /.local &&\
     cd /opt && \
     git clone https://github.com/keras-team/keras-tuner.git && \
     cd keras-tuner && \
     /opt/conda/bin/pip install . && \
     cd /opt && \
     rm -rf keras-tuner

# Update ENV
ENV PATH /opt/conda/bin:$PATH

# TODO later: add password to jupyter or disable it, to avoid copy-pasta of session token
# TODO later: find a way to auto-start tensorboard on some location? Maybe run it as a second image attached to the same volume?
# (different service, might be a good idea to try building a way smaller image for tensorboard only?)

WORKDIR /workspace
EXPOSE 8888 6006
CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter lab --notebook-dir=/io --ip 0.0.0.0 --no-browser --allow-root"]
