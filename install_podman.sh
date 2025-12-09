#!/usr/bin/env bash
set -euo pipefail

echo "=== Detecting architecture ==="
ARCH=$(uname -m)
case "$ARCH" in
  x86_64|amd64)
    REL_ARCH="amd64"
    ;;
  aarch64|arm64)
    REL_ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac
echo "ARCH=${ARCH}, release arch=${REL_ARCH}"

echo "=== Fetching latest podman release url from GitHub ==="
API_URL="https://api.github.com/repos/containers/podman/releases/latest"

# 取最新的 podman-remote-static-linux_${REL_ARCH}.tar.gz 下载链接
TARBALL_URL=$(
  curl -fsSL "${API_URL}" \
  | grep '"browser_download_url"' \
  | grep "podman-remote-static-linux_${REL_ARCH}.tar.gz" \
  | head -n1 \
  | cut -d '"' -f 4
)

if [[ -z "${TARBALL_URL}" ]]; then
  echo "Failed to find podman-remote-static-linux_${REL_ARCH}.tar.gz in latest release."
  exit 1
fi

echo "Latest tarball: ${TARBALL_URL}"

TMP_TAR="/tmp/podman-remote-static-linux_${REL_ARCH}.tar.gz"
echo "=== Downloading to ${TMP_TAR} ==="
curl -L "${TARBALL_URL}" -o "${TMP_TAR}"

echo "=== Extracting into /usr/local ==="
# 里面自带 bin 目录，包含 podman-remote-static-linux_${REL_ARCH}
sudo tar -C /usr/local -xzf "${TMP_TAR}"

BIN_PATH="/usr/local/bin/podman-remote-static-linux_${REL_ARCH}"
if [[ ! -x "${BIN_PATH}" ]]; then
  echo "Expected binary not found at ${BIN_PATH}"
  exit 1
fi

echo "=== Installing/Updating /usr/local/bin/podman ==="
# 覆盖已有 podman（二进制或链接），满足“如果已经用了，替换”
sudo ln -sf "${BIN_PATH}" /usr/local/bin/podman

echo
echo "Done."
echo "Installed podman-remote at: ${BIN_PATH}"
echo "Symlinked as: /usr/local/bin/podman"
echo
podman --version || true
