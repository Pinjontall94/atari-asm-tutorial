    processor 6502
    seg code
    org $F000


Start:
    lda #1

Loop:
    ; Increment A
    ; Compare the value in A with the decimal value 10
    ; Branch back to loop if the comparison was not equals (to zero)
    adc #1
    cmp #10
    bcc Loop

    jmp Start

    org $FFFC
    .word Start
    .word Start
