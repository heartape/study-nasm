SECTION code vstart=0
start:
	mov ax,0x07c0
	mov ds,ax
	mov ax,0x9000
	mov es,ax
	mov cx,256
	sub si,si
	sub di,di
	rep movsw

	jmp 0x9000:go
;迁移引导扇区
go: 
	mov ax,cs
    mov ds,ax
    mov es,ax

    mov ss,ax
    mov sp,0xFF00

;读取引导扇区后的4个扇区
load_setup:
    ; bios在dl保存了驱动器号
    mov dh,0x00     ; dh:磁头,dl:驱动器
    mov cx,0x0002   ; ch:磁道,cl:扇区号
    mov bx,0x0200   ; es:bx指向读入数据的内存地址，前面共有512个字节
    mov ax,0x0204   ; ah=2表示读，al:扇区数
    int 0x13
    jnc ok_load_setup
    ; mov dx,0x0000
    mov ax,0x0000
    int 0x13
    jmp load_setup

ok_load_setup:
    mov ax,0x1000
    mov es,ax

load_system:
    ;mov dx,0x0000
    mov cx,0x0006
    mov bx,0x0a00
    mov ax,0x0210
    int 0x13
    jnc ok_load_system
    mov dx,0x0000
    mov ax,0x0000
    int 0x13
    jmp load_system

ok_load_system:
    jmp 0x9020:0

  	times 510 - ($ - $$) db 0
    dw 0xaa55