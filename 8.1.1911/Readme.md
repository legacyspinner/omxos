OK SERIOUS NOW = 1


arm7 (32bit) USERLAND RPM DEVELOPMENT TESTING / Random thoughts, a few to remember.

Based of old Centos-Altarch 8.1 Currently the 8.1 tree is 3 years out of date, packages 
for centos-altarch8 are currently being updated using Rocky/Alma 8.x SRPMS. It's been my
observation that Rocky ported arm before Alma, so I will defer to their previous work with
higher priority.

The image/spin here was the first public 8.x omxos release in a string to come of spins for 8.x.
This will be the system that transfers to 9 eventually, version 7 development will be minimal
now except for critical backport type fixes, until I build out this to 8.current.  

*June 2023, Sun 4th. Most all packages except python have now be rebuilt to build proper complete
mock dev host. I will wrangle python2 into a corner very soon now and  once  done I will
put up the complete 8.1.X build set needed up on SF. 

Respins/Updating of RPM building delayed while I test UTM with el8 4k pages.

**WARNING Notes about reusing any work:**
This is very early work with many bugs I'm sure. The "COMPLETE" rpmdevset repo will be 
labeled "8.1.2", RPMS&SRPMS over at SF omxos. This should be the base to build higher level
*RPMS in 8.x else you could end up in "a circular rpm devel eeeehell. 

*util-linux patch and rebuilt(libfdisk 32bit issue with reading existing UUIDS, per a previous
patch/fix I found from ubuntu/debian Bug 1817302. 

*The next test image/spin will include a new '8.1.2' repo pointing to a rpm set that is hopefully complete
enough to build the next version or so.

*After version 8 is built up, I will return to 7.x and focus on rebuilting it as lean and small as possible, without
breaking stuff too much. 

<hr>
Mini-status:

1.) 8.1.2 SRPM's rebuilding(delayed)

2.) el8 aarch64 kernel rebuild testing on a rpi4.
Kernel configuerd with :CONFIG_ARM64_64K_PAGES=n and CONFIG_ARM64_4K_PAGES=y
and a couple other physical address options pa/va.
I think i have the right combination of pagesize/pa and va now after reading more on paging options:
4K 16K or 64K.

*June 10, 2023: Updated: Kernel /boot/vmlinuz-4.18.0-477.13.1.el8_8.1_4K_pages.aarch64 built,  I had to install it
manually as it said the build broke the kABI. 

Testing: After reading more about the kABI from the quality people over at elrepo. Thanks for `still` updating
the docs! 

With the tips, now I'm running a new test build with:

<code>
rpmbuild -bb --target=`uname -m` kernel.spec \
--without debug \
--without debuginfo \
--without kabichk \
kernel.spec 2> build-err.log | tee build-out.log
</code>

Guess I have to take a whole class on just:
"HOW TO ADD IMAGES TO A GITHUB PAGE BY BROWSER!"


<hr>
<hr>

**OmxOS 8.X**
<br />
<br />
 - Uses legacy software such as openmax.
 - Will follow USV's 8.x as long as maintenance support packages are available.
 - Verified working on RPi2/3/3a models.
   - OmxOS has 1 flavor now with 1 more expected*.
	 - omxplayer  #fits on a >=2G SDCARD, Kiosk/Camview  omxplayer.service                                                    
           - TBD -server  #motioneye, WPA2-AP (hostapd),+?
<br />
On *nix types you can use dd to write it out to a sdcard quickly from a terminal as root.

***If your sdcard is at /dev/sdx***,  then change 'x' to your actual target {a..z} below.

`dd if=OmxOS-rpi-8.x.armv7hl.raw.img of=/dev/sdx bs=4M status=progress`
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
