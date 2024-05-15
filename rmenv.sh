#!/bin/bash
read -p "Input your env name and press ENTER: " ENV
mamba remove --prefix=/home/jhu/dev/envs/$ENV --all -y
jupyter kernelspec uninstall $ENV -y
jupyter kernelspec list
