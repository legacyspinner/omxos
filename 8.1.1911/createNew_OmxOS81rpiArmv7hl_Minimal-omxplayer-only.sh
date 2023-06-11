#!/bin/sh
SECONDS=0
if [ $(id -u) -ne 0 ]; then
	tput bel
    echo "Root privileges are required for running $0."
    exit 1
elif [ -z $1 ]; then
    echo "Usage: $0 [KICKSTARTFILE]"
    exit 1
fi

if [ $(pwd) != '/var/tmp' ]; then 
	tput bel
echo "================================================================================"
echo "================================================================================"
echo "Only run from /var/tmp/, you are at $PWD !"
echo 
echo 
echo "Copy the files over to '/var/tmp' and try again."
echo "================================================================================"
exit 1
fi

ARCH=armv7hl
BUILD=20;#++
OS=OmxOS-rpi
nextBUILD=$((++BUILD))
DATESTAMP=`date +%Y%m%d`
DATETIMESTAMP=`date +%Y%m%d%H%M%S`
KS_SPINTYPE=Minimal
UPREL=8.1
#change to your proxy or rem out
#MYPROXY=http://10.10.1.254:3128
#KEEP '$IMAGENAME' used here sync'd to kickstart custom %post work, if any.
IMAGENAME=OmxOS-rpi-8.1.armv7hl.raw.img
echo
echo "Delay/Countdown timer till job starts"
echo "Do not cancel after job starts or running 'anaconda-cleanup' may be needed."
echo "================================================================================"
echo "================================================================================"
echo
echo
echo "Press ctrl-c to cancel job."
echo
IFS=:
set -- $*
secs=5
while [ $secs -gt 0 ]
  do
  sleep 1 &
  secs=$(( $secs - 1 ))
  printf "\n%d" $secs
  printf "\n\n" 
  wait
done
sleep 2
echo "Starting new image generation."
echo "================================================================================"
echo "================================================================================"
echo
echo "With large or slow builds over network consider using 'screen' or 'nohup'"
echo
touch ./BuildStart-r$BUILD-$DATETIMESTAMP.start
livemedia-creator --ks $1 \
--compression none \
--no-virt \
--image-only \
--keep-image \
--make-disk \
--image-name=$IMAGENAME \
&& sed -i "/#++$/s/=.*#/=$nextBUILD;#/" \
${0} && export DATETIMESTAMP=`date +%Y%m%d%H%M%S` \
&& touch ./BuildEnd---r$BUILD-$DATETIMESTAMP-ELAPSED-$SECONDS.end \
&& ln -s $IMAGENAME r$BUILD-$DATETIMESTAMP
