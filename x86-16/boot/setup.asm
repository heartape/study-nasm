;INITSEG  equ 0x9000	; we move boot here - out of the way
;SYSSEG   equ 0x1000	; system loaded at 0x10000 (65536).
;SETUPSEG equ 0x9020	; this is the current segment

start:
    mov ax,0x9000
    mov ds,ax
    mov ah,0x03
    xor bh,bh
    int 0x10        ;获取光标的位置,ah=3:读光标位置,bh:页号,dh:行号,dl:列号
    mov [0],dx


; Get memory size (extended mem, kB) - 获取内存信息。
    mov ah,0x88
    int 0x15
    mov [2],ax

; Get video-card data - 获取显卡显示模式。
    mov ah,0x0f
    int 0x10
    mov [4],bx      ; bh = display page
    mov [6],ax      ; al = video mode, ah = window width

; check for EGA/VGA and some config parameters - 检查显示方式并取参数
    mov ah,0x12
    mov bl,0x10
    int 0x10
    mov [8],ax
    mov [10],bx
    mov [12],cx

; Get hd0 data - 获取第一块硬盘的信息。
    mov ax,0x0000
    mov ds,ax
    lds si,[4*0x41]
    mov ax,0x9000
    mov es,ax
    mov di,0x0080
    mov cx,0x10
    rep
    movsb

;Get hd1 data - 获取第二块硬盘的信息。
    mov ax,0x0000
    mov ds,ax
    lds si,[4*0x46]
    mov ax,0x9000
    mov es,ax
    mov di,0x0090
    mov cx,0x10
    rep
    movsb

    cli                 ;把原本BIOS提供的中断向量表覆盖掉，写上操作系统的中断向量表，所以这个时候不允许中断

    mov ax,0x0000
    cld
;将操作系统向前移动0x1000
do_move:
    mov es,ax
    add ax,0x1000
    cmp ax,0x9000
    jz  end_move
    mov ds,ax
    sub di,di
    sub si,si
    mov cx,0x8000
    rep movsw
    jmp do_move

end_move:

    ; 以下为打开32位保护模式的步骤
    ; 设置gdt、idt
    ; 打开 A20 地址线
    ; 对可编程中断控制器 8259 芯片进行的编程
    ; 切换32位保护模式

    sti

    jmp 0:0            ; 跳转head.asm

    times 512*4 - ($ - $$) db 0