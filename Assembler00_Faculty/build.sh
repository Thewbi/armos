#!/bin/bash

function delete {
    rm -f *.o
    rm -f kernel.elf
    rm -f kernel.img
    rm -f kernel7.img
    rm -f kernel.list
    rm -f kernel.map
}

function compile {
    arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -c faculty.S -o faculty.o

    #arm-none-eabi-gcc -mcpu=arm1176jzf-s -fpic -ffreestanding -std=gnu99 -O2 -Wall -Wextra -I "rpi-base.h, rpi-gpio.h, rpi-armtimer.h, rpi-interrupts.h, rpi-systimer.h" -c armc-013.c -o armc-013.o

    arm-none-eabi-gcc -T linker.ld -o kernel.elf -ffreestanding -O2 -nostdlib faculty.o -lgcc

    arm-none-eabi-objcopy kernel.elf -O binary kernel.img
}

case "$1" in
    -c | --clean | --clear)
        delete
    ;;

    * )
        delete
        compile
    ;;
esac
