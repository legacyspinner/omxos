**OmxOS 7.9**
<br />
<br />
 - Uses legacy software such as openmax.
 - Will follow USV's 7.9 as long as maintenance support packages are available.
  - omxplayer  #fits on a >=1G SDCARD, Kiosk/Camview  omxplayer.service                                                    
           - TBD   *Winter 2023 -server  #motioneye, WPA2-AP (hostapd),+?
<br />
On *nix types you can use dd to write it out to a sdcard quickly from a terminal as root.

***If your 1G+ sdcard is at /dev/sdx***,  then change 'x' to your actual target {a..z} below.

`dd if=OmxOS-rpi-7.9.armv7hl.raw.img of=/dev/sdx bs=4M status=progress`
<br />
<br />
<br />
<br />
root password = omxos
<br />
Expand the rootfs:
`rootfs-expand`

<br />
<br />
eg. for a quick wifi connection:

`nmcli --ask d wifi c 'WiFiSSID'`
<br />
<br />
*Note: If you mis-type or enter wrong password you may need to clean old files:*

*'ifcfg-SSIDname' & 'keys.SSIDname' from /etc/sysconfig/network-scripts/*

<br />
<br />

*Kiosk use:*

Enable /etc/systemd/system/omxplayer.service, ***after**** you have entered your
camera info and ***tested manually first*** or else it can be difficult to get a local console.
