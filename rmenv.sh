#!/bin/bash
set -euo pipefail

read -p "Input your env name and press ENTER: " ENV

if [[ -z "${ENV}" ]]; then
  echo "Env name must not be empty."
  exit 1
fi

echo "=== Remove Jupyter kernel: $ENV ==="
# 如果不存在该 kernel，不要直接报错退出
if jupyter kernelspec list | grep -q "^[[:space:]]*$ENV[[:space:]]"; then
  jupyter kernelspec uninstall "$ENV" -y
else
  echo "No Jupyter kernel named '$ENV' found, skip uninstall."
fi

# 删除对应的 pixi 环境目录（你之前创建在 ~/.pixi/envs/$ENV）
BASE_DIR="$HOME/.pixi/envs"
ENV_DIR="${BASE_DIR}/${ENV}"

if [[ -d "$ENV_DIR" ]]; then
  echo "Found pixi env directory: $ENV_DIR"
  read -p "This directory will be removed recursively. Continue? [y/N]: " CONFIRM
  case "$CONFIRM" in
    y|Y|yes|YES)
      rm -rf "$ENV_DIR"
      echo "Removed directory: $ENV_DIR"
      ;;
    *)
      echo "Skip removing directory."
      ;;
  esac
else
  echo "No pixi env directory found at: $ENV_DIR, skip."
fi

echo
echo "=== Current Jupyter kernelspec list ==="
jupyter kernelspec list