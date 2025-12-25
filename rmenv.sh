#!/bin/bash
set -euo pipefail

read -p "Input env name to remove: " ENV

if [[ -z "${ENV}" ]]; then
  echo "Env name must not be empty."
  exit 1
fi

echo "=== Remove Jupyter kernel (name: $ENV) ==="

KERNEL_DIR="$HOME/.local/share/jupyter/kernels/$ENV"

if [[ -d "$KERNEL_DIR" ]]; then
  echo "Found kernelspec: $KERNEL_DIR"
  jupyter kernelspec uninstall "$ENV" -y
else
  echo "No kernelspec named '$ENV' found, skip."
fi

echo
echo "=== Remove pixi env directory (legacy layout) ==="

BASE_DIR="$HOME/.pixi/envs"
ENV_DIR="$BASE_DIR/$ENV"

if [[ -d "$ENV_DIR" ]]; then
  echo "Found pixi env directory: $ENV_DIR"
  read -p "This directory will be removed recursively. Continue? [y/N]: " CONFIRM
  case "$CONFIRM" in
    y|Y|yes|YES)
      rm -rf "$ENV_DIR"
      echo "Removed pixi env directory: $ENV_DIR"
      ;;
    *)
      echo "Skip removing pixi env directory."
      ;;
  esac
else
  echo "No pixi env directory found at: $ENV_DIR, skip."
fi

echo
echo "=== Current Jupyter kernels ==="
jupyter kernelspec list
