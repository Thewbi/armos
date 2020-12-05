rm boot.o
rm kernel.o
rm kernel.elf
rm kernel.img
rm kernel7.img
rm kernel.list
rm kernel.map
arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -c boot.s -o boot.o
arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -c kernel.c -o kernel.o -O2 -Wall -Wextra
arm-none-eabi-gcc -T linker.ld -o kernel.elf -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc
arm-none-eabi-objcopy kernel.elf -O binary kernel.img

# assembler

arm-none-eabi-as -c boot.S -o boot.o
arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -c boot.s -o boot.o

# C compoiler

arm-none-eabi-gcc -ffreestanding -c kernel.c -o kernel.o -O2 -Wall -Wextra
arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -c kernel.c -o kernel.o -O2 -Wall -Wextra

# link

arm-none-eabi-ld --no-undefined kernel.o -Map kernel.map -o kernel.elf -T linker.ld
arm-none-eabi-gcc -T linker.ld -o kernel.elf -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc

# remove elf, create image

arm-none-eabi-objcopy kernel.elf -O binary kernel7.img
arm-none-eabi-objcopy kernel.elf -O binary kernel.img

arm-none-eabi-objdump -d kernel.elf > kernel.list

qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M versatilepb -no-reboot -nodefaults -display none -serial stdio
qemu-system-arm -kernel kernel.elf -cpu arm1176 -m 256 -M versatilepb -no-reboot -nodefaults -display none -serial stdio
qemu-system-arm -kernel kernel.elf -cpu arm1176 -m 256 -M versatilepb -no-reboot -nodefaults -display none -serial none -serial stdio

qemu-system-arm -m 256 -M raspi2 -display none -serial stdio -kernel kernel.elf
qemu-system-arm -m 256 -M raspi2 -display none -serial stdio -kernel kernel7.img
qemu-system-arm -m 256 -M raspi2 -nographic -kernel kernel.elf
qemu-system-arm -m 256 -M raspi2 -nographic -kernel kernel7.img

/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -kernel kernel.img -cpu arm1176 -m 256 -M versatilepb -no-reboot -nodefaults -display none -serial stdio

/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -kernel kernel.img -m 1024 -M raspi3 -no-reboot -nodefaults -display none -serial stdio

qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M versatilepb -nographic -d in_asm
qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M versatilepb -nographic -serial null -monitor stdio
qemu-system-arm -kernel kernel7.img -cpu arm1176 -m 256 -M versatilepb -nographic

qemu-system-arm -kernel uart05.bin -cpu arm1176 -m 256 -M versatilepb -nographic -serial stdio
qemu-system-arm -kernel uart05.bin -cpu arm1176 -m 256 -M versatilepb -display none -serial stdio

qemu-system-arm -kernel kernel7.img -cpu arm1176 -m 256 -M raspi2 -nographic
qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M raspi2 -nographic

/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -m 1024 -M raspi3 -kernel kernel.img
/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -m 1024 -M raspi3 -kernel kernel.img -serial stdio

qemu-system-arm -machine help
qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M versatilepb -nographic
qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M versatilepb -nographic -serial null
qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M versatilepb -nographic -monitor stdio

qemu-system-arm: -serial stdio: could not connect serial device to character backend 'stdio'

qemu-system-arm -kernel uart01.bin -cpu arm1176 -m 256 -M versatilepb -nographic
qemu-system-arm -kernel uart02.bin -cpu arm1176 -m 256 -M versatilepb -nographic

https://www.raspberrypi.org/forums/viewtopic.php?t=142531

https://stackoverflow.com/questions/60552355/qemu-baremetal-emulation-how-to-view-uart-output
-s is a shortcut for -gdb tcp::1234
-S means freeze CPU at startup

https://stackoverflow.com/questions/48135954/bare-metal-arm-raspberry-pi-qemu-strange-behavior-with-floating-point-division

brew install minicom

sudo minicom --device /dev/tty.SLAB_USBtoUART

Esc-Q to quit, Esc-O for options, etc

brew install screen

sudo screen /dev/tty.SLAB_USBtoUART 115200

ls /dev/tty\*
