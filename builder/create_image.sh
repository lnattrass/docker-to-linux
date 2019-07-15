#!/bin/bash

set -e

#
# Pad the disk by 1024 bytes * kilobytes * megabytes = 1gb
#
BOOT_SIZE=$(( 1024 * 1024 * 300 ))

ROOT_SIZE=$(stat -c '%s' /rootfs.tar)
DISK_PADDING=$(( 1024 * 1024 * 1024 * 1 ))
DISK_SIZE=$(( $DISK_PADDING + $ROOT_SIZE + $BOOT_SIZE ))

OUT_IMAGE="/output/rootfs.img"

# 
#
#
function cleanup {
  set +e
  if [ "$MOUNTED" != "" ]; then
    echo -e "\n[Unmount]"
    umount /rootfs/boot
    umount /rootfs
  fi
  if [ "$PARTED" != "" ]; then
    echo -e "\n[Deactivate LVM]"
    dmsetup remove_all
  fi
  if [ "$LOOPDEV" != "" ]; then
    echo -e "\n[Delete loopback mount]"
    losetup -d "$LOOPDEV"
  fi
}

set -x

echo -e "[Create disk image]"
dd if=/dev/zero of="$OUT_IMAGE" bs=$DISK_SIZE count=1

echo -e "\n[Mount loopback]"
LOOPDEV=$(losetup -f)
losetup "$LOOPDEV" "$OUT_IMAGE"
trap cleanup EXIT

echo -e "\n[Create LVM volumes]"
pvcreate "$LOOPDEV"
vgcreate vg_root "$LOOPDEV"
PARTED=1
lvcreate -n boot -L "${BOOT_SIZE}b" vg_root
lvcreate -n root -L "${ROOT_SIZE}b" vg_root

echo -e "\n[Format volumes]"
mkfs.ext3 /dev/vg_root/boot
mkfs.ext4 /dev/vg_root/root

echo -e "\n[Mount volumes]"
mkdir /rootfs
mount -t auto /dev/vg_root/root /rootfs
MOUNTED=1

mkdir /rootfs/boot
mount -t auto /dev/vg_root/boot /rootfs/boot


echo -e "\n[Extract linux rootfs]"
tar -xf /rootfs.tar -C /rootfs

echo -e "\n[Setup extlinux]"
#extlinux --install /rootfs/boot/
#cp /rootfs/syslinux.cfg /rootfs/boot/syslinux.cfg


echo -e "\n[Write syslinux MBR]"
#dd if=/usr/lib/syslinux/mbr/mbr.bin of=/output/linux.img bs=440 count=1 conv=notrunc
  read -p "Press enter to continue" "input"

