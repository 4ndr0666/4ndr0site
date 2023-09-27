# First, remove the problematic files:

```

sudo rm /usr/lib/libtbbmalloc.so.2
sudo rm /usr/lib/libtbbmalloc_proxy.so.2
sudo rm /usr/lib/libtbb.so.12
sudo rm /usr/lib/libtbbbind_2_5.so.3
sudo rm /usr/lib/libtbbbind_2_0.so.3

```

Then, reinstall the tbb package:

```
sudo pacman -S tbb

```

Finally, run ldconfig again:

```

sudo ldconfig
