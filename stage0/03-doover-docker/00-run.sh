#!/bin/bash -e

mkdir -p "${ROOTFS_DIR}/etc/apt/keyrings"
cat files/docker.gpg.key > "${ROOTFS_DIR}/etc/apt/keyrings/docker.asc"
chmod a+r /etc/apt/keyrings/docker.asc

cat files/doover.gpg.key > "${ROOTFS_DIR}/etc/apt/keyrings/doover.asc"
chmod a+r /etc/apt/keyrings/doover.asc

echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${RELEASE} stable" > "${ROOTFS_DIR}/etc/apt/sources.list.d/docker.list"
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/doover.asc] http://apt.u.doover.com stable main" > "${ROOTFS_DIR}/etc/apt/sources.list.d/doover.list"

on_chroot <<- \EOF
  apt-get update
EOF