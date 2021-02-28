
FROM nvidia/cuda:11.2.1-cudnn8-devel-ubuntu20.04
ARG PYTHON_VERSION=3.8
# ENV TZ=Europe/Paris
ENV DEBIAN_FRONTEND noninteractive

LABEL maintainer="Maryan Morel <maryan.morel@polytechnique.edu>"

# Needed for string substitution 
SHELL ["/bin/bash", "-c"]
COPY bashrc /etc/bash.bashrc
ENV PATH /opt/conda/bin:$PATH

# Setup env. conda, python and install basic libs
RUN chmod a+rwx /etc/bash.bashrc &&\
    apt update && \
    apt-get update && \
    apt-get install -y --no-install-recommends --fix-missing \
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
        wget \
        rsync && \
    curl -sL https://deb.nodesource.com/setup_13.x | bash - && \
    apt-get install -y nodejs yarn && \
    rm -rf /var/lib/apt/lists/* && \
    wget 'https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh' -O ~/miniconda.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    conda install -y python=$PYTHON_VERSION \
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
        networkx \
        pyyaml \
        h5py \
        protobuf \
        matplotlib \
        seaborn && \
    conda install -c conda-forge -c pytorch -c nvidia -c dglteam -y \
        ninja \
        jedi \
        jupyterlab \
        fastparquet \
        python-snappy \
        rise \
        pytorch=1.7.1 \
        torchtext \
        torchvision \
        torchaudio \
        ignite \
        captum \
        cudatoolkit=11.2 \
        dgl-cuda11.0 \
        magma-cuda112 \
        nodejs=15.10 \
        jupyterlab_execute_time && \
    pip install \
        pyarrow \
        comet_ml \
        pytorch-lightning==1.2.1 \
        tensorboard \
        hydra-core \
        optuna \
        hyperopt \
        ray[tune] && \
    jupyter labextension install @aquirdturtle/collapsible_headings && \
    jupyter labextension enable @aquirdturtle/collapsible_headings && \
    jupyter labextension enable jupyterlab-execute-time && \
    jupyter lab clean && \
    jupyter lab build --dev-build=False --minimize=False && \
    conda clean -ya

RUN mkdir -p /home/mayhem && chmod a+rwx /home/mayhem && cd /home/mayhem && \
    mkdir -p .local && chmod a+rwx .local && \
    mkdir -p .config/git && chmod -R a+rwx .config && \
    mkdir -p .jupyter/lab/user-settings/@jupyterlab/notebook-extension && \
    echo "{\"recordTiming\": true}" > .jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings && \
    chmod -R a+rwx .jupyter && \
    mkdir -p .conda && chmod -R a+rwx .conda && \
    mkdir -p /data && chmod -R a+rwx /data

ENV HOME /home/mayhem
WORKDIR /io
EXPOSE 8888 8265 6006
CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter lab --notebook-dir=/io --ip 0.0.0.0 --no-browser --allow-root"]
