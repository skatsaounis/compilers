xseg segment public'code'
	assume cs:xseg, ds:xseg, ss:xseg
	org 100h
main proc near
	call near ptr _solve
	mov ax,4C00h
	int 21h
main endp
@0:
_move proc near
	push bp
	mov bp,sp
	sub sp,0

@1:
	lea si,byte ptr @str1
	push si

@2:
	sub sp,2
	mov si, word [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	push word ptr [si+4]
	call near ptr _puts
	add sp,2+4

@3:
	mov si, word ptr [bp + (10)]
	push si

@4:
	sub sp,2
	mov si, word [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	push word ptr [si+4]
	call near ptr _puts
	add sp,2+4

@5:
	lea si,byte ptr @str2
	push si

@6:
	sub sp,2
	mov si, word [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	push word ptr [si+4]
	call near ptr _puts
	add sp,2+4

@7:
	mov si, word ptr [bp + (8)]
	push si

@8:
	sub sp,2
	mov si, word [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	push word ptr [si+4]
	call near ptr _puts
	add sp,2+4

@9:
	lea si,byte ptr @str3
	push si

@10:
	sub sp,2
	mov si, word [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	push word ptr [si+4]
	call near ptr _puts
	add sp,2+4

@11:
@move_: mov sp,bp
	pop bp
	ret
_move endp

@12:
_hanoi proc near
	push bp
	mov bp,sp
	sub sp,5

@13:
	mov ax, word ptr [bp + (14)]
	mov dx,1
	cmp ax,dx
	jge @15

@14:
	jmp @30

@15:
	mov ax, word ptr [bp + (14)]
	mov dx,1
	sub ax,dx
	mov word ptr [bp + (-3)], ax

@16:
	mov al, word ptr [bp + (-3)]
	sub sp,1
	mov si,sp
	mov byte ptr [si],al

@17:
	mov si, word ptr [bp + (12)]
	push si

@18:
	mov si, word ptr [bp + (8)]
	push si

@19:
	mov si, word ptr [bp + (10)]
	push si

@20:
	sub sp,2
	mov si, word [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	push word ptr [si+4]
	call near ptr _hanoi
	add sp,8+4

@21:
	mov si, word ptr [bp + (12)]
	push si

@22:
	mov si, word ptr [bp + (10)]
	push si

@23:
	sub sp,2
	mov si, word [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	push word ptr [si+4]
	call near ptr _move
	add sp,4+4

@24:
	mov ax, word ptr [bp + (14)]
	mov dx,1
	sub ax,dx
	mov word ptr [bp + (-5)], ax

@25:
	mov al, word ptr [bp + (-5)]
	sub sp,1
	mov si,sp
	mov byte ptr [si],al

@26:
	mov si, word ptr [bp + (8)]
	push si

@27:
	mov si, word ptr [bp + (10)]
	push si

@28:
	mov si, word ptr [bp + (12)]
	push si

@29:
	sub sp,2
	mov si, word [bp+4]
	mov si, word ptr [bp+4]
	mov si, word ptr [bp+4]
	push word ptr [si+4]
	call near ptr _hanoi
	add sp,8+4

@30:
@hanoi_: mov sp,bp
	pop bp
	ret
_hanoi endp

@31:
_solve proc near
	push bp
	mov bp,sp
	sub sp,4

@32:
	lea si,byte ptr @str4
	push si

@33:
	sub sp,2
	mov si, word [bp+4]
	mov si, word ptr [bp+4]
	push word ptr [si+4]
	call near ptr _puts
	add sp,2+4

@34:
	lea si, word ptr [bp + (-4)]
	push si

@35:
	sub sp,2
	mov si, word [bp+4]
	mov si, word ptr [bp+4]
	push word ptr [si+4]
	call near ptr _geti
	add sp,0+4

@36:
	mov ax, word ptr [bp + (-4)]

@37:
	mov al, word ptr [bp + (-2)]
	sub sp,1
	mov si,sp
	mov byte ptr [si],al

@38:
	lea si,byte ptr @str5
	push si

@39:
	lea si,byte ptr @str6
	push si

@40:
	lea si,byte ptr @str7
	push si

@41:
	sub sp,2
	mov si, word [bp+4]
	mov si, word ptr [bp+4]
	push word ptr [si+4]
	call near ptr _hanoi
	add sp,8+4

@42:
@solve_: mov sp,bp
	pop bp
	ret
_solve endp

@str1 	db 'Moving from '
	db 00
@str2 	db ' to '
	db 00
@str3 	db '.'
	db 10
	db 00
@str4 	db 'Rings: '
	db 00
@str5 	db 'left'
	db 00
@str6 	db 'right'
	db 00
@str7 	db 'middle'
	db 00

	extrn _puts : proc
	extrn _geti : proc
xseg ends
	end main
