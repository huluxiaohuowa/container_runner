#!/bin/bash
set -euo pipefail

read -p "Input your env name and press ENTER: " ENV
read -p "Input your python version of this environment and press ENTER: " PYVER

if [[ -z "${ENV}" || -z "${PYVER}" ]]; then
  echo "ENV name and PY version must not be empty."
  exit 1
fi

# ========= 检测架构并映射到 pixi 的平台名 =========
ARCH=$(uname -m)
case "$ARCH" in
  x86_64|amd64)
    PLATFORM="linux-64"
    ;;
  aarch64|arm64)
    PLATFORM="linux-aarch64"
    ;;
  armv7l)
    PLATFORM="linux-armv7l"
    ;;
  armv6l)
    PLATFORM="linux-armv6l"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    echo "Please set PLATFORM manually."
    exit 1
    ;;
esac

echo "Detected arch: $ARCH  -> pixi platform: $PLATFORM"

# 基础目录（你原来写的是 /home/jhu/.pixi/envs）
BASE_DIR="$HOME/.pixi/envs"
ENV_DIR="${BASE_DIR}/${ENV}"

mkdir -p "$ENV_DIR"
cd "$ENV_DIR"

# 如果已经有 pixi.toml，避免覆盖
if [[ -f "pixi.toml" ]]; then
  echo "pixi.toml already exists in $ENV_DIR, aborting to avoid overwrite."
  exit 1
fi

# 初始化 pixi 项目并安装 python + ipykernel
pixi init --platform "$PLATFORM"
pixi add "python=${PYVER}"
pixi add ipykernel

# 注册到 Jupyter
pixi run python -m ipykernel install --user \
  --name "$ENV" \
  --display-name "$ENV"

echo "Done. New pixi env '$ENV' created in $ENV_DIR and Jupyter kernel '$ENV' registered."