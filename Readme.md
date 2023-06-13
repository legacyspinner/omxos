**OmxOS 7.9 & 8.x**
<br />
<br />
<br />
 - Updated custom respins of centos-altarch 7.9 and  8.x armv7hl -32bit userland
 - Lightweight, trimmed, minimal package selection, results in fast respins even when rebuilding on older pi.
 - Uses legacy software such as openmax, can run as service for kiosk cam/video viewing.
 - Will follow USV 7.9 & 8.x as long as maintenance support packages are available.
 - Kernels currently follow upstream 5.4LTS
 - 8.x verified working spins/rebuilds on RPi2(v1.2)/3a/3b/3b+ models using sdcards or usb.
  
   
*Support 32bit userland.
Current examples:
 - rpi2 Revision 1.2
 - rpi3a+ 
 - rpi3b
 - rpi3b+
 - cm3*
 - rpi Zero 2 W



(These SOC's have ARMv8-A (Cortex-A53), with Videocore IV GPU)
*older versions may work run, but support for 32bit without PAE is complicated on some older units.
