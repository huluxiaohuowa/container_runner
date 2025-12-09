#!/usr/bin/env bash
set -euo pipefail

echo "=== 1. 安装编译依赖（只需执行一次） ==="
sudo apt update
sudo apt install -y \
  git golang-go make gcc \
  btrfs-progs libbtrfs-dev \
  libgpgme-dev libassuan-dev \
  libdevmapper-dev libglib2.0-dev \
  libseccomp-dev pkg-config uidmap \
  slirp4netns

echo "=== 2. 清理旧的临时目录 ==="
BUILD_DIR=/tmp/build-podman-full
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "=== 3. 克隆 Podman 源码 ==="
git clone https://github.com/containers/podman.git "$BUILD_DIR"
cd "$BUILD_DIR"

echo "=== 4. 获取 GitHub 最新发布的 tag ==="
LATEST_TAG=$(
  curl -fsSL https://api.github.com/repos/containers/podman/releases/latest \
  | awk -F'"' '/"tag_name":/ {print $4; exit}'
)

if [[ -z "${LATEST_TAG}" ]]; then
  echo "获取最新 tag 失败，退出。"
  exit 1
fi

echo "最新 tag: ${LATEST_TAG}"
git checkout "${LATEST_TAG}"

echo "=== 5. 编译 Podman（启用 seccomp） ==="
make BUILDTAGS="seccomp"

echo "=== 6. 安装到 /usr/local/bin （需要 sudo） ==="
sudo make install

echo "=== 7. 确认最终版本 ==="
command -v podman || echo "podman 不在 PATH 中，请检查 /usr/local/bin"
podman --version || true

echo
echo "✅ 完成：已安装完整 Podman ${LATEST_TAG} 到 /usr/local/bin/podman"
echo "现在可以直接使用： podman run / podman images / podman ps ..."
