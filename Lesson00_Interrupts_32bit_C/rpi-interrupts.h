/*
    Part of the Raspberry-Pi Bare Metal Tutorials
    https://www.valvers.com/rpi/bare-metal/
    Copyright (c) 2013-2018, Brian Sidebotham

    This software is licensed under the MIT License.
    Please see the LICENSE file included with this software.

*/

#ifndef RPI_INTERRUPTS_H
#define RPI_INTERRUPTS_H

//#include <stdint.h>

#define RPI0 1

#include "rpi-base.h"

// defined in rpi-interrupts-controller.c
extern void RPI_EnableARMTimerInterrupt(void);

#endif
