;-----------------------------------------------------------------------------------------
;Interpreter for the esoteric programming language brainfuck
;
;In this implementation each cell will have 4 bytes (quadword) assigned to it, as to allow
;bigger values
;-----------------------------------------------------------------------------------------

INPUT_SIZE: equ 10000       ;maximum size the input buffer should have
CELL_COUNT: equ 10000

section .bss
;reserve space for input and cells
input: resb INPUT_SIZE      ;address at which input code will be stored
cells: resb CELL_COUNT      ;address at which the machines cells will be stored

section .text
global _start
_start:

;-----------------------------------------------------------------------------------------
; Register :
; EAX: instruction pointer
; EBX: cell pointer
; ECX: temporary variables
; EDX: current character
;-----------------------------------------------------------------------------------------

main:
  call read_input         ;read code input from stdin
  call init_pointers      ;initialize registers
    
  ;step through input string
  loop_step:
    mov dl, [input + eax] ;move current char into dl

    cmp dl, 0             ;check for end of string (null-terminated)
    je exit
    
    call switch_char      ;interprete character
    
    inc eax
    jmp loop_step

exit:
  mov rax, 60
  mov rdi, 0
  syscall
    
read_input:
  ;read from stdin (rax = 0, rdi = 0) to addres input with size input_size
  xor rax, rax 
  xor rdi, rdi
  mov rsi, input
  mov rdx, INPUT_SIZE
  syscall
  ret

init_pointers:
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx
  ret
  
switch_char:
  ;command description from https://en.wikipedia.org/wiki/Brainfuck
  case1:                
    ; > Increment the data pointer
    cmp dl, 0x3E
    jne case2
    inc ebx
    jmp end
  
  case2:                
    ; < Decrement the data pointer
    cmp dl, 0x3C
    jne case3
    dec ebx
    jmp end
  
  case3:                
    ; + Increment the byte at the data pointer
    cmp dl, 0x2B
    jne case4
    inc qword [cells +ebx]
    jmp end
    
  case4:                
    ; - Decrement the byte at the data pointer
    cmp dl, 0x2D
    jne case5
    dec qword [cells +ebx]
    jmp end
    
  case5:                
    ; . Output the byte at the data pointer
    cmp dl, 0x2E
    jne case6
    
    push rax
    mov rax, 1
    mov rdi, 1
    lea rsi, [cells + ebx]
    mov rdx, 1
    syscall
    pop rax
    jmp end
    
  case6:                
    ; , Accept one byte of input, storing its value in the byte at the data pointer
    cmp dl, 0x2C
    jne case7

    push rax
    xor rax, rax
    xor rdi, rdi
    lea rsi, [cells + ebx]
    mov rdx, 1
    syscall
    pop rax
    jmp end
    
  case7:                
    ; [ If the byte at the data pointer is zero, then instead of moving the instruction
    ; pointer forward to the next command, jump it forward to the command after the
    ; matching ] command
    cmp dl, 0x5B
    jne case8
    
    mov cl, [cells + ebx]
    cmp cl, 0
    jne case8
    
    mov cl, 1
    o_brack_loop:
      inc eax
      mov dl, [input + eax]
      o_if:
        cmp dl, 0x5B
        jne o_elif
        inc cl
        jmp o_end
      o_elif:
        cmp dl, 0x5D
        jne o_end
        dec cl
      o_end:
      
      cmp cl, 0
      jne o_brack_loop
    jmp end
    
  case8:                
    ; ] If the byte at the data pointer is nonzero, then instead of moving the instruction
    ; pointer forward to the next command, jump it back to the command after the 
    ; matching [ command
    cmp dl, 0x5D
    jne end
    
    mov cl, [cells + ebx]
    cmp cl, 0
    je end
    
    mov cl, -1
    c_brack_loop:
      dec eax
      mov dl, [input + eax]
      c_if:
        cmp dl, 0x5B
        jne c_elif
        inc cl
        jmp c_end
      c_elif:
        cmp dl, 0x5D
        jne c_end
        dec cl
      c_end:
  
      cmp cl, 0
      jne c_brack_loop
  end:
    ret
  

  
  
