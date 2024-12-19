#!/bin/bash -e


## Set the default keyboard layout to US
install -v -m 644 files/keyboard "${ROOTFS_DIR}/etc/default/keyboard"

## Make a folder to store doover branding
install -v -d -m 755 "${ROOTFS_DIR}/usr/share/doover"
install -v -m 644 files/doover_logo.png "${ROOTFS_DIR}/usr/share/doover/doover_logo.png"
install -v -m 644 files/doover_splash.png "${ROOTFS_DIR}/usr/share/doover/doover_splash.png"

## Change the desktop wallpaper
install -v -d -m 755 "${ROOTFS_DIR}/home/doovit/.config/pcmanfm/LXDE-pi"
install -v -m 644 files/desktop-items-0.conf "${ROOTFS_DIR}/home/doovit/.config/pcmanfm/LXDE-pi/desktop-items-0.conf"

## Change the splash screen
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
install -v -m 644 files/doover_logo.ico "${ROOTFS_DIR}/usr/share/cockpit/branding/debian/favicon.ico"

## Customizing the MOTD message (Displayed when a user logs in on terminal or cockpit) 
install -v -m 644 files/motd "${ROOTFS_DIR}/etc/motd"

## Clear any existing MOTD files
on_chroot <<- EOF
  rm -f /etc/update-motd.d/*
  rm -f /etc/motd.d/*
EOF

## Stop cockpit from displaying the MOTD message, by removing the line that calls the motd file
on_chroot <<- EOF
  sudo sed -i '/\/usr\/share\/cockpit\/motd\/update-motd/d' /usr/lib/systemd/system/cockpit.socket
  sudo sed -i '/\/run\/cockpit\/motd/d' /usr/lib/systemd/system/cockpit.socket
EOF