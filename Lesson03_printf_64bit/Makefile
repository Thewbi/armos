#
# Copyright (C) 2018 bzt (bztsrc@github)
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#
#

SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)
CFLAGS = -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles

all: clean kernel8.img

start.o: start.S
	aarch64-linux-gnu-gcc $(CFLAGS) -c start.S -o start.o

%.o: %.c
	aarch64-linux-gnu-gcc -I/usr/lib/gcc-cross/aarch64-linux-gnu/9/include $(CFLAGS) -c $< -o $@

kernel8.img: start.o $(OBJS)
	aarch64-linux-gnu-ld -nostdlib -nostartfiles start.o $(OBJS) -T link.ld -o kernel8.elf
	#aarch64-linux-gnu-ld -nostdlib -nostartfiles start.o $(OBJS) -T link.ld -o kernel.elf
	aarch64-linux-gnu-objcopy -O binary kernel8.elf kernel8.img
	#aarch64-linux-gnu-objcopy -O binary kernel.elf kernel.img

clean:
	rm kernel.elf kernel.img kernel8.elf kernel8.img *.o >/dev/null 2>/dev/null || true

run:
	# QEmu options: https://wiki.gentoo.org/wiki/QEMU/Options
	#/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -M raspi3 -kernel kernel8.img -d in_asm
	#/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -m 1024 -M raspi3 -kernel kernel8.img
	/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -display none -serial stdio -m 1024 -M raspi3 -kernel kernel8.img
    # for Raspberry Pi 1
	#qemu-system-arm -kernel kernel8.img -cpu arm1176 -m 256 -M versatilepb -nographic