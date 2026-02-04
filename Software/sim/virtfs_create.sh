#!/bin/bash

disk_size=64M
disk_name=virt_disk
mnt_point=/mnt/8b_disk


if [ ! -f ${disk_name} ]; then
    touch ${disk_name}
    truncate -s ${disk_size} ${disk_name}
    echo "$disk_name created"
    sfdisk ${disk_name} < sd.sfdisk
    sudo losetup -D /dev/loop0
    sudo losetup -P /dev/loop0 ${disk_name}
    sudo mkfs.fat -F 16 /dev/loop0p1
    echo "Filesystem created"
    
else
    echo "Filesystem exists"
fi


sudo losetup -D /dev/loop0
sudo losetup -P /dev/loop0 ${disk_name}
sudo mkdir -p ${mnt_point}
sudo mount -o loop /dev/loop0p1 ${mnt_point} -o uid=`id -u`,gid=`id -g`

echo "${disk_size} filesystem mounted at ${mnt_point} "

echo "Hello World!" > ${mnt_point}/HELLO.TXT
echo "Created test file on disk"