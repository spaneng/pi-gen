#!/bin/bash -e

on_chroot <<- EOF
  groupadd docker
  usermod -aG docker $FIRST_USER_NAME
EOF
