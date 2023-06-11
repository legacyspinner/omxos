NOTE: even though many pi's can boot from usb rather than sd, currently
some parts of this projects kickstart depends on static entries for mmcblk0.
I will change this later to support sda or mmcblk0 and then boot from usb will work.

# yum update -y;yum install anaconda lorax

Then as root user make sure you have free enough space(2G or so) at '/var/tmp':


#cd /var/tmp


#USING the anaconda-ks.cfg is untested.
#livemedia-creator --ks /root/anaconda-ks.cfg \
--no-virt \
--image-only \
--keep-image \
--make-disk \
--image-name OmxOS-rpi-7.9.armv7hl.raw


or 

Using the omx create script and ks:

*Copy the script/ks/cleanUP.sh over to '/var/tmp/' and run:

#sh ./createNew_OmxOS79rpiArmv7hl_Minimal-omxplayer-only.sh OmxOS79rpi-armv7hl-Minimal-omxplayer-only.ks

For more debug info while building follow logs at /tmp
#tail -f /tmp/*.log

*Everything will be in /var/tmp using this, you can clean it up with ./cleanUP.sh

Important:
Due to the procedures anaconda/liveimage-creator expects in this older version, services that can 
trigger and touch files systems while building and/or the mounting/unmounting of volume steps. 
Build this in a chroot or console only with at a low runlevel or with dbus/pulse disabled. 
These services can touch files and create locks on the image volume and or /tmp that will get bound
over to the chroot, as a result , that will hold a mount or unmount due to a process lock. 
If you dont intend to do any custom image resizing mounting/umounting in your build.
Remove the %post --nochroot section then it will build without many precautions or a dedicated
build chroot. Then you only have to be concerned with the image name/location/cmdline.txt&fstab
