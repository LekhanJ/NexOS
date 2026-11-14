org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A


; FAT12 headers
jmp short main
nop

bdb_oem:                    db 'MSWIN4.1'
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluter:     db 1
bdb_reserved_sector:        dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880
bdb_media_descriptor_type:  db 0F0h
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_head:                   dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; extended boot record
ebr_drive_number:           db 0
                            db 0
ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h
ebr_volume_label:           db 'NEX OS     '
ebr_system_id:              db 'FAT12   '


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

os_boot_msg: DB 'Our OS has booted!', ENDL, 0

; ax         -> LBA address
; cx [0-5]   -> sector number
; cx [6-15]  -> cylinder
; dh         -> head
lba_to_chs:

    push ax
    push dx

    xor dx, dx                          ; dx = 0
    div word [bda_sectors_per_track]    ; ax = LBA / SectorsPerTrack
                                        ; dx = LBA % SectorsPerTrack

    inc dx                              ; dx = (LBA % SectorsPerTrack) + 1 = sector
    mov cx, dx                          ; cx = sector

    xor dx, dx                          ; dx = 0
    div word [bdb_heads]                ; ax = (LBA / SectorsPerTrack) / Heads = cylinder
                                        ; dx = (LBA / SectorsPerTrack) % Heads = head

    mov dh, dl                          ; dh = head

    mov ch, al                          ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah

    pop ax
    mov dl, al                          ; restore DL
    pop ax

    ret

times 510 - ($ - $$) db 0
dw 0xAA55