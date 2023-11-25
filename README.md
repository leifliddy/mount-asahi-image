Mounts Raw Fedora Asahi Build Images  
https://fedora-asahi-remix.org/builds.html


**Fedora package install:**
```dnf install arch-install-scripts zstd```

**Usage:**

./script-mount-asahi-img.sh {image name}
./build.sh chroot
./build.sh umount


### How-to
Pull in a raw image from https://fedora-asahi-remix.org/builds.html
ie
```
wget https://fedora-asahi-remix.org/os/fedora-39-minimal-202311241600.raw.zst
```

**Mount the image:**
```
./script-mount-asahi-img.sh fedora-39-minimal-202311241600.raw.zst
# or if already decompressed
fedora-39-minimal-202311241600.raw
```
This will create a directory named `mnt_image` in the current directory -- and will mount the image to that directory

**Chroot into the image:**
Once the image is mounted -- you can chroot into it with:  
```
./script-mount-asahi-img.sh chroot
```
To exit from the `chroot` environment, simply type `ctrl+d` or `exit`  

**Umounting the image:**
```
./script-mount-asahi-img.sh umount
```
This will unmount the image from `mnt_image`  
