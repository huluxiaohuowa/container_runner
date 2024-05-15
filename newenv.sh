
read -p "Input your env name and press ENTER: " ENV
read -p "Input your python version of this environment and press ENTER: " PYVER

mamba create --prefix=/home/jhu/dev/envs/$ENV python=$PYVER

conda activate $ENV
pip install ipykernel
python -m ipykernel install --user --name $ENV
conda deactivate