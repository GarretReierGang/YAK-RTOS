; Generated by c86 (BYU-NASM) 5.1 (beta) from yakc.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
queue_insertNode:
	jmp	L_yakc_1
L_yakc_2:
	mov	si, word [bp+4]
	mov	ax, word [si]
	test	ax, ax
	jne	L_yakc_3
	mov	ax, word [bp+6]
	mov	word [si], ax
	mov	si, word [bp+6]
	add	si, 10
	mov	word [si], 0
	mov	si, word [bp+6]
	add	si, 8
	mov	word [si], 0
	jmp	L_yakc_4
L_yakc_3:
	mov	si, word [bp+6]
	add	si, 4
	mov	di, word [bp+4]
	mov	di, word [di]
	add	di, 4
	mov	ax, word [di]
	cmp	ax, word [si]
	jle	L_yakc_5
	mov	si, word [bp+6]
	add	si, 10
	mov	word [si], 0
	mov	si, word [bp+4]
	mov	si, word [si]
	add	si, 10
	mov	ax, word [bp+6]
	mov	word [si], ax
	mov	si, word [bp+4]
	mov	di, word [bp+6]
	add	di, 8
	mov	ax, word [si]
	mov	word [di], ax
	mov	si, word [bp+4]
	mov	ax, word [bp+6]
	mov	word [si], ax
	jmp	L_yakc_4
L_yakc_5:
	mov	si, word [bp+4]
	mov	si, word [si]
	add	si, 8
	mov	ax, word [si]
	mov	word [bp-2], ax
	jmp	L_yakc_7
L_yakc_6:
	mov	si, word [bp-2]
	add	si, 8
	mov	ax, word [si]
	mov	word [bp-2], ax
L_yakc_7:
	mov	si, word [bp-2]
	add	si, 8
	mov	ax, word [si]
	test	ax, ax
	je	L_yakc_9
	mov	si, word [bp-2]
	add	si, 8
	mov	si, word [si]
	add	si, 4
	mov	di, word [bp+6]
	add	di, 4
	mov	ax, word [di]
	cmp	ax, word [si]
	jge	L_yakc_6
L_yakc_9:
L_yakc_8:
	mov	si, word [bp-2]
	add	si, 8
	mov	si, word [si]
	add	si, 10
	mov	ax, word [bp+6]
	mov	word [si], ax
	mov	si, word [bp-2]
	add	si, 8
	mov	di, word [bp+6]
	add	di, 8
	mov	ax, word [si]
	mov	word [di], ax
	mov	si, word [bp+6]
	add	si, 10
	mov	ax, word [bp-2]
	mov	word [si], ax
	mov	si, word [bp-2]
	add	si, 8
	mov	ax, word [bp+6]
	mov	word [si], ax
L_yakc_4:
	mov	sp, bp
	pop	bp
	ret
L_yakc_1:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_yakc_2
	ALIGN	2
queue_pop:
	jmp	L_yakc_11
L_yakc_12:
	mov	si, word [bp+4]
	mov	ax, word [si]
	mov	word [bp-2], ax
	mov	si, word [bp+4]
	mov	si, word [si]
	add	si, 8
	mov	di, word [bp+4]
	mov	ax, word [si]
	mov	word [di], ax
	mov	si, word [bp+4]
	mov	si, word [si]
	add	si, 10
	mov	word [si], 0
	mov	ax, word [bp-2]
L_yakc_13:
	mov	sp, bp
	pop	bp
	ret
L_yakc_11:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_yakc_12
	ALIGN	2
printQueue:
	jmp	L_yakc_15
L_yakc_16:
	jmp	L_yakc_18
L_yakc_17:
	mov	si, word [bp+4]
	add	si, 4
	push	word [si]
	call	printInt
	add	sp, 2
	mov	si, word [bp+4]
	add	si, 8
	mov	ax, word [si]
	mov	word [bp+4], ax
L_yakc_18:
	mov	ax, word [bp+4]
	test	ax, ax
	jne	L_yakc_17
L_yakc_19:
	mov	sp, bp
	pop	bp
	ret
L_yakc_15:
	push	bp
	mov	bp, sp
	jmp	L_yakc_16
	ALIGN	2
YKScheduler:
	jmp	L_yakc_21
L_yakc_22:
	mov	ax, word [runningTask]
	cmp	ax, word [YKRdyList]
	je	L_yakc_24
L_yakc_23:
	mov	si, word [runningTask]
	mov	ax, word [si]
	mov	word [savePointer], ax
	mov	ax, word [YKRdyList]
	mov	word [runningTask], ax
	mov	si, word [runningTask]
	mov	ax, word [si]
	mov	word [restorePointer], ax
	inc	word [YKCtxSwCount]
	mov	ax, 1
	push	ax
	call	YKDispatcher
	add	sp, 2
L_yakc_24:
	mov	sp, bp
	pop	bp
	ret
L_yakc_21:
	push	bp
	mov	bp, sp
	jmp	L_yakc_22
	ALIGN	2
YKIdleTask:
	jmp	L_yakc_26
L_yakc_27:
	jmp	L_yakc_29
L_yakc_28:
	inc	word [YKIdleCount]
L_yakc_29:
	jmp	L_yakc_28
L_yakc_30:
	mov	sp, bp
	pop	bp
	ret
L_yakc_26:
	push	bp
	mov	bp, sp
	jmp	L_yakc_27
	ALIGN	2
YKNewTask:
	jmp	L_yakc_32
L_yakc_33:
	mov	ax, word [bp+6]
	sub	ax, 2
	mov	word [bp-8], ax
	sub	word [bp-8], 2
	mov	si, word [bp-8]
	mov	word [si], 0
	sub	word [bp-8], 2
	mov	si, word [bp-8]
	mov	ax, word [bp+4]
	mov	word [si], ax
	sub	word [bp-8], 2
	mov	ax, word [bp+6]
	dec	ax
	mov	si, word [bp-8]
	mov	word [si], ax
	mov	word [bp-6], 0
	jmp	L_yakc_35
L_yakc_34:
	sub	word [bp-8], 2
	mov	si, word [bp-8]
	mov	word [si], 0
L_yakc_37:
	inc	word [bp-6]
L_yakc_35:
	cmp	word [bp-6], 8
	jl	L_yakc_34
L_yakc_36:
	mov	ax, word [YKAvailTCBList]
	mov	word [bp-2], ax
	mov	si, word [YKAvailTCBList]
	add	si, 8
	mov	ax, word [si]
	mov	word [YKAvailTCBList], ax
	mov	si, word [bp-2]
	mov	ax, word [bp-8]
	mov	word [si], ax
	mov	al, byte [bp+8]
	xor	ah, ah
	mov	si, word [bp-2]
	add	si, 4
	mov	word [si], ax
	mov	si, word [bp-2]
	add	si, 2
	mov	word [si], 0
	mov	si, word [bp-2]
	add	si, 6
	mov	word [si], 0
	push	word [bp-2]
	mov	ax, YKRdyList
	push	ax
	call	queue_insertNode
	add	sp, 4
	mov	ax, word [running]
	test	ax, ax
	je	L_yakc_38
	call	YKScheduler
L_yakc_38:
	mov	sp, bp
	pop	bp
	ret
L_yakc_32:
	push	bp
	mov	bp, sp
	sub	sp, 8
	jmp	L_yakc_33
	ALIGN	2
YKInitialize:
	jmp	L_yakc_40
L_yakc_41:
	mov	word [running], 0
	mov	word [YKAvailTCBList], YKTCBArray
	mov	word [bp-2], 0
	jmp	L_yakc_43
L_yakc_42:
	mov	ax, word [bp-2]
	inc	ax
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	push	ax
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	mov	dx, ax
	add	dx, YKTCBArray
	mov	si, dx
	add	si, 8
	pop	ax
	mov	word [si], ax
L_yakc_45:
	inc	word [bp-2]
L_yakc_43:
	cmp	word [bp-2], 5
	jl	L_yakc_42
L_yakc_44:
	mov	word [(68+YKTCBArray)], 0
	mov	al, 100
	push	ax
	mov	ax, (IdleStk+512)
	push	ax
	mov	ax, YKIdleTask
	push	ax
	call	YKNewTask
	add	sp, 6
	mov	word [YKIdleCount], 0
	mov	word [YKCtxSwCount], 0
	mov	word [YKTickNum], 0
	mov	ax, word [YKRdyList]
	mov	word [runningTask], ax
	mov	sp, bp
	pop	bp
	ret
L_yakc_40:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_yakc_41
	ALIGN	2
YKRun:
	jmp	L_yakc_47
L_yakc_48:
	mov	word [running], 1
	inc	word [YKCtxSwCount]
	mov	ax, word [YKRdyList]
	mov	word [runningTask], ax
	mov	si, word [runningTask]
	mov	ax, word [si]
	mov	word [restorePointer], ax
	xor	ax, ax
	push	ax
	call	YKDispatcher
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_yakc_47:
	push	bp
	mov	bp, sp
	jmp	L_yakc_48
	ALIGN	2
YKCtxSwCount:
	TIMES	2 db 0
YKIdleCount:
	TIMES	2 db 0
YKTickNum:
	TIMES	2 db 0
savePointer:
	TIMES	2 db 0
restorePointer:
	TIMES	2 db 0
running:
	TIMES	2 db 0
runningTask:
	TIMES	2 db 0
YKRdyList:
	TIMES	2 db 0
YKSuspList:
	TIMES	2 db 0
YKAvailTCBList:
	TIMES	2 db 0
YKTCBArray:
	TIMES	72 db 0
IdleStk:
	TIMES	512 db 0
