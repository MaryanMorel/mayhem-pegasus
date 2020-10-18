#!/bin/bash
echo -e "\e[1;31mLet the mayhem begin!\e[0m \n"

GPU_ARG=$1  # Number or id of GPUs
CMD=${2:-''}  # input "/bin/bash" if you want to run the container in shell mode instead of a jupyter server
CPU_COUNT=${3:-10} # Default number of cpus used by the container
JUPYTER_PORT=${4:-8888}  # Notebook port
TB_PORT=${5:-6006}  # Tensorboard default port
RAY_PORT=${6:-8206}  # Ray[tune] default port

# To run as root, simply remove '-u $(id -u):$(id -g)'
docker run -u $(id -u):$(id -g) --shm-size=40g -v $PWD/mnt:/io \
    -p 0.0.0.0:$JUPYTER_PORT:8888 \
    -p 0.0.0.0:$TB_PORT:6006 \
    -p 0.0.0.0:$RAY_PORT:8265 \
    -it --gpus $GPU_ARG --cpus=$CPU_COUNT \
    --rm maryanmorel/mayhem-pegasus:latest $CMD
