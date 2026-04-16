#!/bin/bash
set -euo pipefail

read -p "Input your env name and press ENTER: " ENV
read -p "Input your python version of this environment and press ENTER: " PYVER

if [[ -z "${ENV}" || -z "${PYVER}" ]]; then
  echo "ENV name and PY version must not be empty."
  exit 1
fi

ARCH=$(uname -m)
case "$ARCH" in
  x86_64|amd64)   PLATFORM="linux-64" ;;
  aarch64|arm64)  PLATFORM="linux-aarch64" ;;
  armv7l)         PLATFORM="linux-armv7l" ;;
  armv6l)         PLATFORM="linux-armv6l" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

BASE_DIR="$HOME/.pixi/envs"
ENV_DIR="${BASE_DIR}/${ENV}"
mkdir -p "$ENV_DIR"
cd "$ENV_DIR"

if [[ -f "pixi.toml" ]]; then
  echo "pixi.toml already exists in $ENV_DIR, aborting to avoid overwrite."
  exit 1
fi

pixi init --platform "$PLATFORM"

# ✔ 正确方式：先加 channel
pixi project channel add conda-forge

# ✔ 再装 python
pixi add "python=${PYVER}"

# ✔ 再装 ipykernel
pixi add ipykernel

# 清理旧 kernel
KDIR="$HOME/.local/share/jupyter/kernels/${ENV}"
if [[ -d "$KDIR" ]]; then
  rm -rf "$KDIR"
fi

# 注册 kernel
pixi run python -m ipykernel install --user \
  --name "$ENV" \
  --display-name "${ENV} (pixi)"

echo "Done. New pixi env '$ENV' created in $ENV_DIR and Jupyter kernel '${ENV} (pixi)' registered."
