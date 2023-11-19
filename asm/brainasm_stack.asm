;-----------------------------------------------------------------------------------------
; Interpreter for the esoteric programming language brainfuck
;
; In this implementation each cell will have eight bytes (64 bit) assigned to it.
; The code input and cells will be stored on the stack, as to avoid indirect addressing and
; memory, as the MemeASM standard doesn't provide any commands for direct memory access.
; This problem is circumvented by pushing/popping from the stack. This however means that
; the Stackpointer has to be moved which results in everything below the new location of
; rsp to be abandoned to the OS wilderness. It is a gamble and we can only hope that this
; memory won't be overwritten until we're ready to set rsp to its correct location again.
; This code is guaranteed to induce horrible pain in anyone who has written atleast two
; lines of assembly in their life, but I don't see any other option.
;-----------------------------------------------------------------------------------------

INPUT_SIZE: equ 10000     ; maximum size the input buffer should have
CELL_B_CNT: equ 80000     ; number of cells times 8

section .text
global _start
_start:

;-----------------------------------------------------------------------------------------
; Registers:
; RAX: instruction pointer  (absolute, BYTE increment scaling)
; RBX: data pointer         (relative to R9, QWORD increment scaling)    
; RCX: temporary variables
; RDX: current character
; R8:  input address
; R9:  data address
; R10: temporary variables  (mainly for saving RSP)
; R11: temporary variables
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
; Stack layout:
;  _____________________
; |      R8 (input)     |
; |         ...         | <- RAX (absolute, BYTE scaling)
; |     max 10k chars   |
; |---------------------|
; |       R9 (data)     |
; |         ...         | <- RBX  (relative, QWORD scaling)
; |---------------------|
; |                     | <- RSP
;  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
; RAX stores the absolute address of the first char of the input-string.
; RBX stores the cell offset relative to the first cell. The first cells address is stored
; in R9.
; This offset is in QWORD scaling and 0-indexed, meaning cell 1 has offset 0, cell 2 has
; offset 1, cell 3 has offset 2 etc. Each cell is 64 bit wide.
;-----------------------------------------------------------------------------------------


main:
  ; preserve callee-saved registers
  push rbx
  push rbp
  push r12
  push r13
  push r14
  mov rbp, rsp

  ;initialize registers
  xor rax, rax
  xor rbx, rbx
  xor rcx, rcx
  xor rdx, rdx
  xor r8, r8
  xor r9, r9
  xor r10, r10
  xor r11, r11

  sub rsp, 8  
  mov r8, rsp         ; set input start address        
  sub rsp, INPUT_SIZE  ; set maximum extent for input
  
  ;;read code input from stdin
  ;loop:
  ;  sub rsp, 1        ; allocate space for one char on stack
  ;  cmp rsp, r9 
  ;  jle exit          ; exit on input size too large
;
  ;  xor rax, rax      ; sys_read
  ;  xor rdi, rdi      ; stdin
  ;  mov rsi, rsp      ; save onto stack
  ;  mov rdx, 1        ; read 1 byte
  ;  syscall
  ;  
  ;  cmp rax, 0        ; check rax for end of input
  ;  ;cmp rax, 0x04     ; check rax for EOT
  ;  jne loop

  ;read from stdin (rax = 0, rdi = 0) to stack with size input_size
  xor rax, rax 
  xor rdi, rdi
  mov rsi, r8
  mov rdx, INPUT_SIZE
  syscall

  ;pop rdx
  xor rax, rax
  ; end of reading - now the input string should be saved on the stack
    
  mov r9, rsp         ; set data start address
  sub r9, 8
  sub rsp, CELL_B_CNT ; reserve 10000 8-byte-cells (80kB)
  
  ;step through input string
  mov rax, r8
  loop_step: 
    cmp rax, r9         ; check for end of string (beginning of data)
    je exit

    mov r10, rsp        ; save current rsp for later
    mov rsp, rax
    pop dl              ; move current char into dl
    mov rsp, r10        ; quickly put rsp back to where it belongs
    call switch_char    ; interprete character
    sub rax, 1
    jmp loop_step

exit:
  ;mov rsp, r8
  mov rsp, rbp
  pop r14
  pop r13
  pop r12 
  pop rbp
  pop rbx

  mov rax, 60
  mov rdi, 0
  syscall
  
  
print_char:
 ; prints char in dl
  push rax
  push rdx
  mov rax, 1
  mov rdi, 1
  mov rsi, rsp    ; print char on stack
  mov rdx, 1      ; write 1 byte
  syscall
  pop rdx
  pop rax
  ret
  
error: 
  mov rsp, rbp
  pop r14
  pop r13
  pop r12 
  pop rbp
  pop rbx

  mov rax, 60
  mov rdi, 0
  syscall
  ret

  
switch_char:
; command description from https://en.wikipedia.org/wiki/Brainfuck
case1:                
  ; > Increment the data pointer
  cmp dl, '>'
  jne case2
  cmp rbx, CELL_B_CNT
  jge error   ; exit on out of bounds (upper)
  inc rbx
  jmp end

case2:                
  ; < Decrement the data pointer
  cmp dl, '<'
  jne case3
  cmp rbx, 0
  je error  ; exit on out of bounds (lower)
  dec rbx
  jmp end

case3:                
  ; + Increment the byte at the data pointer
  cmp dl, '+'
  jne case4
  
  mov r10, rsp
  mov rsp, r9
  mov rcx, rbx
  shl rcx, 3
  sub rsp, rcx        ; calculate data address
  
  pop rcx             ; get cells contents
  inc rcx
  push rcx
  mov rsp, r10
  jmp end
  
case4:                
  ; - Decrement the byte at the data pointer
  cmp dl, '-'
  jne case5
  
  mov r10, rsp
  mov rsp, r9
  mov rcx, rbx
  shl rcx, 3
  sub rsp, rcx        ; calculate data address
  
  pop rcx             ; get cells contents
  dec rcx
  push rcx
  mov rsp, r10
  
  jmp end
  
case5:                
  ; . Output the byte at the data pointer
  cmp dl, '.'
  jne case6
  
  push rax
  push rbx
  push rdx
  mov rax, 1          ; sys_write
  mov rdi, 1
  
  mov rcx, r9
  shl rbx, 3
  sub rcx, rbx        ; calculate data address
  mov rsi, rcx
  
  mov rdx, 1
  syscall
  pop rdx
  pop rbx
  pop rax
  
  jmp end
  
case6:                
  ; , Accept one byte of input, storing its value in the byte at the data pointer
  cmp dl, ','
  jne case7
  push rax
  push rbx
  push rdx
  xor rax, rax        ; sys_read
  xor rdi, rdi        ; stdin
  
  mov rcx, r9
  shl rbx, 3
  sub rcx, rbx        ; calculate data address
  mov rsi, rcx
  
  mov rdx, 1
  syscall
  pop rdx
  pop rbx
  pop rax
  
  jmp end
  
case7:                
  ; [ If the byte at the data pointer is zero, then instead of moving the instruction
  ; pointer forward to the next command, jump it forward to the command after the
  ; matching ] command
  cmp dl, '['
  jne case8
  
  
  mov rcx, r9
  mov r11, rbx
  shl r11, 3
  sub rcx, r11        ; calculate data address
  
  mov r10, rsp
  mov rsp, rcx
  pop rcx
  mov rsp, r10
  
  cmp rcx, 0          ; check if byte is zero
  jne end
  
  push rbx
  push rdx
  mov rcx, 1
  
  o_brack_loop:
    sub rax, 1        ; step forward
    sub r9, rax       ; transform to relative
    cmp r9, INPUT_SIZE
    jg error          ; exit on missing matching closing bracket
    add r9, rax       ; transform back to absolute


    mov r10, rsp
    mov rsp, rax
    pop rdx           ; get input char
    mov rsp, r10
  
    o_if:
      cmp dl, '['
      jne o_elif
      inc rcx
      jmp o_end
    o_elif:
      cmp dl, ']'
      jne o_end
      dec rcx
    o_end:

    cmp rcx, 0
    jne o_brack_loop  ; break if the number of '[ is the same as for ']'
    
    
  pop rdx
  pop rbx
  jmp end
  
case8:                
  ; ] If the byte at the data pointer is nonzero, then instead of moving the instruction
  ; pointer forward to the next command, jump it back to the command after the 
  ; matching [ command
  cmp dl, ']'
  jne end
  
  mov rcx, r9
  mov r11, rbx
  shl r11, 3
  sub rcx, r11        ; calculate data address
  
  mov r10, rsp
  mov rsp, rcx
  pop rcx
  mov rsp, r10
  
  cmp rcx, 0          ; check if byte is nonzero
  je end
  
  push rbx
  push rdx  
  ; mov rcx, -1
  mov rcx, 0
  sub rcx, 1
  
  c_brack_loop:
    add rax, 1        ; step back
    sub r9, rax       ; transform to relative
    cmp rax, 0
    je error          ; exit on missing matching opening bracket
    add r9, rax       ; transform back to absolute
    
    mov r10, rsp
    mov rsp, rax
    pop rdx           ; get input char
    mov rsp, r10
  
    c_if:
      cmp dl, '['
      jne c_elif
      inc rcx
      jmp c_end
    c_elif:
      cmp dl, ']'
      jne c_end
      dec rcx
    c_end:

    cmp rcx, 0
    jne c_brack_loop  ; break if the number of '[ is the same as for ']'
    
  pop rdx
  pop rbx

end:
  ret