#!/bin/bash
set -euo pipefail

# pixi-kernelctl.sh
# Usage:
#   ./pixi-kernelctl.sh create <env> [python_version]
#   ./pixi-kernelctl.sh remove <env>
#   ./pixi-kernelctl.sh list
#
# Notes:
# - This script uses the "legacy layout" env dir: ~/.pixi/envs/<env>
# - It registers Jupyter kernelspec with --name <env>, display-name "<env> (pixi)"

BASE_DIR="${HOME}/.pixi/envs"
KERNEL_BASE="${HOME}/.local/share/jupyter/kernels"

usage() {
  cat <<'EOF'
Usage:
  pixi-kernelctl.sh create <env> [python_version]
  pixi-kernelctl.sh remove <env>
  pixi-kernelctl.sh list

Examples:
  ./pixi-kernelctl.sh create agent 3.12
  ./pixi-kernelctl.sh remove agent
  ./pixi-kernelctl.sh list
EOF
}

detect_platform() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64)   echo "linux-64" ;;
    aarch64|arm64)  echo "linux-aarch64" ;;
    armv7l)         echo "linux-armv7l" ;;
    armv6l)         echo "linux-armv6l" ;;
    *)
      echo "Unsupported architecture: $arch" >&2
      echo "" >&2
      echo "Please set PLATFORM manually inside the script if needed." >&2
      exit 1
      ;;
  esac
}

ensure_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing command: $cmd" >&2
    exit 1
  fi
}

kernel_dir() {
  local env="$1"
  echo "${KERNEL_BASE}/${env}"
}

remove_kernel_if_exists() {
  local env="$1"
  local kdir
  kdir="$(kernel_dir "$env")"
  if [[ -d "$kdir" ]]; then
    echo "Found kernelspec dir: $kdir"
    echo "Uninstalling Jupyter kernel (name: $env) ..."
    # Prefer jupyter kernelspec uninstall, but keep dir-check as source of truth
    jupyter kernelspec uninstall "$env" -y >/dev/null 2>&1 || true
    # Safety: ensure directory is gone (sometimes uninstall can be partial)
    rm -rf "$kdir"
    echo "Removed kernelspec: $env"
  else
    echo "No kernelspec named '$env' found, skip."
  fi
}

create_env() {
  local env="$1"
  local pyver="${2:-}"

  if [[ -z "$env" ]]; then
    echo "Env name must not be empty." >&2
    exit 1
  fi

  if [[ -z "$pyver" ]]; then
    read -p "Input python version for env '$env' (e.g. 3.12): " pyver
  fi

  if [[ -z "$pyver" ]]; then
    echo "Python version must not be empty." >&2
    exit 1
  fi

  ensure_cmd pixi
  ensure_cmd jupyter

  local platform
  platform="$(detect_platform)"
  echo "Detected pixi platform: $platform"

  local env_dir="${BASE_DIR}/${env}"
  mkdir -p "$env_dir"
  cd "$env_dir"

  if [[ -f "pixi.toml" ]]; then
    echo "pixi.toml already exists in $env_dir, aborting to avoid overwrite." >&2
    exit 1
  fi

  echo "=== Create pixi env project: $env_dir ==="
  pixi init --platform "$platform"

  # Prefer explicit channel for reproducibility
  pixi add -c conda-forge "python=${pyver}"
  pixi add ipykernel

  echo "=== Register Jupyter kernel ==="
  # Critical: remove old kernelspec with same NAME to avoid stale/duplicate kernels
  remove_kernel_if_exists "$env"

  pixi run python -m ipykernel install --user \
    --name "$env" \
    --display-name "${env} (pixi)"

  echo
  echo "Done."
  echo "  pixi env project: ${env_dir}"
  echo "  jupyter kernel name: ${env}"
  echo "  jupyter kernel display: ${env} (pixi)"
}

remove_env() {
  local env="$1"
  if [[ -z "$env" ]]; then
    echo "Env name must not be empty." >&2
    exit 1
  fi

  ensure_cmd jupyter

  echo "=== Remove Jupyter kernel: $env ==="
  remove_kernel_if_exists "$env"

  echo
  echo "=== Remove pixi env directory (legacy layout): ~/.pixi/envs/$env ==="
  local env_dir="${BASE_DIR}/${env}"
  if [[ -d "$env_dir" ]]; then
    echo "Found pixi env directory: $env_dir"
    read -p "This directory will be removed recursively. Continue? [y/N]: " confirm
    case "${confirm:-}" in
      y|Y|yes|YES)
        rm -rf "$env_dir"
        echo "Removed directory: $env_dir"
        ;;
      *)
        echo "Skip removing directory."
        ;;
    esac
  else
    echo "No pixi env directory found at: $env_dir, skip."
  fi

  echo
  echo "=== Current Jupyter kernels ==="
  jupyter kernelspec list
}

list_kernels() {
  ensure_cmd jupyter
  jupyter kernelspec list
}

main() {
  local cmd="${1:-}"
  case "$cmd" in
    create)
      create_env "${2:-}" "${3:-}"
      ;;
    remove|delete|rm)
      remove_env "${2:-}"
      ;;
    list|ls)
      list_kernels
      ;;
    -h|--help|help|"")
      usage
      exit 0
      ;;
    *)
      echo "Unknown command: $cmd" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
