# [WIP] brainASM
This project is an interpreter for the esoteric programming language brainfuck, written in assembly. Included is a translation to the most excellent programming language [MemeAssembly](https://github.com/kammt/MemeAssembly).

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

### I just wanna run this without much of a hassle
Compile it online via [[myCompiler]](https://www.mycompiler.io/new/asm-x86_64)
### Compiling locally
Build your own executable locally with NASM and GNU Linker:
- brainasm.asm: 
```bash
nasm -f elf64 -o asm/object_a.o asm/brainasm.asm && ld -o asm/out_a asm/object_a.o
```
- brainasm_stack.asm
```bash
nasm -f elf64 -o asm/object_b.o asm/brainasm_stack.asm && ld -o asm/out_b asm/object_b.o
```
- brainasm_stack.memeasm:
```bash
memeasm -o memeasm/out_c memeasm/brainasm_stack.memeasm
```


## Examples
Examples can be found in `/examples/`. These can be passed to the interpreter like so: 
```bash
cat examples/helloworld.b | ./asm/out_a
```

- Hello World

```brainfuck
++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.
```

Output: `Hello World!`

- The mathematical constant e

```brainfuck
>>>>++>+>++>+>>++<+[[>[>>[>>>>]<<<<[[>>>>+<<<<-]<<<<]
>>>>>>]+<]>->>--[+[+++<<<<--]++>>>>--]+[>>>>]<<<<[<<+
<+<]<<[>>>>>>[[<<<<+>>>>-]>>>>]<<<<<<<<[<<<<]>>-[<<+>
>-]+<<[->>>>[-[+>>>>-]-<<-[>>>>-]++>>+[-<<<<+]+>>>>]<
<<<[<<<<]]>[-[<+>-]]+<[->>>>[-[+>>>>-]-<<<-[>>>>-]++>
>>+[-<<<<+]+>>>>]<<<<[<<<<]]<<]>>>+[>>>>]-[+<<<<--]++
[<<<<]>>>+[>-[>>[--[++>>+>>--]-<[-[-[+++<<<<-]+>>>>-]
]++>+[-<<<<+]++>>+>>]<<[>[<-<<<]+<]>->>>]+>[>>>>]-[+<
<<<--]++<[[>>>>]<<<<[-[+>[<->-]++<[[>-<-]++[<<<<]+>>+
>>-]++<<<<-]>-[+[<+[<<<<]>]<+>]+<[->->>>[-]]+<<<<]]>[
<<<<]>[-[-[+++++[>++++++++<-]>-.>>>-[<<<----.<]<[<<]>
>[-]>->>+[[>>>>]+[-[->>>>+>>>>>>>>-[-[+++<<<<[-]]+>>>
>-]++[<<<<]]+<<<<]>>>]+<+<<]>[-[->[--[++>>>>--]->[-[-
[+++<<<<-]+>>>>-]]++<+[-<<<<+]++>>>>]<<<<[>[<<<<]+<]>
->>]<]>>>>[--[++>>>>--]-<--[+++>>>>--]+>+[-<<<<+]++>>
>>]<<<<<[<<<<]<]>[>+<<++<]<]>[+>[--[++>>>>--]->--[+++
>>>>--]+<+[-<<<<+]++>>>>]<<<[<<<<]]>>]>]
```

Note: Has to be manually terminated. [[brainfuck.org]](http://brainfuck.org/)

Output: `2.71828182845904523536028747135266249775...`
- Sierpiński triangle
```brainfuck
++++++++[>+>++++<<-]>++>>+<[-[>>+<<-]+>>]>+[-<<<[->[+
[-]+>++>>>-<<]<[<]>>++++++[<<+++++>>-]+<<++.[-]<<]>.>
+[>>]>+]
```
Output: 
```
                               *
                              * *
                             *   *
                            * * * *
                           *       *
                          * *     * *
                         *   *   *   *
                        * * * * * * * *
...
```
