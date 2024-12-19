#!/bin/bash

MOUNT_POINT="/mnt/rp2040"

# Find the block device associated with the RP2040 USB
DEVICE=$(lsblk -npo NAME,TYPE | while read -r dev type; do
    if [[ "$type" == "disk" ]]; then
        if udevadm info --query=all --name="$dev" | grep -q "ID_VENDOR_ID=2e8a" && \
           udevadm info --query=all --name="$dev" | grep -q "ID_MODEL_ID=0003"; then
            echo "$dev"
            break
        fi
    fi
done)

if [ -n "$DEVICE" ]; then
    mkdir -p "$MOUNT_POINT"
    mount "${DEVICE}1" "$MOUNT_POINT"  # Assuming the partition is /dev/sda1
    echo "RP2040 mounted at $MOUNT_POINT"
else
    echo "RP2040 device not found."
fi