# Raspberry Pi Boards

This lesson just contains introductory information about Raspberry Pi Boards and some terminology, there is no coding done in this lesson. There are many product names and it is easy to get confused. To bring some order to the chaos, this chapter describes the hardware and separates concepts from each other.

## Raspberry Pi Models

There are several revisions of the Raspberry Pi. With each new revision the hardware changed. Programming on the hardware (bare metal) makes it necessary to know what hardware is present because assembler is used to talk to the hardware directly and this type of software development is inherently platform dependant. The hardware names can then be used to retrieve the correct documentation.

https://en.wikipedia.org/wiki/Raspberry_Pi has a good overview of all models.

It talks about

- SoC
- CPU
- Instruction Set

How do these terms relate to each other?

A system on a chip (SoC) is pretty similar to a Microcontroller. A Microcontroller contains a CPU, Memory and other hardware components on a single chip. That means for a SoC there is a die of silicon which contains circuitry for a CPU, Memory and other components.

The CPU is a IP (Intellectual property) of the company ARM (Achorn RISC Machines, Advanced RISC Machines, today just ARM) which licences the specifications out. ARM does not manufacture CPU themselves, instead they licence their IP to companies such as Broadcom, TexasInstruments or STM that actually do produce the ARM CPUs in silicon.

The ARM processor is just one component in a SoC. The SoC on the Raspberry Pi is created by Broadcom. The Raspberry Pi Single Board Computer (SBC) is as large as a credit card and it is created by the Raspberry Pi Foundation. On that credit card sized SBC, the Broadcom SoC is placed below the memory chip! That means the SoC is very, very small and the terms Raspberry Pi SBC and SoC are not the same at all.

Inside the Broadcom SoC there is an ARM CPU as mentioned already. This ARM CPU is different for differnet versions of the Raspberry Pi.

## ARM CPU Families.

ARM produced the ARM11 family of processors. Earlier processor families where called ARM10, ARM9 and so forth.

The ARM CPU ARM1176JZF-S belongs to the ARM11 family as can be seen by the first part (ARM11) of it's name. It has it's own [ARM1176JZF-S Technical Reference Manual](https://developer.arm.com/documentation/ddi0301/h/programmer-s-model/exceptions/exception-vectors)

The early Raspberry Pi versions used a single ARM1176JZF-S CPU which is a 32bit CPU at 700 Mhz. (Just for your information, the ARM11 family also contains the CPUs ARM1136, ARM1156 (added Thumb2 instructions), ARM1176 (used on the early Raspberry Pi and added security extensions), ARM11MPCore (added multicore support))

ARM eventually released their Cortex lineup of CPUs with replaced ARM11 and ARM11 was discontinued.

The Cortex family has three branches. The branches are

- Cortex-M for embedded applications. (Cortex-M0, Cortex-M3, Cortex-M4, ...)
- Cortex-A for end-user application grade software. (Cortex-A7, Cortex-A53, ...)
- Cortex-R for real-time applications.

The later Raspbery Pi use CPU from the Cortex-A processor branch. Later Raspberry Pi versions used four Cortex-A7 CPUs in their SoC and even later Raspberry Pi versions used four Cortex-A53 CPU in their SoC which makes the SoC, quad-core SoCs.

## Instruction Sets

Now that the terms SoC and CPU have been established, the only term left is the term Instruction Set.
The Instruction Set is important for the software development part of bare metal programming because it determines which assembler instructions are available and which effects those assembly instructions have.

The instructions set used by the Raspberry Pi are

- ARMv6 for the Raspberry Pi 1
- ARMv7 for the Raspberry Pi 2 v1.1
- ARMv8 for the Raspberry Pi 2 v1.2
- ARMv8 for the Raspberry Pi 3
- ARMv8 for the Raspberry Pi 4

ARMv6 is 32 bit and it is used in the ARM11 family.
ARMv7 is 32 bit and it is used in the Cortex family.
ARMv8 is 32/64 bit and it is used in the Cortex family.

## Documentation

For information about the Broadcom SoC look for the documentation section on the Raspberry Pi Foundation website.

For information about the ARM1176JZF-S CPU, the Cortex-A CPUs and the ARM InstructionSets, consult the ARM website.

There is the ARM (A)rchitectural (R)eference (M)anual also called ARM ARM. So if some article talks about (arm arm) you now know that they refer to the ARM Architectural Reference Manual.
