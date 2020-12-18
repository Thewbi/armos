# Ethernet and TCP IP

## Links

- https://www.pebblebay.com/raspberry-pi-embedded/
- https://www.mouser.de/datasheet/2/268/evb9512user-468043.pdf
- http://ww1.microchip.com/downloads/en/DeviceDoc/9513db.pdf
- https://www.microchip.com/wwwproducts/en/LAN9514
- https://www.raspberrypi.org/forums/viewtopic.php?t=180024

## Example Code

- https://github.com/rsta2/uspi/tree/master/sample/ethernet

## Strategy

First get to the point where you are able to list all devices connected to the USB bus.
There should be a device called LAN9512.

Then, read this [post](https://www.raspberrypi.org/forums/viewtopic.php?t=180024) in which the user LdB posted code from the Xinu OS that shoes how to send data and receive data to and from the LAN9512 device. The idea is to wrap ethernet packets into USB messages and let the chip take care of the transmission over the ethernet physical layer.

To send ethernet packets over USB, you need to be able to construct those ethernet packets, so that is another open task.

Implement arping as one of the most basic things that can be done with ethernet.

## Hardware

From [pebblebay](https://www.pebblebay.com/raspberry-pi-embedded/):

> The network interface is provided by a SMSC LAN9512 Ethernet controller (it is a SMSC LAN9514 on the Model B+), which is connected to the USB host interface. To use the network interface a lot of additional software (and effort) is required:
>
> - A USB host controller driver for the Synopsys DesignWare USB 2.0 OTG
>   controller embedded in the processor
> - A USB host stack with USB networking infrastructure
> - A device driver for LAN9512/4 Ethernet controller

## USB

All raspberry pi have a single USB 2.0 Bus. (see [here](https://www.raspberrypi.org/forums/viewtopic.php?t=180024))

The SMSC LAN9512 will appear as a USB Hub on that USB Bus to any connected USB host.

When enumerating the devices on the USB bus, the SMSC LAN9512 will show up as a device called LAN9512.
