#!/bin/bash


[[ -z $1 ]] && echo 'usage ./script [raw image file] | umount | chroot' && exit

mnt_image="$(pwd)/mnt_image"
[ ! -d mnt_image ] && mkdir mnt_image


uncompress_image() {
    if [[ "$(echo $image_name | grep '\.zst')" ]]; then
        decompressed_image_name=$(echo $image_name | sed 's/\.zst$//')
        [[ ! -f $decompressed_image_name ]] && unzstd $image_name
        image_name=$decompressed_image_name
    fi
}

delete_loop_devices() {
    existing_loop_devices=$(losetup | grep $image_name | awk '{print $1}')

    if [[ -n $existing_loop_devices ]]; then
        echo "### Removing existing loopback devices"
        for device in $existing_loop_devices; do
            losetup -d $device
        done
    fi
}

create_loop_devices() {
    offsets=$(fdisk -l -b 4096 $image_name | awk "/^$image_name/ {print \$2*4096}")

    delete_loop_devices

    for offset in $offsets; do
        losetup -b 4096 -P -o $offset -f $image_name
        [[ count -eq 0 ]] && efi_part=$(losetup | grep $offset | awk '{print $1}')
        [[ count -eq 1 ]] && boot_part=$(losetup | grep $offset | awk '{print $1}')
        [[ count -eq 2 ]] && root_part=$(losetup | grep $offset | awk '{print $1}')
        count=$((count+1))
    done
}

mount_image() {
    create_loop_devices

    if [[ -z $efi_part || -z $boot_part || -z $root_part ]]; then
        echo 'one or more partition varibles are not set'
        exit 1
    fi

    echo "### Mounting to $mnt_image"
    [[ -z "$(findmnt -n $mnt_image)" ]] && mount -o subvol=root $root_part $mnt_image
    [[ -z "$(findmnt -n $mnt_image/boot)" ]] && mount $boot_part $mnt_image/boot
    [[ -z "$(findmnt -n $mnt_image/boot/efi)" ]] && mount $efi_part $mnt_image/boot/efi/
}

umount_image() {
    if [ ! "$(findmnt -n $mnt_image)" ]; then
        return
    fi

    echo "### Umounting from $mnt_image"
    efi_loopback=$(findmnt -n $mnt_image/boot/efi | awk '{print $2}')
    boot_loopback=$(findmnt -n $mnt_image/boot | awk '{print $2}')
    root_loopback=$(findmnt -n $mnt_image/ | awk '{print $2}' | sed 's/\[\/root\]$//')

    [[ -n $efi_loopback ]] && umount $mnt_image/boot/efi
    [[ -n $boot_loopback ]] && umount $mnt_image/boot
    [[ -n $root_loopback ]] && umount $mnt_image

    echo "### Removing loopback devices"
    for device in $efi_loopback $boot_loopback $root_loopback; do
        losetup -d $device
    done
}

chroot_image() {
    if [[ -n "$(findmnt -n $mnt_image/boot/efi)" ]]; then
        echo "### Chrooting into $mnt_image"
        arch-chroot $mnt_image
    else
        echo 'image not mounted'
        exit 1
   fi
}

if [[ $1 == 'umount' ]] || [[ $1 == 'unmount' ]]; then
    umount_image
elif [[ $1 == 'chroot' ]]; then
    chroot_image
else
    image_name=$1
    [[ ! -f $image_name ]] && echo "$image_name does not exist" && exit
    uncompress_image
    mount_image
fi
