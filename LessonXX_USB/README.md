# USB

## Links

- http://www.usbmadesimple.co.uk/ums_1.htm
- https://www.amazon.de/USB-The-Universal-Serial-Bus/dp/1468151983/ref=sr_1_1?ie=UTF8&qid=1341688212&sr=8-1
- https://www.raspberrypi.org/forums/viewtopic.php?t=185990
- https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/input01.html
- https://www.cypress.com/file/134171/download
- https://www.pjrc.com/teensy/usb_debug_only.html
- https://www.pjrc.com/teensy/usb_keyboard.html
- https://www.kernel.org/doc/html/v4.12/driver-api/usb/writing_usb_driver.html
- https://de.wikipedia.org/wiki/Universal_Serial_Bus
- https://www.raspberrypi.org/forums/viewtopic.php?t=10485
- https://www.eevblog.com/forum/microcontrollers/how-do-you-write-a-usb-stack/
- https://github.com/forthnutter/USB/tree/master/doc
- https://github.com/ataradov/dgw/tree/master/embedded
- https://ultibo.org/wiki/Unit_DWCOTG
- https://github.com/ultibohub/Core/blob/master/source/rtl/ultibo/core/usb.pas

## USB Driver Source Code

- https://github.com/jncronin/rpi-boot/blob/master/dwc_usb.c
- https://github.com/rsta2/uspi
- https://github.com/rsta2/circle/tree/master/lib/usb
- https://github.com/Chadderz121/csud
- https://github.com/LdB-ECM/Raspberry-Pi/tree/master/Arm32_64_USB
- https://github.com/ataradov/dgw/tree/master/embedded

## USB Implementations On Microcontrollers

- https://www.obdev.at/products/vusb/index.html

## What is USB

The Universal Serial Bus is a way to connect external phyiscal devices to a computer systems.

- It promisses hot-plugging capabilities, that means external phyiscal devices can be connected while the operating system is running.
- USB also defines several connector plugs (USB-Type-A (the common plug found on mice and keyboards), USB-Type-B found at the Arduino, UST-Type-C found at the Raspberry Pi 4) so that a common interface is defined.
- USB is also able to transmit power to an electronic system.
- It allows to extend the amount of ports a PC has to plug in external phyiscal devices. The USB-Hubs can be plugged into a USB port and they provide even more USB ports for more devices.
- It is a fast, bi-directional, isochronous, low-cost, dynamically attachable serial interface that is consistent with the requirements of the PC platform of today and tomorrow

USB puts every device in device classes.

There are standard device classes such as HID (Humen Interface Devices) or Mass Storage Devices.

| Device Class    | Example Device              |
| --------------- | --------------------------- |
| Display         | Monitor                     |
| Communication   | Modem                       |
| Audio           | Speakers                    |
| Mass storage    | Hard drive                  |
| Human interface | Mouse, Keyboard, Data glove |

Then in addition to the predefined classes, hardware developers can define their own device classes for their custom external phyiscal devices.

The idea is that for a device class, the way to talk to all external phyiscal devices that fit the device class is defined. A driver is written not for individual external phyiscal devices but for device classes. If you have a driver for mass storage devices, your OS using the mass storage driver can talk to all mass storage devices. This also means when designing hardware, there is the possibility to design the device to fit into one of the classes that already have a driver. That way, no effort goes into driver development for all major operating systems. Also the device will work without driver installation.

## The physical structure of USB

In the following the term 'external phyiscal device' is used for a external piece of hardware that is connected via USB such as a mouse, a keyboard or a printer. The term 'device' and 'compound device' are special terms used throughout the USB specification and are defined in the following. A 'device' is not necessarily the same as a 'external phyiscal device'.

A Host (= A computer system such a PC or an embedded device) contains one or, to increase bandwith, more USB HostControllers. A USB Host Controller talks to the OS. It also contains a Root Hub.

A hub contains anywhere between 2 and 7 ports and is used to extend the USB topology. Starting from the root hub, hubs are connected to hubs and the 'external phyiscal device' plug in into hubs.

Up to 5 hubs can be connected in series and a total amount of 127 'external phyiscal device' can be plugged into the USB topology. If more hubs are needed instead of connecting them all in series just plug the hubs in at any hierarchy level to extend the topology.

A hub contains connectors. A connector is either a upstream or a downstream connector. Each hub contains exactly one upstream connector to talk to the host. Downstream connectors are used to talk to the children in the topology (= connected hubs or devices). In addition to connectors, a hub also contains internal connections to embedded devices.

A USB port is a concept that subsumes downstream connectors and internal connections inside hubs.

The terms 'device' and 'compound device' describe different things and the terms have to be distinguished!

A 'external phyiscal device' can contain one or more 'devices' and a Hub at the same time and is then called a 'compound device'.

A 'external phyiscal device' that provides a functionality to the host is called a function. A mouse, a keyboard, a printer are functions for example. Functions and hubs are subsumed under the term 'device'. When the term 'device' is used, it is either a function or a hub.

There are even more terms: 'composite device', 'interface', '(interface) descriptor', 'device descriptor' and 'port'.

## The logical structure of USB

The physical structure of USB does not matter that much to USB software.

On the software level, the tology does not matter. It does not matter through how many hubs a device has to send messages to talk to the host. Also all functions in a compound device are treated as independant entities on the software side of things. It does not matter inside which physical hardware a device lives.

On the bus, every device is identified by a unique address. The address acts as a ID.

As the name implies, USB is a bus system. As such several components are connected to the same bus.

In theory all components connected to a bus can all send at the same time and they all can receive all data on the bus at the same time. This will cause signal collisions on the bus and hence a scheme that organizes the bus communication is needed.

In USB, the bus will have exactly one USB host connected to it and a [maximum number of 127](https://de.wikipedia.org/wiki/Universal_Serial_Bus) devices. The host is installed on a motherboard in most cases. A host contains a 'Host Hub' internally. The devices are external devices connected to the bus via USB plugs / cables. The devices are connected to hubs via these plugs and cables. Hubs can be connected to hubs or devices and form a hierarchy of which the root node is the Host Hub inside the Host controller (See Figure 4-1. Bus Topology of the USB 2.0 base specification (usb_20.pdf)). In the USB Topology, devices are called functions.

The host is the only device that can send data onto the bus at will (See 4.4 Bus Protocol in USB 2.0 Spec). All other devices are not allowed to send data at will but only when the host asks them to send data. The host will poll the devices and ask them if they want to send data. It then allows those devices to send data. The devices will send their data and then keep quite again.

From the USB 2.0 Specification:

> The attached peripherals share USB bandwidth through a hostscheduled, token-based protocol. The bus allows peripherals to be attached, configured, used, and detached while the host and other peripherals are in operation.

A 'device' has 'interfaces'. Each 'interface' is described by a 'interface descriptor' that is stored inside the 'device'.

A 'composite device' (!= 'compound device') is a 'device' that contains several functions whereas the functions are use different 'interfaces' and different drivers. A 'composite device' has only a single address on the bus. For example a 'composite device' could have one interface for an audo device and another for a control panel. Each interface uses it's own driver.

A 'port' is ???.

A 'endpoint' is ???. The USB specification defines a device endpoint as “a uniquely addressable portion of a USB device that is the source or sink of information in a communication flow between the host and device.”

A endpoint is either a source or a sink for information. A USB device can have up to 16 endpoints in total.

Out of these 16 endpoints, there are 15 endpoints that are either OUT endpoints (OUT from the host perspective, that means the host sends data OUT to the device) or IN endpoints (IN from the host perspective, that means the host receives data IN from the device).

enpoint 0 is special in that it is used for commands to control the device and it is a OUT and an IN endpoint at the same time.

Another way of phrasing this is that all USB speeds (low, full and high) support one bidirectional endpoint (endpoint 0) and 15 unidirectional endpoints (endpoints 1 through 16).

An endpoint is defined by

- bus access frequency
- bandwidth requirement
- endpoint number
- error handling mechanism
- maximum packet size
- transfer type ()
- direction (IN or OUT from host perspective)

A 'endpoint descriptor' is ???. Each endpoint descriptor is a block of information that tells the host what it needs to know about the endpoint in order to communicate with it.

A 'pipe' is ???. A pipe is a connection between the host and a device's endpoint. For example a host establishes a pipe to an endpoint of enumerated devices during device enumeration. When the devices are removed, the pipe is removed too.

A pipe has a transfer type:

- Control
- Bulk
- Interrupt
- Isochronous

Control is for a host that enumerates devices or sends other control messages.

Bulk is for sending large blobs of data such as files.

Interrupt is used by keyboard and mice.

Isochronous does not perform error detection and is used for audio, video and other data streams. Besides a transfer type, a pipe is also characterized by either being a stream or a message pipe. Control transfers use bidirectional message pipes. All other transfer types use unidirectional stream pipes.

'Message Pipe': each transfer starts with a setup transaction containing a request. During the transfer the host and the device exchange data. The data is exchanged in transactions. There is at least one transaction that transfers data in both transactions.

'Stream Pipe': Data is send in both ways. The format of the data that is transferred is not defined by the USB standard.

## USB Descriptors

https://www.beyondlogic.org/usbnutshell/usb5.shtml

Every USB device maintains a hierarchical structure of descriptors that can be requested during device enumeration.

There are different types of descriptors

- Device Descriptors
- Configuration Descriptors
- Interface Descriptors
- Endpoint Descriptors
- String Descriptors
- ... (even more descriptors exist)

The device descriptor is the most basic descriptor and describes the entire device. There is exactly one device descriptor per USB device and the device descriptor has a predefined format.

A device descriptor contains information such as

- maker
- type of device
- supported USB standard
- configuration options
- number an types of endpoints
- etc.

libusb defines the device descriptor [here](http://libusb.sourceforge.net/api-1.0/structlibusb__device__descriptor.html).

[CSUD](https://github.com/Chadderz121/csud) defines the device descriptor in descriptors.h

```C
/**
	\brief The device descriptor information.

	The device descriptor sturcture defined in the USB 2.0 manual in 9.6.1.
*/
enum DeviceClass {
  DeviceClassInInterface = 0x00,
  DeviceClassCommunications = 0x2,
  DeviceClassHub = 0x9,
  DeviceClassDiagnostic = 0xdc,
  DeviceClassMiscellaneous = 0xef,
  DeviceClassVendorSpecific = 0xff,
};

struct UsbDeviceDescriptor {
	u8 DescriptorLength; // +0x0
	enum DescriptorType DescriptorType : 8; // +0x1
	u16 UsbVersion; // (in BCD 0x210 = USB2.10) +0x2
	enum DeviceClass Class : 8; // +0x4
	u8 SubClass; // +0x5
	u8 Protocol; // +0x6
	u8 MaxPacketSize0; // +0x7
	u16 VendorId; // +0x8
	u16 ProductId; // +0xa
	u16 Version; // +0xc
	u8 Manufacturer; // +0xe
	u8 Product; // +0xf
	u8 SerialNumber; // +0x10
	u8 ConfigurationCount; // +0x11
} __attribute__ ((__packed__));
```

## Reading the Specification

The USB 2.0 base specification document can be found in the [USB Document Library](https://www.usb.org/documents). Search for the term 'Specification' and in the search results, look for the term USB 2.0 Specification. It is a 12.3 Mb zip archive dated 12/21/2018. Inside that archive, there is a pdf called: usb_20.pdf.

The usb_20.pdf contains a reference to the Universal Serial Bus Device Class Specifications:

> This document is complemented and referenced by the Universal Serial Bus Device Class Specifications. Device class specifications exist for a wide variety of devices. Please contact the USB Implementers Forum for further details.

## USB on the Raspberry PI 1 Model B+

The [Peripherals Manual](https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf) describes USB in chapter 15.

The Peripherals Manuals states that the USB Core (located inside the Videocore) is manufactured by Synopsis and documented on the [Synopsis Homepage](https://www.synopsys.com/dw/ipdir.php?ds=dwc_usb_2_0_hs_otg).

The USB Core is a DesignWare Hi-Speed USB 2.0 On-The-Go (HS OTG) Controller. This also matches the letters used in the documentation link (dwc_usb_2_0_hs_otg).

Let's use the acronym DWC for [D]esign[W]are Hi-Speed USB 2.0 On-The-Go (HS OTG) [C]ontroller.

In the following the CSUD USB code is analyzed. It is a freestanding git repository containing USB code for the hardware on the raspberry PI. It is easier to understand than the code in the Linux kernel at least for a beginner that has no experience with the linux kernel.

HCD stands for host controller driver which is defined at the [CSUD git page](https://github.com/Chadderz121/csud). HCD is the name of one of the components of the CSUD software.

### Terminology

| Term | Meaning                                                                                                                                                                                                                                                                                                                                                                        |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| CSUD | A RPi USB Driver [CSUD git page](https://github.com/Chadderz121/csud)                                                                                                                                                                                                                                                                                                          |
| DWC  | [D]esign[W]are Hi-Speed USB 2.0 On-The-Go (HS OTG) [C]ontroller                                                                                                                                                                                                                                                                                                                |
| HCD  | Systemmodule inside CSUD. [H]ost [C]ontroller [D]river                                                                                                                                                                                                                                                                                                                         |
| Phy  | The part of the electronic circuit (USB, Ethernet, ...) that converts to and from the digital signals of the computer system and the signals on the physical transmission medium.                                                                                                                                                                                              |
| ULPI | The Standard for High-Speed USB PHYs [Mentor Page](https://www.mentor.com/products/ip/usb/usb20otg/phy_interfaces)                                                                                                                                                                                                                                                             |
| OTG  | USB On-The-Go is a supplement to the USB 2.0 Specification released in 2001. Users wanted to connect their peripherals together directly. To allow this, USB On-The-Go defines limited host capabilities that every device can have which allows arbitrary devices to talk over USB without requiring a full featured host in between that orchestrates the BUS communication. |

|HNP| The host negotiation protocol. Part of the USB specification. |
|SRP| Session request protocol.|
|DMA| Direct Memory Access.|

### DWC Core Registers (TDWCRegisters)

https://ultibo.org/wiki/Unit_DWCOTG

These registers are memory mapped and let software control the DWC.

Modelled in [CSUD](https://github.com/Chadderz121/csud) in enum CoreRegisters inside designware20.h.

| Register Name                         | Offset |
| ------------------------------------- | ------ |
| OTG Control Register                  | 0x0000 |
| RegOtgInterrupt                       | 0x0004 |
| AHB Configuration Register            | 0x0008 |
| Core USB Configuration Register       | 0x000c |
| Core Reset Register                   | 0x0010 |
| Core Interrupt Register               | 0x0014 |
| RegInterruptMask                      | 0x0018 |
| RegReceivePeek                        | 0x001c |
| RegReceivePop                         | 0x0020 |
| RegReceiveSize                        | 0x0024 |
| RegNonPeriodicFifoSize                | 0x0028 |
| RegNonPeriodicFifoStatus              | 0x002c |
| RegI2cControl                         | 0x0030 |
| RegPhyVendorControl                   | 0x0034 |
| RegGpio                               | 0x0038 |
| RegUserId                             | 0x003c |
| Vendor Id Register                    | 0x0040 |
| RegHardware                           | 0x0044 |
| Hardware Configuration 2              | 0x0048 |
| Hardware Configuration 3              | 0x004C |
| Hardware Configuration 4              | 0x0050 |
| ???                                   | ???    |
| (BROADCOM_2835 only) RegMdioControl   | 0x0080 |
| (BROADCOM_2835 only) RegMdioRead      | 0x0084 |
| (BROADCOM_2835 only) RegMdioWrite     | 0x0084 |
| (BROADCOM_2835 only) RegMiscControl   | 0x0088 |
| RegPeriodicFifoSize                   | 0x0100 |
| RegPeriodicFifoBase                   | 0x0104 |
| RegPower                              | 0x0e00 |
| Host Frame Interval Register          | 0x0404 |
| Host Frame Register                   | 0x0408 |
| Host Port Control and Status Register | 0x0440 |
| Channel Characteristics Register      | 0x0000 |

### Registers in CSUD

CSUD abstracts registers. Instead of reading 32 bit integers per register, some registers such as the hardware register are actually a combination of several 32 bit values. The abstraction combines the hardware register into one large C-struct.

To support the abstractions, there are special utility functions that facilitate the loading and storing of registers: See designware20.c

- WriteThroughReg()
- WriteThroughRegMask()
- ReadBackReg
- ClearReg
- SetReg

The utility functions check which register should be read and in the case of a larger register such as the hardware register, instead of reading or writing a single 32 bit value, they read the entire register.

The registers are modeled via C-structs in designware20.h by the CoreGlobalRegs structure which contains substructures for the registers. Looking at the Hardware register, this register contains more than 32 bit because there are four 32 bit registers inside the DWC describing it's hardware status.

All structus are annotated with 'packed' attribute. This tells the compiler to not performa any layouting such as padding bytes into words for faster access by the CPU but to layout the structure into memory exactly as defined by the programmer even if this causes performance loss. The reason is that the structures have to be used as overlays over the memory mapped areas that contain the hardware registers and the overlay has to match every single bit exactly. The compiler reorganizing the layout would cause the application to read the wrong bits and wrong data.

I took the liberty to add comments to add the register names and their offsets to the individual structs and to add whitespace lines to layout the code a little for better readbility.

```C
/**
	\brief Contains the core global registers structure that control the HCD.

	Contains the core global registers structure that controls the DesignWare®
	Hi-Speed USB 2.0 On-The-Go (HS OTG) Controller.
*/
extern volatile struct CoreGlobalRegs {

    // 32 bit
    // OTG Control Register (0x0000)
	volatile struct {
		volatile bool sesreqscs : 1;
		volatile bool sesreq : 1;
		volatile bool vbvalidoven : 1;
		volatile bool vbvalidovval : 1;
		volatile bool avalidoven : 1;
		volatile bool avalidovval : 1;
		volatile bool bvalidoven : 1;
		volatile bool bvalidovval : 1;
		volatile bool hstnegscs : 1;
		volatile bool hnpreq : 1;
		volatile bool HostSetHnpEnable : 1;
		volatile bool devhnpen : 1;
		volatile unsigned _reserved12_15 : 4;
		volatile bool conidsts : 1;
		volatile unsigned dbnctime : 1;
		volatile bool ASessionValid : 1;
		volatile bool BSessionValid : 1;
		volatile unsigned OtgVersion : 1;
		volatile unsigned _reserved21 : 1;
		volatile unsigned multvalidbc : 5;
		volatile bool chirpen : 1;
		volatile unsigned _reserved28_31 : 4;
	} __attribute__ ((__packed__)) OtgControl; // +0x0

    // RegOtgInterrupt (0x0004)
	volatile struct {
		volatile unsigned _reserved0_1 : 2; // @0
		volatile bool SessionEndDetected : 1; // @2
		volatile unsigned _reserved3_7 : 5; // @3
		volatile bool SessionRequestSuccessStatusChange : 1; // @8
		volatile bool HostNegotiationSuccessStatusChange : 1; // @9
		volatile unsigned _reserved10_16 : 7; // @10
		volatile bool HostNegotiationDetected : 1; // @17
		volatile bool ADeviceTimeoutChange : 1; // @18
		volatile bool DebounceDone : 1; // @19
		volatile unsigned _reserved20_31 : 12; // @20
	} __attribute__ ((__packed__)) OtgInterrupt; // +0x4

    // AHB Configuration Register (0x0008)
	volatile struct {
		volatile bool InterruptEnable : 1; // @0
#ifdef BROADCOM_2835
		// In accordance with the SoC-Peripherals manual, broadcom redefines
		// the meaning of bits 1:4 in this structure.
		volatile enum {
			Length4 = 0,
			Length3 = 1,
			Length2 = 2,
			Length1 = 3,
		} AxiBurstLength : 2; // @1
		volatile unsigned _reserved3 : 1; // @3
		volatile bool WaitForAxiWrites : 1; // @4
#else
		volatile enum {
			Single,
			Incremental,
			Incremental4 = 3,
			Incremental8 = 5,
			Incremental16 = 7,
		} DmaBurstType : 4; // @1
#endif
		volatile bool DmaEnable : 1; // @5
		volatile unsigned _reserved6 : 1; // @6
		volatile enum EmptyLevel {
			Empty = 1,
			Half = 0,
		} TransferEmptyLevel : 1; // @7
		volatile enum EmptyLevel PeriodicTransferEmptyLevel : 1; // @8
		volatile unsigned _reserved9_20 : 12; // @9
		volatile bool remmemsupp:1; // @21
		volatile bool notialldmawrit:1; // @22
		volatile enum {
			Incremental = 0,
			Single = 1, // (default)
		} DmaRemainderMode : 1; // @23
		volatile unsigned _reserved24_31 : 8; // @24
	} __attribute__ ((__packed__)) Ahb;	// +0x8

    // Core USB Configuration Register (0x000c)
	volatile struct {
		volatile unsigned toutcal:3; // @0
		volatile bool PhyInterface : 1; // @3
		volatile enum UMode {
			ULPI,
			UTMI,
		}  ModeSelect : 1; // @4
		volatile bool fsintf:1; // @5
		volatile bool physel:1; // @6
		volatile bool ddrsel:1; // @7
		volatile bool SrpCapable : 1; // @8
		volatile bool HnpCapable : 1; // @9
		volatile unsigned usbtrdtim:4; // @10
		volatile unsigned reserved1:1; // @14
		/* PHY lower power mode clock select */
		volatile bool phy_lpm_clk_sel:1; // @15
		volatile bool otgutmifssel:1; // @16
		volatile bool UlpiFsls : 1; // @17
		volatile bool ulpi_auto_res:1; // @18
		volatile bool ulpi_clk_sus_m:1; // @19
		volatile bool UlpiDriveExternalVbus : 1; // @20
		volatile bool ulpi_int_vbus_indicator:1; // @21
		volatile bool TsDlinePulseEnable : 1; // @22
		volatile bool indicator_complement:1; // @23
		volatile bool indicator_pass_through:1; // @24
		volatile bool ulpi_int_prot_dis:1; // @25
		volatile bool ic_usb_capable:1; // @26
		volatile bool ic_traffic_pull_remove:1; // @27
		volatile bool tx_end_delay:1; // @28
		volatile bool force_host_mode:1; // @29
		volatile bool force_dev_mode:1; // @30
		volatile unsigned _reserved31:1; // @31
	} __attribute__ ((__packed__)) Usb; // +0xc

    // Core Reset Register (0x0010)
	volatile struct CoreReset {
		volatile bool CoreSoft : 1; // @0
		volatile bool HclkSoft : 1; // @1
		volatile bool HostFrameCounter : 1; // @2
		volatile bool InTokenQueueFlush : 1; // @3
		volatile bool ReceiveFifoFlush : 1; // @4
		volatile bool TransmitFifoFlush : 1; // @5
		volatile enum CoreFifoFlush {
			FlushNonPeriodic = 0,
			FlushPeriodic1 = 1,
			FlushPeriodic2 = 2,
			FlushPeriodic3 = 3,
			FlushPeriodic4 = 4,
			FlushPeriodic5 = 5,
			FlushPeriodic6 = 6,
			FlushPeriodic7 = 7,
			FlushPeriodic8 = 8,
			FlushPeriodic9 = 9,
			FlushPeriodic10 = 10,
			FlushPeriodic11 = 11,
			FlushPeriodic12 = 12,
			FlushPeriodic13 = 13,
			FlushPeriodic14 = 14,
			FlushPeriodic15 = 15,
			FlushAll = 16,
		} TransmitFifoFlushNumber : 5; // @6
		volatile unsigned _reserved11_29 : 19; // @11
		volatile bool DmaRequestSignal : 1; // @30
		volatile bool AhbMasterIdle : 1; // @31
	} __attribute__ ((__packed__)) Reset;  // +0x10

    //
	volatile struct CoreInterrupts Interrupt; // +0x14

	volatile struct CoreInterrupts InterruptMask; // +0x18

    // RegReceivePeek (0x001c)
	volatile struct {
		volatile struct ReceiveStatus {
			volatile unsigned ChannelNumber : 4; // @0
			volatile unsigned bcnt : 11; // @4
			volatile unsigned dpid : 2; // @15
			volatile enum {
				InPacket = 2,
				InTransferComplete = 3,
				DataToggleError = 5,
				ChannelHalted = 7,
			} PacketStatus : 4; // @17
			volatile unsigned _reserved21_31 : 11; // @21
		} __attribute__ ((__packed__)) Peek; // Read Only +0x1c
		volatile const struct ReceiveStatus Pop; // Read Only +0x20
		volatile u32 Size; // +0x24
	} __attribute__ ((__packed__)) Receive; // +0x1c

	volatile struct {
		volatile struct FifoSize {
			volatile unsigned StartAddress : 16; // @0
			volatile unsigned Depth : 16; // @16
		} __attribute__ ((__packed__)) Size; // +0x28
		volatile const struct {
			volatile unsigned SpaceAvailable : 16; // @0
			volatile unsigned QueueSpaceAvailable : 8; // @16
			volatile unsigned Terminate : 1; // @24
			volatile enum {
				InOut = 0,
				ZeroLengthOut = 1,
				PingCompleteSplit = 2,
				ChannelHalt = 3,
			} TokenType : 2; // @25
			volatile unsigned Channel : 4; // @27
			volatile unsigned Odd : 1; // @31
		} __attribute__ ((__packed__)) Status; // Read Only +0x2c
	} __attribute__ ((__packed__)) NonPeriodicFifo; // +0x28

	volatile struct {
		unsigned ReadWriteData : 8; // @0
		unsigned RegisterAddress : 8; // @8
		unsigned Address : 7; // @16
		bool I2cEnable : 1; // @23
		bool Acknowledge : 1; // @24
		bool I2cSuspendControl : 1; // @25
		unsigned I2cDeviceAddress : 2; // @26
		unsigned _reserved28_29 : 2; // @28
		bool ReadWrite : 1; // @30
		bool bsydne : 1; // @31
	} __attribute__ ((__packed__)) I2cControl; // +0x30

	volatile u32 PhyVendorControl; // +0x34

	volatile u32 Gpio; // +0x38

    // (RegUserId) 0x003c
	volatile u32 UserId; // +0x3c

	volatile const u32 VendorId; // Read Only +0x40

    // RegHardware (0x0044) + Hardware Configuration 2, 3 and 4 (0x0048, 0x004C, 0x0050 respectively)
	volatile const struct {

        // RegHardware (0x0044)
		volatile const unsigned Direction0 : 2; // @0, 2
		volatile const unsigned Direction1 : 2; // @2, 4
		volatile const unsigned Direction2 : 2; // @4, 6
		volatile const unsigned Direction3 : 2; // @6, 8
		volatile const unsigned Direction4 : 2; // @8, 10
		volatile const unsigned Direction5 : 2; // @10, 12
		volatile const unsigned Direction6 : 2; // @12, 14
		volatile const unsigned Direction7 : 2; // @14, 16
		volatile const unsigned Direction8 : 2; // @16, 18
		volatile const unsigned Direction9 : 2; // @18, 20
		volatile const unsigned Direction10 : 2; // @20, 22
		volatile const unsigned Direction11 : 2; // @22, 24
		volatile const unsigned Direction12 : 2; // @24, 26
		volatile const unsigned Direction13 : 2; // @26, 28
		volatile const unsigned Direction14 : 2; // @28, 30
		volatile const unsigned Direction15 : 2; // @30, 32

        // Hardware Configuration 2 (0x0048)
		volatile const enum {
			HNP_SRP_CAPABLE,
			SRP_ONLY_CAPABLE,
			NO_HNP_SRP_CAPABLE,
			SRP_CAPABLE_DEVICE,
			NO_SRP_CAPABLE_DEVICE,
			SRP_CAPABLE_HOST,
			NO_SRP_CAPABLE_HOST,
		} OperatingMode : 3; // @32
		volatile const enum {
			SlaveOnly,
			ExternalDma,
			InternalDma,
		} Architecture : 2; // @35
		bool PointToPoint : 1; // @37
		volatile const enum {
			NotSupported,
			Utmi,
			Ulpi,
			UtmiUlpi,
		} HighSpeedPhysical : 2; // @38
		volatile const enum {
			Physical0,
			Dedicated,
			Physical2,
			Physcial3,
		} FullSpeedPhysical : 2; // @40
		volatile const unsigned DeviceEndPointCount : 4; // @42
		volatile const unsigned HostChannelCount : 4; // @46
		volatile const bool SupportsPeriodicEndpoints : 1; // @50
		volatile const bool DynamicFifo : 1; // @51
		volatile const bool multi_proc_int : 1; // @52
		volatile const unsigned _reserver21 : 1; // @53
		volatile const unsigned NonPeriodicQueueDepth : 2; // @54
		volatile const unsigned HostPeriodicQueueDepth : 2; // @56
		volatile const unsigned DeviceTokenQueueDepth : 5; // @58
		volatile const bool EnableIcUsb : 1; // @63

        // Hardware Configuration 3 (0x004C)
		volatile const unsigned TransferSizeControlWidth : 4; // @64
		volatile const unsigned PacketSizeControlWidth : 3; // @68
		volatile const bool otg_func : 1; // @71
		volatile const bool I2c : 1; // @72
		volatile const bool VendorControlInterface : 1; // @73
		volatile const bool OptionalFeatures : 1; // @74
		volatile const bool SynchronousResetType : 1; // @75
		volatile const bool AdpSupport : 1; // @76
		volatile const bool otg_enable_hsic : 1; // @77
		volatile const bool bc_support : 1; // @78
		volatile const bool LowPowerModeEnabled : 1; // @79
		volatile const unsigned FifoDepth : 16;  // @80

        // Hardware Configuration 4 (0x0050)
		volatile const unsigned PeriodicInEndpointCount : 4; // @96
		volatile const bool PowerOptimisation : 1; // @100
		volatile const bool MinimumAhbFrequency : 1; // @101
		volatile const bool PartialPowerOff : 1; // @102
		volatile const unsigned _reserved103_109 : 7;  // @103
		volatile const enum {
			Width8bit,
			Width16bit,
			Width8or16bit,
		} UtmiPhysicalDataWidth : 2; // @110
		volatile const unsigned ModeControlEndpointCount : 4; // @112
		volatile const bool ValidFilterIddigEnabled : 1; // @116
		volatile const bool VbusValidFilterEnabled : 1; // @117
		volatile const bool ValidFilterAEnabled : 1; // @118
		volatile const bool ValidFilterBEnabled : 1; // @119
		volatile const bool SessionEndFilterEnabled : 1; // @120
		volatile const bool ded_fifo_en : 1; // @121
		volatile const unsigned InEndpointCount : 4; // @122
		volatile const bool DmaDescription : 1; // @126
		volatile const bool DmaDynamicDescription : 1; // @127

	} __attribute__ ((__packed__)) Hardware; // All read only +0x44

	volatile struct {
		volatile bool LowPowerModeCapable : 1; // @0
		volatile bool ApplicationResponse : 1; // @1
		volatile unsigned HostInitiatedResumeDuration : 4; // @2
		volatile bool RemoteWakeupEnabled : 1; // @6
		volatile bool UtmiSleepEnabled : 1; // @7
		volatile unsigned HostInitiatedResumeDurationThreshold : 5; // @8
		volatile unsigned LowPowerModeResponse : 2; // @13
		volatile bool PortSleepStatus : 1;  // @15
		volatile bool SleepStateResumeOk : 1; // @16
		volatile unsigned LowPowerModeChannelIndex : 4; // @17
		volatile unsigned RetryCount : 3; // @21
		volatile bool SendLowPowerMode : 1; // @24
		volatile unsigned RetryCountStatus : 3; // @25
		volatile unsigned _reserved28_29 : 2; // @28
		volatile bool HsicConnect : 1; // @30
		volatile bool InverseSelectHsic : 1; // @31
	} __attribute__ ((__packed__)) LowPowerModeConfiguration; // +0x54
	volatile const u8 _reserved58_80[0x80 - 0x58]; // No read or write +0x58
#ifdef BROADCOM_2835
	volatile struct {
		volatile const unsigned Read : 16; // Read Only @0
		volatile unsigned ClockRatio : 4; // @16
		volatile bool FreeRun : 1; // @20
		volatile bool BithashEnable : 1; // @21
		volatile bool MdcWrite : 1; // @22
		volatile bool MdoWrite : 1; // @23
		volatile unsigned _reserved24_30 : 7; // @24
		volatile const bool Busy : 1; // @31
	} __attribute__ ((__packed__)) MdioControl; // +0x80
	volatile union {
		volatile const u32 MdioRead; // Read Only +0x84
		volatile u32 MdioWrite; // +0x84
	};
	volatile struct {
		volatile bool SessionEnd : 1; // @0
		volatile bool VbusValid : 1; // @1
		volatile bool BSessionValid : 1; // @2
		volatile bool ASessionValid : 1; // @3
		volatile const bool DischargeVbus : 1; // Read Only @4
		volatile const bool ChargeVbus : 1; // Read Only @5
		volatile const bool DriveVbus : 1; // Read Only @6
		volatile bool DisableDriving : 1; // @7
		volatile bool VbusIrqEnabled : 1; // @8
		volatile const bool VbusIrq : 1; // Cleared on Read! @9
		volatile unsigned _reserved10_15 : 6; // @10
		volatile unsigned AxiPriorityLevel : 4; // @16
		volatile unsigned _reserved20_31 : 12; // @20
	} __attribute__ ((__packed__)) MiscControl; // +0x88
#else
	volatile u32 _reserved80_8c[3]; // +0x80
#endif
	volatile u8 _reserved8c_100[0x100-0x8c]; // +0x8c
	volatile struct {
		volatile struct FifoSize HostSize; // +0x100
		volatile struct FifoSize DataSize[15]; // +0x104
	} __attribute__ ((__packed__)) PeriodicFifo; // +0x100
	volatile u8 _reserved140_400[0x400-0x140]; // +0x140
} __attribute__ ((__packed__)) *CorePhysical, *Core;
```

## Initializing USB on the Raspberry Pi 1 Model B+

First the DWC is initialized (HcdInitialise()).

Compare UsbInitialise() in [CSUD](https://github.com/Chadderz121/csud) code.

### Reading the vendor ID

Compare: https://github.com/jncronin/rpi-boot/blob/master/dwc_usb.c
Also compare HcdInitialise() in [CSUD](https://github.com/Chadderz121/csud) code.

The vendor id register (0x0040) is read from the DWC. The read value has to match 0x4F54280A which is the vendor code of Synopsis, the manufacturer of the DWC. If the code does not match, abort.

```C
#define SYNOPSYS_ID	0x4f54280a

uint32_t vendor = mmio_read(base + 0x0040);

if(vendor != SYNOPSYS_ID)
{
    printf("DWC_USB: invalid vendor id %08x\n", vendor);
    return -1;
}
```

### Reading the user id / GUID

Compare: https://github.com/jncronin/rpi-boot/blob/master/dwc_usb.c

The GUID is read from the user id register (0x003c) of the DWC. The read value has to match 0x2708A000. I do not know, where the specific value 0x2708A000 comes from. If the code does not match, abort.

```C
#define DWD_GUID 0x2708A000

uint32_t userid = mmio_read(base + 0x003c);

if (userid != USER_ID)
{
    printf("DWC_USB: invalid user id / GUID %08x\n", userid);
    return -1;
}
```

### Reading hardware capabilities. Check for Internal DMA mode and HighSpeedPhysical.

Compare HcdInitialise() in [CSUD](https://github.com/Chadderz121/csud) code.
Compare https://ultibo.org/wiki/Unit_DWCOTG

The Hardware Configuration 2 register (0x0048) contains a 2 bit value which can be interpreted as an enum:

```C
volatile const enum {
    SlaveOnly,
    ExternalDma,
    InternalDma,
} Architecture : 2;
```

The driver checks for the 'InternalDma' value and if the value is not there, aborts.

Why exactly is that done? I do not know!

The Hardware Configuration 2 register (0x0048) contains a 2 bit value that can be interpreted as an enum:

```C
volatile const enum {
    NotSupported,
    Utmi,
    Ulpi,
    UtmiUlpi,
} HighSpeedPhysical : 2;
```

The driver checks that the value is anything but 'NotSupported'. If the value is 'NotSupported', the driver aborts.

Why exactly is that done? I do not know!

### Disable all interrupts

Compare https://github.com/jncronin/rpi-boot/blob/master/dwc_usb.c
Compare HcdInitialise() in [CSUD](https://github.com/Chadderz121/csud) code.

```C
LOG_DEBUG("HCD: Disabling interrupts.\n");
ReadBackReg(&Core->Ahb);
Core->Ahb.InterruptEnable = false;
ClearReg(&Core->InterruptMask);
WriteThroughReg(&Core->InterruptMask);
WriteThroughReg(&Core->Ahb);
```

### Power USB On

Compare https://github.com/jncronin/rpi-boot/blob/master/dwc_usb.c
Compare HcdInitialise() in [CSUD](https://github.com/Chadderz121/csud) code.

```C
// Power on the USB via the mailbox interface (undocumented - from csud)
mbox_write(0, 0x80);
if(mbox_read(0) != 0x80)
{
    printf("DWC_USB: unable to power up USB\n");
    return -1;
}
```

or

```C
LOG_DEBUG("HCD: Powering USB on.\n");
if ((result = PowerOnUsb()) != OK) {
    LOG("HCD: Failed to power on USB Host Controller.\n");
    result = ErrorIncompatible;
    goto deallocate;
}
```

## Starting USB on the Raspberry Pi 1 Model B+

After initialization comes starting.

Compare UsbInitialise() in [CSUD](https://github.com/Chadderz121/csud) code.

### Change the USB Configuration Register (0x000c)

Compare HcdStart() in [CSUD](https://github.com/Chadderz121/csud) code.

The USB Configuration Register is read, modified and written.

```C
ReadBackReg(&Core->Usb);
Core->Usb.UlpiDriveExternalVbus = 0;
Core->Usb.TsDlinePulseEnable = 0;
WriteThroughReg(&Core->Usb);
```

### Perform a Master Reset

Compare HcdStart() in [CSUD](https://github.com/Chadderz121/csud) code.

```C
LOG_DEBUG("HCD: Master reset.\n");
if ((result = HcdReset()) != OK) {
    goto deallocate;
}
```

### Configure the USB Phy

Compare HcdStart() in [CSUD](https://github.com/Chadderz121/csud) code.

Phy = The part of the electronic circuit (USB, Ethernet, ...) that converts to and from the digital signals of the computer system and the signals on the physical transmission medium.

When you search the internet for PHY USB, you will find chips by Cadence, Microchip and other manufacturers that you can use to add USB support to your system.

The CSUD code sets the mode to UTMI and then calls HcdReset().

```C
Core->Usb.ModeSelect = UTMI;
LOG_DEBUG("HCD: Interface: UTMI+.\n");
Core->Usb.PhyInterface = false;

WriteThroughReg(&Core->Usb);
HcdReset();
```

### Configure ULPI

ULPI is a standard for high-speed USB PHYs

```C
ReadBackReg(&Core->Usb);
if (Core->Hardware.HighSpeedPhysical == Ulpi
    && Core->Hardware.FullSpeedPhysical == Dedicated) {
    LOG_DEBUG("HCD: ULPI FSLS configuration: enabled.\n");
    Core->Usb.UlpiFsls = true;
    Core->Usb.ulpi_clk_sus_m = true;
} else {
    LOG_DEBUG("HCD: ULPI FSLS configuration: disabled.\n");
    Core->Usb.UlpiFsls = false;
    Core->Usb.ulpi_clk_sus_m = false;
}
WriteThroughReg(&Core->Usb);
```

### Enable DMA

```C
LOG_DEBUG("HCD: DMA configuration: enabled.\n");
ReadBackReg(&Core->Ahb);
Core->Ahb.DmaEnable = true;
Core->Ahb.DmaRemainderMode = Incremental;
WriteThroughReg(&Core->Ahb);
```

### Set Capabilities based on Operating Mode

The capabilities are HNP (host negotiation protocol) and SRP (session request protocol). Based on the operating mode, the flags are set.

```C
ReadBackReg(&Core->Usb);
switch (Core->Hardware.OperatingMode) {
case HNP_SRP_CAPABLE:
    LOG_DEBUG("HCD: HNP/SRP configuration: HNP, SRP.\n");
    Core->Usb.HnpCapable = true;
    Core->Usb.SrpCapable = true;
    break;
case SRP_ONLY_CAPABLE:
case SRP_CAPABLE_DEVICE:
case SRP_CAPABLE_HOST:
    LOG_DEBUG("HCD: HNP/SRP configuration: SRP.\n");
    Core->Usb.HnpCapable = false;
    Core->Usb.SrpCapable = true;
    break;
case NO_HNP_SRP_CAPABLE:
case NO_SRP_CAPABLE_DEVICE:
case NO_SRP_CAPABLE_HOST:
    LOG_DEBUG("HCD: HNP/SRP configuration: none.\n");
    Core->Usb.HnpCapable = false;
    Core->Usb.SrpCapable = false;
    break;
}
WriteThroughReg(&Core->Usb);
```

### Clear the Power Register

???

```C
ClearReg(Power);
WriteThroughReg(Power);
```

### Set the clock rote in the UBS host

???

```C
ReadBackReg(&Host->Config);
if (Core->Hardware.HighSpeedPhysical == Ulpi
    && Core->Hardware.FullSpeedPhysical == Dedicated
    && Core->Usb.UlpiFsls) {
    LOG_DEBUG("HCD: Host clock: 48Mhz.\n");
    Host->Config.ClockRate = Clock48MHz;
} else {
    LOG_DEBUG("HCD: Host clock: 30-60Mhz.\n");
    Host->Config.ClockRate = Clock30_60MHz;
}
WriteThroughReg(&Host->Config);
```

### Set FslsOnly

???

```C
ReadBackReg(&Host->Config);
Host->Config.FslsOnly = true;
WriteThroughReg(&Host->Config);
```

### Set FIFO sizes

```C
LOG_DEBUGF("HCD: FIFO configuration: Total=%#x Rx=%#x NPTx=%#x PTx=%#x.\n", ReceiveFifoSize + NonPeriodicFifoSize + PeriodicFifoSize, ReceiveFifoSize, NonPeriodicFifoSize, PeriodicFifoSize);
ReadBackReg(&Core->Receive.Size);
Core->Receive.Size = ReceiveFifoSize;
WriteThroughReg(&Core->Receive.Size);

ReadBackReg(&Core->NonPeriodicFifo.Size);
Core->NonPeriodicFifo.Size.Depth = NonPeriodicFifoSize;
Core->NonPeriodicFifo.Size.StartAddress = ReceiveFifoSize;
WriteThroughReg(&Core->NonPeriodicFifo.Size);

ReadBackReg(&Core->PeriodicFifo.HostSize);
Core->PeriodicFifo.HostSize.Depth = PeriodicFifoSize;
Core->PeriodicFifo.HostSize.StartAddress = ReceiveFifoSize + NonPeriodicFifoSize;
WriteThroughReg(&Core->PeriodicFifo.HostSize);
```

### Enable HNP (host negotiation protocol)

```C
LOG_DEBUG("HCD: Set HNP: enabled.\n");
ReadBackReg(&Core->OtgControl);
Core->OtgControl.HostSetHnpEnable = true;
WriteThroughReg(&Core->OtgControl);
```

### Flush FIFOs

Flush Receive and Transmit FIFO.

```C
if ((result = HcdTransmitFifoFlush(FlushAll)) != OK)
    goto deallocate;
if ((result = HcdReceiveFifoFlush()) != OK)
    goto deallocate;
```

### Start Channels (in a known state)

```C
if (!Host->Config.EnableDmaDescriptor) {
    for (u32 channel = 0; channel < Core->Hardware.HostChannelCount; channel++) {
        ReadBackReg(&Host->Channel[channel].Characteristic);
        Host->Channel[channel].Characteristic.Enable = false;
        Host->Channel[channel].Characteristic.Disable = true;
        Host->Channel[channel].Characteristic.EndPointDirection = In;
        WriteThroughReg(&Host->Channel[channel].Characteristic);
        timeout = 0;
    }

    // Halt channels to put them into known state.
    for (u32 channel = 0; channel < Core->Hardware.HostChannelCount; channel++) {
        ReadBackReg(&Host->Channel[channel].Characteristic);
        Host->Channel[channel].Characteristic.Enable = true;
        Host->Channel[channel].Characteristic.Disable = true;
        Host->Channel[channel].Characteristic.EndPointDirection = In;
        WriteThroughReg(&Host->Channel[channel].Characteristic);
        timeout = 0;
        do {
            ReadBackReg(&Host->Channel[channel].Characteristic);

            if (timeout++ > 0x100000) {
                LOGF("HCD: Unable to clear halt on channel %u.\n", channel);
            }
        } while (Host->Channel[channel].Characteristic.Enable);
    }
}
```

### Power and Reset Port

```C
ReadBackReg(&Host->Port);
if (!Host->Port.Power) {
    LOG_DEBUG("HCD: Powering up port.\n");
    Host->Port.Power = true;
    WriteThroughRegMask(&Host->Port, 0x1000);
}

LOG_DEBUG("HCD: Reset port.\n");
ReadBackReg(&Host->Port);
Host->Port.Reset = true;
WriteThroughRegMask(&Host->Port, 0x100);
MicroDelay(50000);
Host->Port.Reset = false;
WriteThroughRegMask(&Host->Port, 0x100);
ReadBackReg(&Host->Port);
```

## Read Devices on the BUS

The USB Root Hub inside the USB Controller is always at index 0 inside the devices array:

```C
struct UsbDevice *UsbGetRootHub() { return Devices[0]; }
```

Also see usbd.c UsbGetDescription()

```C
const char* UsbGetDescription(struct UsbDevice *device) {
	if (device->Status == Attached)
		return "New Device (Not Ready)\0";
	else if (device->Status == Powered)
		return "Unknown Device (Not Ready)\0";
	else if (device == Devices[0])
		return "USB Root Hub\0";
```

This section describes what is happening inside UsbAttachRootHub()

- UsbInitialise() - usbd.c:51
  - HcdInitialise()
  - HcdStart()
  - UsbAttachRootHub() - usbd.c:681
    - UsbDeallocateDevice() - usbd.c
    - UsbAllocateDevice() - usbd.c
    - UsbAttachDevice() - usbd.c:537 - The comment says the method recurses, but I am not sure if it really does!
      - UsbSetAddress() - usbd.c:286
      - UsbReadDeviceDescriptor() - usbd.c:256
        - UsbGetDescriptor() - usbd.c:140 <---- Creates the parameters UsbPipeAddress and UsbDeviceRequest
          - UsbControlMessage() - usbd.c:95
            - HcdSumbitControlMessage() - designware20.c:511 <---- typo sumbit should be submit
              - HcdProcessRootHubMessage() - roothub.c:135
      - UsbConfigure.c:353
  - HcdStop()
  - HcdDeinitialise()

It looks like as if the root hub inside the USB host controller is not really queried, when asked for it's device descriptor. Instead the driver defines a device descriptor in roothub.c as a variable called 'DeviceDescriptor'. When a the device descriptor is requested from the roothub in UsbAttachDevice(), the driver will just MemCopy data from the variable into the request buffer (see roothub.c HcdProcessRootHubMessage() switch-case GetDescriptor, 0x80 is exclusively implemented via MemCopy)

## Log of driver output

I modified the driver to print logging messages to UART. The the build of the [input01](https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/input01.html) was modified to not use the precompiled version of the CSUD driver library but the custom compiled version that contains the additional log statements.

Also for log messages to appear on UART, the [input01](https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/input01.html) example was modified.
For that, a uart.s file was added to the input01 example and in uart.s the function LogPrint() is implement and it makes use of the writeCharacter() function to output a string of a predefined length to UART. The CSUD driver calls LogPrint() for logging but it does not provied an implementation. The host operating system hast to provide an implementation of LogPrint(). The linker will combine the driver and the operating system and the call is made to the correct LogPrint() function implementation.

The code is horrible but I am a beginner with assembly so have mercy:

```ASM
/* Check if another character can be written and if the fifo is empty, write the character */
/* The character to output is stored in r2 */
.globl writeCharacter
writeCharacter:
    push { r0, r1, r2, r3 }

    /* r0 is GPIO base, 0x20200000 */
    mov r0, #0x20000000
    mov r1, #0x00200000
    orr r0, r0, r1

writeCharWaitLoop:
    /* r1 is UART base */
    orr r1, r0, #0x1000

    ldr r3, [r1, #0x18]
    and r3, r3, #0x20
    cmp r3, #0
    bne writeCharWaitLoop

    /*str r2, [r1, #0x0000] actually writes a character to the UART */
    str r2, [r1, #0x0000]

    pop { r0, r1, r2, r3 }

    /* return to caller. r15 is the programm counter. r14 is the link register */
    mov pc, lr





/* Writes a string of n characters to the UART */
/* */
/* r0 the address of the first character of the string to output */
/* r1 the length of the string */
/* USAGE: */
/* ldr r0, =teststring */
/* mov r1, #0x05 */
/* bl LogPrint */
.globl LogPrint
LogPrint:
    push { r0, r1, r2, r3, r9, r10, r11 }

loopLogPrint:
    /* Load the first value of R0 into R2 and skip */
    /* ahead one character(8 bits) */
    /* */
    /* Note the "B" in LDR. It indicates that you load ONLY 1 byte! */
    ldrb r2, [r0], #1

    /* as soon as the loop counter is zero, return from the function */
    cmp r1, #0x00
    beq returnFromLogPrint

    /* nested function call, save link register */
    mov r9, r0
    mov r10, r1
    mov r11, lr

    /* call write character */
    bl writeCharacter

    /* nested function call, restore link register */
    mov lr, r11
    mov r1, r10
    mov r0, r9

    /* decrement r1 */
    sub r1, #0x01

    b loopLogPrint

returnFromLogPrint:
    pop { r0, r1, r2, r3, r9, r10, r11 }
    /* return to caller. r15 is the programm counter. r14 is the link register */
    mov pc, lr
```

What you cannot see is that the driver constantly calls UsbControlMessage() to poll the keyboard state.
I removed the log message from UsbControlMessage() because it spams the serial console.

Here is the annotated output:

```
UsbInitialise() ...
.UsbLoad() ...
.UsbLoad(): CSUD: USB driver version 0.1
.HubLoad() ...
.HcdInitialise() ...
.HCD: Hardware: OT2.80a (BCM2708a).
.HcdStart() ...
.HcdReset() ...
.HcdReset() ...
.UsbAttachRootHub() ...
.UsbAllocateDevice() ...
.UsbAttachDevice() ... <-------- Call to UsbAttachDevice()
.USBD: Scanning 1. 480 Mb/s.
.UsbReadDeviceDescriptor() ...
.UsbGetDescriptor() ...
.UsbSetAddress() ...
.UsbReadDeviceDescriptor() ...
.UsbGetDescriptor() ...
.UsbGetDescription() ...
.USBD: Device Attached: USB Root Hub.
.UsbReadString() ...
.UsbReadStringLang() ...
.UsbGetString() ...
.UsbGetDescriptor() ...
.UsbGetString() ...
.UsbGetDescriptor() ...
.UsbReadStringLang() ...
.UsbGetString() ...
.UsbGetDescriptor() ...
.UsbGetString() ...
.UsbGetDescriptor() ...
.USBD:  -Product:       USB 2.0 Root Hub.
.UsbConfigure() ...
.UsbGetDescriptor() ...
.UsbGetDescriptor() ...
.UsbSetConfiguration() ...
.UsbAttachDevice() Calling InterfaceClassAttach[] array method ... <------- call to a configurable handler for specific devices such as hubs
.HubAttach() ... <------- specific method HubAttach() is called
.HubReadDescriptor() ...
.UsbGetDescriptor() ...
.UsbGetDescriptor() ...
.HUB: Hub power: Global.
.HUB: Hub nature: Standalone.
.HUB: Hub over current protection: Global.
.HUB: Hub power to good: 0ms.
.HUB: Hub current required: 0mA.
.HUB: Hub ports: 1.
.HUB: Hub port 1 is removable.
.HubGetStatus() ...
.USB Hub power: Good.
.USB Hub over current condition: No.
.HUB: Hub powering on.
.HubPowerOn() ...
.HubChangePortFeature() ...
.HubGetStatus() ...
.USB Hub power: Good.
.USB Hub over current condition: No.
.UsbGetDescription() ...
.HUB: USB Root Hub status 0:0.
.HubCheckConnection() ...
.HubPortGetStatus() ...
.HubPortConnectionChanged() ... <-------- HubPortConnectionChanged() calls the method UsbAttachDevice(). This is the recursion!
.HubPortGetStatus() ...
.UsbGetDescription() ...
.HUB: USB Root Hub.Port1 Status 101:11.
.HubChangePortFeature() ...
.HubPortReset() ...
.HubChangePortFeature() ...
.HubPortGetStatus() ...
.HubChangePortFeature() ...
.UsbAllocateDevice() ...
.HubPortGetStatus() ...
.UsbGetDescription() ...
.HUB: USB Root Hub.Port1 Status 503:12.
.UsbAttachDevice() ... <-------- Call to UsbAttachDevice() either for the plugged in keyboard or the USB LAN controller
.USBD: Scanning 2. 480 Mb/s.
.UsbReadDeviceDescriptor() ...
.UsbGetDescriptor() ...
.HubChildReset() ...
.HubPortReset() ...
.HubChangePortFeature() ...
.HubPortGetStatus() ...
.HubChangePortFeature() ...
.UsbSetAddress() ...
.UsbReadDeviceDescriptor() ...
.UsbGetDescriptor() ...
.UsbGetDescription() ...
.USBD: Device Attached: USB 2.0 Hub.
.UsbConfigure() ...
.UsbGetDescriptor() ...
.UsbGetDescriptor() ...
.UsbSetConfiguration() ...
.UsbAttachDevice() Calling InterfaceClassAttach[] array method ...
.HubAttach() ...
.HubReadDescriptor() ...
.UsbGetDescriptor() ...
.UsbGetDescriptor() ...
.HUB: Hub power: Individual.
.HUB: Hub nature: Compound.
.HUB: Hub over current protection: Individual.
.HUB: Hub power to good: 100ms.
.HUB: Hub current required: 2mA.
.HUB: Hub ports: 3.
.HUB: Hub port 1 is not removable.
.HUB: Hub port 2 is removable.
.HUB: Hub port 3 is removable.
.HubGetStatus() ...
.USB Hub power: Good.
.USB Hub over current condition: No.
.HUB: Hub powering on.
.HubPowerOn() ...
.HubChangePortFeature() ...
.HubChangePortFeature() ...
.HubChangePortFeature() ...
.HubGetStatus() ...
.USB Hub power: Good.
.USB Hub over current condition: No.
.UsbGetDescription() ...
.HUB: USB 2.0 Hub status 0:0.
.HubCheckConnection() ...
.HubPortGetStatus() ...
.HubPortConnectionChanged() ... <-------- HubPortConnectionChanged() calls the method UsbAllocateDevice(). This is the recursion!
.HubPortGetStatus() ...
.UsbGetDescription() ...
.HUB: USB 2.0 Hub.Port1 Status 101:1.
.HubChangePortFeature() ...
.HubPortReset() ...
.HubChangePortFeature() ...
.HubPortGetStatus() ...
.HubChangePortFeature() ...
.UsbAllocateDevice() ... <-------- Call to UsbAllocateDevice() either for the plugged in keyboard or the USB LAN controller
.HubPortGetStatus() ...
.UsbGetDescription() ...
.HUB: USB 2.0 Hub.Port1 Status 503:0.
.UsbAttachDevice() ...
.USBD: Scanning 3. 480 Mb/s.
.UsbReadDeviceDescriptor() ...
.UsbGetDescriptor() ...
.HubChildReset() ...
.HubPortReset() ...
.HubChangePortFeature() ...
.HubPortGetStatus() ...
.HubChangePortFeature() ...
.UsbSetAddress() ...
.UsbReadDeviceDescriptor() ...
.UsbGetDescriptor() ...
.UsbGetDescription() ...
.USBD: Device Attached: SMSC LAN9512.
.UsbConfigure() ...
.UsbGetDescriptor() ...
.UsbGetDescriptor() ...
.UsbSetConfiguration() ...
.HubChangePortFeature() ...
.HubCheckConnection() ...
.HubPortGetStatus() ...
.HubPortConnectionChanged() ...
.HubPortGetStatus() ...
.UsbGetDescription() ...
.HUB: USB 2.0 Hub.Port2 Status 301:1.
.HubChangePortFeature() ...
.HubPortReset() ...
.HubChangePortFeature() ...
.HubPortGetStatus() ...
.HubChangePortFeature() ...
.UsbAllocateDevice() ...
.HubPortGetStatus() ...
.UsbGetDescription() ...
.HUB: USB 2.0 Hub.Port2 Status 303:0.
.UsbAttachDevice() ...
.USBD: Scanning 4. 1.5 Mb/s.
.UsbReadDeviceDescriptor() ...
.UsbGetDescriptor() ...
.HubChildReset() ...
.HubPortReset() ...
.HubChangePortFeature() ...
.HubPortGetStatus() ...
.HubChangePortFeature() ...
.UsbSetAddress() ...
.UsbReadDeviceDescriptor() ...
.UsbGetDescriptor() ...
.UsbGetDescription() ...
.USBD: Device Attached: Unconfigured Device.
.UsbReadString() ...
.UsbReadStringLang() ...
.UsbGetString() ...
.UsbGetDescriptor() ...
.UsbGetString() ...
.UsbGetDescriptor() ...
.UsbReadStringLang() ...
.UsbGetString() ...
.UsbGetDescriptor() ...
.UsbGetString() ...
.UsbGetDescriptor() ...
.USBD:  -Product:       USB Keyboard.
.UsbConfigure() ...
.UsbGetDescriptor() ...
.UsbGetDescriptor() ...
.UsbSetConfiguration() ...
.UsbAttachDevice() Calling InterfaceClassAttach[] array method ...
.UsbGetDescriptor() ...
.HubChangePortFeature() ...
.HubCheckConnection() ...
.HubPortGetStatus() ...
.HubChangePortFeature() ...
.HubChangePortFeature() ...
.UsbCheckForChange() ...
.HubCheckForChange() ...
.HubCheckConnection() ...
.HubPortGetStatus() ...
.HubChangePortFeature() ...
.HubCheckForChange() ...
.HubCheckConnection() ...
.HubPortGetStatus() ...
.HubCheckConnection() ...
.HubPortGetStatus() ...
.HubCheckConnection() ...
.HubPortGetStatus() ...
```

## Device enumeration

When the host powers up, it iterates the hubs recursively and sends information to the hubs, asking them for all connected 'external physical devices'. The hubs answer. The host then asks the devices for their descriptors.

After the initial power up, the host receives an event for each added or removed device. The host then asks that device for it's descriptors.

The recursion for device enumeration over all hubs in CSUD works as follows:

The user of CSUD has to call the UsbInitialise() method at some point to set up the driver. This is part of the API.

UsbInitialise() does some preparation and eventually call UsbAttachRootHub().

UsbAttachRootHub() calls UsbAttachDevice() for the root hub inside the USB controller.

UsbAttachDevice() retrieves the interfaces of a device and the classes on the interfaces. It then performs a lookup for a configurable
function pointer for a specific device class. In the case of the root hub, the lookup returns a method that can attach USB hubs.

That method is called HubAttach(), it is implemented in hub.c and it is then invoked.

HubAttach() has a loop at the very end that iterates over all ports of the hub and tries to detect a connected device or hub on that port by calling HubCheckConnection()

```C
for (u8 port = 0; port < data->MaxChildren; port++) {
	HubCheckConnection(device, port);
}
```

HubCheckConnection() calls HubPortConnectionChanged().

HubPortConnectionChanged() calls UsbAllocateDevice() and UsbAttachDevice().

This call to UsbAttachDevice() causes the recusion during device enumeration.

From UsbAttachDevice() the recursion can detect functions such as keyboards, mice, USB network controllers or it can detect Hubs that in turn
are connected to more functions or hubs. This is how the recursion detects an entire tree and all functions within that tree through recursion.

## CSUD Platform functions

For the driver to work, four functions have to be provided by the operating system / the platform.

Those four functions are mentioned in the readme.txt of CSUD.

```
The mapping between standard methods and platform.c's version is as follows:
malloc	<-> MemoryAllocate
free	<-> MemoryDeallocate
memcpy	<-> MemoryCopy
print	<-> LogPrint
```

The listing th in readme.txt shows that the four libc functions, malloc, free, memcpy and print are wrapped in functions that CSUD will call. This makes the CSUD driver portable to every operating system.

### malloc, MemoryAllocte

The purpose of malloc() is to provide dynamically allocated memory to a process. In contemporary operating systems, when the MMU is used, memory is organized in pages or sections. Those pages or sections are very large. If a process needs 8 byte for example, wasting an entire page for one variable is not feasable. Instead a heap data structure is placed on top of pages and sections. The heap intially grabs a page and manages memory within that page. When the heap outgrows the page, it requests another page and keeps growing. When memory is returned, the heap shrinks and also returns pages to the MMU in the process.

The heap is basically a fine grained memory allocation mechanism and is built on top of the coarse grained memory mechanism of paging.

If no paging is used, if the MMU is not turned on yet, the heap will just organize memory in physical address space.

The reference implementation for MemoryAllocate for the Raspberry PI in CSUD is contained in platform.c. A variable called Heap is defined that points to an array of 0x4000 bytes.

```C
u8 Heap[0x4000] __attribute__((aligned(8))); // Support a maximum of 16KiB of allocations
```

A HeapAllocation structure is defined:

```C
struct HeapAllocation {
	u32 Length;
	void* Address;
	struct HeapAllocation *Next;
};
```

The HeapAllocation structure allows to create a single linked list where each element stores the address and length of a heap memory allocated block of memory.

An array of 0x100 HeapAllocate elements is defined:

```C
struct HeapAllocation Allocations[0x100]; // Support 256 allocations
```

The array is where the list will takes it's elements from. The length of the list is limited to 0x100 elements in length. The end of the list is defined by a pointer to the address 0xFFFFFFFF. A preprocessor directive is defined to denote that end address:

```C
#define HEAP_END ((void*)0xFFFFFFFF)
```

A variable called 'allocated' is defined to store the current size of the heap. It is used to tell if there are bytes left or if an allocation exceeds the space that is left on the heap in which case a call to MemoryAllocte() will fail. The process calling has to be prepared to handle that outcome. Instead of the memory address of the allocated variable, the function will just return NULL in that case.

First MemoryReserve() is called to reserve memory for the entire heap and the list of allocations. MemoryReserve() is an empty function that merely returns the identity mapped memory location. If your operating system employs virtual memory via the MMU, you can map in pages or sections of memory here and return the virtual address insted of a identity mapped physical address. On top of that virtual memory page or section the heap manages memory in a more fine graned manner.

When memory is allocated, the algorithm tries to squeeze in a HeapAllocate element to fit the required amount of bytes.

There are two cases, either all elements in the list are used and an element has to be added to the end of the list which is possible only if there is enough space on the heap. In this case an element is added to the least and the HEAP_END pointer is moved back to the end after the new element.

The HEAP_END element is always moved to the end of the list as long as the heap has enough space left to house more requested bytes.

The other case is that the list contains a hole, i.e. an unused element, which happens when memory is returned by the process by a call to MemoryDeallocate(). When the list is iterated on the search for a element that has space and an unused element is encountered that is large enough to serve the requested amounts of bytes, that element is reused instead of adding a new element to the end of the list.

### free, MemoryDeallocate

MemoryDeallocate() is given an address of reserved memory. It will iterate the list and find the element that manages the allocation. The element contains the size of allocated memory, that is why the address alone is enough to return all memory.

MemoryDeallocate() will remove the HeapAllocation element from the list and decrease the value of the 'allocated' variable by the amount of returned bytes so that the heap knows it's new size.

### memcpy, MemoryCopy

loops over the amounts of bytes specified in the length parameter and copies the source byte to the destination bytes. Source and destination are addresses specified as parameters.

The method is very straight-forwared. Usually copying individual bytes is very slow compared to buffered transfers where blocks of memory are copied. This method could probably be optimised.
