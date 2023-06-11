#This spin has customizations to consider when rebuilding: 
#The image will be resized/reduced down to just below 1G.
#the image name(--image-name): "OmxOS-rpi-7.9.armv7hl.raw"
#the image target location: /var/tmp/
#WARNING: Changes to the image name,location may require
#adaption of related entries. 
#You can remove the:
#%post --nochroot section completely
#it was just an experiment/demo in resizing in ks.

keyboard --vckeymap=us --xlayouts='us'
# Root password
rootpw --plaintext omxos
# System language
lang en_US.UTF-8

# Use network installation
url --url=http://mirror.centos.org/altarch/7/os/armhfp/
repo --name="updates" --mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=armhfp&repo=updates&infra=$infra
repo --name="kernelLTS-rpi2" --mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=armhfp&repo=kernel-kernel-rpi2&infra=$infra
repo --name="epel" --baseurl=https://armv7.dev.centos.org/repodir/epel-pass-1/ 
repo --name="omxos" --baseurl=https://sourceforge.net/projects/omxos/files/spins/yum/
#
#repo --name="updates" --baseurl=http://mirror.centos.org/altarch/7.9.2009/updates/armhfp/ 
#repo --name="kernel-rpi" --baseurl=http://mirror.centos.org/altarch/7.9.2009/kernel/armhfp/kernel-rpi2/ 

# SELinux configuration
selinux --permissive

# System services
services --enabled="sshd,NetworkManager,chronyd"

# Firewall configuration
firewall --enabled --port=22:tcp

# Network information
network  --bootproto=dhcp --device=link --activate

# Shutdown after installation
shutdown

# System timezone
timezone UTC --isUtc --nontp

bootloader --location=mbr
# Partition clearing information
clearpart --all --initlabel
zerombr

# Disk partitioning information
part /boot --asprimary --fstype="ext4" --size=100 --label=boot
part / --asprimary --fstype="ext4" --size=2947 --label=rootfs

%pre 
touch /tmp/NOSAVE_LOGS
touch /tmp/NOSAVE_INPUT_KS
%end


%post
touch /tmp/NOSAVE_LOGS
touch /tmp/NOSAVE_INPUT_KS

# Generating initrd
export kvr=$(rpm -q --queryformat '%{version}-%{release}' $(rpm -q raspberrypi2-kernel|tail -n 1))
dracut --force /boot/initramfs-$kvr.armv7hl.img $kvr.armv7hl


# Mandatory README file
cat >/root/README.expand_RootFS.txt << EOF
If you want to automatically resize your / partition, just type the following (as root user):
rootfs-expand
EOF

# Enabling chronyd on boot
systemctl enable chronyd

# config.txt  raspberrypi2/3
cat > /boot/config.txt << EOF
#framebuffer_width=1280
#framebuffer_height=720
gpu_mem=128
arm_64bit=0
EOF

#enable epel-pass-1 repo aka (epel workalike arm32)
cat > /etc/yum.repos.d/epel-pass-1.repo << EOF
[epel-pass-1]
name=epel-pass-1
baseurl=https://armv7.dev.centos.org/repodir/epel-pass-1
gpgcheck=0
enabled=1
EOF

#enable OmxOS repo 
cat > /etc/yum.repos.d/omxos.repo << EOF
[omxos]
name=OmxOS
baseurl=http://sourceforge.net/projects/omxos/files/spins/yum/
enabled=1
gpgcheck=0
EOF

# Setting correct yum variable to use raspberrypi kernel repo
echo "rpi2" > /etc/yum/vars/kvariant

# install omxplayer.service
cat > /etc/systemd/system/omxplayer.service << EOF
[Unit]
Description=omxplayer.service
After=network.target 

[Service]
Type=simple

#User=
#usage examples
#ExecStart=/usr/bin/timeout 15 /usr/bin/omxplayer -o hdmi -b --live http://192.168.1.100:8081
#ExecStart=/usr/bin/timeout 65 /usr/bin/omxplayer -o hdmi -b --live --avdict 'rtsp_transport:udp' rtsp://$USER:$PWD@192.168.1.100:88/videoMain
#ExecStart=/usr/bin/timeout 65 /usr/bin/omxplayer -o hdmi -b --live --avdict 'rtsp_transport:udp' rtsp://$USER:$PWD@192.168.1.100:88/videoSub
ExecReload=/bin/kill -HUP $MAINPID
KillMode=control-group

Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF
chmod +0644 /etc/systemd/system/omxplayer.service

# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id

# Removing some firmware files, more trim possible 
rm -rf /usr/lib/firmware/mixart
rm -rf /usr/lib/firmware/pcxhr
rm -rf /usr/lib/firmware/bnx2
rm -rf /usr/lib/firmware/ueagle-atm
rm -rf /usr/lib/firmware/qca
rm -rf /usr/lib/firmware/asihpi
rm -rf /usr/lib/firmware/nvidia
rm -rf /usr/lib/firmware/cxgb4
rm -rf /usr/lib/firmware/mediatek
rm -rf /usr/lib/firmware/radeon
rm -rf /usr/lib/firmware/mrvl
rm -rf /usr/lib/firmware/i915
rm -rf /usr/lib/firmware/bnx2x
rm -rf /usr/lib/firmware/dpaa2
rm -rf /usr/lib/firmware/mellanox
rm -rf /usr/lib/firmware/qed
rm -rf /usr/lib/firmware/qcom
rm -rf /usr/lib/firmware/liquidio
rm -rf /usr/lib/firmware/intel
rm -rf /usr/lib/firmware/amdgpu
rm -rr /usr/lib/firmware/netronome

#save some space by pruning locales down to en_US
cp /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
/sbin/build-locale-archive --install="en_US"
/bin/find /usr/share/locale/ -type d -not -name 'en' -not -name 'en_US' -not -name 'locale' -exec rm -rf {} \; 2>/dev/null
/bin/find /usr/lib/locale/ -type d -not -name 'en_US' -not -name 'locale' -not -name 'locale-archive' -delete

#defrag/trim rootfs(raw2)
e4defrag /dev/mapper/OmxOS-rpi-8.1.armv7hl.raw2
sleep 1
fstrim /
sleep 1

#convert boot(raw1) from ext4-->vfat
mkdir -p /tmp/oldext4 
cp -r /boot/* /tmp/oldext4/
sleep 1
umount  /dev/mapper/OmxOS-rpi-8.1.armv7hl.raw1
mkfs -V -t vfat /dev/mapper/OmxOS-rpi-8.1.armv7hl.raw1
sleep 1
mount -v -t ext4 -o defaults /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw1 /boot
sleep1
mkdir -pv /tmp/oldext4 
cp -rv /boot/* /tmp/oldext4/
sleep 1
umount -v /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw1
mkfs -V -t vfat -n rpiboot /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw1
# fdisk update partition fs info type from 83-->c
echo "t
1
c
w
" | /usr/sbin/fdisk /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw
sleep 1
partprobe -s
sleep 1
mount -v -t vfat -o defaults /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw1 /boot
sleep 1
cp -rv /tmp/oldext4/* /boot
sleep 1
rm -rf /tmp/oldext4
sleep 1
BOOTPARTUUID=$(blkid /dev/mapper/OmxOS-rpi-8.1.armv7hl.raw1 -o value -s PARTUUID)
ROOTPARTUUID=$(blkid /dev/mapper/OmxOS-rpi-8.1.armv7hl.raw2 -o value -s PARTUUID)
# cmdline.txt raspberrypi2/3
cat > /boot/cmdline.txt << EOF
console=ttyAMA0,115200 console=tty1 root=PARTUUID=$ROOTPARTUUID rootfstype=ext4 elevator=deadline rootwait
EOF

# fstab  raspberrypi2/3
cat > /etc/fstab << EOF
PARTUUID=$BOOTPARTUUID          /boot           vfat            defaults                0 0
PARTUUID=$ROOTPARTUUID          /               ext4            defaults,noatime        0 1
EOF

#really trying to keep logs off target
touch /tmp/NOSAVE_LOGS
touch /tmp/NOSAVE_INPUT_KS
%end


#resize/shrink fs/partition/imagefile
%post --nochroot --log=./omxos-post_nochroot_resize.log
umount -v /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw1
umount -v /mnt/sysimage/sys
umount -v /mnt/sysimage/run
umount -v /mnt/sysimage/proc
umount -v /mnt/sysimage/dev/shm
umount -v /mnt/sysimage/dev/pts
umount -v /mnt/sysimage/dev
sleep 3
umount -v /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw2
sleep 2
lsof -V /mnt/sysimage
# check/shrink root filesytem
e2fsck -f -y -v -C0 /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw2
sleep 1
resize2fs -p /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw2 923M
# fdisk update root partition size 
echo "d
2
n
p
2
206848
+945152K
w
" | /usr/sbin/fdisk /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw
sleep 1

#truncate of image starts
truncate --size=$[(2097151+1)*512] /var/tmp/OmxOS-rpi-7.9.armv7hl.raw.img

#remount
losetup -c /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw
mount -v -t ext4 -o defaults /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw2 /mnt/sysimage
mount -v -t vfat -o rw /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw1 /mnt/sysimage/boot
mount -t bind -o bind,defaults /dev /mnt/sysimage/dev
mount -t devpts -o gid=5,mode=620 devpts /mnt/sysimage/dev/pts
mount -t tmpfs -o defaults tmpfs /mnt/sysimage/dev/shm
mount -t proc -o defaults proc /mnt/sysimage/proc
mount -t bind -o bind,defaults /run /mnt/sysimage/run
mount -t sysfs -o defaults sysfs /mnt/sysimage/sys
%end

%post --nochroot --log=./omxos-post_nochroot_finalcleanup.log
#misc cleanup/final defrag/trim
rm -rvf /mnt/sysimage/var/cache/yum/armhfp
rm -rfv /mnt/sysimage/tmp/*
rm -rfv /mnt/sysimage/tmp/.*-unix
touch /tmp/NOSAVE_LOGS
touch /tmp/NOSAVE_INPUT_KS
e4defrag /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw2
sleep 1
fstrim /
sleep 1
e4defrag /dev/mapper/OmxOS-rpi-7.9.armv7hl.raw2
fstrim /

# README2 file
cat /var/tmp/respin_readme.txt >/mnt/sysimage/root/respin_readme.txt

#todo:remove entries from /root/anaconda-ks.cfg that prevent automated auto-rebuilds 
%end

#if you want to rebuild with more packages and need space,
#delete all of the "%post --nochroot" section above.
%packages
@core
chrony
cloud-utils-growpart
dosfstools
NetworkManager-wifi
##nmap
omxplayer
raspberrypi2-kernel
raspberrypi2-firmware
raspberrypi-vc-utils
#removals
-aic94xx-firmware*
-caribou*
-iw*-firmware*
-NetworkManager-team*
-gnome-shell-browser-plugin
-kexec-tools*
-NetworkManager-team*
-plymouth*
-python*-caribou*
-java-1.6.0-*
-java-1.7.0-*
-java-11-*
%end
