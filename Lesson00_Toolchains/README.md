# Toolchains

In this section, it is assumed that you have a Ubuntu linux to your avail. If you are on Windows, MAC or even on a native Ubuntu, you can use Docker to run a Ubuntu on your Computer as described [here](../doc/Environment/README.md)

A toolchain is a set of tools that converts your sourcecode into an executable. A toolchain also contains diagnostic and debugging tools.

For our purposes, royalty free toolchains are required because this course has to be available to everyone even when on a tight budget.

The gnu toolchain is available in 64 bit and in 32 bit. If the OS should run on a 64 bit CPU, the use of a toolchain that is able to output 64 bit binaries is mandatory. A 32 bit toolchain will not ever be able to create a 64 bit binary. If the CPU is a 32 bit CPU, then it cannot run 64 bit binaries and a 32 bit toolchain must be used.

The first Raspberry Pi that has a 64 bit processor is the "RPi 2 Model B v1.2" as can be seen [here](https://en.wikipedia.org/wiki/Raspberry_Pi). Look for the checkmark in the 64 bit column. All prior models are 32 bit.

## 32 bit Toolchain - Precompiled via APT

Before going through the process or compiling the ARM 32 bit toolchain manually, first try if the APT Package Manager provides a precomiled package.

```
apt-get update
apt-cache search gcc-arm-none-eabi
```

```
apt-get install gcc-arm-none-eabi
```

## 32 bit Toolchain - Compiling the gcc-arm-none-eabi Source Code

ARM itself provides the source code for an 32 bit ARM toolchain based on open source gcc tools. They do not provide the source code for a 64 bit toolchain.

The [ARM gnu-toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads) contains an explanation on what the toolchain actually does.

> The GNU Arm Embedded Toolchain is a ready-to-use, open-source suite of tools for C, C++ and assembly programming. The GNU Arm Embedded Toolchain targets the 32-bit Arm Cortex-A, Arm Cortex-M, and Arm Cortex-R processor families. The GNU Arm Embedded Toolchain includes the GNU Compiler (GCC) and is available free of charge directly from Arm for embedded software development on Windows, Linux, and Mac OS X operating systems.

The important thing to notice is that, compiling the source code yields a compiler that produces 32 bit code! The ARM gnu toolchain is not a 64 bit toolchain!

For 64 bit toolchain on Ubuntu, read the section on the [64 bit toolchain](#64-bit-toolchain---installing-the-apt-package)

### Step 1 - Download and Extract the SourceCode Archive

Download the Source Package from the ARM homepage

```
curl https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2 --output gcc-arm-none-eabi-src.tar.bz2
```

```
curl https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2?revision=e2232c7c-4893-46b6-b791-356bdc29fd7f&la=en&hash=8E864863FA6E16582633DEABE590A7C010C8F750 --output gcc-arm-none-eabi-src.tar.bz2
```

```
wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2?revision=e2232c7c-4893-46b6-b791-356bdc29fd7f&la=en&hash=8E864863FA6E16582633DEABE590A7C010C8F750
```

Rename the file

```
mv 'gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2?revision=e2232c7c-4893-46b6-b791-356bdc29fd7f' gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2
```

Compare the MD5 checksum with the value given [here](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)

```
md5sum gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2
```

Extract the archive to get the source code

```
tar -xvjf gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2
```

### Step 2 - Compiling:

Install dependencies for the compilation

```
apt-get update

apt-get install build-essential autoconf autogen bison dejagnu flex flip gawk git gperf gzip nsis openssh-client p7zip-full perl python-dev libisl-dev scons tcl texinfo tofrodos wget zip texlive texlive-extra-utils libncurses5-dev
```

```
$ ./install-sources.sh --skip_steps=mingw32
$ ./build-prerequisites.sh --skip_steps=mingw32
$ ./build-toolchain.sh --skip_steps=mingw32
```

When the build has finished, you should find a directory called install-native/ in the same directory that you ran the build scripts in. That folder will contain the finished toolchain which we will install in the next step.

### Step 3 - Install the Toolchain

It looks like the toolchain’s build contains four directories: bin/, lib/, share/, and arm-none-eabi/.

Just copy everything into the /usr directory:

```
$ cp -R install-native/* /usr/
$ ldconfig
```

### Step 4 - Test the Installation

```
$ which arm-none-eabi-gcc
$ arm-none-eabi-gcc -v
$ arm-none-eabi-gcc -print-search-dirs
```

## 64 bit Toolchain - Installing the apt package

Luckily for a 64 bit toolchain on Ubuntu, a precompiled version is available via the apt package manger. This package is called gcc-aarch64-linux-gnu.

Installing that package is done via

```
$ apt-get install gcc-aarch64-linux-gnu
```

or via a Docker file:

```
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install gcc-aarch64-linux-gnu
```

The package provides a 64 bit assembler, compiler and linker amongst other tools.

- aarch64-linux-gnu-as
- aarch64-linux-gnu-gcc
- aarch64-linux-gnu-ld

## 64 bit Toolchain - Compiling from Source

To compile a 64 bit toolchain for ARM from source, read https://kasiviswanathanblog.wordpress.com/create-your-own-cross-toolchain-for-64-bit-32-bit-arm-machines/

## Qemu, for kernel testing

https://blog.agchapman.com/using-qemu-to-emulate-a-raspberry-pi/

```
apt update
apt-cache search qemu
apt-get install qemu-system-arm
```
