xseg segment public'code'
	assume cs:xseg, ds:xseg, ss:xseg
	org 100h
main proc near
	call near ptr _main
	mov ax,4C00h
	int 21h
main endp
@0:
_swap proc near
	push bp
	mov bp,sp
	sub sp,2

@1:
	mov si, word ptr [bp + (10)]
	mov ax, word ptr [si]

@2:
	mov si, word ptr [bp + (8)]
	mov ax, word ptr [si]
	mov si, word ptr [bp + (10)]
	mov word ptr [si], ax

@3:
	mov ax, word ptr [bp + (-2)]
	mov si, word ptr [bp + (8)]
	mov word ptr [si], ax

@4:
@_swap_: mov sp,bp
	pop bp
	ret
_swap endp

@5:
_bsort proc near
	push bp
	mov bp,sp
	sub sp,21

@6:
	jmp @-1

@7:
	mov al,1

@8:
	jmp @8

@9:
	jmp @-1

@10:
	mov al,0

@11:
	mov ax,0

@12:
	mov ax, word ptr [bp + (10)]
	mov dx,1
	sub ax,dx
	mov word ptr [bp + (-5)], ax

@13:
	mov ax, word ptr [bp + (-2)]
	mov dx, word ptr [bp + (-5)]
	cmp ax,dx
	jl @18

@14:
	jmp @32

@15:
	mov ax, word ptr [bp + (-2)]
	mov dx,1
	add ax,dx
	mov word ptr [bp + (-8)], ax

@16:
	mov ax, word ptr [bp + (-8)]

@17:
	jmp @12

@18:
	mov ax, word ptr [bp + (-2)]
	mov cx,2
	imul cx
	mov cx, word ptr [bp + (8)]
	add ax,cx
	mov word ptr [bp + (-10)], ax

@19:
	mov ax, word ptr [bp + (-2)]
	mov dx,1
	add ax,dx
	mov word ptr [bp + (-12)], ax

@20:
	mov ax, word ptr [bp + (-12)]
	mov cx,2
	imul cx
	mov cx, word ptr [bp + (8)]
	add ax,cx
	mov word ptr [bp + (-14)], ax

@21:
	mov di, word ptr [bp + (-10)]
	mov ax, word ptr [di]
	mov di, word ptr [bp + (-14)]
	mov dx, word ptr [di]
	cmp ax,dx
	jg @23

@22:
	jmp @31

@23:
	mov ax, word ptr [bp + (-2)]
	mov cx,2
	imul cx
	mov cx, word ptr [bp + (8)]
	add ax,cx
	mov word ptr [bp + (-17)], ax

@24:
	mov di, word ptr [bp + (-17)]
	push si

@25:
	mov ax, word ptr [bp + (-2)]
	mov dx,1
	add ax,dx
	mov word ptr [bp + (-19)], ax

@26:
	mov ax, word ptr [bp + (-19)]
	mov cx,2
	imul cx
	mov cx, word ptr [bp + (8)]
	add ax,cx
	mov word ptr [bp + (-21)], ax

@27:
	mov di, word ptr [bp + (-21)]
	push si

@28:
	sub sp,2
	push word ptr [bp+4]
	call near ptr _swap
	add sp,4+4

@29:
	jmp @-1

@30:
	mov al,1

@31:
	jmp @15

@32:
	jmp @8

@33:
@_bsort_: mov sp,bp
	pop bp
	ret
_bsort endp

@34:
_writeArray proc near
	push bp
	mov bp,sp
	sub sp,8

@35:
	mov si, word ptr [bp + (12)]
	push si

@36:
	sub sp,2
	mov si, word ptr [bp+4]
	mov si, word ptr [si+4]
	push word ptr [si+4]
	call near ptr _puts
	add sp,2+4

@37:
	mov ax,0

@38:
	mov ax, word ptr [bp + (-2)]
	mov dx, word ptr [bp + (10)]
	cmp ax,dx
	jl @43

@39:
	jmp @51

@40:
	mov ax, word ptr [bp + (-2)]
	mov dx,1
	add ax,dx
	mov word ptr [bp + (-5)], ax

@41:
	mov ax, word ptr [bp + (-5)]

@42:
	jmp @38

@43:
	mov ax, word ptr [bp + (-2)]
	mov dx,0
	cmp ax,dx
	jg @45

@44:
	jmp @47

@45:
	lea si,byte ptr @str1
	push si

@46:
	sub sp,2
	mov si, word ptr [bp+4]
	mov si, word ptr [si+4]
	push word ptr [si+4]
	call near ptr _puts
	add sp,2+4

@47:
	mov ax, word ptr [bp + (-2)]
	mov cx,2
	imul cx
	mov cx, word ptr [bp + (8)]
	add ax,cx
	mov word ptr [bp + (-8)], ax

@48:
	mov di, word ptr [bp + (-8)]
	push si

@49:
	sub sp,2
	mov si, word ptr [bp+4]
	mov si, word ptr [si+4]
	push word ptr [si+4]
	call near ptr _puti
	add sp,2+4

@50:
	jmp @40

@51:
	lea si,byte ptr @str2
	push si

@52:
	sub sp,2
	mov si, word ptr [bp+4]
	mov si, word ptr [si+4]
	push word ptr [si+4]
	call near ptr _puts
	add sp,2+4

@53:
@_writeArray_: mov sp,bp
	pop bp
	ret
_writeArray endp

@54:
_main proc near
	push bp
	mov bp,sp
	sub sp,23

@55:
	mov ax,16
	mov cx,2
	imul cx
	mov word ptr [bp + (-8)], ax

@56:
	mov ax, word ptr [bp + (-8)]
	push ax

@57:
	push si

@58:
	sub sp,2
	mov si, word ptr [bp+4]
	mov si, word ptr [si+4]
	push word ptr [si+4]
	call near ptr _newarrv
	add sp,2+4

@59:
	mov ax, word ptr [bp + (-10)]

@60:
	mov ax,65

@61:
	mov ax,0

@62:
	mov ax, word ptr [bp + (-4)]
	mov dx,16
	cmp ax,dx
	jl @67

@63:
	jmp @75

@64:
	mov ax, word ptr [bp + (-4)]
	mov dx,1
	add ax,dx
	mov word ptr [bp + (-13)], ax

@65:
	mov ax, word ptr [bp + (-13)]

@66:
	jmp @62

@67:
	mov ax, word ptr [bp + (-2)]
	mov cx,137
	imul cx
	mov word ptr [bp + (-15)], ax

@68:
	mov ax, word ptr [bp + (-15)]
	mov dx,220
	add ax,dx
	mov word ptr [bp + (-17)], ax

@69:
	mov ax, word ptr [bp + (-17)]
	mov dx, word ptr [bp + (-4)]
	add ax,dx
	mov word ptr [bp + (-19)], ax

@70:
	mov ax, word ptr [bp + (-19)]
	cwd
	mov cx,101
	idiv cx
	mov word ptr [bp + (-21)], dx

@71:
	mov ax, word ptr [bp + (-21)]

@72:
	mov ax, word ptr [bp + (-4)]
	mov cx,2
	imul cx
	add ax,cx
	mov word ptr [bp + (-23)], ax

@73:
	mov ax, word ptr [bp + (-2)]
	mov di, word ptr [bp + (-23)]
	mov word ptr [di], ax

@74:
	jmp @64

@75:
	lea si,byte ptr @str3
	push si

@76:
	mov ax,16
	push ax

@77:
	push si

@78:
	sub sp,2
	push word ptr [bp+4]
	call near ptr _writeArray
	add sp,6+4

@79:
	mov ax,16
	push ax

@80:
	push si

@81:
	sub sp,2
	push word ptr [bp+4]
	call near ptr _bsort
	add sp,4+4

@82:
	lea si,byte ptr @str4
	push si

@83:
	mov ax,16
	push ax

@84:
	push si

@85:
	sub sp,2
	push word ptr [bp+4]
	call near ptr _writeArray
	add sp,6+4

@86:
@_main_: mov sp,bp
	pop bp
	ret
_main endp

@str1 	db ', '
	db 0
@str2 	db 10
	db 0
@str3 	db 'Initial array: '
	db 0
@str4 	db 'Sorted array: '
	db 0

	extrn _puti : proc
	extrn _puts : proc
	extrn _newarrv : proc
xseg ends
	end main
