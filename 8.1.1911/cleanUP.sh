#!/bin/sh
LOGS=(anaconda BuildStart*.start BuildEnd*.end livemedia.log program.log omxos-post_nochroot_resize.log omxos-post_nochroot_finalcleanup.log r??-??????????????)
echo "This script removes old images at /var/tmp/*.raw.img,"
echo "and related build logs:"
echo $LOGS
echo " "
echo " "
echo " "
echo " "
echo "~5 Second Delay/Countdown timer till job starts"
echo "Press ctrl-c to cancel job."
echo " "
echo " "
echo " "
IFS=:
set -- $*
secs=5
while [ $secs -gt 0 ]
  do
  sleep 1 &
  tput bel
  secs=$(( $secs - 1 ))
  printf "\n%d" $secs
  printf "\n\n"
  wait
done
echo " "
echo " "
echo "Removing Logs: "
IFS=$'\n'
for file in ${LOGS[*]}
do
  rm -rfv $file
done
echo " "
echo " "
echo " "
echo "Removing Images ending in *.raw.img from /var/tmp/" 
echo " "
echo " "
rm -rfv /var/tmp/*.raw.img

