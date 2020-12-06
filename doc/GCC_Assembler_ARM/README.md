# GCC as

The GNU Compiler Collection Assembler is described here: https://sourceware.org/binutils/docs/as/

It contains "ARM Dependent Features" described in chapter 9 (https://sourceware.org/binutils/docs/as/ARM_002dDependent.html#ARM_002dDependent)

The GCC as is used as part of the toolchain that was used for these tutorials.

## Selecting ARM or THUMB instruction sets

.arm or .code 32 selects the ARM instruction set.

.thumb or .code 16 selects the THUMB instruction set. The THUMB instruction set is less performant but more dense to save space.

## Assembler Syntax

### Links

https://sourceware.org/binutils/docs/as/
https://sourceware.org/binutils/docs/as/Syntax.html

### Introduction

There are several different syntaxes depending on which toolchain is used.
The two most common are the ARM syntax and the GCC syntax.

The syntaxes are not compatible, i.e. a GCC tool will not be able to understand the ARM syntax and vice versa.

This document will describe the GCC syntax.

### Comments in GCC as

https://sourceware.org/binutils/docs/as/Comments.html#Comments states that there are single and multiline comments. Both are reduced to a single space.

Multiline comments are defined to be /\* ... \*/.

Single line comments are started by one or more characters. Which character or characters are used to start a single line comment depends on the target.

I have seen

- semicolon (;)
- double slash (//)
- semicolon followd by the at sign (;@)
- single at sign (@)

## Deal with

; ...
;@ ...
// ...
#define
.equ
.section
.balign
.section "name", "aw"
label: <INSTRUCTION>;
.globl <LABEL>;
.globl <LABEL>
.syntax unified
.arm
<LABEL>:
.long 0xE12EF30E

Everything else is a assembler instruction
mrs r0,cpsr
and r1, r0, #0x1F ;@ Mask off the CPU mode bits to register r1
cmp r1, #CPU_HYPMODE

ldr r2, = \_\_SVC_stack_core0
ldr r1, =#ARM6_CPU_ID
ands r5, r5, #0x3
