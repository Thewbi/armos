# Timers

The Raspberry Pi contains a CPU and a GPU.

There is a timer inside the CPU and inside the GPU.

In the following, the timer inside the CPU is referred to as the ARM / CPU timer and the timer inside the GPU is referred to as the system timer.

This document explains both of those timers.

## Links

- https://jsandler18.github.io/extra/sys-time.html
- https://starfishmedical.com/blog/raspberry-pi-clock-conundrum/
- https://www.snaums.de/informatik/pios-arm-timer-and-interrupts.html
- https://www.raspberrypi.org/forums/viewtopic.php?t=159858

## Terminology

Timer - Timers are devices which generate timing pulses exactly at a required frequency.

Counter - Count events. Are not tied to a frequency but only to occuring events.

System Clock - The System Clock is the speed at which the GPU (not CPU!) is running. If the GPU is clocked to 250 Mhz for example, the clock will tick 250 Million times per second. The System Clock can actually change during operation. For example switching the Raspberry Pi to reduced-power or low-power mode will lower the System Clock. The system clock speed / GPU clock speed can be adjusted in the config.txt file on the SD Card. The property core_freq defines the GPU clock speed. It is described here: https://www.raspberrypi.org/documentation/configuration/config-txt/overclocking.md. The default speed is 250 Mhz on the Raspberry Pi 1.

ARM/CPU Timer - A timer peripheral build into the ARM CPU by the CPU manufacturer. It is described in chapter 14 of the Peripherals manual. The ARM/CPU timer is a semi-automatic timer (see semi-automtic timer) and also a free running counter. As a semi-automatic timer it decrements a value until the value goes to zero and then sends out a signal to the interrupt controller for example, it then reloads the value so it can decrement again. The frequency at which the value is decremented is derived from the System Clock. (What is the formula for the derivation? See ARM/CPU Timer Predivider). Also the System Clock is not fixed (low power mode lowers the System Clock) hence the ARM/CPU Timer can change in frequency.

semi-automatic timer - See (see https://www.embedded.com/introduction-to-counter-timers/ for a definition of semi-automatic)

free-running counter - is described in chapter 14 of the Peripherals manual. It is a register that stores a value that is continuously incremented or decremented at a certain frequency (derived from the System Clock) that just rolls-over / wraps around. The initial value does not matter and the value cannot be reset. The free-running counter can be read. I am not sure if the free-running counter can trigger an interrupt.

ARM/CPU Timer Predivider - The ARM/CPU Timer contains a register called 'timer pre-divider register'. It is described in chapter 14 of the Peripherals Manual. It's default value is 0x7D = 125. (Note: The default value as described in the Peripherals Manually was not set during my tests! Set it yourself before using the ARM/CPU Timer!) It is used to derive the ARM/CPU Timer frequency from the System Clock. The formula is: timer_clock = apb_clock / (pre_divider + 1). Initially

System Timer - A timer build into the GPU. It is described in chapter 12 of the Peripherals Manual. It's physical hardware address is 0x7E003000 but after mapping the ARM CPU sees it at 0x20003000. The CLO register at offset 0x04 (Ox20003004) contains the current timer value. The timer value is incremented with a frequency of 1 Mhz. That means the frequency is fixed and not tied to the System Clock.

Accurate Timing - Is the process of meassuring real time. The Peripherals Manual states in chapter 14 that to perform Accurate Timing, the System Timer shoudl be used and the use of the ARM/CPU Timer for Accurate Timer is discouraged.

APB - Advanced Peripheral Bus (APB) is mentioned in chapter 13 of the Peripherals manual.

APB Clock - ??? Is this maybe the same thing as the system clock? Or is it the ARM/CPU Timer? I could not find a definition yet. Is the APB clock the GPU clock speed = core_freq? See https://raspberrypi.stackexchange.com/questions/699/what-spi-frequencies-does-raspberry-pi-support which says: "... runs at APB clock speed, which is equivalent to core clock speed, 250 MHz."

## Links

- https://www.raspberrypi.org/forums/viewtopic.php?t=234418
- https://www.raspberrypi.org/forums/viewtopic.php?t=52393
- https://www.embedded.com/introduction-to-counter-timers/
- https://mindplusplus.wordpress.com/2013/05/21/accessing-the-raspberry-pis-1mhz-timer/#note1
- https://github.com/dwelch67/raspberrypi/tree/master/blinker07

## ARM / CPU Timer

The CPU or ARM timer peripheral is documented in chapter 14 of the BCM2835-ARM-Peripherals document.

It combines two functions into one peripheral.

It supports

1. a timer (ARM/CPU Timer)
2. a free running counter (ARM/CPU counter).

There is another set of timers in the GPU which are used for accurate timing but those timers are not described here.
The timers in the GPU are called system timers.

### ARM free running counter

It uses two registers

1. control register (Address: base + 0x40C)
2. free running counter register (Address: base + 0x420)

The free running counter has it's own register (Free running counter at offset 0x420) that contains the current value of the free running counter. The value is continuously decremented at the configured frequency and rolls-over / wraps around. The initial value does not matter and the value cannot be reset. The free-running counter can be read. I am not sure if the free-running counter can trigger an interrupt.

The pre-scale bits in the control register affect the ARM Timer free running counter's frequency.

The formula is:

```
switch (pre-scale bits) {

    case 00 :
        system_clock / 1 (No pre-scale)
        break;

    case 01 :
        system_clock / 16
        break;

    case 10 :
        system_clock / 256
        break;

    case 11 :
        system_clock / 1
        break;
}
```

That means that the value in the free running counter register is decremented. The rate/frequency at which the value is decremented is derived from the system clock (GPU clock). Derived means that the system clock is taken and devided. The factor to devide by is controlled by the pre-scale bits in the control register. There are two bits, which makes four different values possible outlined by the pseudo code above.

The value can be read from the free running counter by reading the free running counter register at offset (Address: base + 0x420).

After reading that value, the reaction is application dependant. The application designer has to devise their own algorithm to use that value. One possible way is to compute a delta of ticks and perform an action when the delta reaches a certain value.

### ARM timer (aka. CPU Timer)

The ARM timer is the second peripheral apart from the ARM free running counter that is build into the ARM timer peripheral.

The timer uses three registers:

1. timer pre-divider register (Address: base + 0x41C)
2. timer reload register (Address: base + 0x400)
3. timer value register (Address: base + 0x404)

### ARM/CPU Timer Frequency

The ARM CPU timer has a load register in which the application can put a value. The CPU Timer will first copy that value to a value register. It will then decrement that value at it's configured frequency. Once the value register contains the value 0, two things happen:

- The value register is again filled with the value stored in the load register
- The timer interrupt is signaled/thrown

The frequency of the CPU Timer, the rate at which it decrements the value register, is described in the Peripherals document as

> The clock from the ARM timer is derived from the system clock. This clock can change dynamically e.g. if the system goes into reduced power or in low power mode. Thus the clock speed adapts to the overal system performance capabilities. For accurate timing it is recommended to use the system timers.

The frequency is derived from the system clock.

Now what exactly is the system clock and what does 'derived' mean exactly?

The system clock aka. apb_clock is the frequency of the GPU. That frequency is used as a base to derive the frequency of UART, SPI, ... and also the ARM timer peripheral. On a Raspberry Pi 1 this value is 250 Mhz by defaut. It can be configured in config.txt using the core_freq property. (Watch out to not overclock too hard and damage your chips!)

The pre-divider register affects the clock of the ARM / CPU timer. The formula is:

```
timer_clock = apb_clock / (pre_divider + 1)
```

The Peripherals Manual describes that the default value for pre_divider is 0x7D = 125. There seems to be a problem with this default value. During my tests, I never set the pre_divider in the hopes that the default value is used. I got wrong results. After setting the value of the pre_divider register manually, the problems were gone. My suggestion generally is to set default values manually to make sure the hardware is set up correctly under all circumstances.

The Peripherals Manual describes that the timer is not suitable for real-time clocking as described in the Peripherals Manual but as a test it is used here anyways.

### Triggering the ARM / CPU Timer Frequency once a second.

In order to trigger an interrupt every second

1. Interrupts have to be set up correctly
2. A correct pre_devider value has to be set
3. A correct value has to be loaded into the value register.

Let's assume the interrupts are [set up correctly](https://www.valvers.com/open-software/raspberry-pi/bare-metal-programming-in-c-part-4/), here is an example for computing the value and the pre_divider value.

When the default value 0x7D = 125 is written into the pre_divider register of a Raspberry Pi 1 that has a GPU clock of 250 MHz (= apb_clock), the ARM / CPU counter will have a frequency of:

```
timer_clock = apb_clock / (pre_divider + 1)
= 250 Mhz / (125 + 1)
= 250.000.000 Hz / 126
= 1984126,984126984126984 Hz
= 1984127 Hz
```

If the value 1984127 = 0x1E467F is written into the value register, then the configured frequency of the system clock will cause the ARM / CPU timer to count down to 0 and trigger the interrupt about every second.

### Using the ARM / CPU timer with interrupts

To use the ARM / CPU timer with interrupts (described [here](https://www.valvers.com/open-software/raspberry-pi/bare-metal-programming-in-c-part-4/))

- Enable the ARM Timer Interrupt in the Interrupt Controller
- Enable interrupts globally
- Enable and configure the ARM Timer peripheral

# System Timers

The Peripherals Manual makes a difference between the ARM Timer == ARM clock and the term system timers:

> The clock from the ARM timer is derived from the system clock. This clock can change dynamically e.g. if the system goes into reduced power or in low power mode. Thus the clock speed adapts to the overal system performance capabilities. For accurate timing it is recommended to use the system timers.

The System Timer is described in chapter 12 of the Peripherals Manual. The system timers are part of the GPU and can be used for accurate timing.

Here: https://stackoverflow.com/questions/14617241/mmap-get-a-64-bit-value-with-an-offset it says:
The system timer counts up every microsecond.

Here: https://mindplusplus.wordpress.com/2013/05/21/accessing-the-raspberry-pis-1mhz-timer/ it says:

> According to the official Broadcom 2835 documentation, the free-running 1MHz timer resides at ARM address 0x20003004

Just as a reminder a 1 MHZ clock ticks every microsecond (!= millisecond (ms)).

```
Micro = 10 ^ -6 = 1 / 1000000 = 1 Million Herz = 1 Mega Hertz.
```
