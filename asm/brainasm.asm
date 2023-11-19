;-----------------------------------------------------------------------------------------
; Interpreter for the esoteric programming language brainfuck
;
; In this implementation each cell will have one byte assigned to it
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
; Registers:
; RAX: instruction pointer
; RBX: cell pointer
; RCX: temporary variables
; RDX: current character
;-----------------------------------------------------------------------------------------

main:
  call read_input         ;read code input from stdin
  call init_pointers      ;initialize registers
    
  ;step through input string
  loop_step:
    mov dl, [input + rax] ;move current char into dl

    cmp dl, 0             ;check for end of string (null-terminated)
    je exit
    
    call switch_char      ;interprete character
    
    inc rax
    jmp loop_step

exit:
  mov rax, 60
  mov rdi, 0
  syscall

error:
  mov rax, 60
  mov rdi, 0
  syscall
    
read_input:
  ;read from stdin (rax = 0, rdi = 0) to address input with size input_size
  xor rax, rax 
  xor rdi, rdi
  mov rsi, input
  mov rdx, INPUT_SIZE
  syscall
  ret

init_pointers:
  xor rax, rax
  xor rbx, rbx
  xor rcx, rcx
  xor rdx, rdx
  ret

  
switch_char:
  ;command description from https://en.wikipedia.org/wiki/Brainfuck
  case1:                
    ; > Increment the data pointer
    cmp dl, '>'
    jne case2
    cmp rbx, CELL_COUNT
    jge error   ; exit on out of bounds (upper)
    inc rbx
    jmp end
  
  case2:                
    ; < Decrement the data pointer
    cmp dl, '<'
    jne case3
    cmp rbx, 0
    je error    ; exit on out of bounds (lower)
    dec rbx
    jmp end
  
  case3:                
    ; + Increment the byte at the data pointer
    cmp dl, '+'
    jne case4
    inc byte [cells + rbx]
    jmp end
    
  case4:                
    ; - Decrement the byte at the data pointer
    cmp dl, '-'
    jne case5
    dec byte [cells + rbx]
    jmp end
    
  case5:                
    ; . Output the byte at the data pointer
    cmp dl, '.'
    jne case6
    
    push rax
    mov rax, 1
    mov rdi, 1
    lea rsi, [cells + rbx]
    mov rdx, 1
    syscall
    pop rax
    jmp end
    
  case6:                
    ; , Accept one byte of input, storing its value in the byte at the data pointer
    cmp dl, ','
    jne case7

    push rax
    xor rax, rax
    xor rdi, rdi
    lea rsi, [cells + rbx]
    mov rdx, 1
    syscall
    pop rax
    jmp end
    
  case7:                
    ; [ If the byte at the data pointer is zero, then instead of moving the instruction
    ; pointer forward to the next command, jump forward to the command after the
    ; matching ] command
    cmp dl, '['
    jne case8
    
    mov cl, [cells + rbx]
    cmp cl, 0
    jne case8
    
    mov cl, 1
    o_brack_loop:
      inc rax
      cmp rax, INPUT_SIZE
      jg error  ; exit on missing matching closing bracket
      mov dl, [input + rax]
      o_if:
        cmp dl, '['
        jne o_elif
        inc cl
        jmp o_end
      o_elif:
        cmp dl, ']'
        jne o_end
        dec cl
      o_end:
      
      cmp cl, 0
      jne o_brack_loop
    jmp end
    
  case8:                
    ; ] If the byte at the data pointer is nonzero, then instead of moving the instruction
    ; pointer forward to the next command, jump back to the command after the 
    ; matching [ command
    cmp dl, ']'
    jne end
    
    mov cl, [cells + rbx]
    cmp cl, 0
    je end
    
    mov cl, -1
    c_brack_loop:
      dec rax
      cmp rax, 0
      je error  ; exit on missing matching opening bracket
      mov dl, [input + rax]
      c_if:
        cmp dl, '['
        jne c_elif
        inc cl
        jmp c_end
      c_elif:
        cmp dl, ']'
        jne c_end
        dec cl
      c_end:
  
      cmp cl, 0
      jne c_brack_loop
  end:
    ret
  

  
  
