xseg            segment public 'code'
                assume  cs:xseg, ds:xseg, ss:xseg
                org     100h

LIVENESS = 0

main            proc    near
        ;; initialize memory: 2/3 heap and 1/3 stack
                mov     cx, OFFSET DGROUP:_start_of_space
                mov     word ptr _space_from, cx
                mov     word ptr _next, cx
                mov     ax, 0FFFEh
                sub     ax, cx
                xor     dx, dx
                mov     bx, 3
                idiv    bx
                and     ax, 0FFFEh ; even number!
                add     cx, ax
                mov     word ptr _limit_from, cx
                mov     word ptr _space_to, cx
                add     cx, ax
                mov     word ptr _limit_to, cx
        ;; register allocating functions
                mov     ax, OFFSET _consv_call_table
                call    near ptr _register_call_table
                mov     ax, OFFSET _make_list_1_call_table
                call    near ptr _register_call_table
                mov     ax, OFFSET _revert_aux_4_call_table
                call    near ptr _register_call_table
                mov     ax, OFFSET _revert_list_5_call_table
                call    near ptr _register_call_table
                mov     ax, OFFSET _main_6_call_table
                call    near ptr _register_call_table
        ;; call main
                call    near ptr _main_6
_ret_of_main:
        ;; exit with code 0
                mov     ax, 4C00h
                int     21h
main            endp


        ;; 0: unit, make_list, -, -
@0:
_make_list_1    proc    near
                push    bp
                mov     bp, sp
                xor     ax, ax
                push    ax      ; result = nil
                sub     sp, 2   ; i
                push    ax      ; $1 = nil
        ;; 1: :=, nil, -, result
@1:
                mov     ax, 0
                mov     word ptr [bp-2], ax
        ;; 2: :=, 1, -, i
@2:
                mov     ax, 1
                mov     word ptr [bp-4], ax
        ;; 3: <=, i, size, 5
@3:
                mov     ax, word ptr [bp-4]
                mov     dx, word ptr [bp+8]
                cmp     ax, dx
                jle     @5
        ;; 4: jump, -, -, 12
@4:
                jmp     @12
        ;; 5: par, i, V, -
@5:
                mov     ax, word ptr [bp-4]
                push    ax
        ;; 6: par, result, V, -
@6:
                mov     ax, word ptr [bp-2]
                push    ax
        ;; 7: par, $1, RET, -
@7:
                lea     si, word ptr [bp-6]
                push    si
        ;; 8: call, -, -, cons
@8:
                push    bp
                call    near ptr _consv
@make_list_1_call_1:
                add     sp, 8
        ;; 9: :=, $1, -, result
@9:
                mov     ax, word ptr [bp-6]
                mov     word ptr [bp-2], ax
        ;; 10: +, i, 1, i
@10:
                mov     ax, word ptr [bp-4]
                inc     ax
                mov     word ptr [bp-4], ax
        ;; 11: jump, -, -, 3
@11:
                jmp     @3
        ;; 12: :=, result, -, $$
@12:
                mov     ax, word ptr [bp-2]
                mov     si, word ptr [bp+6]
                mov     word ptr [si], ax
        ;; 13: ret, -, -, -
@13:
                jmp     @make_list_1
        ;; 14: endu, make_list, -, -
@14:
@make_list_1:
                mov     sp, bp
                pop     bp
                ret
_make_list_1    endp

_make_list_1_call_table:
@call_1_1       dw      @make_list_1_call_1
                dw      0
                dw      8 + 0 + 6 + 4
IF LIVENESS eq 0
                dw      -2      ; result -- NOT LIVE
                dw      -6      ; $1 -- NOT LIVE
ENDIF
                dw      0

        ;; 15: unit, print_list, -, -
@15:
_print_list_2   proc    near
                push    bp
                mov     bp, sp
                sub     sp, 2   ; $1
                xor     ax, ax
                push    ax      ; $2 = nil
        ;; 16: <>, l, nil, 18
@16:
                mov     ax, word ptr [bp+8]
                mov     dx, 0
                cmp     ax, dx
                jnz     @18
        ;; 17: jump, -, -, 30
@17:
                jmp     @30
        ;; 18: par, l, V, -
@18:
                mov     ax, word ptr [bp+8]
                push    ax
        ;; 19: par, $1, RET, -
@19:
                lea     si, word ptr [bp-2]
                push    si
        ;; 20: call, -, -, head
@20:
                push    bp
                call    near ptr _head
                add     sp, 6
        ;; 21: par, $1, V, -
@21:
                mov     ax, word ptr [bp-2]
                push    ax
        ;; 22: call, -, -, puti
@22:
                sub     sp, 2
                push    bp
                call    near ptr _puti
                add     sp, 6
        ;; 23: par, ", ", V, -
@23:
                lea     si, byte ptr @str1
                push    si
        ;; 24: call, -, -, puts
@24:
                sub     sp, 2
                push    bp
                call    near ptr _puts
                add     sp, 6
        ;; 25: par, l, V, -
@25:
                mov     ax, word ptr [bp+8]
                push    ax
        ;; 26: par, $2, RET, -
@26:
                lea     si, word ptr [bp-4]
                push    si
        ;; 27: call, -, -, tail
@27:
                push    bp
                call    near ptr _tail
                add     sp, 6
        ;; 28: :=, $2, -, l
@28:
                mov     ax, word ptr [bp-4]
                mov     word ptr [bp+8], ax
        ;; 29: jump, -, -, 16
@29:
                jmp     @16
        ;; 30: par, "end\n", V, -
@30:
                lea     si, byte ptr @str2
                push    si
        ;; 31: call, -, -, puts
@31:
                sub     sp, 2
                push    bp
                call    near ptr _puts
                add     sp, 6
        ;; 32: endu, print_list, -, -
@32:
@print_list_2:
                mov     sp, bp
                pop     bp
                ret
_print_list_2   endp

@str1           db      ', '
                db      0
@str2           db      'end'
                db      10, 0


        ;; 33, unit, check_lists, -
@33:
_check_lists_3  proc    near
                push    bp
                mov     bp, sp
                sub     sp, 4   ; i, $1
                xor     ax, ax
                push    ax      ; $2 = nil
                sub     sp, 2   ; $3
                push    ax      ; $4 = nil
        ;; 34: :=, 1, -, i
@34:
                mov     ax, 1
                mov     word ptr [bp-2], ax
        ;; 35: <=, i, n, 37
@35:
                mov     ax, word ptr [bp-2]
                mov     dx, word ptr [bp+12]
                cmp     ax, dx
                jle     @37
        ;; 36: jump, -, -, 52
@36:
                jmp     @52
        ;; 37: =, r, nil, 44
@37:
                mov     ax, word ptr [bp+8]
                mov     dx, 0
                cmp     ax, dx
                je      @44
        ;; 38: jump, -, -, 39
@38:
                jmp     @39
        ;; 39: push, r, V, -
@39:
                mov     ax, word ptr [bp+8]
                push    ax
        ;; 40: push, $1, RET, -
@40:
                lea     ax, word ptr [bp-4]
                push    ax
        ;; 41: call, -, -, head
@41:
                push    bp
                call    near ptr _head
                add     sp, 6
        ;; 42: <>, $1, i, 44
@42:
                mov     ax, word ptr [bp-4]
                mov     dx, word ptr [bp-2]
                cmp     ax, dx
                jne     @44
        ;; 43: jump, -, -, 46
@43:
                jmp     @46
        ;; 44: :=, false, -, $$
@44:
                mov     ax, 0
                mov     si, word ptr [bp+6]
                mov     word ptr [si], ax
        ;; 45: ret, -, -, -
@45:
                jmp     @check_lists_3
        ;; 46: +, i, 1, i
@46:
                mov     ax, word ptr [bp-2]
                inc     ax
                mov     word ptr [bp-2], ax
        ;; 47: push, r, V, -
@47:
                mov     ax, word ptr [bp+8]
                push    ax
        ;; 48: push, $2, RET, -
@48:
                lea     ax, word ptr [bp-6]
                push    ax
        ;; 49: call, -, -, tail
@49:
                push    bp
                call    near ptr _tail
                add     sp, 6
        ;; 50: :=, $2, -, r
@50:
                mov     ax, word ptr [bp-6]
                mov     word ptr [bp+8], ax
        ;; 51: jump, -, -, 35
@51:
                jmp     @35
        ;; 52: :=, n, -, i
@52:
                mov     ax, word ptr [bp+12]
                mov     word ptr [bp-2], ax
        ;; 53: >=, i, 1, 55
@53:
                mov     ax, word ptr [bp-2]
                mov     dx, 1
                cmp     ax, dx
                jge     @55
        ;; 54: jump, -, -, 70
@54:
                jmp     @70
        ;; 55: =, l, nil, 62
@55:
                mov     ax, word ptr [bp+10]
                mov     dx, 0
                cmp     ax, dx
                je      @62
        ;; 56: jump, -, -, 57
@56:
                jmp     @57
        ;; 57: push, l, V, -
@57:
                mov     ax, word ptr [bp+10]
                push    ax
        ;; 58: push, $3, RET, -
@58:
                lea     ax, word ptr [bp-8]
                push    ax
        ;; 59: call, -, -, head
@59:
                push    bp
                call    near ptr _head
                add     sp, 6
        ;; 60: <>, $3, i, 62
@60:
                mov     ax, word ptr [bp-8]
                mov     dx, word ptr [bp-2]
                cmp     ax, dx
                jne     @62
        ;; 61: jump, -, -, 64
@61:
                jmp     @64
        ;; 62: :=, false, -, $$
@62:
                mov     ax, 0
                mov     si, word ptr [bp+6]
                mov     word ptr [si], ax
        ;; 63: ret, -, -, -
@63:
                jmp     @check_lists_3
        ;; 64: -, i, 1, i
@64:
                mov     ax, word ptr [bp-2]
                dec     ax
                mov     word ptr [bp-2], ax
        ;; 65: push, l, V, -
@65:
                mov     ax, word ptr [bp+10]
                push    ax
        ;; 66: push, $4, RET, -
@66:
                lea     ax, word ptr [bp-10]
                push    ax
        ;; 67: call, -, -, tail
@67:
                push    bp
                call    near ptr _tail
                add     sp, 6
        ;; 68: :=, $4, -, l
@68:
                mov     ax, word ptr [bp-10]
                mov     word ptr [bp+10], ax
        ;; 69: jump, -, -, 53
@69:
                jmp     @53
        ;; 70: :=, true, -, $$
@70:
                mov     ax, 1
                mov     si, word ptr [bp+6]
                mov     word ptr [si], ax
        ;; 71: ret, -, -, -
@71:
                jmp     @check_lists_3
        ;; 72: endu, check_lists, -, -
@72:
@check_lists_3:
                mov     sp, bp
                pop     bp
                ret
_check_lists_3  endp


        ;; 73: unit, revert_aux, -, -
@73:
_revert_aux_4   proc    near
                push    bp
                mov     bp, sp
                xor     ax, ax
                push    ax      ; $1 = nil
                sub     sp, 2   ; $2
                push    ax      ; $3 = nil
                push    ax      ; $4 = nil
        ;; 74: =, l, nil, 76
@74:
                mov     ax, word ptr [bp+10]
                mov     dx, 0
                cmp     ax, dx
                je      @76
        ;; 75: jump, -, -, 79
@75:
                jmp     @79
        ;; 76: :=, r, -, $$
@76:
                mov     ax, word ptr [bp+8]
                mov     si, word ptr [bp+6]
                mov     word ptr [si], ax
        ;; 77: ret, -, -, -
@77:
                jmp     @revert_aux_4
        ;; 78: jump -, -, 96
@78:
                jmp     @96
        ;; 79: par, l, V, -
@79:
                mov     ax, word ptr [bp+10]
                push    ax
        ;; 80: par, $1, RET, -
@80:
                lea     ax, word ptr [bp-2]
                push    ax
        ;; 81: call, -, -, tail
@81:
                push    bp
                call    near ptr _tail
                add     sp, 6
        ;; 82: par, $1, V, -
        ;; this is the extra
@82:
                mov     ax, word ptr [bp-2]
                push    ax
        ;; 84: par, l, V, -
@84:
                mov     ax, word ptr [bp+10]
                push    ax
        ;; 85: par, $2, RET, -
@85:
                lea     ax, word ptr [bp-4]
                push    ax
        ;; 86: call, -, -, head
@86:
                push    bp
                call    near ptr _head
                add     sp, 6
        ;; 87: par, $2, V, -
@87:
                mov     ax, word ptr [bp-4]
                push    ax
        ;; 88: par, r, V, -
@88:
                mov     ax, word ptr [bp+8]
                push    ax
        ;; 89: par, $3, RET, -
@89:
                lea     ax, word ptr [bp-6]
                push    ax
        ;; 90: call, -, -, cons
@90:
                push    bp
                call    near ptr _consv
@revert_aux_4_call_1:
                add     sp, 8
        ;; 91: par, $3, V, -
@91:
                mov     ax, word ptr [bp-6]
                push    ax
        ;; 92: par, $4, RET, -
@92:
                lea     ax, word ptr [bp-8]
                push    ax
        ;; 93: call, -, -, revert_aux
@93:
                mov     si, word ptr [bp-4]
                push    si
                call    near ptr _revert_aux_4
@revert_aux_4_call_2:
                add     sp, 8
        ;; 94: :=, $4, -, $$
@94:
                mov     ax, word ptr [bp-8]
                mov     si, word ptr [bp+6]
                mov     word ptr [si], ax
        ;; 95: ret, -, -, -
@95:
                jmp     @revert_aux_4
        ;; 96: endu, revert_aux, -, -
@96:
@revert_aux_4:
                mov     sp, bp
	        pop	bp
	        ret
_revert_aux_4	endp

_revert_aux_4_call_table:
@call_4_1       dw      @revert_aux_4_call_1
                dw      @call_4_2
                dw      8 + 2 + 8 + 4
IF LIVENESS eq 0
                dw      10      ; l -- NOT LIVE
                dw      8       ; r -- NOT LIVE
                dw      -2      ; $1 -- NOT LIVE
                dw      -6      ; $3 -- NOT LIVE
                dw      -8      ; $4 -- NOT LIVE
ENDIF
                dw      -10     ; extra
                dw      0
@call_4_2       dw      @revert_aux_4_call_2
                dw      0
                dw      8 + 0 + 8 + 4
IF LIVENESS eq 0
                dw      10      ; l -- NOT LIVE
                dw      8       ; r -- NOT LIVE
                dw      -2      ; $1 -- NOT LIVE
                dw      -6      ; $3 -- NOT LIVE
                dw      -8      ; $4 -- NOT LIVE
ENDIF
                dw      0

        ;; 97: unit, revert_list, -, -
@97:
_revert_list_5	proc	near
	        push	bp
	        mov	bp, sp
                xor     ax, ax
                push    ax      ; $1 = nil
        ;; 98: par, l, V, -
@98:
                mov     ax, word ptr [bp+8]
                push    ax
        ;; 99: par, nil, V, -
@99:
                mov     ax, 0
                push    ax
        ;; 100: par, $1, RET, -
@100:
                lea     ax, word ptr [bp-2]
                push    ax
        ;; 101: call, -, -, revert_aux
@101:
                push    bp
                call    near ptr _revert_aux_4
@revert_list_5_call_1:
                add     sp, 8
        ;; 102: :=, $1, -, $$
@102:
                mov     ax, word ptr [bp-2]
                mov     si, word ptr [bp+6]
                mov     word ptr [si], ax
        ;; 103: ret, -, -, -
@103:
                jmp     @revert_list_5
        ;; 104: endu, revert_list, -, -
@104:
@revert_list_5:
                mov     sp, bp
	        pop	bp
	        ret
_revert_list_5	endp

_revert_list_5_call_table:
@call_5_1       dw      @revert_list_5_call_1
                dw      0
                dw      8 + 0 + 2 + 4
IF LIVENESS eq 0
                dw      8       ; l -- NOT LIVE
                dw      -2      ; $1 -- NOT LIVE
ENDIF
                dw      0

        ;; 105: unit, main, -, -
@105:
_main_6 	proc	near
	        push	bp
	        mov	bp, sp
                xor     ax, ax
                push    ax      ; l = nil
                push    ax      ; r = nil
                sub     sp, 2   ; i
                push    ax      ; $1 = nil
                push    ax      ; $2 = nil
                sub     sp, 2   ; $3
        ;; 106: :=, 1, -, i
@106:
                mov     ax, 1
                mov     word ptr [bp-6], ax
        ;; 107: <, i, 1000, 109
@107:
                mov     ax, word ptr [bp-6]
                mov     dx, 1000
                cmp     ax, dx
                jl      @109
        ;; 108: jump, -, -, 136
@108:
                jmp     @136
        ;; 109: par, i, V, -
@109:
                mov     ax, word ptr [bp-6]
                push    ax
        ;; 110: par, $1, RET, -
@110:
                lea     ax, word ptr [bp-8]
                push    ax
        ;; 111: call, -, -, make_list
@111:
                push    bp
                call    near ptr _make_list_1
@main_6_call_1:
                add     sp, 6
        ;; 112: :=, $1, -, l
@112:
                mov     ax, word ptr [bp-8]
                mov     word ptr [bp-2], ax
        ;; 113: <, i, 10, 115
@113:
                mov     ax, word ptr [bp-6]
                mov     dx, 10
                cmp     ax, dx
                jl      @115
        ;; 114: jump, -, -, 117
@114:
                jmp     @117
        ;; 115: par, l, V, -
@115:
                mov     ax, word ptr [bp-2]
                push    ax
        ;; 116: call, -, -, print_list
@116:
                sub     sp, 2
                push    bp
                call    near ptr _print_list_2
@main_6_call_2:
                add     sp, 6
        ;; 117: par, l, V, -
@117:
                mov     ax, word ptr [bp-2]
                push    ax
        ;; 118: par, $2, RET, -
@118:
                lea     ax, word ptr [bp-10]
                push    ax
        ;; 119: call, -, -, revert_list
@119:
                push    bp
                call    near ptr _revert_list_5
@main_6_call_3:
                add     sp, 6
        ;; 120: :=, $2, -, r
@120:
                mov     ax, word ptr [bp-10]
                mov     word ptr [bp-4], ax
        ;; 121: <, i, 10, 123
@121:
                mov     ax, word ptr [bp-6]
                mov     dx, 10
                cmp     ax, dx
                jl      @123
        ;; 122: jump, -, -, 125
@122:
                jmp     @125
        ;; 123: par, r, V, -
@123:
                mov     ax, word ptr [bp-4]
                push    ax
        ;; 124: call, -, -, print_list
@124:
                sub     sp, 2
                push    bp
                call    near ptr _print_list_2
@main_6_call_4:
                add     sp, 6
        ;; 125: par, i, V, -
@125:
                mov     ax, word ptr [bp-6]
                push    ax
        ;; 126: par, l, V, -
@126:
                mov     ax, word ptr [bp-2]
                push    ax
        ;; 127: par, r, V, -
@127:
                mov     ax, word ptr [bp-4]
                push    ax
        ;; 128: par, $3, RET, -
@128:
                lea     ax, word ptr [bp-12]
                push    ax
        ;; 129: call, -, -, check_lists
@129:
                push    bp
                call    near ptr _check_lists_3
@main_6_call_5:
                add     sp, 10
        ;; 130: ifb, $3, -, 134
@130:
                mov     ax, word ptr [bp-12]
                or      ax, ax
                jnz     @134
        ;; 131: jump, -, -, 132
@131:
                jmp     @132
        ;; 132: par, "WRONG!\n", V, -
@132:
                lea     si, byte ptr @str3
                push    si
        ;; 133: call, -, -, puts
@133:
                sub     sp, 2
                push    bp
                call    _puts
                add     sp, 6
        ;; 134: +, i, 1, i
@134:
                mov     ax, word ptr [bp-6]
                inc     ax
                mov     word ptr [bp-6], ax
        ;; 135: jump, -, -, 107
@135:
                jmp     @107
        ;; 136: endu, main, -, -
@136:
@main_6:
                mov     sp, bp
	        pop	bp
	        ret
_main_6 	endp

@str3           db      'WRONG!'
                db      10, 0

_main_6_call_table:
@call_6_1       dw      @main_6_call_1
                dw      @call_6_2
                dw      6 + 0 + 12 + 4
IF LIVENESS eq 0
                dw      -2      ; l -- NOT LIVE
                dw      -4      ; r -- NOT LIVE
                dw      -8      ; $1 -- NOT LIVE
                dw      -10     ; $2 -- NOT LIVE
ENDIF
                dw      0
@call_6_2       dw      @main_6_call_2
                dw      @call_6_3
                dw      6 + 0 + 12 + 4
                dw      -2      ; l
IF LIVENESS eq 0
                dw      -4      ; r -- NOT LIVE
                dw      -8      ; $1 -- NOT LIVE
                dw      -10     ; $2 -- NOT LIVE
ENDIF
                dw      0
@call_6_3       dw      @main_6_call_3
                dw      @call_6_4
                dw      6 + 0 + 12 + 4
                dw      -2      ; l
IF LIVENESS eq 0
                dw      -4      ; r -- NOT LIVE
                dw      -8      ; $1 -- NOT LIVE
                dw      -10     ; $2 -- NOT LIVE
ENDIF
                dw      0
@call_6_4       dw      @main_6_call_4
                dw      @call_6_5
                dw      6 + 0 + 12 + 4
                dw      -2      ; l
                dw      -4      ; r
IF LIVENESS eq 0
                dw      -8      ; $1 -- NOT LIVE
                dw      -10     ; $2 -- NOT LIVE
ENDIF
                dw      0
@call_6_5       dw      @main_6_call_5
                dw      0
                dw      10 + 0 + 12 + 4
IF LIVENESS eq 0
                dw      -2      ; l -- NOT LIVE
                dw      -4      ; r -- NOT LIVE
                dw      -8      ; $1 -- NOT LIVE
                dw      -10     ; $2 -- NOT LIVE
ENDIF
                dw      0

                extrn   _register_call_table : proc
                extrn   _consv : proc
                extrn   _consv_call_table : word
                extrn   _head : proc
                extrn   _tail : proc
                extrn   _puti : proc
                extrn   _puts : proc

                public  _next
                public  _space_from
                public  _limit_from
                public  _space_to
                public  _limit_to
                public  _ret_of_main

_space_from     dw      ?
_limit_from     dw      ?
_space_to       dw      ?
_limit_to       dw      ?
_next           dw      ?

                xseg    ends

_DATA_END       segment byte public 'stack'
_start_of_space label   byte
_DATA_END       ends

DGROUP          group   xseg, _DATA_END

                end     main
