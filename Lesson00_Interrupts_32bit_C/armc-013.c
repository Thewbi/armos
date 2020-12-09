/*
    Part of the Raspberry-Pi Bare Metal Tutorials
    https://www.valvers.com/rpi/bare-metal/
    Copyright (c) 2013-2018, Brian Sidebotham

    This software is licensed under the MIT License.
    Please see the LICENSE file included with this software.

*/
/*
    Interrupts example, show how to use the interrupt controller and to load
    the vector table at runtime.
*/

//#include <string.h>
//#include <stdlib.h>

//#define RPI0

//#include "gic-400.h"

#include "rpi-gpio.h"
#include "rpi-armtimer.h"
#include "rpi-systimer.h"
#include "rpi-interrupts.h"

extern void _enable_interrupts(void);
extern void writeCharacter(char a, char b, char c);
extern void delay();

/** Main function - we'll never return from here */
void kernel_main( unsigned int r0, unsigned int r1, unsigned int atags )
{
    /* Write 1 to the LED init nibble in the Function Select GPIO
       peripheral register to enable LED pin as an output */
    RPI_SetGpioPinFunction(LED_GPIO, FS_OUTPUT);
    RPI_SetGpioHi(LED_GPIO);

    LED_OFF();

    // //while (1) {
    // for (int i = 0; i < 5; i++) {
    //     writeCharacter('b', 'b', 'b');

    //     LED_ON();
    //     delay();

    //     LED_OFF();
    //     delay();
    // }
    // //}



    // for (int i = 0; i < 5; i++) {
    //     writeCharacter('c', 'c', 'c');

    //     LED_ON();
    //     delay();

    //     LED_OFF();
    //     delay();
    // }

#ifdef RPI4
    gic400_init(0xFF840000UL);
#endif

    RPI_EnableARMTimerInterrupt();

    // for (int i = 0; i < 5; i++) {
    //     writeCharacter('d', 'd', 'd');

    //     LED_ON();
    //     delay();

    //     LED_OFF();
    //     delay();
    // }

    /* Setup the system timer interrupt
       Timer frequency = Clk/256 * 0x400

       NOTE: If the system decides to alter the clock, the frequency of these
             interrupts will also change. The system timer remains consistent.
    */
#if defined ( RPI4 )
    RPI_GetArmTimer()->Load = 0x4000;
#else
    RPI_GetArmTimer()->Load = 0x400;
#endif

    // for (int i = 0; i < 5; i++) {
    //     writeCharacter('e', 'e', 'e');

    //     LED_ON();
    //     delay();

    //     LED_OFF();
    //     delay();
    // }

    /* Setup the ARM Timer */
    RPI_GetArmTimer()->Control =
            RPI_ARMTIMER_CTRL_23BIT |
            RPI_ARMTIMER_CTRL_ENABLE |
            RPI_ARMTIMER_CTRL_INT_ENABLE |
            RPI_ARMTIMER_CTRL_PRESCALE_256;

    /* Enable interrupts! */
    /* Defined in armc-013-start.S */
    _enable_interrupts();

    // for (int i = 0; i < 5; i++) {
    //     writeCharacter('f', 'f', 'f');

    //     LED_ON();
    //     delay();

    //     LED_OFF();
    //     delay();
    // }

    /* Never exit as there is no OS to exit to! */
    while(1)
    {

    }
}
