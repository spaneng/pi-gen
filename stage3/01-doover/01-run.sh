#!/bin/bash -e

on_chroot <<- EOF
  usermod -aG docker $FIRST_USER_NAME
  ufw allow 22
  ufw allow 80
  ufw allow 443
  ufw --force enable
EOF
