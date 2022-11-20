    processor 6502

    seg code
    org $F000

Start:
    sei                         ; disable interrupts
    cld                         ; disable binary-coded decimal system
    ldx #$FF                    ; load the literal $FF into X
    tsx                         ; transfer X register to the stack pointer

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Clear memory page zero region
;;; (meaning the entire RAM & all TIA addresses)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0                      ; A = 0
    ldx #$FF                    ; X = $FF

Memloop:
    sta $0,X                    ; Store A register in address 0 + X
    dex                         ; Decrement X
    bne Memloop                 ; Exit loop when dex sets the Z flag at X = 0

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fill ROM to the required size of 4kb (filling the cartridge)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start                 ; Reset vector at the new origin, $FFFC
    .word Start                 ; Interrupt vector at $FFFE (req'd for all 6502)
