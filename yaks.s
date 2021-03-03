YKEnterMutex:
    cli
    ret

YKExitMutex:
    sti
    ret

YKSaveContext:
    pushf           ; Saving Flags
    push cs         ; Code Segment
    push word[bp+2] ; Instruction Pointer

    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push es
    push ds

    mov bx, [TaskToSave]
    mov [bx], sp

    jmp YKRestoreContext

YKDispatcher:
    push bp
    mov bp, sp
    push ax
    mov ax, word[bp+4]
    cmp al, 1
    pop ax
    je YKSaveContext
YKRestoreContext:
    mov bx, [RunningTask]
    mov sp, [bx]

    pop ds
    pop es
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    iret    ; Restores Flags, Code Segment, and the Instruction Pointer.

YKTick:
    ;Save Context
    push AX
    push BX
    push CX
    push DX
    push BP
    push SI
    push DI
    push DS
    push ES

    call YKEnterISR

    sti
    call YKTickHandler
    cli

    call YKExitISR

    mov al, 0x20
    out 0x20, al
    pop ES
    pop DS
    pop DI
    pop SI
    pop BP
    pop DX
    pop CX
    pop BX
    pop AX
    iret
