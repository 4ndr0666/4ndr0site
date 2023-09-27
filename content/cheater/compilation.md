## Dependencies for picom
$ yay -S libx11 libxcomposite libxdamage libxfixes libXext libxrender libXrandr libXinerama pkg-config make xproto x11proto sh xprop xwininfo x11-utils libpcre libconfig libdrm libGL libdbus asciidoc docbook-xml-dtd libxml-utils libxslt xsltproc xmlto --needed

## Libraries
After building libraries remember to run 'libtool --finish /usr/lib'
```

## Wayland
If using GDM on wayland, run systemctl enable --now nvidia-resume.service
```

## 
