/*
    Part of the Raspberry-Pi Bare Metal Tutorials
    https://www.valvers.com/rpi/bare-metal/
    Copyright (c) 2013-2018, Brian Sidebotham

    This software is licensed under the MIT License.
    Please see the LICENSE file included with this software.

*/

extern int __bss_start;
extern int __bss_end;

extern void kernel_main(unsigned int r0, unsigned int r1, unsigned int atags);
// extern void writeCharacter(char a, char b, char c);
// extern void delay();

void _cstartup(unsigned int r0, unsigned int r1, unsigned int r2)
{
    int* bss = &__bss_start;
    int* bss_end = &__bss_end;

    /*
        Clear the BSS section

        See http://en.wikipedia.org/wiki/.bss for further information on the
            BSS section

        See https://sourceware.org/newlib/libc.html#Stubs for further
            information on the c-library stubs
    */
    while (bss < bss_end) {
        *bss++ = 0;
    }

    // while (1) {
    //     writeCharacter('a', 'a', 'a');
    //     delay();
    // }

    /* We should never return from main ... */
    kernel_main(r0, r1, r2);

    /* ... but if we do, safely trap here */
    while (1)
    {
        /* EMPTY! */
    }
}
