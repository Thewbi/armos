# Ethernet and TCP IP

## Links

- https://www.pebblebay.com/raspberry-pi-embedded/
- https://www.mouser.de/datasheet/2/268/evb9512user-468043.pdf
- http://ww1.microchip.com/downloads/en/DeviceDoc/9513db.pdf
- https://www.microchip.com/wwwproducts/en/LAN9514
- https://www.raspberrypi.org/forums/viewtopic.php?t=180024
- https://embedded-xinu.readthedocs.io/en/latest/arm/rpi/SMSC-LAN9512.html

## Example Code

- https://github.com/rsta2/uspi/tree/master/sample/ethernet
- https://github.com/xinu-os/xinu/tree/master/device/smsc9512
- https://elixir.bootlin.com/linux/v4.3/source/drivers/net/usb/smsc95xx.c

## Building csud

```
apt-get install gcc-arm-none-eabi
make driver CONFIG=FINAL TYPE=LOWLEVEL TARGET=RPI GNU=arm-none-eabi-
```

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

From [www.elektronikpraxis.vogel.de](https://www.elektronikpraxis.vogel.de/alle-raspberry-pi-modelle-im-ueberblick-a-484985/?p=5)

> Ärgerlich ist jedoch der Flaschenhals in puncto Datentransfer, der sich daraus ergibt, dass bei den Raspberry-Pi-Modellen mit zwei USB-Buchsen der I/O-Chip SMSC LAN9512 von Microchip (SMSC wurde 2012 von Microchip übernommen) und bei Modellen mit vier USB-Buchsen der I/O-Chip SMSC LAN9514 zum Einsatz kommt.

Translated:

> It is aggravating that there is a bottleneck when it comes to data transfer which stems from the fact the raspberry pi models equipped with two USB ports are using Microchip's SMSC LAN9512 I/O chip a ... and the models equipped with four USB ports are using Microchip's SMSC LAN9514.

## USB

All raspberry pi have a single USB 2.0 Bus. (see [here](https://www.raspberrypi.org/forums/viewtopic.php?t=180024))

The SMSC LAN9512 or LAN9514 will appear as a USB Hub on that USB Bus to any connected USB host.

When enumerating the devices on the USB bus, the SMSC LAN9512 will show up as a device called LAN9512.
When enumerating the devices on the USB bus, the SMSC LAN9514 will show up as a device called LAN9514.

According to https://www.the-sz.com/products/usbid/:

It's vendor ID is: 0x0424
Microchip Technology, Inc. (formerly SMSC)
www.smc.com

It's product ID is: 0xEC00
Microchip Technology, Inc. (formerly SMSC)
SMSC9512/9514 Fast Ethernet Adapter

## Embedded Xinu Driver

Read this [PDF document](https://core.ac.uk/download/pdf/46725298.pdf) by the original author of the XINU USB Ethernet Driver for the SMSC9521 first.

The [Embedded Xinu driver for the SMSC LAN9512](https://embedded-xinu.readthedocs.io/en/latest/arm/rpi/SMSC-LAN9512.html) was created by reading the code of the Linux driver for the SMSC LAN9512 that Microchip/SMSC contributed to the Linux kernel. There is apparently no official documentation for that driver.

The git repository is: https://github.com/xinu-os/xinu

The driver for the SMSC LAN9512 is here: https://github.com/xinu-os/xinu/tree/master/device/smsc9512

The registers of the SMSC LAN9512 are not memory mapped. The reason is that the SMSC LAN9512 is a device connected to the USB system. Registers are read and written via USB control transfers (see: https://github.com/xinu-os/xinu/blob/master/device/smsc9512/etherInit.c)

This [forum entry](https://www.raspberrypi.org/forums/viewtopic.php?t=180024)\*\* states that the SMSC LAN9512 USB device has two USB bulk endpoints. One in endpoint and one out endpoint. The Bulk IN endpoint will receive ethernet frames. Those ethernet frames are prefixed with a four byte header that contains status flags.

To send an ethernet frame, that frame has to be prefixed with an eight byte header and is then send over the OUT bulk endpoint.

\*\* When reading the forum thread, please be wary. At some point the user neuberfran hijacks the thread and the thread gets all nonsensical from there. Also the thread that neuberfran refers to contains no real usable information.

## Usage of the Embedded XINU SMSC9512 driver

### etherInit() in etherInit.c, smsc9512_bind_device() in etherInit.c and etherOpen() in etherOpen.c

Embedded xinu contains a xinu.conf file that controls which functions are called for to initial what hardware. etherInit() from the SMSC9512 driver is configured in xinu.conf. As USB devices can come and go at any point because of the hot-plugging capabilities of the USB standard, the etherInit() method might be called at a point in time where the USB device has not been detected yet! This can happen although the SMSC9512 is a non removable chip connected via traces on the PCB. When etherInit() returns an OK return value, there is still no guarantee that the USB device is actually detected by the system yet.

Because the USB might no be connected when etherInit() is called, the initialization is split across etherInit() and smsc9512_bind_device(). smsc9512_bind_device() will perform initialization as soon as the SMSC9512 USB device is actually connected. It will set the MAC address, enable multiple ethernet frames per USB transfer and it will do Embedded Xinu housekeeping.

To set the MAC address and to enable multiple ethernet frames per USB transfer, smsc9512_bind_device() sends USB commands to the default endpoint 0 on the USB device. The commands are used to write values into registers. USB commands have to be used because the SMSC9512 is not memory mapped but connected via USB.

etherOpen() is called when the USB actually is enabled after all prerequisit initialization happened succesfully. etherOpen() for the SMSC9512 driver is a blocking call that only returns once the USB device is connected to the BUS. It enables Rx and Tx which starts frame reception and transfer. Before enabling RX and TX, bulk transfer is configured and buffers are allocated.

I could not find the place in the code that calls etherOpen(). More Embedded Xinu knowledge is required.

### etherRead() and etherWrite()

Embedded Xinu has a common interface for ethernet drivers. That interface enforces two methods etherRead() and etherWrite() to read and write ethernet frames respectively. The SMSC9512 driver therefore also contains etherRead.c and etherWrite.c.

### etherRead.c

In the background the driver uses smsc9512_rx_complete() which puts received data into a circular buffer and signals the reception of data. At that point, the data sits in the buffer and waits for retrieval by etherRead().

```C
devcall etherRead(device *devptr, void *buf, uint len)
```

Calling etherRead(), the user has to provide a buffer and the length of that buffer. etherRead() will then put retrieved data into the buffer. No more then len bytes are ever retrieved.

etherRead() merely checks the signal and retrieves the data from the circular buffer and memcopies the data into the user specified buffer.

## Initialization in Xinu

Where is the Mac Address set?
Where is the USB address set?
Where are the descriptors (device descriptor) read for finding the endpoints and interfaces of the device?
How are USB transactions handled? (dwc_channel_start_transaction())

Embedded XINU defines a structure for device drivers. For the SMSC LAN9512 this structure is created in etherInit.c

```C
/**
 * Specification of a USB device driver for the SMSC LAN9512.  This is
 * specifically for the USB core and is not related to Xinu's primary device and
 * driver model, which is static.
 */
static const struct usb_device_driver smsc9512_driver = {
    .name          = "SMSC LAN9512 USB Ethernet Adapter Driver",
    .bind_device   = smsc9512_bind_device,
    .unbind_device = smsc9512_unbind_device,
};
```

You can see that the methods for bind and unbind are function pointers to the functions smsc9512_bind_device() and smsc9512_unbind_device().

The driver calls the function pointers in usb_try_to_bind_device_driver in usbcore.c:828.

- etherOpen() - etherOpen.c:26

  - smsc9512_set_mac_address() - smsc9512.c:143 <!----- MAC Address is set here

- smsc9512_bind_device() - etherInit.c:33
  - smsc9512_set_mac_address() - smsc9512.c:143 <!----- MAC Address is set here

Comment in smsc9512_bind_device():

> The rest of this function is responsible for making the SMSC LAN9512 ready to use, but not actually enabling Rx and Tx (which is done in etherOpen()).

This primarily involves writing to the registers on the SMSC LAN9512 by sending USB messages to the device.

# Sending Bulk Data

As opposed to USB command messages to the default endpoint 0, sending data over the SMSC 9512 requires the use of bulk transfer. The bulk transfer starts at the DWC (DesignWare Hi-Speed USB 2.0 OTG Controller) and as a target has the USB address of the SMSC 9512 ethernet controller.

For bulk transfers, the DWC maintains so called channels. A channel is specific to the DWC hardware, it is nothing you will find in the USB specification.

The DWC has a certain amount of channels available (up to 16 host channels, I think (cref. https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/arria-10/a10_54018.pdf). In the Embedded Xinu Code only 8 channels are defined (see usb_dwc_regs.h, #define DWC_NUM_CHANNELS 8)) and to send data, one of those channels has to be programmed to the endpoint to send data to and with the correct carracteristics that describe the type of data transfer.

Once a channel is programmed, an arbitrary amount of transactions or packets can be sent over that channel until it is reprogrammed to support another characteristic or targets another endpoint on another USB device. Several channels can transfer data at the same time, that means the DWC supports several USB transfers in parallel.

Channels are described in the source code of the Embedded Xinu code (usb_dwc_regs.h):

```C
/**
* 0x500 : Array of host channels.  Each host channel can be used to
* execute an independent USB transfer or transaction simultaneously.
*
* A USB transfer may consist of multiple transactions, or packets.
*
* To avoid
* having to re-program the channel, it may be useful to use one channel for
* all transactions of a transfer before allowing other transfers to be
* scheduled on it.
*/
```

The embedded xinu code in usb_dwc_hcd.c contains the dwc_channel_start_xfer() function.

```C
/**
 * Starts or restarts a USB transfer on a channel of the DesignWare Hi-Speed USB
 * 2.0 OTG Controller.
 *
 * To do this, software must give the parameters of a series of low-level
 * transactions on the USB to the DWC by writing to various registers.
 *
 * Detailed
 * documentation about the registers used here can be found in the declaration
 * of dwc_regs::dwc_host_channel.
 *
 * @param chan
 *      Index of the host channel to start the transfer on.
 * @param req
 *      USB transfer to start.
 */
static void dwc_channel_start_xfer(uint chan, struct usb_xfer_request \*req)
```

dwc_channel_start_xfer() has the index of the channel to use and a usb_xfer_request as parameters.

The usb_xfer_request structure describes the characteristics of the requested transfer, amongst other things if the type of transfer is a USB control- or a USB bulk-transfer.

Depending on the requested type of transfer, dwc_channel_start_xfer() will reprogramm the channel indicated by the channel index to suit the requested transfer characteristics.

dwc_channel_start_xfer() manipulates several structures:

- a usb_xfer_request req struct given as parameter (contains information about the requested type of transfer (command, bulk, isochronous, ...)). The usb_xfer_request variable is also used to perform bookkeeping about the transfer. It maintains how many packets have been transferred succesfully, how many bytes remain, how many packets remain.
- a dwc_host_channel_characteristics characteristics union created as a local variable (information about the endpoint, packets and frames to send)
- a dwc_host_channel_transfer transfer union created as a local variable (transfer size, packet id and amount of packets to send)
- a struct dwc_host_channel \*chanptr struct. (this is a pointer to the structure that models a channel on the DWH. It will get the objects described above assigned to it)

For bulk transfer, it will configure the address of the USB device to talk to and the number, type and direction of the endpoint to talk to as well the amount and size of packets to send. It will also make sure that the payload data to send is word-aligned and it will store a pointer to the payload-data.

Possible endpoint types and directions are:

```C
/** Directions of USB transfers (defined relative to the host) */
enum usb_direction {
    USB_DIRECTION_OUT = 0,  /* Host to device */
    USB_DIRECTION_IN = 1    /* Device to host */
};

enum usb_transfer_type {
    USB_TRANSFER_TYPE_CONTROL     = 0,
    USB_TRANSFER_TYPE_ISOCHRONOUS = 1,
    USB_TRANSFER_TYPE_BULK        = 2,
    USB_TRANSFER_TYPE_INTERRUPT   = 3,
};
```

When dwc_channel_start_xfer() is done and the chanptr was used to set data into the dwc_host_channel struct, dwc_channel_start_xfer() finally calls dwc_channel_start_transaction():

```C
/**
 * Starts a low-level transaction on the USB.
 *
 * @param chan
 *      Index of the host channel to start the transaction on.
 * @param req
 *      USB request set up for the next transaction
 */
static void
dwc_channel_start_transaction(uint chan, struct usb_xfer_request *req)
```

The API is the same as for the dwc_channel_start_xfer() function.

dwc_channel_start_transaction() has the index of the channel to use and a usb_xfer_request as parameters.

### Channel Pointers

How does the driver interact with the channels of the DWC (DesignWare Hi-Speed USB 2.0 OTG Controller)?

The DWC has it's registers memory mapped as described in the Raspberry Pi's Peripheral Manual.

The channels are available as an array inside that memory mapped area.

The usage pattern (example calls, non-sensical calls) in the Embedded Xinu driver is:

```C
volatile struct dwc_host_channel *chanptr = &regs->host_channels[chan];

/* Clear pending interrupts.  */
chanptr->interrupt_mask.val = 0;
chanptr->interrupts.val = 0xffffffff;

...

chanptr->split_control = split_control;

...

chanptr->characteristics = characteristics;

...

chanptr->interrupt_mask = interrupt_mask;
```

Given an index into the array of channels, a pointer to a specific channel is retrieved from the memory mapped areas and the memory is modified which affects the registers and therefore the operation of the DWC and it's channels immediately.
