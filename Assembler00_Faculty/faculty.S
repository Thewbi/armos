.section ".text.startup"

.globl _start
_start:

    /* set the stack pointer */
    ldr sp, =0x7000

    /* init serial */
    bl initUart

    /* set parameter 1, the value to compute the faculty for */
    mov r0, #0x03

    bl faculty

    /* r0 contains the result */

    /* Convert the integer in r0 to the ASCII code of the character representing that number by adding 0x30 */
    add r0, r0, #0x30

end_of_app:
    /* output character stored in r2 */
    mov r2, r0
    bl writeCharacter

    /* output H
    mov r2, #0x48
    bl writeCharacter*/

    /* output space */
    mov r2, #0x20
    bl writeCharacter

    bl delay

    bal end_of_app




faculty:

    push {lr}

    cmp r0, #0x00
    bne continue_faculty
    mov r0, #0x01
    b return_faculty

continue_faculty:
    push {r0}
    sub r0, r0, #0x01
    bl faculty
    mov r1, r0

    pop {r0}

    mul r0, r0, r1

return_faculty:
    pop {lr}
    /* return to caller. r15 is the programm counter. r14 is the link register */
    mov pc, lr




/* Make the system wait */
delay:
    mov r2, #0
wait:
    add r2, r2, #1
    cmp r2, #0x00400000
    bne wait

    /* return to caller. r15 is the programm counter. r14 is the link register */
    mov pc, lr




/* Check if another character can be written and if the fifo is empty, write the character */
/* write value from r2 to the serial connection */
writeCharacter:
    /* r0 is GPIO base, 0x20200000 */
    mov r0, #0x20000000
    mov r1, #0x00200000
    orr r0, r0, r1

    /* r1 is UART base */
    orr r1, r0, #0x1000

    /* Check if another character can be written */
    ldr r3, [r1, #0x18]
    and r3, r3, #0x20
    cmp r3, #0
    bne writeCharacter

    /* str r2, [r1, #0x0000] actually writes a character to the UART */
    str r2, [r1, #0x0000]

    /* return to caller. r15 is the programm counter. r14 is the link register */
    mov pc, lr




/* set up the hardware that can transfer data over a serial connection */
initUart:
    /* r0 is GPIO base, 0x20200000 */
    mov r0, #0x20000000
    mov r1, #0x00200000
    orr r0, r0, r1

    /* r1 is UART base */
    orr r1, r0, #0x1000

    /* disable UART by writing 0 to the UART_CR register */
    mov r2, #0x00000000
    str r2, [r1, #0x30]

    /* write ggpud, pud = pull up / down */
    /* Disable pull up/down for all GPIO pins */
    /* 0x94 = 10010100 */
    str r2, [r0, #0x94]

    /* nested function call, save link register */
    mov r11, lr
    /* wait */
    bl delay
    /* nested function call, restore link register */
    mov lr, r11

    /* Write 1<<14 | 1<<15 = 0xC000 into the GPPUDCLK0 register.  */
    mov r2, #0xC000
    /* 0x98 = 10011000 */
    str r2, [r0, #0x98]

    /* nested function call, save link register */
    mov r11, lr
    /* wait */
    bl delay
    /* nested function call, restore link register */
    mov lr, r11

    /* write 0 into GPPUDCLK0. Write 0 to GPPUDCLK0 to make it take effect*/
    mov r2, #0x00
    str r2, [r0, #0x98]

    /* clear interrupts */
    /* */
    /* write 0x07ff == 0111 1111 1111 into UART0_ICR (= UART0_BASE + offset 0x44) */
    /* UART0_ICR = interrupt clear register */
    /* 0x07ff clears all interrupts */
    mov r2, #0x0700
    orr r2, r2, #0x00ff
    str r2, [r1, #0x44]

    /* Set the baud rate */
    /* */
    /* write a 1 into UART0_IBRD (= UART0_BASE + offset 0x24) */
    /* IBRD =  Integral Baud Rate Definition */
    /* Set integer & fractional part of baud rate */
    /* Divider = UART_CLOCK/(16 * Baud) */
    /* Fraction part register = (Fractional part * 64) + 0.5 */
    /* UART_CLOCK = 3000000; Baud = 115200. */
    /* Divider = 3000000 / (16 * 115200) = 1.627 = ~1. */
    /* Fractional part register = (.627 * 64) + 0.5 = 40.6 = ~40. */
    mov r2, #1
    str r2, [r1, #0x24]

    /* Set the baud rate */
    /* */
    /* write a 40 into UART0_FBRD (= UART0_BASE + offset 0x28) */
    /* FBRD = Fractional Baud Rate Definition */
    mov r2, #40
    str r2, [r1, #0x28]

    /* enable 8 bit data transmission (1 stop bit, no parity) */
    /* */
    /* UARTC_LCRH = Line Control Register */
    /* write 70 0100 0110 = into UARTC_LCRH (= UART0_BASE + offset 0x2C) */
    mov r2, #0x60
    str r2, [r1, #0x2C]

    /* mask all interrupts, means disables or ignores all interrupts */
    /* */
    /* write 0x07F2 into UART0_IMSC (= UART0_BASE + offset 0x38) */
    /* 0x07F2 = 0111 1111 0010 = (1 << 1) | (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7) | (1 << 8) | (1 << 9) | (1 << 10) */
    mov r2, #0x0700
    orr r2, r2, #0x00F2
    str r2, [r1, #0x38]

    /* enable UART0 */
    /* */
    /* write 0x0301 = 0011 0000 0001 into UART0_CR (= UART0_BASE + offset 0x30) */
    /* bit 0 = enable/disable */
    /* bit 8 = enable receive */
    /* bit 9 = enable transmit */
    mov r2, #0x0300
    orr r2, r2, #0x0001
    str r2, [r1, #0x0030]

    /* return to caller. r15 is the programm counter. r14 is the link register */
    mov pc, lr
