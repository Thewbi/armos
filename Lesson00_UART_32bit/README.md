# UART

## Links

- https://www.youtube.com/watch?v=4RrMoa5PS_M
- https://www.raspberrypi.org/documentation/configuration/uart.md
- https://jsandler18.github.io/tutorial/boot.html
- https://wiki.osdev.org/Raspberry_Pi_Bare_Bones
- BCM2835 ARM Peripherals
- ARM PrimeCell UART (PL011) Revision: r1p5 Technical Reference Manual

## Disclaimer

Note that for the Raspberry 2, 3 and 4, the addresses are different than for the Rapsberry PI 1! This document only is valid for the Raspberry Pi 1! See https://wiki.osdev.org/Detecting_Raspberry_Pi_Board.

There is an individual document describing the UART (ARM PrimeCell UART (PL011) Revision: r1p5 Technical Reference Manual)

## Introduction to UART

UART means Universal Asynchronous Receiver/Transmitter. It is often used in embedded systems that do not have a VGA, HDMI, Display Port or any other usable graphical connector. UART can be used to exchange bytes of data. When transmitting ASCII characters, terminal emulators such as Putty, screen, CoolTerm or MobaXTerm can be used to send commands and receive output from a embedded device.

On the Rapsberry PI the UART hardware is exposed via 3.3 Volt pins. The same pins are used throughout all revisions of the Raspberry Pi. You have to make sure that you do not damage your raspberry pi by using the wrong voltage. USB outputs 5V. When you want to connect your raspberry pi's UART to your compute make sure to use a USB to TTL adapter that performs voltage level shifting from 5V to 3.3V such as [this ones](https://www.amazon.de/AZDelivery-CP2102-Konverter-HW-598-Arduino/dp/B07N2YLH26/ref=sr_1_12_sspa?__mk_de_DE=%C3%85M%C3%85%C5%BD%C3%95%C3%91&crid=3PJMDM6C9L673&dchild=1&keywords=usb+ttl+adapter+3.3v&qid=1607361578&sprefix=USB+ttl+%2Caps%2C165&sr=8-12-spons&psc=1&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUEyTTNZOUk5S0lINDdRJmVuY3J5cHRlZElkPUEwOTQ1NDYwM09QTlpDQU42MVlLWSZlbmNyeXB0ZWRBZElkPUEwMjk2OTgzM0RLM0FUWThRTEFOMCZ3aWRnZXROYW1lPXNwX210ZiZhY3Rpb249Y2xpY2tSZWRpcmVjdCZkb05vdExvZ0NsaWNrPXRydWU=).

Also the TX (transmit) pin on one end of the connection has to be connected to the RX (receive) pin on the other end of the connection (They are flipped around so TX is connected to RX for both directions!). Make sure to connect RX to TX and TX to RX. Then also connect the two grounds. Some USB to TTL converters contain a 3.3V and a 5V pin. In theory you could connect the 5V pin from the USB to a pin on the Raspberry Pi that can take 5V to power the system. If you power your raspberry pi using a dedicated power supply, do not power the raspberry pi over the USB to Serial adapter at the same time. Only use a single power source. The serial UART connection works with RX, TX and ground connected. You do not net voltage connection for the UART serial connection.

The pins will output serial data. You can plug in a serial to USB adapter or adapter cable and connect it to your PC. Or you can connect RS232 or RS485 adapters to transfer the serial data over cables of larger length.

Serial data is mostly used for outputting ASCII characters. Those serial ASCII data is then received and interpretted by terminal software such as Putty, Picocom or MobaXTerm. That way, you can get access to your raspberry pi embedded system without a video adapter.

There are applications such as [minicom](https://linux.die.net/man/1/minicom) defined over serial connections that allow the transfer of files.

A call in your kernel can send ASCII characters out to the pins. The serial data is received on your PC via terminal software and you can see what the kernel prints. The reverse direction is also possible (Remember UART stands for receiver/transmitter). Your terminal software can collect ASCII characters in a buffer. When you hit enter, those characters are transferred over the USB to serial cable to the pins of the raspberry pi, where they go into the UART hardware and can be read by the kernel via interrupt routines.

On Linux, a terminal can be connected to UART. This is the same principal as a Linux terminal being connected to a ssh (secure shell). Basically when Linux detects a UART communication it will allow the user to login with their credentials and after logging in, you have command line access to the Linux shell.

## UART on Raspberry PI 1 (BCM2835)

https://www.raspberrypi.org/documentation/configuration/uart.md

There are two UARTs on the raspberry pi.

They are

- mini UART (example source code: [Part 5 of the valvers](https://www.valvers.com/open-software/raspberry-pi/bare-metal-programming-in-c-part-5/) code repository contains code that uses Mini UART)
- PL011 UART (https://wiki.osdev.org/Raspberry_Pi_Bare_Bones)

PL011 is a implementation of a UART that is very close to the UART standard. It can be configured in many ways, for example the baudrate can be set. Mini UART is a version of UART that is fixed in it's configuration and that is not as fast as the PL011 UART. The point of Mini UART is to be avaialable with minimal amount of setup code.

The pinout is taken from [here](https://de.pinout.xyz/pinout/uart)

By default, both UARTs have to be enabled in the config.txt file on the raspberry pi's sd card.

- https://www.raspberrypi.org/forums/viewtopic.php?t=223736
- https://www.raspberrypi.org/forums/viewtopic.php?t=175527
- https://raspberrypi.stackexchange.com/questions/63468/uart-send-receive-not-working
- http://www.netzmafia.de/skripten/hardware/RasPi/RasPi_Serial.html

Starting with the Raspberry Pi 3, the UART configuration was removed apparently it conflicted with the WiFi connection.

On any raspberry pi revision, if you try to programm the UART and you only get garbage characters out of the UART connection, first look into the config.txt file and set up UART and the clock speed correctly. Sometimes the UART is just disabled via the config.txt file. In this case, you can establish a connection to the UART but it will only output trash.

What worked for me is (taken from the repository mentioned in https://www.raspberrypi.org/forums/viewtopic.php?t=223736):

cmdline.txt

```
console=serial0,115200 console=tty1 root=PARTUUID=42084a2f-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles
```

and config.txt

```
...

# Enable uart
init_uart_clock=3000000
enable_uart=1
core_freq=250

# Enable audio
#dtparam=audio=on

# ???
dtoverlay=pi3-disable-bt

...
```

On MAC I use a application called CoolTerm as a serial monitor and a USB to TTL converter to establish the serial connection. The connection is established over the port called 'SLAB_USBtoUART'. The Baudrate is 115200 and 8N1 (= 8 data bits, No Parity, 1 Stop Bit). The code I use is the [osdev wiki's bare metal programming tutorial for the raspberry pi](https://wiki.osdev.org/Raspberry_Pi_Bare_Bones).

I tested it on a RPI 2 Model v1.1 and a RPI 1 Model B+.

## UART on QEmu

The support for UART in qemu is a bit of a mystery to me. Some forum entries on the internet say, that only PL011 is supported by qemu and MiniUART is not. I have seen the valvers code work on qemu with the MiniUART, so the information seems not to be accurate.

Another point is that the PL011 works for me when I run the .elf file of the kernel in qemu and it does not work, when I run the object dumped .img version of the kernel! So qemu treats .elf different than .img or my .img is broken.

The general takeaway is to try and find out what works on your version of qemu. Try PL011 and try MiniUART. Also try .elf and .img to see what results you get. Basically sometimes qemu prints your UART Strings to the console, then you know that it works. Sometimes there is no UART output and you know that it does not work.

## How to interpret Addresses

This section uses addresses for the RPi 1 Model B+. If you use another RPi revision, adjust the addresses accordingly.

The document "BCM2835 ARM Peripherals" contains a mapping of addresses on page 5. The left address space is what the CPU sees. The VC/ARM MMU (VC/ARM Memory Management Unit) maps the CPU addresses to the so-called ARM Physical Addresses. This address space is what the custom kernel will operate on.

The right column is the address space as is configured by a linux implementation which does not concern a custom os developer. The problem is that all addresses described in the document are listed in terms of the right column! There has to be a way to convert the peripheral addresses from the right column to the center column so that the manual can be used as a reference for custom os development. That mapping is described now.

The middle column is what matters for custom kernel development. You can see that the "I/O Peripherals" are mapped to the address 0x20000000. Section (1.2.3 ARM physical addresses) states that the perihperals are mapped to the address range 0x20000000 to 0x20FFFFFF.

Also in [this](https://www.youtube.com/watch?v=U9H7TmRt64A&list=PLRwVmtr-pp05PQDzfuOOo-eRskwHsONY0&index=4) video, Steve Halladay mentions that the base address 0x2000000 has something to do with the processor mode which I do not fully understand yet.

As the UARTs are I/0 peripherals, the UART PIN Addresses are somewhere above the 0x20000000 address. The 0x20000000 is called the PERIPHERAL_BASE in the following.

The peripheral manual states:

> Physical addresses range from 0x20000000 to 0x20FFFFFF for peripherals. The bus addresses for peripherals are set up to map onto the peripheral bus address range starting at 0x7E000000. Thus a peripheral advertised here at bus address 0x7Ennnnnn is available at physical address 0x20nnnnnn.

This means that if a peripheral address is given in terms of the right column for the linux virtual address space, take the lower six nibbles and use them as an offset to the physical address PERIPHERAL_BASE (0x20000000) to figure out which address to use during bare metal os development.

## GPIO Controller/Registers

Individual peripherals do have an address of the shape 0x20nnnnnn that means 6 nibbles per peripheral in the physical address space.

The general purpose I/O pins (GPIO) are a specific type of peripherals. The GPIO pins are managed by the GPIO controller. The controller is controlled by memory mapping. Memory mapping means, the controller's registers are available under physical addresses and it is sufficient to just write data to those addresses using assembler to operate the GPIO controller.

GPIO is described in section "6 General Purpose I/O (GPIO)". Specifically the table "6.1 Register View" lists all registers and uses the Linux virtual address space for the memory mapped addresses. As an example, lets map one Linux virtual address to a physical address. The first register GPFSEL0 is located at 0x7E200000. That means (0x7Ennnnnn -> 0x20nnnnnn) it is available at 0x20200000 in the physical address space.

The offset 0x00200000 is the offset to the GPIO controllers registers and is called GPIO_BASE in the following!

Why is the GPIO controller even important for UART? Because the UART controller is located at an offset from the GPIO_BASE adress.

## UART registers

The UART0 addresses are called UART0_BASE and they are at an offset of 0x1000 from the GPIO_BASE

```
// The base address for UART.
UART0_BASE = (GPIO_BASE + 0x1000), // for raspi4 0xFE201000, raspi2 & 3 0x3F201000, and 0x20201000 for raspi1
```

## Code organization

As an example [JSandler18](https://jsandler18.github.io/tutorial/boot.html) organizes all the addresses in a single enum which is outlined here. The code should now make sense to you. Note that for the Raspberry Pi 1 replace 0x3F200000 by 0x20200000!

```
enum
{
    // The GPIO registers base address.
    // for raspi2 & 3, 0x20200000 for raspi1
    GPIO_BASE = 0x3F200000,

    GPPUD = (GPIO_BASE + 0x94),
    GPPUDCLK0 = (GPIO_BASE + 0x98),

    // The base address for UART.
    UART0_BASE = GPIO_BASE + 0x1000,

    UART0_DR     = (UART0_BASE + 0x00),
    UART0_RSRECR = (UART0_BASE + 0x04),
    UART0_FR     = (UART0_BASE + 0x18),
    UART0_ILPR   = (UART0_BASE + 0x20),
    UART0_IBRD   = (UART0_BASE + 0x24),
    UART0_FBRD   = (UART0_BASE + 0x28),
    UART0_LCRH   = (UART0_BASE + 0x2C),
    UART0_CR     = (UART0_BASE + 0x30),
    UART0_IFLS   = (UART0_BASE + 0x34),
    UART0_IMSC   = (UART0_BASE + 0x38),
    UART0_RIS    = (UART0_BASE + 0x3C),
    UART0_MIS    = (UART0_BASE + 0x40),
    UART0_ICR    = (UART0_BASE + 0x44),
    UART0_DMACR  = (UART0_BASE + 0x48),
    UART0_ITCR   = (UART0_BASE + 0x80),
    UART0_ITIP   = (UART0_BASE + 0x84),
    UART0_ITOP   = (UART0_BASE + 0x88),
    UART0_TDR    = (UART0_BASE + 0x8C),
};
```

Another way to do it is taken from the [OS Dev wiki](https://wiki.osdev.org/Raspberry_Pi_Bare_Bones): (MMIO stands for Memory Mapped IO)

With this solution, there is a switch inside the enum, which I think will not compile in C! I do not understand why teh os dev wiki contains that code! I removed it with a single MMIO_BASE entry into the enum. Please adjust that enum to match the Raspberry Pi board version you are using.

```
enum
{
    //// The MMIO area base address.
    //switch (raspi) {
    //    case 2:
    //    case 3:  MMIO_BASE = 0x3F000000; break; // for raspi2 & 3
    //    case 4:  MMIO_BASE = 0xFE000000; break; // for raspi4
    //    default: MMIO_BASE = 0x20000000; break; // for raspi1, raspi zero etc.
    //}

    // for raspi1, raspi zero etc.
    MMIO_BASE = 0x20000000,

    // The offsets for reach register.
    GPIO_BASE = (MMIO_BASE + 0x200000),

    // Controls actuation of pull up/down to ALL GPIO pins.
    GPPUD = (GPIO_BASE + 0x94),

    // Controls actuation of pull up/down for specific GPIO pin.
    GPPUDCLK0 = (GPIO_BASE + 0x98),

    // The base address for UART.
    UART0_BASE = (GPIO_BASE + 0x1000),

    // The offsets for reach register for the UART.
    UART0_DR     = (UART0_BASE + 0x00),
    UART0_RSRECR = (UART0_BASE + 0x04),
    UART0_FR     = (UART0_BASE + 0x18),
    UART0_ILPR   = (UART0_BASE + 0x20),
    UART0_IBRD   = (UART0_BASE + 0x24),
    UART0_FBRD   = (UART0_BASE + 0x28),
    UART0_LCRH   = (UART0_BASE + 0x2C),
    UART0_CR     = (UART0_BASE + 0x30),
    UART0_IFLS   = (UART0_BASE + 0x34),
    UART0_IMSC   = (UART0_BASE + 0x38),
    UART0_RIS    = (UART0_BASE + 0x3C),
    UART0_MIS    = (UART0_BASE + 0x40),
    UART0_ICR    = (UART0_BASE + 0x44),
    UART0_DMACR  = (UART0_BASE + 0x48),
    UART0_ITCR   = (UART0_BASE + 0x80),
    UART0_ITIP   = (UART0_BASE + 0x84),
    UART0_ITOP   = (UART0_BASE + 0x88),
    UART0_TDR    = (UART0_BASE + 0x8C),

    // The offsets for Mailbox registers
    MBOX_BASE    = (MMIO_BASE + 0xB880),
    MBOX_READ    = (MBOX_BASE + 0x00),
    MBOX_STATUS  = (MBOX_BASE + 0x18),
    MBOX_WRITE   = (MBOX_BASE + 0x20)
};
```

## Initializing UART

The steps required to get anything out of the UART hardware are:

- disable UART0 so it can be configured
- Set up the GPIO pins because the pins are use to connect the UART0 hardware over the GPIO pins to the terminal software via a cable.
- disable all interrupts
- set the UART baudrate
- mask the interrupts and turn the interrupts back on
- enable UART0 again

main.S contains an assembler application that goes through all those steps outlined above. It is taken from Steve Hallady's series on [Youtube](https://www.youtube.com/playlist?list=PLRwVmtr-pp05PQDzfuOOo-eRskwHsONY0).

## Testing with QEmu

Running for the Raspberry Pi 1 using the versatilepb machine.
If you want to know what Qemu is doing, add the -d in_asm flag.

```
qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M versatilepb -nographic -d in_asm
qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M versatilepb -display none -serial stdio
qemu-system-arm -kernel uartx01.bin -cpu arm1176 -m 256 -M versatilepb -display none -serial stdio
qemu-system-arm -kernel uartx01.bin -cpu arm1176 -m 256 -M versatilepb -nographic

qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M versatilepb -display none -serial stdio
qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M versatilepb -display none -serial stdio -serial none
```

Running for the Raspberry Pi 2 using the raspi2 machine

```
qemu-system-arm -kernel kernel.img -cpu arm1176 -m 256 -M raspi2 -nographic -d in_asm
```

To terminate qemu once it is running:

Ctrl+a x

qemu-system-arm -m 256 -M raspi2 -display none -serial mon:stdio -kernel kernel.img
