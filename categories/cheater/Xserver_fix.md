################### Fix the fckn bitch ass Xserver #################

$ strace xauth list
```
$ cd /home/andro
$ ls -l | grep .Xauth*
```
$ rm -fr .Xauthority-*
```
$ cd /home/andro
$ ls -a -lh
$ chown andro:andro .Xau*
```
$ cd /home/machine
$ mv .Xauthority .Xauthority.bak
$ touch .Xauthority
$ chown machine:machine .Xauthority
```
$ chmod +x .Xauthority
```
$ xauth -b
```

#################### Invalid MIT-MAGIC-COOKIE-1 #######################

$ xhost +si:localuser:root
```

#################### Kill the X server ########################

$ pkill -x X
```

################### Copy the default xinitrc ##################

$ cp /etc/X11/xinit/xinitrc ~/.xinitrc
```

############### Make an .xserverrc if needed ################

#!/bin/sh

exec /usr/bin/Xorg -nolisten tcp "$@" vt$XDG_VTNR
````
## Optionally place this line if the xserverrc exists:

$ xinit -- :1
```

############### Autostart script for X at login ##############










############## Make an new Xorg.conf ##################

$ Xorg :0 -configure

## Copy that over to etc

$ cp ~/xorg.conf.new /etc/X11/xorg.conf
```

################ Check your drivers ###############

$ lspci -v | grep -A1 -e VGA -e 3D
```

$ pacman -Ss xf86-video
```

########## Get you bus IDs (in hexadecimal) ##########

$ lspci | grep -e VGA -e 3D
```

######## Check your display size and DPI ############

$ xdpyinfo | grep -B2 resolution
```

########### Prevent user from killing X ############

Section "ServerFlags"
    Option "DontZap"  "True"
EndSection
```


#################### Lastly!!!! #######################

## Ensure /tmp/.X11-unix/ is owned by root (smh I fckn hate X)

$ chown root:root /tmp/.X11-unix
```

###################### Sockets ####################

xorg@.socket
xorg@Type\x3ddbus.socket >> systemd-escape -up (to unmangle the hidden name and path)
x@.service
xlogin@.service
user@.service
usert@@.service
serial-getty@.service
getty@service
getty@default.service
autotv@.service
container-getty@.service
```

################## Custom Xinitrc ################
##In the default file:

/etc/X11/xinit/xinitrc
```
## add the following:

xset s off
xset -dpms
xset s noblank
```

################## Input Trouble? ####################33

$ sudo pacman -Rdd xf86-input-libinput
$ sudo pacman -Sw xf86-input-evdev
$ sudo pacman -U /var/cache/pacman/pkg/xf86-input-evdev-VERSION.pkg.tar.xz
```

################# Must install packagesa ########################

lsdesktopf (list desktop files and their contents)
```
$ lsdesktopf --list
$ lsdesktopf --list gtk zh_TW,zh_CN,en_GB
```

fbrokendesktop (detects broken Exec values pointing to non-existent paths)
```
$ fbrokendesktop /usr
$ fbrokendesktop /usr/share/xsessions/icewm.desktop
```

################## Lukes zprofile script for x ###########################3

[ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec startx "$XINITRC"
