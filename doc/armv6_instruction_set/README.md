# Testing

You can use OakSim to test the instruction. OakSim is a simulator that works in the browser.

https://wunkolo.github.io/OakSim/

Beware: OakSim represents register values in hexadecimal notation but it does not prefix 0x to the numbers
but displays them like integer numbers. So if a register contains the number 10, you know that it in decimal notation contains the value 16.

# {S}

If a command's syntax supports a {S} modifier, the character 'S' can be added to the command.

e.g. MUL{S}{cond} {Rd}, Rn, Rm

```
MULS    r0, r2, r2
```

The {S} modifier causes the condition flags in the CPSR to be updated as a result of the command.

What does the above sentence even mean?
Aren't the condition flags in the CPSR always updated?????
I do not understand!!!?!?!!

# Condition Code Suffixes {cond}

https://www.keil.com/support/man/docs/armasm/armasm_dom1361289860997.htm

If a command's syntax supports a {cond} suffix, a condition code suffix can be added to the command.

e.g. MUL{S}{cond} {Rd}, Rn, Rm

The list of available condition code suffixes {cond} are:

| Suffix | Meaning                                   |
| ------ | ----------------------------------------- |
| EQ     | Equal                                     |
| NE     | Not equal                                 |
| CS     | Carry set (identical to HS)               |
| HS     | Unsigned higher or same (identical to CS) |
| CC     | Carry clear (identical to LO)             |
| LO     | Unsigned lower (identical to CC)          |
| MI     | Minus or negative result                  |
| PL     | Positive or zero result                   |
| VS     | Overflow                                  |
| VC     | No overflow                               |
| HI     | Unsigned higher                           |
| LS     | Unsigned lower or same                    |
| GE     | Signed greater than or equal              |
| LT     | Signed less than                          |
| GT     | Signed greater than                       |
| LE     | Signed less than or equal                 |
| AL     | Always (this is the default)              |

# mov

https://www.keil.com/support/man/docs/armasm/armasm_dom1361289878994.htm

mov - Move

## Syntax

```
MOV{S}{cond} Rd, Operand2
MOV{cond} Rd, #imm16
```

## Examples

```
MOVS   r3, r2, LSR #3
```

# ldr

https://www.keil.com/support/man/docs/armasm/armasm_dom1361289873425.htm
https://www.keil.com/support/man/docs/armasm/armasm_dom1361289873875.htm
https://www.keil.com/support/man/docs/armasm/armasm_dom1361289874275.htm
https://www.keil.com/support/man/docs/armasm/armasm_dom1361289874695.htm
https://www.keil.com/support/man/docs/armasm/armasm_dom1361289875065.htm
https://www.keil.com/support/man/docs/armasm/armasm_dom1361289875455.htm

ldr - Load Register

## Syntax

Immediate offset

```
LDR{type}{cond} Rt, [Rn {, #offset}] ; immediate offset
LDR{type}{cond} Rt, [Rn, #offset]! ; pre-indexed
LDR{type}{cond} Rt, [Rn], #offset ; post-indexed
LDRD{cond} Rt, Rt2, [Rn {, #offset}] ; immediate offset, doubleword
LDRD{cond} Rt, Rt2, [Rn, #offset]! ; pre-indexed, doubleword
LDRD{cond} Rt, Rt2, [Rn], #offset ; post-indexed, doubleword
```

PC relative

```
LDR{type}{cond}{.W} Rt, label
LDRD{cond} Rt, Rt2, label ; Doubleword
```

Register offset

```
LDR{type}{cond} Rt, [Rn, ±Rm {, shift}] ; register offset
LDR{type}{cond} Rt, [Rn, ±Rm {, shift}]! ; pre-indexed ; ARM only
LDR{type}{cond} Rt, [Rn], ±Rm {, shift} ; post-indexed ; ARM only
LDRD{cond} Rt, Rt2, [Rn, ±Rm] ; register offset, doubleword ; ARM only
LDRD{cond} Rt, Rt2, [Rn, ±Rm]! ; pre-indexed, doubleword ; ARM only
LDRD{cond} Rt, Rt2, [Rn], ±Rm ; post-indexed, doubleword ; ARM only
```

Register relative

```
LDR{type}{cond}{.W} Rt, label
LDRD{cond} Rt, Rt2, label ; Doubleword
```

Pseudo instruction

```
LDR{cond}{.W} Rt, =expr
LDR{cond}{.W} Rt, =label_expr
```

LDR unprivileged

```
LDR{type}T{cond} Rt, [Rn {, #offset}] ; immediate offset (32-bit Thumb encoding only)
LDR{type}T{cond} Rt, [Rn] {, #offset} ; post-indexed (ARM only)
LDR{type}T{cond} Rt, [Rn], ±Rm {, shift} ; post-indexed (register) (ARM only)
```

## Examples

```
ldr pc, =_reset_
```

The statement is part of the ldr pseudo instruction flavor. (See https://stackoverflow.com/questions/37840754/what-does-an-equals-sign-on-the-right-side-of-a-ldr-instruction-in-arm-mean).

The value _reset_ denotes an address that is then resolved and moved to pc.
Pseudo instruction means that the assembler will preprocess the command and then encode the result into assembler instruction.

```
ldr pc, _reset_h
```

# mul

https://www.keil.com/support/man/docs/armasm/armasm_dom1361289882394.htm

mul - Multiply

# bl

https://www.keil.com/support/man/docs/armasm/armasm_dom1361289865686.htm

branch with link

Do not confuse with bal. bal is a variantion of the branch (b) instruction and means branch always.
bal has nothing to do with branch with link (bl)

# b

https://www.keil.com/support/man/docs/armasm/armasm_dom1361289863797.htm

branch
