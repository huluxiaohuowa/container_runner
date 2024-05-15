#!/bin/bash
read -p "Input your env name and press ENTER: " ENV
read -p "Input your python version of this environment and press ENTER: " PYVER

mamba create --prefix=/home/jhu/dev/envs/$ENV python=$PYVER -y

mamba activate $ENV
pip install ipykernel
python -m ipykernel install --user --name $ENV
mamba deactivate