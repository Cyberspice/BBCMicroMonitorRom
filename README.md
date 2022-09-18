# BBC Micro Machine Code Monitor ROM

## Introduction

This is a BBC Micro machine code monitor ROM that fits in 4K. It
supports:

- Memory dumps
- Disassembly
- Setting memory values
- Executing from a memory location

It also has its own 'language' which supports all of the above
with simple command names together with break points and register
value reading and setting.

## Help

The monitor supports help.

!(Example help)[/images/help.png]

## Star Commands

MDISS ADDRESS (<+RANGE>|<END>) (<ROM>)

This command disassembles 6502 opcodes starting at ADDRESS in memory.
If no RANGE or END is specified it disassembles 8 bytes. If a RANGE
preceded by + is specified it disassembles at least RANGE bytes. If
END is specified it disassembles at least up to END in memory. If ROM
is specified it will switch to that sideways ROM bank.

!(Example use of MDISS)[/images/mdiss.png]

MDUMP ADDRESS (<+RANGE>|<END>) (<ROM>)

This command hex dumps data starting at ADDRESS in memory. If no RANGE
or END is specified it displays 8 bytes. If a RANGE preceded by + is
specified it displays at least RANGE bytes. If END is specified it
displays bytes up to END in memory. If ROM is specified it will switch
to that sideways ROM bank.

!(Example use of MDUMP)[/images/mdump.png]

MGO ADDRESS

JSR to code at the specified ADDRESS

MON

This command starts the monitor as a Language.

MSET ADDRESS <BYTE> (<BYTE>) ...

This command sets bytes in memory starting at the specified address.
Each byte is read and set, incrementing the address after each set.
You can set as many bytes as you can fit on a command line.

## Monitor language

The monitor language supports a command line which allows monitor 
commands and/or * commands. The commands are single character followed
by parameters. They are as follows:

D - Disassemble (Arguments as MDISS above)
G - Go to address (Arguments as MGO above)
M - dump Memory (Arguments as MDUMP above)
Q - Quit. I.e. return to BASIC
R - Display registers (See below)
S - Set memory (See below)

S - Set memory

This can be used in an alternative way to MSET. If you just 
specify the starting address, the address and current byte value
will be presented after which you may type a new byte value. Return
updates the value, at which point the next address and byte value
will be displayed. This is repeated until ESC is pressed.

!(Example use of set memory)[/images/s.png]

R - Show/set the shadow register values

R on its own will display the current shadow register values.
These values are set when a breakpoint occurs (See BRK) below.
All of the values may be updated except the program counter by
specifying the register name, equals, and value or flag bit 
characters, as an argument.

!(Example use of set registers)[/images/r_set.png]

## Breakpoints

The monitor language supports breakpoints via the BRK instruction.
Although the BRK instruction is one byte, the program counter is
moved on by two bytes. Typically, in non Acorn environments, the
second byte is a BRK identified. In normal usage on Acorn machines
the second byte is an error code and further bytes are a zero
byte terminated error string. The monitor treats error 0 as a true
break point (error 0 is "Silly" in BASIC). All other values are
treated as normal.

When a sequence BRK BRK is seen, execution is stopped, the registers
are displayed, and a prompt is shown which allows you to return to
the monitor command line or continue execution.

!(Example use of a breakpoint)[/images/brk.png]

The example above shows a small routine which prints 0 to 9.
The breakpoint is set in the loop. The user continues the first
couple of loops, before stopping execution, updating the value of
the accumulator, and then restarting execution.


