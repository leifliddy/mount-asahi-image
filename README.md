# mount-asahi-image

Mounts Raw Fedora Asahi Images which can be found here:  
https://fedora-asahi-remix.org/builds.html


## Fedora Package Install
```dnf install arch-install-scripts zstd```

**Usage:**
```
./script-asahi-img.sh {image name}
./script-asahi-img.sh chroot
./script-asahi-img.sh umount
```


### How-to
Download a raw image from https://fedora-asahi-remix.org/builds.html  
```
wget https://fedora-asahi-remix.org/os/fedora-39-minimal-202311241600.raw.zst
```

**Mount the image:**
```
./script-asahi-img.sh fedora-39-minimal-202311241600.raw.zst
# or if already decompressed
./script-asahi-img.sh fedora-39-minimal-202311241600.raw
```
This will create a directory named `mnt_image` within the current directory -- and will mount the image to that directory

**Chroot into the image:**  
Once the image is mounted -- you can chroot into it with:  
```
./script-asahi-img.sh chroot
```
To exit from the `chroot` environment, simply type `ctrl+d` or `exit`  

**Umounting the image:**
```
./script-asahi-img.sh umount
```
This will unmount the image from `mnt_image`  
