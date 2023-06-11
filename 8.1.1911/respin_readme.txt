# yum update -y;yum install anaconda lorax

Then as root user make sure you have free enough space on / and/or /var/tmp

#cd /var/tmp


#USING the anaconda-ks.cfg is untested.
#livemedia-creator --ks /root/anaconda-ks.cfg \
--no-virt \
--image-only \
--keep-image \
--make-disk \
--compression none \
--image-name OmxOS-rpi-8.1.armv7hl.raw


or 

Using the omx create script and ks:

*Copy the script/ks/cleanUP.sh over to '/var/tmp/' and run:

#sh ./createNew_OmxOS81rpiArmv7hl_Minimal-omxplayer-only.sh OmxOS81rpi-armv7hl-Minimal-omxplayer-only.ks

For more debug info while building follow logs at /tmp
#tail -f /tmp/*.log

*Everything will be in /var/tmp using this, you can clean it up with ./cleanUP.sh

