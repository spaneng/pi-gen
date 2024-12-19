#!/bin/bash -e

mkdir -p "${ROOTFS_DIR}/etc/apt/keyrings"
cat files/docker.gpg.key > "${ROOTFS_DIR}/etc/apt/keyrings/docker.asc"
chmod a+r "${ROOTFS_DIR}/etc/apt/keyrings/docker.asc"

cat files/doover.gpg.key > "${ROOTFS_DIR}/etc/apt/keyrings/doover.asc"
chmod a+r "${ROOTFS_DIR}/etc/apt/keyrings/doover.asc"

echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${RELEASE} stable" > "${ROOTFS_DIR}/etc/apt/sources.list.d/docker.list"
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/doover.asc] http://apt.u.doover.com stable main" > "${ROOTFS_DIR}/etc/apt/sources.list.d/doover.list"

## Add the 45drives repo to the sources list
on_chroot <<- EOF
  wget -qO - https://repo.45drives.com/key/gpg.asc | gpg --dearmor -o /usr/share/keyrings/45drives-archive-keyring.gpg
  curl -sSL https://repo.45drives.com/lists/45drives.sources -o /etc/apt/sources.list.d/45drives.sources
EOF

on_chroot <<- \EOF
  apt-get update
EOF