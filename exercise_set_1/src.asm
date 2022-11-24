    processor 6502
    seg code
    org $F000


Start:
    sei
    cld
    lda #$A                     ; Load the A register with the hexadecimal value $A
    ldx #%11111111              ; Load the X register with the binary value %11111111
    sta $80                     ; Store the value in the A register into memory address $80
    stx $81                     ; Store the value in the X register into memory address $81

    jmp Start

    org $FFFC
    .word Start
    .word Start
