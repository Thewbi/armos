#include <stddef.h>
#include <stdint.h>

// board type, raspi0 = 0, raspi1 = 1, raspi2 == 2, raspi3 == 3, raspi4 == 4
//int raspi = 3;
int raspi = 0;

static inline void mmio_write(uint32_t reg, uint32_t data)
{
    *(volatile uint32_t*)reg = data;
}

static inline uint32_t mmio_read(uint32_t reg)
{
    return *(volatile uint32_t*)reg;
}

// Loop <delay> times in a way that the compiler won't optimize away
static inline void delay(int32_t count)
{
    asm volatile("__delay_%=: subs %[count], %[count], #1; bne __delay_%=\n"
            : "=r"(count): [count]"0"(count) : "cc");
}

enum
{
    // // The MMIO area base address
    // switch (raspi) {

    //     case 0:
    //     case 1:  MMIO_BASE = 0x20000000; break; // for raspi 1, raspi zero etc.

    //     case 2:
    //     case 3:  MMIO_BASE = 0x3F000000; break; // for raspi 2 & 3

    //     case 4:  MMIO_BASE = 0xFE000000; break; // for raspi 4

    //     default: MMIO_BASE = 0x20000000; break; // for raspi 1, raspi zero etc.
    // }

    // The MMIO area base address
    //MMIO_BASE = 0x3F000000,
    MMIO_BASE = 0x20000000,

    // the GPIO registers base address.
    GPIO_BASE = MMIO_BASE + 0x200000,

    GPPUD = (GPIO_BASE + 0x94),
    GPPUDCLK0 = (GPIO_BASE + 0x98),

    // the base address for UART.
    UART0_BASE = GPIO_BASE + 0x1000,

    // Data Register
    UART0_DR     = (UART0_BASE + 0x00),
    // receive status register/error clear register
    UART0_RSRECR = (UART0_BASE + 0x04),
    // Flag Register
    UART0_FR     = (UART0_BASE + 0x18),
    // not in use
    UART0_ILPR   = (UART0_BASE + 0x20),
    // Integer Baud Rate Divisor
    UART0_IBRD   = (UART0_BASE + 0x24),
    // Fractional Baud Rate Divisor
    UART0_FBRD   = (UART0_BASE + 0x28),
    // Line Control Register
    UART0_LCRH   = (UART0_BASE + 0x2C),
    // Control Register
    UART0_CR     = (UART0_BASE + 0x30),
    // Interupt FIFO Level Select Register
    UART0_IFLS   = (UART0_BASE + 0x34),
    // Interupt Mask Set Clear Register
    UART0_IMSC   = (UART0_BASE + 0x38),
    // Raw Interupt Status Register
    UART0_RIS    = (UART0_BASE + 0x3C),
    // Masked Interupt Status Register
    UART0_MIS    = (UART0_BASE + 0x40),
    // Interupt Clear Register
    UART0_ICR    = (UART0_BASE + 0x44),
    // DMA Control Register
    UART0_DMACR  = (UART0_BASE + 0x48),
    // Test Control register
    UART0_ITCR   = (UART0_BASE + 0x80),
    // Integration test input reg
    UART0_ITIP   = (UART0_BASE + 0x84),
    // Integration test output reg
    UART0_ITOP   = (UART0_BASE + 0x88),
    // Test Data reg
    UART0_TDR    = (UART0_BASE + 0x8C),
};

void uart_init()
{
    //
    // GPIO pin setup

    // setup the GPIO pin 14 and 15
	// Disable pull up/down for all GPIO pins
    mmio_write(GPPUD, 0x00000000);

    // delay for 150 cycles
    delay(150);

    // disable pull up/down for pin 14 and 15
    mmio_write(GPPUDCLK0, (1 << 14) | (1 << 15));

    // delay for 150 cycles
    delay(150);

    // write 0 to GPPUDCLK0 to make it take effect
    mmio_write(GPPUDCLK0, 0x00000000);

    //
    // UART setup

    // disable UART0
    // the UART0_CR register is the UART controll register
    // the bit 0 will disable UART0 if the value is 0
    mmio_write(UART0_CR, 0x00000000);

    // Clear uart Flag Register
    mmio_write(UART0_FR, 0x00000000);

    // clear pending interrupts
    // ICR = Interrupt Clear register
    // 0x7FF clears all interrupts see the Peripherals Manual
    mmio_write(UART0_ICR, 0x7FF);

    // setting the baud rate is done by computing an integral and fractional part
    // and then writing those two values into the IBRD and FBRD registers respectively
    //
    // set integer & fractional part of baud rate
	// Divider = UART_CLOCK/(16 * Baud)
	// Fraction part register = (Fractional part * 64) + 0.5
	// Baud = 115200.

	// for Raspi3 and 4 the UART_CLOCK is system-clock dependent by default.
	// Set it to 3Mhz so that we can consistently set the baud rate

    // divider = 3000000 / (16 * 115200) = 1.627 = ~1
    // the divider 3000000 is not documented and is taken from the Linux kernel source code
    mmio_write(UART0_IBRD, 1);

    // fractional part register = (.627 * 64) + 0.5 = 40.6 = ~40
    mmio_write(UART0_FBRD, 40);

    //Clear UART FIFO by writing 0 in FEN bit of LCRH register
	mmio_write(UART0_LCRH, (0 << 4));

    // enable FIFO & 8 bit data transmission (1 stop bit, no parity)
    // LCRH = Line Control Register. Enables FIFO and
    mmio_write(UART0_LCRH, (1 << 4) | (1 << 5) | (1 << 6));
    //mmio_write(UART0_LCRH, (1 << 5) | (1 << 6));

    // Mask all interrupts (= turn them off)
    // IMSC = interrupt mask, mask of or disables interrupts
    mmio_write(UART0_IMSC, (1 << 1) | (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7) | (1 << 8) | (1 << 9) | (1 << 10));

    // enable UART0, receive & transfer part of UART
    mmio_write(UART0_CR, (1 << 0) | (1 << 8) | (1 << 9));
}

void uart_putc(unsigned char c)
{
    while ( mmio_read(UART0_FR) & (1 << 5) )
    {
        // nop
    }
    mmio_write(UART0_DR, c);
    //mmio_write(UART0_DR, 65);
}

unsigned char uart_getc()
{
    while ( mmio_read(UART0_FR) & (1 << 4) )
    {
        // nop
    }
    return mmio_read(UART0_DR);
}

void uart_puts(const char* str)
{
    for (size_t i = 0; str[i] != '\0'; i ++) {
        uart_putc((unsigned char)str[i]);
    }
}

void kernel_main(uint32_t r0, uint32_t r1, uint32_t atags)
{
    (void) r0;
    (void) r1;
    (void) atags;

    uart_init();

    // uart_putc('H');
    // uart_putc('a');
    // uart_putc('l');
    // uart_putc('l');
    // uart_putc('o');

    //while (1) {
        //uart_puts("Garbage!\r\n");
    //}

    while (1) {
        uart_putc(uart_getc());

        // uart_getc();
        // uart_putc('A');

        // uart_putc('\n');
    }
}