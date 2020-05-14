[![Build automation](https://img.shields.io/docker/cloud/automated/maryanmorel/mayhem-pegasus.svg)](https://img.shields.io/docker/cloud/automated/maryanmorel/mayhem-pegasus)
[![Build status](https://img.shields.io/docker/cloud/build/maryanmorel/mayhem-pegasus.svg)](https://img.shields.io/docker/cloud/build/maryanmorel/mayhem-pegasus)

# mayhem-pegasus

Useful docker images for deep learning and machine learning in general.

Current version: Pytorch, tensorflow-gpu, and usual useful python libraries (numpy, pandas, dask, sklearn, matplotlib, seaborn ray, optuna, hydra, lightning...)

To build images (don't forget the final dot!):

```bash
docker build -f ./Dockerfile -t mayhem-pegasus:<TAG> .
```

To run a jupyter lab session and mounting a shared folder (host: `./mnt` will be paired with `/io` in the container) :

```bash
docker run -u $(id -u):$(id -g)  -v $PWD/mnt:/io -p 0.0.0.0:<local jupyter port>:8888 -p 0.0.0.0:<local tensorboard port>:6006 -it --gpus <device> --rm mayhem-pegasus:<TAG>
```

where `<device>` is the device number. If you want to use multiple devices, see usage [examples](https://github.com/NVIDIA/nvidia-docker#usage).

I you are lazy, just put the startup script `start-mayhem.sh` somewhere in your `PATH` and `chmod +x` it. Read the script and edit it before using it to match the ports you are using!

## Examples

`--gpus 0` to use only device 0

`--gpus '"device=1,2"'` to use devices 1 and 2

`--gpus all` to use all devices

## Prerequisites

The provider docker file / container suppose NVidia GPU usage. You need to install nvidia-docker2 to be able to use `--runtime=nvidia`, see the following [installation instructions](https://github.com/nvidia/nvidia-docker/wiki/Installation-(version-2.0)).

## Known issues

### Code completion

Autocompletion in Jupyter might be veeeery slow or inactive. This might be caused by issues with `jedi` (see many issues in jupyter repo on this matter). To deactivate `jedi` and get autocompletion jupyter lab, you can run the following magic:

```%config Completer.use_jedi = False```

Jupyterlab extensions providing alternative autocompletion do not play way with docker for now. I'm still investigating this issue, suggestions are welcome.

### Ray / tune usage

Ray default ip and workdir do not play well with docker. To avoid any issue, you should override `temp_dir` and `webui_host` parameters in `init` ray at the beginning of you ray jobs:

```python
import ray
from ray import tune

ray.init(temp_dir='/io/ray_log_dir', webui_host='0.0.0.0')
analysis = tune.run(..., local_dir='/io/ray_results_dir', resources_per_trial={'gpu': 1})
```

Default port of the ray UI (`8265`) is exposed by docker. Note the this UI can be an easy way to manage tensorboard and the cluster or server ressources (CPU / RAM / IO ; no GPU monitoring yet sadly).
To monitor experiments, go to the tune tab enter the tune local_dir location in "Tune Log Directory Here:", submit. Embedded tensorboard from this interface is not functional at the moment, see other options below to run tensorboard.

### Tensorboard

If you are not using Ray, you can launch tensorboard manually using Jupyter Lab terminal

```bash
tensorboard --host 0.0.0.0 --logdir /io/path_to_logdir
```

and access it through tensorboard default port (6006) exposed by this docker image. Another solution consist in using notebook-embedded tensorboard by using magic commands

```
%load_ext tensorboard
%tensorboard --logdir /io/results --host=0.0.0.0
```

The resulting cell will load an iframe displaying tensorboard. If you delete the cell result, tensorboard will still be running in the background. To display it again, you can run

```python
from tensorboard import notebook
notebook.list() # View open TensorBoard instances

# Control TensorBoard display. If no port is provided, 
# the most recently launched TensorBoard is used
notebook.display(port=6006, height=1000)
```

To kill tensorboard, use the kill command (in shell or in a notebook cell with the `!` prefix)

```kill [tensorboard_pid]```

The pid can be found in the output of `notebook.list()`. For more information, please refer to tensorflow  [documentation](https://www.tensorflow.org/tensorboard/tensorboard_in_notebooks#tensorboard_in_notebooks).

## Final words

[Let the mayhem begin!](https://www.youtube.com/watch?v=tuQ--6wF0aQ)
