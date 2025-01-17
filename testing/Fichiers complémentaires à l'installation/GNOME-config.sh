#!/usr/bin/env bash
# Contributeurs :
#  - Babilinx : code
#  - Chevek : vérifications et debuging
#  - Wamuu : vérifications et test
# mars 2022
# Script de configuration GNOME pour passer le clavier en AZERTY
#
# On prépare le chroot pour openrc-gsettingsd -> dbus
mkdir -p /lib64/rc/init.d
ln -s /lib64/rc/init.d /run/openrc
touch /run/openrc/softlevel
# save default OpenRC setup, and configure for chroot
mv /etc/rc.conf /etc/rc.conf.SAVE
echo 'rc_sys="prefix"' >> /etc/rc.conf
echo 'rc_controller_cgroups="NO"' >> /etc/rc.conf
echo 'rc_depend_strict="NO"' >> /etc/rc.conf
echo 'rc_need="!net !dev !udev-mount !sysfs !checkfs !fsck !netmount !logger !clock !modules"' >> /etc/rc.conf
rc-update --update
rc-service openrc-settingsd start
# On récupère la langue du système
if [ -r /etc/env.d/02locale ]; then source /etc/env.d/02locale; fi
LANG_SYSTEM="${LANG:0:2}"
read -p "Nom de l'utilisateur précédemment créé : " username
mv /etc/X11/xorg.conf.d/10-keyboard.conf /etc/X11/xorg.conf.d/30-keyboard.conf
source /etc/conf.d/keymaps
KEYMAP=${LANG_SYSTEM}

gdbus call --system                                             \
           --dest org.freedesktop.locale1                       \
           --object-path /org/freedesktop/locale1               \
           --method org.freedesktop.locale1.SetVConsoleKeyboard \
           "$KEYMAP" "$KEYMAP_CORRECTIONS" true true
# On lance dbus en shell
dbus-run-session -- su -c "gsettings set org.gnome.desktop.input-sources sources \"[('xkb', '${LAND_SYSTEM}')]\"" $username
rc-service openrc-settingsd stop
# restaure default setup
rm -f /etc/rc.conf
mv /etc/rc.conf.SAVE /etc/rc.conf
