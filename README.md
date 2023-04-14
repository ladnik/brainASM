# Brainfuck interpreter
This project is a interpreter for the esoteric programming language brainfuck, written in assembly.

If you have any questions regarding this project or ideas on improving it, feel free to contact me.

## Background
> Brainfuck is an esoteric programming language created in 1993 by Urban Müller. Notable for its extreme minimalism, the language consists of only eight simple commands, a data pointer and an instruction pointer. While it is fully Turing complete, it is not intended for practical use, but to challenge and amuse programmers. [[Wikipedia]](https://en.wikipedia.org/wiki/Brainfuck)

## Implementation
In this project, two memory ranges are reserved: input and cells. The input brainfuck string is provided via stdin with a maximum buffer size of 10k characters. For each cell one byte of memory is reserved, in total there is space for 10k cells. These constants are defined as *INPUT_SIZE* and *CELL_COUNT*, respectively.
As Brainfuck has a very limited number of commands (8 in total: `< > + - , . [ ]`), a switch-like comparision is used to perform the desired actions.
Characters not defined as commands will be ignored.
The instruction pointer is stored in `EAX`, the cell pointer in `EBX`.

Further details are explained in the code's comments.

## Execution
Provide the brainfuck program to stdin, output will be sent do stdout.

Compile online via [[myCompiler]](https://www.mycompiler.io/new/asm-x86_64)

Compile locally with x86_64 NASM 

## Examples
1. Hello World

`++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.`

Output: `Hello World!`

2. Computing the mathematical constant e

`>>>>++>+>++>+>>++<+[[>[>>[>>>>]<<<<[[>>>>+<<<<-]<<<<]>>>>>>]+<]>->>--[+[+++<<<<--]++>>>>--]+[>>>>]<<<<[<<+<+<]<<[>>>>>>[[<<<<+>>>>-]>>>>]<<<<<<<<[<<<<]>>-[<<+>>-]+<<[->>>>[-[+>>>>-]-<<-[>>>>-]++>>+[-<<<<+]+>>>>]<<<<[<<<<]]>[-[<+>-]]+<[->>>>[-[+>>>>-]-<<<-[>>>>-]++>>>+[-<<<<+]+>>>>]<<<<[<<<<]]<<]>>>+[>>>>]-[+<<<<--]++[<<<<]>>>+[>-[>>[--[++>>+>>--]-<[-[-[+++<<<<-]+>>>>-]]++>+[-<<<<+]++>>+>>]<<[>[<-<<<]+<]>->>>]+>[>>>>]-[+<<<<--]++<[[>>>>]<<<<[-[+>[<->-]++<[[>-<-]++[<<<<]+>>+>>-]++<<<<-]>-[+[<+[<<<<]>]<+>]+<[->->>>[-]]+<<<<]]>[<<<<]>[-[-[+++++[>++++++++<-]>-.>>>-[<<<----.<]<[<<]>>[-]>->>+[[>>>>]+[-[->>>>+>>>>>>>>-[-[+++<<<<[-]]+>>>>-]++[<<<<]]+<<<<]>>>]+<+<<]>[-[->[--[++>>>>--]->[-[-[+++<<<<-]+>>>>-]]++<+[-<<<<+]++>>>>]<<<<[>[<<<<]+<]>->>]<]>>>>[--[++>>>>--]-<--[+++>>>>--]+>+[-<<<<+]++>>>>]<<<<<[<<<<]<]>[>+<<++<]<]>[+>[--[++>>>>--]->--[+++>>>>--]+<+[-<<<<+]++>>>>]<<<[<<<<]]>>]>]`

Note: Has to be manually terminated. Code stolen from Daniel B. Cristofani on [[brainfuck.org]](http://brainfuck.org/)

Output: `2.71828182845904523536028747135266249775...`
