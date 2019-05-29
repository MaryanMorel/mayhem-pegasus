# mayhem-pegasus
Useful docker images for deep learning and machine learning in general.

Current version: Pytorch, tensorflow-gpu, tensorboardx and usual useful python libraries (numpy, pandas, dask, sklearn, matplotlib, seaborn)

To build images (don't forget the dot at the ends):
``` docker build -f ./Dockerfile -t mayhem-pegasus:<TAG> .
```

To run a jupyter lab session and mounting a shared folder (host: `./mnt` will be paired with `/io` in the container) :
``` docker run -u $(id -u):$(id -g)  -v $PWD/mnt:/io -p 0.0.0.0:<local jupyter port>:8888 -p 0.0.0.0:<local tensorboard port>:6006 -it --runtime=nvidia --rm mayhem-pegasus:<TAG>
```

## Known issues
Autocompletion in Jupyter might be veeeery slow or inactive. This might be cause by issues with `jedi` (see many issues in jupyter repo on this matter). To deactivate `jedi` and get autocompletion in the notebooks, you can run the following magic:

```%config Completer.use_jedi = False```