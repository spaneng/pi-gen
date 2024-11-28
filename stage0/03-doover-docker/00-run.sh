#!/bin/bash -e

mkdir -p "${ROOTFS_DIR}/etc/apt/keyrings"
cat files/docker.gpg.key > "${ROOTFS_DIR}/etc/apt/keyrings/docker.asc"
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${RELEASE} stable" > "${ROOTFS_DIR}/etc/apt/sources.list.d/docker.list"
on_chroot <<- \EOF
  apt-get update
  sudo apt-get install
EOF