setenv mac_addr 00:06:dc:2e:ad:67
setenv bootargs console=${console} earlycon=uart,mmio32,0x01c28000 mac_addr=${mac_addr} root=/dev/mmcblk0p2 rootwait panic=10 ${extra}
setenv fdt_filename pine64.dtb
fatload mmc 0:1 ${fdt_addr} ${fdt_filename}; fdt addr ${fdt_addr}; fdt resize
fatload mmc 0:1 ${kernel_addr} Image 
booti ${kernel_addr} - ${fdt_addr} 
