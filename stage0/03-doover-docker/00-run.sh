#!/bin/bash -e

cat files/docker.gpg.key | gpg --dearmor > "${STAGE_WORK_DIR}/docker.gpg"
install -m 644 "${STAGE_WORK_DIR}/docker.gpg" "${ROOTFS_DIR}/etc/apt/keyrings/docker.asc"

echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu   ${RELEASE} stable" > "${ROOTFS_DIR}/etc/apt/sources.list.d/docker.list"
on_chroot <<- \EOF
  apt-get update
  sudo apt-get install
EOF