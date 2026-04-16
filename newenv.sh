#!/bin/bash
set -euo pipefail

read -p "Input your env name and press ENTER: " ENV
read -p "Input your python version of this environment and press ENTER: " PYVER

if [[ -z "${ENV}" || -z "${PYVER}" ]]; then
  echo "ENV name and PY version must not be empty."
  exit 1
fi

BASE_DIR="$HOME/dev/envs"
ENV_DIR="${BASE_DIR}/${ENV}"

mkdir -p "$BASE_DIR"

if [[ -e "$ENV_DIR" ]]; then
  echo "Target env directory already exists: $ENV_DIR"
  echo "Aborting to avoid overwrite."
  exit 1
fi

# 创建 mamba 环境到指定前缀目录
mamba create -y -p "$ENV_DIR" -c conda-forge "python=${PYVER}" ipykernel

# 清理旧 kernel
KDIR="$HOME/.local/share/jupyter/kernels/${ENV}"
if [[ -d "$KDIR" ]]; then
  rm -rf "$KDIR"
fi

# 注册 kernel
"$ENV_DIR/bin/python" -m ipykernel install --user \
  --name "$ENV" \
  --display-name "$ENV"

echo "Done. New mamba env created at: $ENV_DIR"
echo "Jupyter kernel registered as: $ENV"