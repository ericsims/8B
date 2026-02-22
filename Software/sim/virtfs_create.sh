#!/bin/bash
set -e

disk_size=64M
disk_name=virt_disk
mnt_point=/mnt/8b_disk


if [ ! -f ${disk_name} ]; then
    touch ${disk_name}
    truncate -s ${disk_size} ${disk_name}
    echo "$disk_name created"
    sfdisk ${disk_name} < sd.sfdisk
    sudo losetup -D
    loop=$(losetup -f)
    sudo losetup -P ${loop} ${disk_name}
    sudo mkfs.fat -F 16 ${loop}p1
    echo "Filesystem created"    
else
    echo "Filesystem exists"
fi
if ! mountpoint -q ${mnt_point}; then
    echo "${disk_size} filesystem mounted at ${mnt_point} using ${loop}"
    sudo losetup -D
    loop=$(losetup -f)
    sudo losetup -P ${loop} ${disk_name}

    sudo mkdir -p ${mnt_point}
    sudo mount -o loop ${loop}p1 ${mnt_point} -o uid=`id -u`,gid=`id -g`
else
    echo "filesystem already mounted"
fi



echo "Hello World!" > ${mnt_point}/HELLO.TXT
echo "this is some text in file 1" > ${mnt_point}/FILE1.TXT
echo "even more text, located in file 2" > ${mnt_point}/FILE2.TXT
sync
echo "Created test file on disk"

echo "Copying apps to disk..."
for file in ../apps/bin/*.bin; do
    case $file in
        *_static.bin) continue;;
    esac
    cp -v "${file^^}" "${mnt_point}";
done
sync
echo "done"