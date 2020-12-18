# libusb

To get insight into USB programming, this section makes use of lib usb to illustrate the basic USB concepts. Once the basics of USB are understood from a software developers standpoint, implementing a USB stack should be easier.

## What does libusb do?

https://unix.stackexchange.com/questions/109406/how-does-libusb-access-kernel-stuff

Lib usb is a user-space library that allows user-space applications to talk to USB devices. Instead of installing a kernel driver (kernel-space), libusb talks to endpoints exposed by the operating system to user space applications. From these endpoints it interprets transferred byte buffers and applies USB knowledge.

A user-space application can register callbacks with libusb and libusb will provide datatypes for descriptors and other USB structures to the callback. The user-space application can also send USB packets to the devices.

## Building lib usb on mac from source

### Getting the source:

```sh
# retrieve development branch (this only needs to be done once)
git clone git://github.com/libusb/libusb.git
cd libusb

# for further updates, once the clone has been done
git pull
```

### Building the source

Create a configure script and a makefile via autogen.sh

```sh
./autogen.sh
```

Run configure

```sh
./configure --enable-examples-build
```

Run make

```sh
make clean
make
```

Install

```sh
sudo make install
```

Output of install is

```sh
Making install in libusb
 .././install-sh -c -d '/usr/local/lib'
 /bin/sh ../libtool   --mode=install /usr/bin/install -c   libusb-1.0.la '/usr/local/lib'
libtool: install: /usr/bin/install -c .libs/libusb-1.0.0.dylib /usr/local/lib/libusb-1.0.0.dylib
libtool: install: (cd /usr/local/lib && { ln -s -f libusb-1.0.0.dylib libusb-1.0.dylib || { rm -f libusb-1.0.dylib && ln -s libusb-1.0.0.dylib libusb-1.0.dylib; }; })
libtool: install: /usr/bin/install -c .libs/libusb-1.0.lai /usr/local/lib/libusb-1.0.la
libtool: install: /usr/bin/install -c .libs/libusb-1.0.a /usr/local/lib/libusb-1.0.a
libtool: install: chmod 644 /usr/local/lib/libusb-1.0.a
libtool: install: ranlib /usr/local/lib/libusb-1.0.a
 .././install-sh -c -d '/usr/local/include/libusb-1.0'
 /usr/bin/install -c -m 644 libusb.h '/usr/local/include/libusb-1.0'
make[2]: Nothing to be done for `install-exec-am'.
 ./install-sh -c -d '/usr/local/lib/pkgconfig'
 /usr/bin/install -c -m 644 libusb-1.0.pc '/usr/local/lib/pkgconfig'
```

## Compile an example

The examples are built in the libsub/examples folder. (e.g. xusb)

???

https://stackoverflow.com/questions/20416827/linking-libusb-in-mac-os-x

Examples are here: https://github.com/libusb/libusb/tree/master/examples

These compile commands do not work on my system:

```sh
gcc -I /usr/local/include -lusb-1.0 -o xusb xusb.c

gcc -I /usr/local/lib/include -lusb-1.0 -o xusb xusb.c
gcc -I /usr/local/lib -lusb-1.0 -o xusb xusb.c
gcc -I /usr/local/include/libusb-1.0 -l/usr/local/lib/libusb-1.0 -o xusb xusb.c
gcc -I /usr/local/include/libusb-1.0 -l/usr/local/lib/libusb-1.0.a -o xusb xusb.c
gcc -I /usr/local/include/libusb-1.0 -l/usr/local/lib/libusb-1.0.0 -o xusb xusb.c
gcc -I /usr/local/include/libusb-1.0 -l/usr/local/lib/libusb -o xusb xusb.c

gcc -I /usr/local/include/libusb-1.0 -l/Users/bischowg/dev/usb/libusb/libusb/usb-1.0 -o xusb xusb.c
gcc -I /usr/local/include/libusb-1.0 -l/Users/bischowg/dev/usb/libusb/libusb/usb-1.0.a -o xusb xusb.c

gcc -I /Users/bischowg/dev/usb/libusb/libusb -l/Users/bischowg/dev/usb/libusb/libusb/usb-1.0 -o xusb xusb.c
gcc -I /Users/bischowg/dev/usb/libusb/libusb -o xusb xusb.c

/Users/bischowg/dev/usb/libusb/libusb
```

## run listdevs example

```sh
cd examples
./listdevs
```

## Source Code Analysis

The basic usage of libusb in the examples is:

```C
int main(void)
{
	libusb_device **devs;
	int r;
	ssize_t cnt;

	r = libusb_init(NULL);
	if (r < 0) {
		return r;
    }

	cnt = libusb_get_device_list(NULL, &devs);
	if (cnt < 0) {
		libusb_exit(NULL);
		return (int) cnt;
	}

	// custom code here

	libusb_free_device_list(devs, 1);

	libusb_exit(NULL);

	return 0;
}
```

libusb is initialized. The device list is retrieved. The device list is freed, libuse_exit() is called.

### libusb_init() - core.c:2257

Initialize libusb. This function must be called before calling any other libusb function.

### libusb_get_device_descriptor() - descriptor.c

just returns the device_descriptor pointer from the libusb_device.

### struct libusb_device_descriptor - libusb.h:528

### libusb_device - libusbi.h:452

```C
struct libusb_device {
/* lock protects refcnt, everything else is finalized at initialization
 time */
usbi_mutex_t lock;
int refcnt;

    struct libusb_context *ctx;
    struct libusb_device *parent_dev;

    uint8_t bus_number;
    uint8_t port_number;
    uint8_t device_address;
    enum libusb_speed speed;

    struct list_head list;
    unsigned long session_data;

    struct libusb_device_descriptor device_descriptor;
    int attached;

};
```

### darwin_scan_devices() - darwin_usb.c:1170

IOIteratorNext() is a function from Apple's IOKit library.

USBDeviceOpenSeize() is a function from Apple's IOKit library.

DeviceRequestTO()
https://developer.apple.com/documentation/iokit/iousbdeviceinterface182/1559217-devicerequestto
Sends a USB request on the default control pipe.

IOServiceGetMatchingServices() is a function from Apple's IOKit library.
https://developer.apple.com/documentation/iokit/1514494-ioservicegetmatchingservices?language=occ
Look up registered IOService objects that match a matching dictionary.

CFDictionaryCreateMutable is a function from Apple's CoreFoundation library.
https://developer.apple.com/documentation/corefoundation/1516791-cfdictionarycreatemutable?language=occ
Creates a new mutable dictionary.

CFRelease is a function from Apple's CoreFoundation library.
https://developer.apple.com/documentation/corefoundation/1521153-cfrelease?language=occ
Releases a Core Foundation object.

IOCreatePlugInInterfaceForService
https://developer.apple.com/documentation/iokit/1412429-iocreateplugininterfaceforservic?language=occ

### darwin_cache_device_descriptor() - darwin_usb.c:815

### darwin_request_descriptor() - darwin_usb.c:795

- darwin_init - darwin_usb.c:574
  - list_init
  - darwin_scan_devices - darwin_usb.c:1170
    - usb_setup_device_iterator - darwin_usb.c:215 - I think this method actually asks the operating system for all connected usb devices
      - IOServiceGetMatchingServices - Apple IOKit, asks the OS for devices
    - darwin_get_cached_device - darwin_usb.c:982
      - list_for_each_entry
      - darwin_device_from_service
      - darwin_cache_device_descriptor - darwin_usb.c:815 <----
        - darwin_request_descriptor
          - DeviceRequestTO

```C
static inline void list_init(struct list_head *entry)
{
	entry->prev = entry->next = entry;
}
```

### usb_device_t

usb_device_t is a define to OS X platform dependant structures.
The defines are contained in darwin_usb.h:100
