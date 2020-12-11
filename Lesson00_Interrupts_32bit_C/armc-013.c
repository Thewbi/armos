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
//extern void writeCharacter(char a, char b, char c);
extern void delay();

/** Main function - we'll never return from here */
void kernel_main( unsigned int r0, unsigned int r1, unsigned int atags )
{
    /* Write 1 to the LED init nibble in the Function Select GPIO
       peripheral register to enable LED pin as an output */

    // LED_GPIO defined in rpi-gpio.h to the value 16 which is the LED GPIO on the RPI0
    // RPI_SetGpioPinFunction defined in rpi-gpio.h
    RPI_SetGpioPinFunction(LED_GPIO, FS_OUTPUT);

    // setting the LED pin high turns the LED off.
    RPI_SetGpioHi(LED_GPIO);

    // defined in rpi-gpio.h
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

    // defined in rpi-interrupts-controller.c
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

       What is Clk ?
    */
// #if defined ( RPI4 )
//     RPI_GetArmTimer()->Load = 0x4000;
// #else
//     // Set a value into the load register of the ARM timer.
//     // The value in the load register is copied to the timer
//     // value register on write or when the value in the timer value register was decremented to 0
//     RPI_GetArmTimer()->Load = 0x400;
// #endif

    RPI_GetArmTimer()->PreDivider = 0x7D;

    //RPI_GetArmTimer()->Load = 0x000F4240;

    // 15 seconds
    //RPI_GetArmTimer()->Load = 0x0000F424;

    //RPI_GetArmTimer()->Load = 0x1E46;
    RPI_GetArmTimer()->Load = 0x1E467F;

    // little bit slower than every second
    // 0x1000 = 4096d
    //RPI_GetArmTimer()->Load = 0x00001000;


    //RPI_GetArmTimer()->Load = 0x00000800;

    // twice as fast as 0x00000800
    //RPI_GetArmTimer()->Load = 0x00000400;

    // twice as fast as 0x00000400
    //RPI_GetArmTimer()->Load = 0x00000200;

    // for (int i = 0; i < 5; i++) {
    //     writeCharacter('e', 'e', 'e');

    //     LED_ON();
    //     delay();

    //     LED_OFF();
    //     delay();
    // }

    /* Setup the ARM Timer */
    /* Write a value into the control register of the ARM timer */
    RPI_GetArmTimer()->Control =
            RPI_ARMTIMER_CTRL_23BIT |
            RPI_ARMTIMER_CTRL_ENABLE |
            RPI_ARMTIMER_CTRL_INT_ENABLE |
            //RPI_ARMTIMER_CTRL_PRESCALE_256;
            RPI_ARMTIMER_CTRL_PRESCALE_1;

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
