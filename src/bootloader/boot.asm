org 0x7C00
bits 16

main:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7C00
    mov si, os_boot_msg
    call print
    hlt

halt:
    jmp halt

print:
    push si
    push ax
    push bx

print_loop:
    lodsb
    or al, al
    jz done_print

    mov ah, 0x0E ; represents printing a value to the screen
    mov bh, 0    ; represents page number
    int 0x10     ; video interrupt

    jmp print_loop

done_print:
    pop bx
    pop ax
    pop si
    ret

os_boot_msg: DB 'Our OS has booted!', 0x0D, 0x0A, 0

times 510 - ($ - $$) db 0
dw 0xAA55