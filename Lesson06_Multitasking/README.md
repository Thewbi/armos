# Multitasking

## Links

- https://s-matyukevich.github.io/raspberry-pi-os/docs/lesson04/rpi-os.html
- https://github.com/LdB-ECM/Raspberry-Pi
- https://github.com/danielbathke/PIqueno/blob/master/scheduler.c

## Introduction

Running two processes/applications at the same time is called multitasking.

In cooperative multitasking, also known as non-preemptive multitasking, a process gives up control of the processor so other processes can execute. The downside is that an badly written or malisious application can hog the CPU and it cannot be forced to hand over control starving all other processes and the operating system itself. Aside from actively hogging the CPU, a flawed application can execute an endless loop and then never hand over control.

In preemptive multitasking, control over the CPU is actively taken away from a process and given to another process.
A timer is set to a certain frequency. It will cause an interrupt at that frequency. The interrupt handler calls the scheduler. The scheduler is implemented using one of the myriad of existing scheduling algorithms to decide which process is executed next. The current process is then interrupted, the control is given to the process that the scheduler did determine.

See Chapter 2.5.3 of [1] "... A Real-Time Operating System (RTOS) can be used to handle the task scheduling (Figure 2.11). An RTOS allows multiple processes to be executed concurrently, by dividing the processor's time into time slots and allocating the time slots to the processes that require services. A timer is needed to handle the timekeeping for the RTOS, and at the end of each time slot, the timer generates a timer interrupt, which triggers the task scheduler and decides if context switching should be carried out. If yes, the current executing process is suspended and the processor executes another process."

## Multitasking in ARM

How to setup the interrupt handler
Simple scheduling algorithm

When the interrupt occurs, the handler is called.
The handler will

- save CPU state (= CPSR status register) in the process structure, so should the process be continued later, the processor state can be taken from the process structure and written back into the CPU
- save the process's stack
- save the processes pages from the MMU page tables into the process structure, so the page table can be restored later. Another option is to only store the address to the page tables and let the page table reside in memory.
- It will call the scheduler to determine the next process to run
- Restore the processes page table and set them into the MMU. If the process structure only stores the address of the process's page table, that base address has to be set into the base address register of CP15.
- It will restore that process's state (= restore CPSR status register)
- It will restore that process's stack
- continue the CPU on the new process

https://developer.arm.com/documentation/den0024/a/The-Memory-Management-Unit/Context-switching

# Glossary

[1] "The Definitive Guide to ARM CORTEX-M3 ARM CORTEX-M4 Processors, 3rd Edition by Joseph Yiu"

# Next Steps

- Try out the code from https://github.com/danielbathke/PIqueno/blob/master/scheduler.c
- Connect the scheduler to the ARM/CPU Timer
