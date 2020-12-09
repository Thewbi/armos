# Interrupts

## Links

https://www.youtube.com/watch?v=e4ChlZHsx7I&list=PLRwVmtr-pp05PQDzfuOOo-eRskwHsONY0&index=13

Another approach to exceptions / interrupts is described here, but that approach is for ARMv8 I think.
It differs vastly from ARMv6.

https://s-matyukevich.github.io/raspberry-pi-os/docs/lesson03/rpi-os.html

## Introduction

Interrupt is a term used in x86 systems and a lot of low-level systems. ARM decided to refer to Interrupts by the term exception. Exceptions is a bit of a confusing term because exceptions are a concept in high-level programming language and hence confuses high-level software developers a bit. Do not get confused! Now you know that an ARM exception is the same thing as an interrupt.

See https://www.youtube.com/playlist?list=PLRwVmtr-pp05PQDzfuOOo-eRskwHsONY0

Interrupts can occur at any time. They are triggered by external events such as the user typing on the keyboard or data arriving from some peripheral.

A interrupt differs from a normal subroutine in that

- it changes the Current Process Status Register (CPSR)
- Interrupts are not part of the normal, synchronous code flow, they are said to be asynchronous, they are not called by the normal code flow

An interrupt makes the CPU stop what it is doing when the interrupt occures and diverts the CPU to a interrupt routine that was registered (see Interrupt Vector Table) to handle that specific interrupt.

The different interrupts are identified by a memory address that is put into the CPUs programm counter when that interrupt occurs. This mapping from interrupt type to address is hard-coded into the CPUs logic and cannot be configured by the OS developer.

That means each of the possible interrupts that can occur will make the CPU jump to a specific memory address (the respective Interrupt Table Entry) and the CPU will just execute the code that it finds there.

When a interrupt occurs, the CPU jumps to the respective Interrupt Table Entry. There it finds a four byte jump instruction. The target address to jump to is defined by the OS developer and the OS developer will put the address of the custom interrupt handler here. This causes the CPU to perform a second jump from the interrupt table into the interrupt handler. From the interrupt handler it finally jumps back to the initial task.

## Processor Modes

Processor modes are important in the context of interrupts, because when an interrupt occurs, the interrupt changes the processor mode.

Other than interrupts the processor can also be changed using assembly instructions except when in user mode. The user mode is not a priviledged mode and is not allowed to change the processor mode.

When the processor initially starts, it is in the supervisor mode / privileged mode. For normal applications, the processor can be put into user mode. When in user mode, the processor mode cannot be changed by software but only by interrupts.

Next to user and supervisor mode, there is also a system mode. ??? What is system mode used for ???.

For exceptions / interrupts there are the modes abort, undefined, interrupt and fast interrupt.

## Stack Register

The register r13 aka. sp, the stack pointer contains the memory address where the assembly instructions that work on the stack load and store data.

The r13 register is a banked register meaning that there is an individual r13 register in each processor mode. Individual register means that there are several physical r13 registers in the ARM CPU, one for each processor mode. They can in theory all point to the same stack address but the examples for ARM interrupts all create one seperate stack per processor mode.

When the processor mode is changed either in software or by the interrupt controller, the banked r13 registers are exchanged automatically without and user intervention. That means the stacks change automatically.

## Interrupt Table Structure

https://www.valvers.com/open-software/raspberry-pi/bare-metal-programming-in-c-part-4/
https://github.com/dwelch67/raspberrypi/tree/master/blinker07

The location of the Interrupt Vector Table is configurable.

In the following it is assumed that the interrupt vector table is not relocated to an implementation specific address using the security extensions and that the value of SCTLR.VE has a standard value of 0 which makes the CPU use the SCTLR.V bit to control the location of the interrupt vector tables.

The documentation [1] says

> the SCTLR.V bit controls whether the low or the high exception vectors are used

The SCTLR register is documented here: [1] see "B4.1.130 SCTLR, System Control Register, VMSA"

The V bit is bit number 13 (zero based, whereas 0 is the least significant bit). The description of the V says that

- if SCTLR.V is 0, normal/low exception vectors are used. That means the base address is 0x00000000
- if SCTLR.V is 1, high exception vectors (HIVECS) are used. That means the base address is 0xFFFF0000

The Interrupt Vector Table maps an interrupt by the it's hardwired address that is put into the CPU's programm counter when the interrupt is triggered to a four byte long instruction. That instruction is a b (jump) instruction or a load instruction that puts a new address into the pc to jump to the interrupt handler.

The Interrupt Vector Table is structure as follows:

Exception base address: 0x00000000 (If you set SCTLR.V bit = 1 it becomes 0xFFFF0000, more details see above)

The table [1] "Table B1-3 The vector tables" defines the Vector Table Entries and their offsets in different CPU modes (Hypervisor, Monitor, Secure, Non-Secure). The excerpt below is taken from the Secure column.

| base offset | exception             |
| ----------- | --------------------- |
| 0x00000000  | Reset/Boot/Start      |
| 0x00000004  | Undefined instruction |
| 0x00000008  | Supervisor call       |
| 0x0000000C  | Prefetch abort        |
| 0x00000010  | Data abort            |
| 0x00000014  | Hyp trap              |
| 0x00000018  | IRQ interrupt         |
| 0x0000001C  | FIQ interrupt         |

In order to set the interrupt vector table up at the memory location 0x00000000, a common strategy mentioned in several pages on the internet (dwelch67 and www.valvers.com) is to first create a vector interrupt table at the beginning of the kernel.img which is then loaded to 0x8000 because this is where the kernel is put by the GPU of the Raspberry Pi. In a second step that table is then copied to 0x0000 by using ldmia stmia instructions. In order for the interrupt vector table to be relocatable from 0x8000 to 0x0000 it has to be programmed using relative addresses instead of absolute addresses otherwise even after copying it, it would still contain references to the 0x8000 adresses.

The documents describe this approach:

- https://www.valvers.com/open-software/raspberry-pi/bare-metal-programming-in-c-part-4/
- https://github.com/dwelch67/raspberrypi/tree/master/blinker07

Further reading:

https://developer.arm.com/documentation/ddi0301/h/programmer-s-model/operating-modes?lang=en

Register Mode identifiers: (three letter acronym definitions for all modes)
https://developer.arm.com/documentation/ddi0301/h/programmer-s-model/registers/the-arm-state-core-register-set?lang=en

Explanation of the Program Status Register
https://developer.arm.com/documentation/ddi0301/h/programmer-s-model/the-program-status-registers?lang=en

https://developer.arm.com/documentation/ddi0301/h/programmer-s-model/exceptions/exception-vectors?lang=en

## Steve Halladay - UART echo

https://www.youtube.com/watch?v=e4ChlZHsx7I&list=PLRwVmtr-pp05PQDzfuOOo-eRskwHsONY0&index=13

1:34 - Overall Strategy

- Step 1) Create interrupt routine. This will be a single routine for all possible exceptions/interrupts.
- Step 2) Set interrupt vector to point to routine
- Step 3) Configure UART to generate interrupts. (Done in the start interrupt routine.)
- Step 4) Enable UART interrupt on the Pi interrupt controller. Enable the Pi to receive UART interrupts. (Done in the start interrupt routine.)
- Step 5) Enable ARM interrupts. Tell ARM processor to receive interrupts. (Done in the start interrupt routine.)

2:22 - Step 1) Writing the interrupt routine

- Push all registers onto the stack which saves processor state
- Read character from UART
- Write character to UART
- Clear the interrupt (not needed???)
- Pop registers from the stack
- Change processor mode.

4:23 - Interrupt Vector Table

Low/normal interrupts are used and hence the interrupt vector table starts at 0x00000000

The kernel on a 32 bit Raspberry pi is loaded to 0x8000 (on 64 bit it is 0x80000)

That means the first thing in the kernel binary is to set up the vector table at 0x00000000.
How to write data at 0x00000000?

The vector table has to look like this:

| base offset | instruction  |
| ----------- | ------------ |
| 0x00000000  | BAL start    |
| 0x00000004  | BAL other    |
| 0x00000008  | BAL other    |
| 0x0000000C  | BAL other    |
| 0x00000010  | BAL other    |
| 0x00000014  | BAL other    |
| 0x00000018  | BAL irqStart |
| 0x0000001C  | BAL other    |

6:01 - Start interrupt routine for the Reset/Boot/Start vector table entry

- Disable all ARM interrupts
- Set up Stack pointers, at least for the user and system mode
- Initialize the UART
- Configure UART to generate interrupts.
- Enable UART interrupt on the Pi interrupt controller. Enable the Pi to receive UART interrupts.
- Enable ARM interrupts. Tell ARM processor to receive interrupts. But only normal interrupts not fast interrupts.

```
start:
    /* disable all ARM interrupts */
    /* set up the stack pointers */
    /* initialize the UART */
    /* tell the UART to generate interrupts */
    /* enable the PI to receive UART interrupts */
    /* enable ARM interrupts */
loop:
    MOV R2,0x58 /* ASCII 'X' */
    BL writeChar
    BL delay
    BAL loop
```

7:20 - Disable/Enable all ARM interrupts, then turning regular interrupts back on

- Disable all interrupts by setting the I and F bit in the CPSR
  (Hint: In between disabling and enabling, perform setting up stackpointer, initialize UART, Configure UART to generate interrupts)
- Enable the IRQ by clearing the I bit (but not the F bit) in the CPSR
- The MRS instruction reads the CPSR
- The MSR instruction writes the CPSR

8:41 - Enable UART interrupt on the Pi interrupt controller. Enable the Pi to receive UART interrupts.

- Write 0xFFFFFFFF to 0x2000B21C
- Write 0xFDFFFFFF to 0x2000B220

There are so many interrupts that the interrupt controller can enable or disable that two 32 bit memory
locations are required to describe them. Those two addresses are 0x2000B21C and 0x2000B220.
The values 0xFFFFFFFF and 0xFDFFFFFF that Steve Halladay uses, will disable all interrupts except the
UART interrupt. Now the controller will forward the UART interrupt to the processor.

10:40 - Configure UART to generate interrupts.

- Enable UART see earlier videos
- Write 0x0010 to the IMSC register in the UART peripheral

12:17 - the 'other' handler to place into the interrupt vector table

```
other:
    /* write out an O character, wait, then loop back to the other label and start all over again */
    MOV r2,0x4f /_ ASCII 'O' character _/
    BL writeChar
    BL delay
    BAL other
```

13:02 - How to enter and return from an interrupt

Entering and leaving summary is [here](https://developer.arm.com/documentation/ddi0301/h/programmer-s-model/exceptions/exception-entry-and-exit-summary?lang=en)

Entering is described [here](https://developer.arm.com/documentation/ddi0301/h/programmer-s-model/exceptions/entering-an-arm-exception?lang=en)

Leaving is described [here](https://developer.arm.com/documentation/ddi0301/h/programmer-s-model/exceptions/leaving-an-arm-exception?lang=en)

- When store the CPU state, subtract 4 from R14 first. R14 is the link register and contains the return address.
- STMEA R1,R2,...,R14 - Stores the CPU state onto the stack
- LDMEA R1,R2,...,R14,R15 - Inverse to Store, Load the CPU state from the stack

# Glossary

[1] ARM Architecture Reference Manual® ARMv7-A and ARMv7-R edition (https://developer.arm.com/documentation/ddi0406/c/) specifically https://developer.arm.com/documentation/ddi0406/c/System-Level-Architecture/The-System-Level-Programmers--Model/Exception-handling/Exception-vectors-and-the-exception-base-address?lang=en or chapter "B4.1.130 SCTLR, System Control Register, VMSA" of the PDF document.
