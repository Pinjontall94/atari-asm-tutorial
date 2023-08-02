    processor 6502

    include "vcs.h"
    include "macro.h"

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Start an unitialized segment at RAM addr $80 for variable declaration
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80
P0Height byte                   ; Hardcode sprite height to 9 rows
P0YPos byte                     ; Declare var for player Y coordinates
P0XPos byte                     ; Declare var for player x coord

P1Height byte
P1YPos byte
P1XPos byte
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Start our main ROM segment
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg Code
    org $F000

Start:
    CLEAN_START                 ; Macro to safely clean memory and TIA

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Initial setup and Variables
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #$00                    ; Background color
    stx COLUBK

    lda #$0B
    sta P0Height

    lda #$82
    sta P0YPos

    lda #$28
    sta P1XPos

    lda #$10
    sta P1Height

    lda #$79
    sta P1YPos

    lda #$28
    sta P1XPos
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Turn on VSYNC & VBLANK
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NextFrame:
    lda #2
    sta VSYNC
    sta VBLANK

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Generate 3 VSYNC lines
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #3
LoopVsync:
    sta WSYNC
    dex
    bne LoopVsync
    lda #0
    sta VSYNC

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Set player horizontal position while in VBLANK
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda P1XPos                  ; load acc with desired X position

    sta WSYNC                   ; wait for next scanline
    sta HMCLR                   ; clear old x pos values

    sec                         ; set carry flag before subtraction
DivLoop:
    sbc #15                     ; subtract 15 (#$0F)
    bcs DivLoop              ; loop until the carry flag is used up
                                ;   (acc = (P0XPos % 15) - 15)

    eor #7                      ; adjust range to fit between -8 and +7
    asl                         ; HMP0 only uses top 4b, so need shift left 4x
    asl
    asl
    asl
    sta HMP1                    ; set fine position with the modulo value
    sta RESP1                   ; set coarse value
    sta WSYNC                   ; wait for next scanline
    sta HMOVE                   ; apply the position offset

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Generate 35 ($23) VBLANK lines and
;;;   turn off VSYNC/BLANK (37 - 2 from XPos)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #$23
LoopVblank:
    sta WSYNC
    dex
    bne LoopVblank
    lda #0
    sta VBLANK

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Generate 192 ($CO) visible lines
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #$C0

Scanline:
    txa                         ; Transfer X to A
    sec                         ; Make sure carry flag is set
    sbc P1YPos                  ; Subtract sprite Y coordinates
    cmp P1Height                ; Are we inside the sprite's bounds?
    bcc LoadBitmap              ; If result < Sprite height, run subroutine
    lda #0                      ; Else, set index to 0


LoadBitmap:
    tay                         ; BeamYPos <= P0 sprite bounds, A = P0Height - 1
    lda P1Bitmap,Y              ; Load player bitmap slice of data

    sta GRP1                    ; Set graphics for Player 0 slice
    lda P1Color,Y               ; load and set player 0 color from lookup table
    sta COLUP1

    sta WSYNC                   ; Draw scanline and wait for WSYNC signal from TIA chip

    dex                         ; Decrement x counter
    bne Scanline                ; Loop scanlines until the x counter reaches 0

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Generate 30 ($1E) overscan lines
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK

    ldx #30
LoopOverscan:
    sta WSYNC
    dex
    bne LoopOverscan

    lda #0
    sta VBLANK

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Inc X coord if 40 < x < 80
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda P1XPos
    cmp #80
    bpl ResetXPos               ; if A is greater, reset position
    jmp IncXPos                 ; else, continue to increment x pos
ResetXPos:
    lda #$28
    sta P1XPos                  ; reset player x pos to 40 (#$28)
IncXPos:
    inc P1XPos                  ; inc the player x position
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Loop by jumping to the next frame
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp NextFrame

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Defines an array of bytes to form the player sprites.
;;; We add these bytes in the last ROM addrs
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Bitmap:
    .byte #$00            ;             $#00 slice
    .byte #$92            ; #  #  #
    .byte #$92            ; #  #  #
    .byte #$92            ; #  #  #
    .byte #$54            ;  # # #
    .byte #$54            ;  # # #
    .byte #$54            ;  # # #
    .byte #$54            ;  # # #
    .byte #$54            ;  # # #
    .byte #$54            ;  # # #
    .byte #$54            ;  # # #      $#0A slice


P1Bitmap:
    .byte #$00 ; #%00000000            ; #$00
    .byte #$22 ; #%00100010            ; #$22
    .byte #$22
    .byte #$41 ; #%01000001            ; #$41
    .byte #$41
    .byte #$80 ; #%10000000            ; #$80
    .byte #$80
    .byte #$FF ; #%11111111            ; #$FF
    .byte #$FF
    .byte #$2A ; #%00101010            ; #$2A
    .byte #$2A
    .byte #$30 ; #%00110000            ; #$30
    .byte #$30
    .byte #$1E ; #%00011110            ; #$1E
    .byte #$1E
    .byte #$00 ; #%00000000            ; #$00

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Defines an array of bytes to form the scoreboard number.
;;; We add these bytes in the final ROM addrs
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Color:
    .byte #$00
    .byte #$8C
    .byte #$8C
    .byte #$4C
    .byte #$4C
    .byte #$0E
    .byte #$0E
    .byte #$4C
    .byte #$4C
    .byte #$8C
    .byte #$8C

P1Color:
    .byte #$00
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$4C
    .byte #$4C
    .byte #$4C
    .byte #$4C
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$00
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Put reset vectors at the last two bytes (per 6502 reqs)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start
    .word Start
