#!/bin/bash -e

on_chroot <<- EOF
  usermod -aG docker $FIRST_USER_NAME
EOF
