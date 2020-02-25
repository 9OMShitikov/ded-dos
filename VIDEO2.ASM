.model tiny

videoseg        = 0b800h
probel          = 0b00h
string_color    = 0eh

left_up         = 0ec9h
hor_line        = 0ecdh
right_up        = 0ebbh
ver_line        = 0ebah
right_down      = 0ebch
left_down       = 0ec8h

x1              = 0
x2              = 24
y1              = 5
y2              = 20

d_x             = 80
d_y             = 25
;---
;function clear_box:  args: x1, x2, y1, y2, probel
;function draw_frame: args: x1, x2, y1, y2, left_up, hor_line, right_up, ver_line, right_down, left_down
;function draw_shadow: args: x1, x2, y1, y2, probel
;function count_bytes: args: offset; rets: count
;function print_line: args: x, y, len
;---
.code
org 100h


start:
                push bp
                mov bp, sp
                sub sp, 10
                ;push 4a61h

                mov ax, 0
                mov bx, d_x
                sub bx, 1
                mov cx, 0
                mov dx, d_y
                sub dx, 1
                push probel
                call clear_box
                pop ax

                mov ax, offset msg
                call count_bytes
                push ax

                mov dl, 2
                div dl
                mov ah, 0
                push ax

                mov ax, d_y
                mov dl, 2
                div dl
                mov ah, 0
                mov bx, ax

                mov ax, d_x
                mov dl, 2
                div dl
                mov ah, 0

                pop cx
                sub ax, cx

                pop cx
                mov [bp-2], ax
                mov [bp-4], bx
                mov [bp-6], cx
                call print_line

                mov ax, [bp-2]
                mov bx, ax
                add bx, [bp-6]
                add bx, 2
                mov cx, [bp-4]
                mov dx, cx
                add dx, 3
                push 40h
                call draw_shadow

                mov ax, [bp-2]
                mov bx, ax
                sub ax, 1
                add bx, [bp-6]
                add bx, 1
                mov cx, [bp-4]
                mov dx, cx
                sub cx, 1
                add dx, 2
                push left_down
                push right_down
                push ver_line
                push right_up
                push hor_line
                push left_up
                call draw_frame
                mov ax, [bp-2]

                mov sp, bp
                pop bp

done:           mov ax, 4c00h
                int 21h

;## args: x1, x2, y1, y2, probel
clear_box proc
                push bp
                mov bp, sp
                sub sp, 10

                mov [bp-2], ax ; x1
                mov [bp-4], bx ; x2
                mov [bp-6], cx ; y1
                mov [bp-8], dx ; y2

                mov ax, videoseg
                mov es, ax
                mov ax, [bp+4]

                push ax
                mov ax, [bp-6]
                mov dx, 80
                mul dx
                add ax, [bp-2]
                mov dx, 2
                mul dx
                mov di, ax
                pop ax
                ;mov di, (y1 * 80 + x1) * 2

                mov cx, [bp-4]
                sub cx, [bp-2]
                ;mov cx, x2 - x1 / Window width

                mov si, 0000h           ; si -> bx. if si = bx, exit

                mov bx, [bp-8]
                sub bx, [bp-6]
                ;mov bx, y2 - y1         ; Window height

                push ax
                mov ax, [bp-4]
                sub ax, [bp-2]
                push ax
                mov ax, 80d
                pop dx
                sub ax, dx
                mov dx, 2
                mul dx
                mov dx, ax
                pop ax
                ;mov dx, (80d - (x2 - x1)) * 2
x1_to_x2:       stosw
                loop x1_to_x2

y1_to_y2:
                add di, dx
                ;add di, (80d - (x2 - x1)) * 2

                inc si

                mov cx, [bp-4]
                sub cx, [bp-2]
                ;mov cx, x2 - x1

                cmp si, bx
                jne x1_to_x2


                mov sp, bp
                pop bp
                ret
endp
;##

;## args: x1, x2, y1, y2
draw_frame proc
                mov bh, bl
                sub bh, al
                ; mov bh, x2 - x1

                mov bl, dl
                sub bl, cl

                ; mov bl, y2 - y1
                push ax
                mov al, cl
                mov cl, 80
                mul cl
                pop dx
                add ax, dx
                add ax, ax
                mov dx, ax
                mov di, ax
                ;mov dx, (y1 * 80 + x1) * 2
                ;mov di, dx
                mov ax, left_up
                stosw

                mov ax, hor_line
                mov ch, 0
                mov cl, bh
                sub cx, 2
                ;mov cx, x2 - x1 - 2
                rep stosw

                mov ax, right_up
                stosw

                add dx, 160
                mov di, dx
                ;mov di/dx, ((y1 + 1) * 80 + x1) * 2

                mov ax, ver_line
                mov si, 1d

right_ver:      mov ch, 0
                mov cl, bl
                sub cx, 2
                ;mov cx, y2 - y1 - 2

vertical:       stosw
                add di, 79d * 2
                loop vertical

                mov ax, dx
                mov di, dx
                mov dh, 0
                mov dl, bh
                add di, dx
                add di, dx
                sub di, 2
                mov dx, ax
                ;mov di, (y1 * 80 + x2 + 79) * 2

                mov ax, ver_line
                add si, 1d
                cmp si, 2d
                je  right_ver

                mov ah, 0
                mov al, bl
                mov cl, 80
                mul cl
                add dx, ax
                add dx, ax
                sub dx, 160
                sub dx, 160
                mov di, dx
                ;mov di, ((y2 - 1) * 80 + x1) * 2
                mov ax, left_down
                stosw

                mov ax, hor_line

                mov ch, 0
                mov cl, bh
                sub cx, 2
                ;mov cx, x2 - x1 - 2
                rep stosw

                mov ax, right_down
                stosw
                ret
endp
;##

;## args: x1, x2, y1, y2, probel
draw_shadow proc
                push bp
                mov bp, sp
                sub sp, 10

                mov [bp-2], ax ; x1
                mov [bp-4], bx ; x2
                mov [bp-6], cx ; y1
                mov [bp-8], dx ; y2

                mov al, [bp-6]
                mov bl, 80
                mul bl
                add ax, [bp-2]
                add ax, ax
                mov di, ax
                ;mov di, (y1 * 80 + x1) * 2

                mov dl, [bp+4]
                and dx, 00f0h
                mov cx, [bp-4]
                sub cx, [bp-2]
                ;mov cx, x2 - x1

upper_hor_shadow:
                add di, 1
                mov al, es:[di]
                and ax, 0007h
                add al, dl
                stosb
                loop upper_hor_shadow


                mov al, [bp-6]
                add al, 1
                mov bl, 80
                mul bl
                add ax, [bp-2]
                add ax, ax
                mov di, ax
                ;mov di, ((y1 + 1) * 80 + x1) * 2

                mov dl, [bp+4]
                and dx, 00f0h
                mov si, 1d

right_v:        mov cx, [bp-8]
                sub cx, [bp-6]
                sub cx, 2
                ;mov cx, y2 - y1 - 2

vertic:         add di, 1
                mov al, es:[di]
                and ax, 0007h
                add al, dl
                stosb
                add di, 79d * 2
                loop vertic

                mov al, [bp-6]
                mov bl, 80
                mul bl
                add ax, [bp-4]
                add ax, 79
                add ax, ax
                mov di, ax
                ;mov di, (y1 * 80 + x2 + 79) * 2

                add si, 1d
                cmp si, 2d
                je  right_v

                mov al, [bp-8]
                sub al, 1
                mov bl, 80
                mul bl
                add ax, [bp-2]
                add ax, ax
                mov di, ax
                ;mov di, ((y2 - 1) * 80 + x1) * 2

                mov dl, [bp+4]
                and dx, 00f0h

                mov cx, [bp-4]
                sub cx, [bp-2]
                ;mov cx, x2 - x1

lower_hor_shadow:
                add di, 1
                mov al, es:[di]
                and ax, 0007h
                add al, dl
                stosb
                loop lower_hor_shadow

                mov sp, bp
                pop bp
                ret
endp
;##

;## args: offset
count_bytes proc
                push bp
                mov bp, sp
                sub sp, 10

                mov bx, es
                push bx
                mov bx, ds
                mov es, bx

                mov di, ax
                mov cx, di
                mov al, '$'
                repne scasb

                mov ax, di
                sub ax, cx
                sub ax, 2
                mov dl, 2
                div dl
                mov ah, 0
                pop bx
                mov es, bx

                mov sp, bp
                pop bp
                ret
endp
;##

;## args: x, y, len
print_line proc
                push bp
                mov bp, sp

                push ax
                mov ax, videoseg
                mov es, ax

                mov ax, bx
                mov dl, 80
                mul dl
                pop bx
                add ax, bx
                add ax, ax
                mov di, ax
                ;mov di, (y1 * 80 + x1) * 2

                mov ah, string_color
                mov si, offset msg

pr_again:
                lodsb
                stosw
                loop pr_again

                mov sp, bp
                pop bp
                ret
endp
;##
.data
msg db 'Oleg Mikhailovitch Shitikov$'
end start
