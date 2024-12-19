#!/bin/bash -e

# set default wifi username and password set in the config file.

if [ -v WLAN_SSID ]; then

  wifi_security=""

  if [ -v WLAN_PASS ]; then
    wifi_security="
[wifi-security]
auth-alg=open
key-mgmt=wpa-psk
psk=$WLAN_PASS"

  fi

  cat >> "${ROOTFS_DIR}/etc/NetworkManager/system-connections/$WLAN_SSID.nmconnection" <<- EOF
[connection]
id=$WLAN_SSID
type=wifi
interface-name=wlan0

[wifi]
mode=infrastructure
ssid=$WLAN_SSID

$wifi_security

[ipv4]
method=auto

[ipv6]
addr-gen-mode=default
method=auto

[proxy]
EOF

  on_chroot <<- EOF
chown root:root /etc/NetworkManager/system-connections/$WLAN_SSID.nmconnection
chmod 600 /etc/NetworkManager/system-connections/$WLAN_SSID.nmconnection
EOF

fi

# Create NetworkManager configuration files
install -v -m 600 files/br0.nmconnection "${ROOTFS_DIR}/etc/NetworkManager/system-connections/br0.nmconnection"
install -v -m 600 files/eth0.nmconnection "${ROOTFS_DIR}/etc/NetworkManager/system-connections/eth0.nmconnection"
install -v -m 600 files/eth1.nmconnection "${ROOTFS_DIR}/etc/NetworkManager/system-connections/eth1.nmconnection"

# Ensure the correct owner for the files
on_chroot <<- EOF
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
gpio=20=op,dh
gpio=21=op,dh

## Pin 6 is a run signal pin. Should stay high while the cm4 is running.
## Then go low after shutdown
gpio=6=op,dh
#dtoverlay=gpio-shutdown,gpiopin=6,active_low=on,export=1
dtoverlay=gpio-poweroff,gpiopin=6,active_low=on,timeout=60000,export=1

## Pin 13 controls the power to the CM4. by default, stay high while cm4 running,
# Then go low after shutdown. Ideally, this should be a gpio-poweroff overlay also
# But can't have two of those.
gpio=13=op,dl
#dtoverlay=gpio-poweroff,gpiopin=13,active_low=on,timeout=60000,export=1

## Enable I2C
dtparam=i2c_arm=on

## Disable the rainbow splash screen on boot
disable_splash=1
EOF

on_chroot <<- EOF
  usermod -aG docker $FIRST_USER_NAME
  ufw allow 22
  ufw allow 80
  ufw allow 443
  ufw allow 9090
  ufw --force enable
EOF

## Add the udev rule to mount the RP2040 when in bootloader mode
install -v -m 644 files/99-rp2040.rules "${ROOTFS_DIR}/etc/udev/rules.d/99-rp2040.rules"
install -v -m 755 files/mount_rp2040.sh "${ROOTFS_DIR}/usr/local/bin/mount_rp2040.sh"

## Configure NGINX to proxy to cockpit
install -v -m 644 files/nginx.default.config "${ROOTFS_DIR}/etc/nginx/sites-available/default"

## Add the Nginx certificates
on_chroot <<- EOF
  sudo mkdir -p /etc/nginx/ssl
  sudo openssl genrsa -out /etc/nginx/ssl/self-signed.key 2048
  sudo openssl req -new -x509 -key /etc/nginx/ssl/self-signed.key -out /etc/nginx/ssl/self-signed.crt -subj "/C=AU/ST=QLD/L=Brisbane/O=Doover/OU=Doovit/CN=doover.com"
EOF

## Set the default keyboard layout to US
install -v -m 644 files/keyboard "${ROOTFS_DIR}/etc/default/keyboard"

## Customizing the MOTD message (Displayed when a user logs in on terminal or cockpit) 
install -v -m 644 files/motd "${ROOTFS_DIR}/etc/motd"

## Make a folder to store doover branding
install -v -d -m 644 "${ROOTFS_DIR}/usr/share/doover"
install -v -m 644 files/doover_logo.png "${ROOTFS_DIR}/usr/share/doover/doover_logo.png"
install -v -m 644 files/doover_splash.png "${ROOTFS_DIR}/usr/share/doover/doover_splash.png"

## Change the splash screen
on_chroot <<- EOF
  mkdir -p /usr/share/plymouth/themes/pix
  #update-alternatives --install /usr/share/plymouth/themes/pix/splash.png pix-theme /usr/share/doover/doover_splash.png 100
EOF
install -v -m 644 files/doover_splash.png "${ROOTFS_DIR}/usr/share/plymouth/themes/pix/splash.png"
## Write this new splash screen to the initramfs
on_chroot <<- EOF
  update-initramfs -u
EOF

## Add the following to the /etc/os-release file if it doesn't exist
on_chroot <<- EOF
  if ! grep -q "DOOVIT_NAME" /etc/os-release; then
    echo 'DOOVIT_NAME="Doovit (Bookworm)"' >> /etc/os-release
  fi
EOF

## Update the cockpit branding
install -v -m 644 files/cockpit_branding.css "${ROOTFS_DIR}/usr/share/cockpit/branding/debian/branding.css"
install -v -m 644 files/doover_splash.png "${ROOTFS_DIR}/usr/share/cockpit/branding/debian/doover_splash.png"
install -v -m 644 files/doover_logo.png "${ROOTFS_DIR}/usr/share/cockpit/branding/debian/doover_logo.png"
