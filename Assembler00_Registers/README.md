# Registers

| Register Name | Alias | Description    | Use in ARM Procedure Call Standard                                              |
| ------------- | ----- | -------------- | ------------------------------------------------------------------------------- |
| R0            |       |                | Scratch Register. Used to pass parameters. Will be overwritten by subroutines.  |
| R1            |       |                | Scratch Register. Used to pass parameters. Will be overwritten by subroutines.  |
| R2            |       |                | Scratch Register. Used to pass parameters. Will be overwritten by subroutines.  |
| R3            |       |                | Scratch Register. Used to pass parameters. Will be overwritten by subroutines.  |
| R4            |       |                | Preserve Register. Stack before using. Restore before returning.                |
| R5            |       |                | Preserve Register. Stack before using. Restore before returning.                |
| R6            |       |                | Preserve Register. Stack before using. Restore before returning.                |
| R7            |       |                | Preserve Register. Stack before using. Restore before returning.                |
| R8            |       |                | Preserve Register. Stack before using. Restore before returning.                |
| R9            |       |                | Preserve Register. Stack before using. Restore before returning.                |
| R10           |       |                | Preserve Register. Stack before using. Restore before returning.                |
| R11           |       |                | Preserve Register. Stack before using. Restore before returning.                |
| R12           |       |                | Scratch Register. Used to pass parameters. Will be overwritten by subroutines.  |
| R13           | SP    | StackPointer   |                                                                                 |
| R14           | LR    | LinkRegister   | Set by BL or BLX on entry of routine. Overwritten by further use of BL and BLX. |
| R15           | PC    | ProgramCounter |                                                                                 |
| R16           | CPSR  | StatusRegister |                                                                                 |

# Scratch Registers in the ARM Procedure Call Standard

r0-r3 and r12 are so called scratch registers in the ARM Procedure Call Standard. The calling routine has to be prepared to loose the contents of those registers when calling a routine because the convention is that those register will not be stored and restored by the caller. The caller is free to use those registers and to override the values without taking an precautions.

# Preserve Registers in the ARM Procedure Call Standard

r4-r11 are so called preserve registers in the ARM Procedure Call Standard. The Callee has to stack/save and restore them. The convention says that a callee will keep all values in the preserve registers in tact. This means a caller can be assured that there is no data lost during a function call when the data is stored in one of the preserve registers.
