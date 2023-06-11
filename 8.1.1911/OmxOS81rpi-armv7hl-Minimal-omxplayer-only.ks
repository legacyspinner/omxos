#This spin has customizations to consider when rebuilding: 
#the image name(--image-name): "OmxOS-rpi-8.1.armv7hl.raw"
#the image target location: /var/tmp/
keyboard --vckeymap=us --xlayouts='us'
# Root password
rootpw --plaintext omxos
# System language
lang en_US.UTF-8
# System timezone
timezone UTC --isUtc --nontp
# Network information
network  --bootproto=dhcp --device=link --activate

#accept End User License Agreement.
eula --agreed
#
shutdown

# Use network installation
url --url=http://mirror.centos.org/altarch/8/BaseOS/armhfp/os/
repo --name="BaseOS" --baseurl=http://mirror.centos.org/altarch/8/BaseOS/armhfp/os/
repo --name="AppStream" --baseurl=http://mirror.centos.org/altarch/8/AppStream/armhfp/os/
repo --name="PowerTools" --baseurl=http://mirror.centos.org/altarch/8/PowerTools/armhfp/os/
repo --name="OMXOS8.1.1911" --baseurl=https://sourceforge.net/projects/omxos/files/spins/dnf/8.1.1911/

# Firewall configuration
firewall --enabled --port=22:tcp

# SELinux configuration
selinux --permissive

# System services
services --enabled="sshd,NetworkManager,chronyd"
# System bootloader configuration
bootloader --location=mbr
# Partition clearing information
clearpart --all --initlabel
# Disk partitioning information
part /boot --asprimary --fstype="ext4" --size=200 --label=boot
part / --asprimary --fstype="ext4" --size=1845 --label=rootfs

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
cat >/root/README.rootfs-expand.txt << EOF
If you want to automatically resize your / partition, just type the following (as root user):
rootfs-expand
EOF

# Enabling chronyd on boot
systemctl enable chronyd

# exclude grubby from yum/dnf
cat >> /etc/yum.conf << EOF
exclude=grubby
EOF

# config.txt  raspberrypi2/3
cat > /boot/config.txt << EOF
#framebuffer_width=1280
#framebuffer_height=720
gpu_mem=128
arm_64bit=0
EOF

#remove mirrorlist and use baseurl for centos repos
sed  -i '/mirrorlist/s/^/#/g' /etc/yum.repos.d/*.repo
sed -i  '/mirror.centos.org/s/^#//g' /etc/yum.repos.d/*.repo

#enable OmxOS repo 
cat > /etc/yum.repos.d/omxos.repo << EOF
[omxos-8.1.1911]
name=OmxOS-8.1.1911
baseurl=https://sourceforge.net/projects/omxos/files/spins/dnf/8.1.1911/
enabled=1
gpgcheck=0
EOF

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
# fdisk update partition fs info type from 83-->c
echo "t
1
c
w
" | /usr/sbin/fdisk /dev/mapper/OmxOS-rpi-8.1.armv7hl.raw
sleep 1
kpartx -dvs /dev/mapper/OmxOS-rpi-8.1.armv7hl.raw
sleep 1
kpartx -avs /dev/mapper/OmxOS-rpi-8.1.armv7hl.raw
sleep 1
mount -v -t vfat -o defaults /dev/mapper/OmxOS-rpi-8.1.armv7hl.raw1 /boot
sleep 1
cp -rv /tmp/oldext4/* /boot
sleep 1
rm -rf /tmp/oldext4
sleep 1

touch /tmp/NOSAVE_LOGS
touch /tmp/NOSAVE_INPUT_KS
%end

%post --nochroot --log=./omxos-post_nochroot_final.log
BOOTPARTUUID=$(blkid /dev/mapper/OmxOS-rpi-8.1.armv7hl.raw1 -o value -s PARTUUID)
ROOTPARTUUID=$(blkid /dev/mapper/OmxOS-rpi-8.1.armv7hl.raw2 -o value -s PARTUUID)
# cmdline.txt raspberrypi2/3
cat > /mnt/sysimage/boot/cmdline.txt << EOF
console=ttyAMA0,115200 console=tty1 root=PARTUUID=$ROOTPARTUUID rootfstype=ext4 elevator=deadline rootwait
EOF

# fstab  raspberrypi2/3
cat > /mnt/sysimage/etc/fstab << EOF
PARTUUID=$BOOTPARTUUID          /boot           vfat            defaults                0 0
PARTUUID=$ROOTPARTUUID          /               ext4            defaults,noatime        0 1
EOF

touch /mnt/sysimage/tmp/NOSAVE_LOGS
touch /mnt/sysimage/tmp/NOSAVE_INPUT_KS

# README files
cp -av /var/tmp/respin_readme.txt /mnt/sysimage/root/respin_readme.txt
touch /mnt/sysimage/root/ChangeROOTpassword_ASAP.readme.txt

#todo:remove/update entries from /root/anaconda-ks.cfg that prevent automated auto-rebuilds 
%end

%packages
@core
NetworkManager-wifi
#bcm283x-firmware
chrony
cloud-utils-growpart
dosfstools
#nmap
omxplayer
raspberrypi2-kernel
raspberrypi2-firmware
raspberrypi-vc-utils

-aic94xx-firmware*
-iw*-firmware*
-caribou*
-dracut-config-rescue
-gnome-shell-browser-plugin
-grubby
-kexec-tools*
-java-1.6.0-*
-java-1.7.0-*
-java-11-*
-NetworkManager-team*
-plymouth*
-python*-caribou*

%end
