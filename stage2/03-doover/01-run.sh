#!/bin/bash -e

# set default wifi username and password set in the config file.

echo "test 4"

# Create NetworkManager configuration files
install -v -m 600 files/br0.nmconnection "${ROOTFS_DIR}/etc/NetworkManager/system-connections/br0.nmconnection"
install -v -m 600 files/eth0.nmconnection "${ROOTFS_DIR}/etc/NetworkManager/system-connections/eth0.nmconnection"
install -v -m 600 files/eth1.nmconnection "${ROOTFS_DIR}/etc/NetworkManager/system-connections/eth1.nmconnection"

# Ensure the correct owner for the files
on_chroot << EOF
chown root:root /etc/NetworkManager/system-connections/br0.nmconnection
chown root:root /etc/NetworkManager/system-connections/eth0.nmconnection
chown root:root /etc/NetworkManager/system-connections/eth1.nmconnection
chmod 600 /etc/NetworkManager/system-connections/br0.nmconnection
chmod 600 /etc/NetworkManager/system-connections/eth0.nmconnection
chmod 600 /etc/NetworkManager/system-connections/eth1.nmconnection
EOF

# GPIO
# 14,15 = UART0
# 4,5   = UART1
# 6     = CM4_SHUTDOWN
# 9     = SER_FM_EN
# 11    = SER_485_EN
# 13    = PWR_ENABLE
# 20    = RP_BOOT
# 21    = RP_RESET

cat >> "${ROOTFS_DIR}"/boot/firmware/config.txt << EOF
dtoverlay=uart0,txd1_pin=14,rxd1_pin=15
dtoverlay=uart1,txd1_pin=4,rxd1_pin=5
gpio=9=op,dl
gpio=11=op,dl
gpio=13=op,dl
gpio=20=op,dh
gpio=21=op,dh
dtoverlay=gpio-poweroff,gpiopin=6
dtparam=i2c_arm=on
EOF

on_chroot <<- EOF
  usermod -aG docker $FIRST_USER_NAME
  ufw allow 22
  ufw allow 80
  ufw allow 443
  ufw allow 9090
  ufw --force enable
EOF
