# printf

The goal of this section is to send character output over UART so that the OS can print onto the console.

A hello world output should be printed.

NOTE: For Qemu only UART 0 works! Qemu will onyl output if you write to UART 0!

/home/raspi3-tutorial/05_uart0

./gcc-arm-none-eabi-X-XXXX-XX-update/bin/arm-none-eabi-gcc -mcpu=cortex-a7 -fpic -ffreestanding -c boot.S -o boot.o
./gcc-arm-none-eabi-X-XXXX-XX-update/bin/arm-none-eabi-gcc -mcpu=cortex-a7 -fpic -ffreestanding -std=gnu99 -c kernel.c -o kernel.o -O2 -Wall -Wextra
./gcc-arm-none-eabi-X-XXXX-XX-update/bin/arm-none-eabi-gcc -T linker.ld -o myos.elf -ffreestanding -O2 -nostdlib boot.o kernel.o

THIS WORKS AFTER COMPILING AND INSTALLING THE GNU ARM GNU EABI TOOLCHAIN

rm start.o kernel.o myos.elf kernel8.elf kernel8.img
/usr/bin/arm-none-eabi-gcc -mcpu=cortex-a7 -fpic -ffreestanding -c start.S -o start.o
/usr/bin/arm-none-eabi-gcc -mcpu=cortex-a7 -fpic -ffreestanding -std=gnu99 -c kernel.c -o kernel.o -O2 -Wall -Wextra
/usr/bin/arm-none-eabi-gcc -T link.ld -o kernel8.elf -ffreestanding -O2 -nostdlib start.o kernel.o

/usr/bin/arm-none-eabi-gcc --target=aarch64-arm-none-eabi -mcpu=cortex-a8 -fpic -ffreestanding -c start.S -o start.o
/usr/bin/arm-none-eabi-gcc -mcpu=cortex-a8 -fpic -ffreestanding -std=gnu99 -c kernel.c -o kernel.o -O2 -Wall -Wextra
/usr/bin/arm-none-eabi-gcc -T link.ld -o kernel8.elf -ffreestanding -O2 -nostdlib start.o kernel.o

THIS WORKS:
First install

```
$ apt-get install gcc-aarch64-linux-gnu
```

/usr/bin/aarch64-linux-gnu-gcc -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -c start.S -o start.o
THIS WORKS:
aarch64-linux-gnu-gcc -I/usr/lib/gcc-cross/aarch64-linux-gnu/9/include -std=gnu99 -Wall -Wextra -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -c kernel.c -o kernel.o
THIS WORKS:
/usr/bin/aarch64-linux-gnu-gcc -T link.ld -o kernel8.elf -ffreestanding -O2 -nostdlib start.o kernel.o

aarch64-linux-gnu-objcopy -O binary myos.elf kernel8.img
THIS WORKS:
aarch64-linux-gnu-objcopy -O binary kernel8.elf kernel8.img

qemu-system-arm -m 256 -M raspi2 -serial stdio -kernel myos.elf
THIS WORKS:
/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -M raspi3 -kernel kernel8.img

/home/download/gcc-arm-none-eabi-9-2020-q2-update/bin

/home/download/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-gcc -mcpu=cortex-a7 -fpic -ffreestanding -c start.S -o start.o

/home/download/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-gcc -mcpu=cortex-a7 -fpic -ffreestanding -std=gnu99 -c kernel.c -o kernel.o -O2 -Wall -Wextra

/home/download/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-gcc -T linker.ld -o myos.elf -ffreestanding -O2 -nostdlib start.o kernel.o

rm /lib/ld-linux-aarch64.so.1
rm /lib64/libc.so.6

apt remove binutils-arm-none-eabi gcc-arm-none-eabi libnewlib-arm-none-eabi

apt install software-properties-common

add-apt-repository "deb [arch=armhf,arm64,powerpc] http://ports.ubuntu.com/ focal main"

#dpkg --add-architecture powerpc

dpkg --add-architecture arm64
dpkg --add-architecture armhf
apt-get install libc6:arm64 libc6:armhf libc6:powerpc

apt-get install libc6-armel-cross libc6-dev-armel-cross binutils-arm-linux-gnueabi libncurses5-dev build-essential bison flex libssl-dev bc

apt-get install gcc-arm-none-eabi binutils-arm-none-eabi gdb-arm-none-eabi openocd

export PATH=\$PATH:/home/download/gcc-arm-none-eabi-9-2020-q2-update/bin/

/home/download/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-gcc

/home/download/gcc-arm-none-eabi-9-2020-q2-update/bin/arm-none-eabi-gcc

ERROR:
/lib/ld-linux-aarch64.so.1: No such file or directory

SOLUTION:
/lib/ld-linux-aarch64.so.1 is contained in the libc package for the arm64 architecture

dpkg --add-architecture arm64
apt-get install libc6:arm64

ERROR:
The following packages have unmet dependencies:
libc6:arm64 : Depends: libgcc-s1:arm64 but it is not going to be installed
E: Unable to correct problems, you have held broken packages.

== Compile gcc-arm-none-eabi ==

curl https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2 --output gcc-arm-none-eabi-src.tar.bz2

curl https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2?revision=e2232c7c-4893-46b6-b791-356bdc29fd7f&la=en&hash=8E864863FA6E16582633DEABE590A7C010C8F750 --output gcc-arm-none-eabi-src.tar.bz2

wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2?revision=e2232c7c-4893-46b6-b791-356bdc29fd7f&la=en&hash=8E864863FA6E16582633DEABE590A7C010C8F750

md5sum gcc-arm-none-eabi-src.tar.bz2

rm gcc-arm-none-eabi-src.tar.bz2

mv 'gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2?revision=e2232c7c-4893-46b6-b791-356bdc29fd7f' gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2

md5sum gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2

```
tar -xvjf gcc-arm-none-eabi-9-2020-q2-update-src.tar.bz2
```

cd gcc-arm-none-eabi-9-2020-q2-update

```
apt-get update

apt-get install build-essential autoconf autogen bison dejagnu flex flip gawk git gperf gzip nsis openssh-client p7zip-full perl python-dev libisl-dev scons tcl texinfo tofrodos wget zip texlive texlive-extra-utils libncurses5-dev
```

Compiling:

```
$ ./install-sources.sh --skip_steps=mingw32
$ ./build-prerequisites.sh --skip_steps=mingw32
$ ./build-toolchain.sh --skip_steps=mingw32
```

When the build does finish, you should find a directory called install-native/ in the same directory that you ran the build scripts in. That folder will contain the finished toolchain which we will install in the next step.

Step 3: Install the Toolchain
It looks like the toolchain’s build contains four directories: bin/, lib/, share/, and arm-none-eabi/.

Just copy everything into the /usr directory:

```
$ cp -R install-native/* /usr/
$ ldconfig
```

Test the installation

```
$ which arm-none-eabi-gcc
$ arm-none-eabi-gcc -v
$ arm-none-eabi-gcc -print-search-dirs
```
