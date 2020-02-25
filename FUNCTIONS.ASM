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


                mov sp, bp
                pop bp

done:           mov ax, 4c00h
                int 21h

#ptr to es:[di], num at cx, val at ax
memset proc
    cld
    rep stosw
    ret
endp

#dest ptr to es:[di], source ptr to ds:[si], num at cx
memcpy proc
    cld
    rep movsb
    ret
endp

#ptr to es:[di], res at es:[di], num>0 at cx, char at al; if found zf = 1, else 0
memchr proc
    cld
    repne scasb
    sub di
    mov bl, es:[di]
    cmp al, bl
    ret
endp


.data
msg db 'Oleg Mikhailovitch Shitikov$'
end start
