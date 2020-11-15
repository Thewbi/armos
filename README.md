# ARM OS Course

These notes and code are the preparation for a coures that I hopefully can monetize some day on some learning platform.

## Links

https://github.com/bztsrc/raspi3-tutorial
https://github.com/s-matyukevich/raspberry-pi-os

## Development Board

To test the OS on real hardware, the Raspberry PI 3 Model B+ is used.

The specification is contained here: (https://www.raspberrypi.org/products/raspberry-pi-3-model-b-plus)

Specification
The Raspberry Pi 3 Model B+ is the final revision in the Raspberry Pi 3 range.

- CPU: Broadcom BCM2837B0, Cortex-A53 (ARMv8) 64-bit SoC @ 1.4GHz with 4 cores (quad-core)
- RAM: 1GB LPDDR2 SDRAM
- Bluetooth: 2.4GHz and 5GHz IEEE 802.11.b/g/n/ac wireless LAN, Bluetooth 4.2, BLE
- Ethernet: Gigabit Ethernet over USB 2.0 (maximum throughput 300 Mbps)
- GPIO: Extended 40-pin GPIO header
- HDMI: Full-size HDMI
- USB: 4 USB 2.0 ports
- CAMERA: CSI camera port for connecting a Raspberry Pi camera
- DSI: DSI display port for connecting a Raspberry Pi touchscreen display
- AUDIO: 4-pole stereo output and composite video port
- SD-SLOT: Micro SD port for loading your operating system and storing data
- POWER: 5V/2.5A DC power input
- PoE: Power-over-Ethernet (PoE) support (requires separate PoE HAT)

## Docker

[An Introduction to Docker](doc/Docker/README.md)

## GIT

[An Introduction to GIT](doc/git/README.md)

## Setting up the Development Environment

[Development Environment](doc/Environment/README.md)

## Lesson 1 - Baremetal Assembler

[Baremetal Assembler](Lesson01_Assembler/README.md)

## Lesson 2 - Programming in C

## Running the kernel on qemu

https://github.com/bztsrc/raspi3-tutorial/blob/master/README.md

```
qemu-system-aarch64 -M raspi3 -kernel kernel8.img -serial stdio
```

As a Test:
https://raspberrypi.stackexchange.com/questions/34733/how-to-do-qemu-emulation-for-bare-metal-raspberry-pi-images/85135#85135

cd /temp

# Get source.

```
git clone https://github.com/bztsrc/raspi3-tutorial
cd raspi3-tutorial
git checkout efdae4e4b23c5b0eb96292f2384dfc8b5bc87538
```

# Setup to use the host precompiled cross compiler.

# https://github.com/bztsrc/raspi3-tutorial/issues/30

```
apt-get install gcc-aarch64-linux-gnu
find . -name Makefile | xargs sed -i 's/aarch64-elf-/aarch64-linux-gnu-/'
```

# Compile and run stuff.

```
cd 05_uart0
make
/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -M raspi3 -kernel kernel8.img -serial stdio
```

Q: Unable to init server: Could not connect: Connection refused\
gtk initialization failed\
A: Use -nographic

Q: EMU 5.0.1 monitor - type 'help' for more information\
(qemu) qemu-system-aarch64: -serial stdio: cannot use stdio by multiple character devices\
qemu-system-aarch64: -serial stdio: could not connect serial device to character backend 'stdio'\
A: Start without -serial stdio

```
/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -M raspi3 -kernel kernel8.img
```

## How can I terminate qemu?

Use ^a x
This means, press and hold Ctrl then press a, release Ctrl and a, then press x

## Debugging

https://bertrand.tognoli.fr/todo/work/MyOwnKernel.html

## USB Stack

https://github.com/Chadderz121/csud

You need the USB stack not only for USB devices but also for the ethernet connection,
because the ethernet connection is implemented as a hardware chip that actually converts USB to Ethernet.
https://raspberrypi.stackexchange.com/questions/13241/bare-metal-programming-how-to-access-ethernet-hw-interface

## Drivers

### Driver for External Clock

### Driver for Gyro Sensor

## Networked boot

https://metebalci.com/blog/bare-metal-rpi3-network-boot/

## Networking

https://raspberrypi.stackexchange.com/questions/13241/bare-metal-programming-how-to-access-ethernet-hw-interface

https://ownyourbits.com/2017/02/06/raspbian-on-qemu-with-network-access/

### TCP/IP

## Running the OS on Raspberry PI 3 B+

## Running the OS on BeagleBone Black
