.model tiny

videoseg        = 0b800h
probel          = 4b00h
string_color    = 0eh

left_up         = 0ec9h
hor_line        = 0ecdh
right_up        = 0ebbh
ver_line        = 0ebah
right_down      = 0ebch
left_down       = 0ec8h

x1              = 10
x2              = 70
y1              = 5
y2              = 20

;---
;function clear_box:  args: x1, x2, y1, y2, probel
;function draw_frame: args: x1, x2, y1, y2, left_up, hor_line, right_up, ver_line, right_down, left_down
;---
.code
org 100h

start:
                mov ax, 0
                mov bx, 79
                mov cx, 0
                mov dx, 24
                push 0b00h
                call clear_box

                mov ax, x1
                mov bx, x2
                mov cx, y1
                mov dx, y2
                push probel
                call clear_box

                mov ax, x1
                mov bx, x2
                mov cx, y1
                mov dx, y2
                push left_down
                push right_down
                push ver_line
                push right_up
                push hor_line
                push left_up
                call draw_frame
                
                mov ax, videoseg
                mov es, ax

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

;## args: x1, x2, y1, y2, left_up, hor_line, right_up, ver_line, right_down, left_down
draw_frame proc
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
                sub ax, 81
                add ax, ax
                mov di, ax
                ;mov di, (y1 * 80 + x1 - 81) * 2
                mov ax, [bp+4]
                stosw

                mov ax, [bp+6]
                mov cx, [bp-4]
                sub cx, [bp-2]
                ;mov cx, x2 - x1
                rep stosw

                mov ax, [bp+8]
                stosw

                mov al, [bp-6]
                mov bl, 80
                mul bl
                add ax, [bp-2]
                sub ax, 1
                add ax, ax
                mov di, ax
                ;mov di, (y1 * 80 + x1 - 1) * 2

                mov ax, [bp+10]
                mov si, 1d

right_ver:      mov cx, [bp-8]
                sub cx, [bp-6]
                ;mov cx, y2 - y1

vertical:       stosw
                add di, 79d * 2
                loop vertical

                mov al, [bp-6]
                mov bl, 80
                mul bl
                add ax, [bp-4]
                add ax, ax
                mov di, ax

                ;mov di, (y1 * 80 + x2) * 2
                mov ax, [bp+10]
                add si, 1d
                cmp si, 2d
                je  right_ver

                mov al, [bp-8]
                mov bl, 80
                mul bl
                add ax, [bp-2]
                sub ax, 1
                add ax, ax
                mov di, ax
                mov ax, [bp+14]
                ;mov di, (y2 * 80 + x1 - 1) * 2
                stosw

                mov ax, [bp+6]

                mov cx, [bp-4]
                sub cx, [bp-2]
                ;mov cx, x2 - x1
                rep stosw

                mov ax, [bp+12]
                stosw

;; вывод надписи
;
;                mov di, (y1 * 80 + x1 + 2) * 2
;                mov si, offset msg
;                mov ah, string_color
;again:          lodsb
;                cmp al, '$'
;                je done
;                stosw
;                jmp again

                mov sp, bp
                pop bp
                ret
endp
;##

.data
msg             db '11$'

end start
