YKEnterMutex:
    cli
    ret

YKExitMutex:
    sti
    ret

YKDispatcher: ; Saves current Context if needed and than starts new task.
	push BP
	mov BP, SP
	push AX   ; save AX register
	mov AX, [BP+4]
	cmp AX, 1 ; Check to see if we should save context
  pop AX    ; Restore ax Register
	je YKSaveContext
YKRestoreContext:
  mov	sp, [restorePointer] ; //Restoring stack pointer.
  pop	ax  ; -0
  pop	bx  ; -2
  pop	cx  ; -4
  pop	dx  ; -6
  pop	es  ; -8
  pop	ds  ; -10
  pop	di  ; -12
  pop	si  ; -14
  pop	bp  ; -16;
  iret    ; iret restores IP, CS, and Flags. popped in that order.

YKSaveContext:
  pushf            ; Saving flags
  push	cs         ; -20
  push	word[bp+2] ;-18
  push	word[bp]   ;-16
  push	si ;14
  push	di ;-12
  push	ds ;-10
  push	es ;-8
  push	dx ;-6
  push	cx ;-4
  push	bx ;-2
  push	ax ;-0
  mov	[savePointer], sp ; Stack Pointer.
  jmp	YKRestoreContext

YKRunTaskFirst:
	mov	si, word [runningTask]
	mov sp, word [si]
	mov	si, word [si]
	mov ax, word [si]
	call ax
