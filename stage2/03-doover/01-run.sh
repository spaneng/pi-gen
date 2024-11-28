#!/bin/bash -e

# set default wifi username and password set in the config file.

if [ -v WLAN_SSID ]; then
	on_chroot <<- EOF
		SUDO_USER="${FIRST_USER_NAME}" nmcli c add type wifi con-name "${WLAN_SSID}" ifname wlan0 ssid "${WLAN_SSID}"
	EOF
fi

if [ -v WLAN_SSID ] && [ -v WLAN_PASS ]; then
	on_chroot <<- EOF
  	SUDO_USER="${FIRST_USER_NAME}" nmcli c modify "${WLAN_SSID}" wifi-sec.key-mgmt wpa-psk wifi-sec.psk "${WLAN_PASS}"
	EOF
fi


# set ethernet ports as bridged to allow switching behaviour
cat <<EOT >> "${ROOTFS_DIR}"/etc/network/interfaces
# The loopback network interface
auto lo
iface lo inet loopback

# Set up interfaces manually, avoiding conflicts with, e.g., network manager
iface eth0 inet manual
iface eth1 inet manual

# Bridge setup
auto br0
iface br0 inet dhcp
  bridge_ports eth0 eth1
EOT


# GPIO
# 14,15 = UART0
# 4,5   = UART1
# 6     = CM4_SHUTDOWN
# 9     = SER_FM_EN
# 11    = SER_485_EN
# 13    = PWR_ENABLE
# 20    = RP_BOOT
# 21    = RP_RESET

cat >> "${ROOTFS_DIR}"/boot/config.txt << EOF
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