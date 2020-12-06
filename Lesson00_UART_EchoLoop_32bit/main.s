.section .init
.globl _start
_start:

/* ldr reg,=val puts the number val into the register named reg. */
/* mov reg,#val puts the number val into the register named reg. */
/* str reg,[dest,#val] stores the number in reg at the address given by dest + val. */
/* mrs r0, cpsr copies the status register CPSR into a general purpose register */
/* msr cpsr, r0 copies the value in a general purpose register into the status register CPSR */

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

/* wait */
bl delay

/* Write 1<<14 | 1<<15 = 0xC000 into the GPPUDCLK0 register.  */
mov r2, #0xC000
/* 0x98 = 10011000 */
str r2, [r0, #0x98]

/* wait */
bl delay

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

loop:

/* A = 0x41 */
/* B = 0x42 */
/* C = 0x43 */
/* D = 0x44 */
/* E = 0x45 */
/* F = 0x46 */
/* G = 0x47 */
/* H = 0x48 */

/* a = 0x61 */
/* b = 0x62 */
/* c = 0x63 */
/* ... */
/* l = 0x6C */
/* ... */
/* o = 0x6F */

/*
mov r2, #0x48
bl writeCharacter
mov r2, #0x61
bl writeCharacter
mov r2, #0x6C
bl writeCharacter
mov r2, #0x6C
bl writeCharacter
mov r2, #0x6F
bl writeCharacter
 */

bl readCharacter
bl writeCharacter

/* wait
bl delay*/

bal loop

delay:
mov r2, #0
wait:
add r2, r2, #1
cmp r2, #0x00400000
bne wait
mov r15, r14 /* return to caller. r15 is the programm counter. r14 is the link register */

/* Check if another character can be written and if the fifo is empty, write the character */
writeCharacter:
ldr r3, [r1, #0x18]
and r3, r3, #0x20
cmp r3, #0x00
bne writeCharacter
str r2, [r1, #0x0000] /*str r2, [r1, #0x0000] actually writes the character in r2 to the UART */
mov r15, r14 /* return to caller. r15 is the programm counter. r14 is the link register */

/* Steve Halladay - https://www.youtube.com/watch?v=x3lzMfdlh2o&list=PLRwVmtr-pp05PQDzfuOOo-eRskwHsONY0&index=11 */
readCharacter:
/* wait for the UART to receive a character */
ldr r7, [r1, #0x18]
and r7, r7, #0x0010
cmp r7, #0x00
bne readCharacter
/* get the character from the UART and store it into r2 */
ldr r2, [r1, #0x00]
and r2, r2, #0x00FF /* Cut of leading byte because only the lower byte contains data */
mov r15, r14 /* return to caller. r15 is the programm counter. r14 is the link register */
