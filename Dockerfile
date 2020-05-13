FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
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
        libpng-dev \
        wget && \
    curl -sL https://deb.nodesource.com/setup_13.x | bash - && \
    apt-get install -y nodejs yarn && \
    rm -rf /var/lib/apt/lists/* && \
    wget 'https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh' -O ~/miniconda.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH /opt/conda/bin:$PATH
# Base package
RUN conda install -y python=$PYTHON_VERSION \
        setuptools \
        typing \
        cmake \
        cython \
        mkl \
        mkl-include \
        ninja \
        cffi \
        dill \
        ipython \
        jupyter \
        scipy \
        numpy \
        scikit-learn \
        tqdm \
        pandas \
        dask \
        pyyaml \
        h5py \
        protobuf \
        matplotlib \
        seaborn && \
    conda install -c conda-forge -y \
        ninja \
        jedi \
        jupyterlab \
        fastparquet \
        python-snappy \
        rise && \
    pip install pyarrow && \
    conda install -c pytorch -y \
        pytorch \
        torchtext \
        cudatoolkit=10.1 \
        magma-cuda101 \
        ignite \
        captum && \
    conda install -c dglteam -y dgl-cuda10.1 && \
    pip install \
        pytorch-lightning \
        tensorflow-gpu \
        jupyter-tensorboard \
        hydra-core \
        "ray[tune]"
RUN jupyter labextension install jupyterlab_tensorboard && \
    jupyter labextension enable jupyterlab_tensorboard && \
    jupyter labextension install @aquirdturtle/collapsible_headings && \
    jupyter labextension enable @aquirdturtle/collapsible_headings && \
    jupyter labextension install @jupyterlab/toc && \
    jupyter labextension enable @jupyterlab/toc && \
    jupyter labextension install jupyterlab-execute-time && \
    jupyter labextension enable jupyterlab-execute-time && \
    conda clean -ya && \
    mkdir /.local && chmod a+rwx /.local
RUN mkdir -p /.jupyter/lab/user-settings/@jupyterlab/notebook-extension && \
    cd /.jupyter/lab/user-settings/@jupyterlab/notebook-extension && \
    echo "{\"recordTiming\": true}" > tracker.jupyterlab-settings && \
    chmod a+rwx /.jupyter

WORKDIR /workspace
EXPOSE 8888 6006
CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter lab --notebook-dir=/io --ip 0.0.0.0 --no-browser --allow-root"]
