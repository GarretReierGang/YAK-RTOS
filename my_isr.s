reset:
	mov ax, 0
	push ax
	call exit
tick:
	push AX
	push BX
	push CX
	push DX
	push BP
	push SI
	push DI
	push DS
	push ES
	sti
	call tick_handler
	cli
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
keyboard:
	push AX
	push BX
	push CX
	push DX
	push BP
	push SI
	push DI
	push DS
	push ES
	sti
	call keyboard_handler
	cli
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