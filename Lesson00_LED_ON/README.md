# Turning on a LED

This code is taken from https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/ok01.html

It will not make a LED blink, instead it will turn an LED on.

Another good explanation is given [here](https://www.youtube.com/watch?v=U9H7TmRt64A&list=PLRwVmtr-pp05PQDzfuOOo-eRskwHsONY0&index=4).

The basic idea is that the GPIO controller on the Raspberry Pi has registers and those registers are memory mapped. Memory Mapped means those register are readable and writeable at addresses in the address space of the memory.

The LED on the Raspbery Pi Board is tied to one of the pins of the GPIO controller.

Turning the LED on and off basically means to turn the GPIO pin on and off.

The GPIO controller is controlling the pins. Two steps are required:

1. The GPIO controller has to enable a pin
2. The GPIO controller has to write a 1 to a pin to turn it off or a 0 to turn a pin on (it is reversed, 1 means off, 0 means 0)

## Enabling a Pin

There are 54 pins controller by the GPIO controller.

To remember which pin is enabled or disabled, the GPIO controller uses 3 bits per pin. The GPIO controller uses 24 bytes to organize the 3 bit for all 54 pins. The math adds up: Per 4 byte = 32 bit, 10 pins can be managed with 2 bit unused. 24 bytes can manage 24 / 4 _ 10 = 6 _ 10 = 60 pins. 24 bit is enought to manage all 54 pins.

The three bits for the 15th pin must be set to 001 to enable the pin. The 15th pin is the 6th pin in the second 4 byte group. The first four byte group manages pins 0 to 9. The second four byte group manages 10 - 19. Pin 15 is the 6th pin in the group 10 - 19.

To compute the correct 4 byte value, use the value 1 and left shift it by 18d.
The result is b1000000000000000000 = 262144d. If this value is written into the correct four byte group of the GPIO controller, the pin 15 is enabled.

The pin 15 (= the LED) is contained in the second 4 byte block, that means it has an offset of #4 bytes. The offset has to be added to the address 0x20200000 (on the raspberry pi 1 only!) which is where the first four byte group for GPIO pins start. 0x20200000 is the address where the first register of the GPIO controller is mapped to memory.

0x20200000 + 4 is the address of the second register for the second four byte group for the pins 10 to 19.

The task is to write the value 1 left shifted by 18 to the address 0x20200000 + 4.

Here is the assembler code:

```
/* add a 1 to register r1, execute 18 left shifts on register r1 */
mov r1,#1
lsl r1,#18

/* store the GPIO controller's memory mapped address into r0 */
ldr r0,=0x20200000

/* write to the GPIO controller. Write the value in r1 to r0 with a offset of 4. */
str r1,[r0,#4]
```

## Toggling a pin

After a pin is enabled, a value has to be assigned to the pin to either turn it on or off.

Remember, turning pin 15 off makes the LED light up! Turning pin 15 on, make the LED turn off!

Turning the 15th pin on is achieved by writing the value 1 << 16 to the offset #40 of the GPIO controller.
Turning the 15th pin off is achieved by writing the value 1 << 16 to the offset #28 of the GPIO controller.

Here is the assembler code:

```
/* store the GPIO controller's memory mapped address into r0 */
ldr r0,=0x20200000

/*
* Set the 16th bit of r1.
*/
mov r1,#1
lsl r1,#16

/* copy r1 to r0 offset #40 */
str r1,[r0,#40]

/* copy r1 to r0 offset #40 */
str r1,[r0,#28]
```

## Testing the kernel using QEmu

https://blog.agchapman.com/using-qemu-to-emulate-a-raspberry-pi/

```
apt update
apt-cache search qemu
apt-get install qemu-system-arm
```

Check which machines are supported by qemu, i.e. which systems it is able to emulate:

```
qemu-system-arm -machine help
```

Running for the Raspberry Pi 1 using the versatilepb machine.
If you want to know what Qemu is doing, add the -d in_asm flag.

```
qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M versatilepb -nographic -d in_asm
```

Running for the Raspberry Pi 2 using the raspi2 machine

```
qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M raspi2 -nographic -d in_asm
```

To terminate qemu once it is running:

Ctrl+a x

There is no output at all, because nothing is written anywhere in this first assembly program.

## Transfering the kernel.img onto a SD card

An explanation on how to create a SD card is given [here](https://github.com/me-no-dev/BareMetalPi).

The files that have to go on the SD Card are:

- bootcode.bin
- start.elf
- either kernel.img or kernel7.img

Note that the kernel image for Raspberry Pi 1 is called kernel.img and not kernel7.img or kernel8.img.
The reason is that the Raspberry PI 1 reads a file called kernel.img.

Later Raspberry Pi Versions read kernel7.img and kernel8.img.

The files bootcode.bin and start.elf are taken from the official Raspberry Pi Github repostiory which
contains precompiled versions of those files. You could copy those files from an existing SD card but if
you have no existing SD Card, creating one just to replace kernel.img is a hassle.

bootcode.bin and start.elf are contained here:
https://github.com/raspberrypi/firmware/tree/master/boot

Create a SD Card with

- a single partition
- format it with fat32
- into the root folder, copy bootcode.bin, start.elf and kernel.img
