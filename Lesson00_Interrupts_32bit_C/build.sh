#!/bin/bash

#hlist=`ls *.h`;
#${hlist}

function delete {
    rm -f *.o
    rm -f kernel.elf
    rm -f kernel.img
    rm -f kernel7.img
    rm -f kernel.list
    rm -f kernel.map
}

function compile {
    arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -c armc-013-start.S -o armc-013-start.o

    arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -O2 -Wall -Wextra -I "rpi-base.h, rpi-gpio.h, rpi-armtimer.h, rpi-interrupts.h, rpi-systimer.h" -c armc-013.c -o armc-013.o
    arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -O2 -Wall -Wextra -I "rpi-base.h, rpi-gpio.h, rpi-armtimer.h, rpi-interrupts.h, rpi-systimer.h" -c armc-013-cstartup.c -o armc-013-cstartup.o
    arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -O2 -Wall -Wextra -I "rpi-base.h, rpi-gpio.h, rpi-armtimer.h, rpi-interrupts.h, rpi-systimer.h" -c rpi-armtimer.c -o rpi-armtimer.o
    arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -O2 -Wall -Wextra -I "rpi-base.h, rpi-gpio.h, rpi-armtimer.h, rpi-interrupts.h, rpi-systimer.h" -c rpi-gpio.c -o rpi-gpio.o
    arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -O2 -Wall -Wextra -I "rpi-base.h, rpi-gpio.h, rpi-armtimer.h, rpi-interrupts.h, rpi-systimer.h" -c rpi-interrupts-controller.c -o rpi-interrupts-controller.o
    arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -O2 -Wall -Wextra -I "rpi-base.h, rpi-gpio.h, rpi-armtimer.h, rpi-interrupts.h, rpi-systimer.h" -c rpi-interrupts.c -o rpi-interrupts.o
    arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -O2 -Wall -Wextra -I "rpi-base.h, rpi-gpio.h, rpi-armtimer.h, rpi-interrupts.h, rpi-systimer.h" -c rpi-systimer.c -o rpi-systimer.o

    arm-none-eabi-gcc -T linker.ld -o kernel.elf -ffreestanding -O2 -nostdlib armc-013-start.o armc-013.o armc-013-cstartup.o rpi-armtimer.o rpi-gpio.o rpi-interrupts-controller.o rpi-interrupts.o rpi-systimer.o -lgcc

    arm-none-eabi-objcopy kernel.elf -O binary kernel.img
}

case "$1" in
    -c | --clean)
        delete
    ;;

    * )
        delete
        compile
    ;;
esac
