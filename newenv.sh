#!/bin/bash
read -p "Input your env name and press ENTER: " ENV
read -p "Input your python version of this environment and press ENTER: " PYVER

mamba create --prefix=~/dev/envs/$ENV python=$PYVER -y

conda activate $ENV && pip install ipykernel
python -m ipykernel install --user --name $ENV
pip install ipywidgets
conda deactivate
jupyter kernelspec install ~/dev/envs/$ENV --user