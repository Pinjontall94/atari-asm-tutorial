    processor 6502
    seg code
    org $F000


Start:
    sei
    cld
    ; Load the A register with the decimal value 1
    ; Load the X register with the decimal value 2
    ; Load the Y register with the decimal value 3
    lda #1
    ldx #2
    ldy #3

    ; Increment X
    ; Increment Y
    ; Increment A
    inx
    iny
    adc #0

    ; Decrement X
    ; Decrement Y
    ; Decrement A
    dex
    dey
    sbc #0

    jmp Start

    org $FFFC
    .word Start
    .word Start
