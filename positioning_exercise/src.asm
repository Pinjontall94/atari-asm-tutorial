    processor 6502

    include "vcs.h"
    include "macro.h"

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Start an unitialized segment at RAM addr $80 for variable declaration
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80
P0Height byte                  ; Hardcode sprite height to 9 rows
P0YPos byte                 ; Declare var for player Y coordinates
P0XPos byte                     ; Declare var for player x coord

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

    lda #11
    sta P0Height

    lda #$A2
    sta P0YPos

    lda #$10
    sta P0XPos

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
;;; Generate 37 ($25) VBLANK lines and
;;;   turn off VSYNC/BLANK
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #$25
LoopVblank:
    sta WSYNC
    dex
    bne LoopVblank
    lda #0
    sta VBLANK

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Set player horizontal position while in VBLANK
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda P0XPos                  ; load acc with desired X position

    sta WSYNC                   ; wait for next scanline
    sta HMCLR                   ; clear old x pos values

    sec                         ; set carry flag before subtraction
ModuloLoop:
    sbc #15                     ; subtract 15 (#$0F)
    bcs ModuloLoop              ; loop until the carry flag is used up
                                ;   (acc now contains P0XPos % 15)

    eor #7                      ; adjust range to fit between -8 and +7
    asl                         ; HMP0 only uses top 4b, so need shift left 4x
    asl
    asl
    asl
    sta HMP0                    ; set fine position with the modulo value
    sta RESP0                   ; set coarse value
    sta WSYNC                   ; wait for next scanline
    sta HMOVE                   ; apply the position offset


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Generate 192 ($CO) visible lines
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #$C0

Scanline:
    txa                         ; Transfer X to A
    sec                         ; Make sure carry flag is set
    sbc P0YPos              ; Subtract sprite Y coordinates
    cmp P0Height               ; Are we inside the sprite's bounds?
    bcc LoadBitmap              ; If result < Sprite height, run subroutine
    lda #0                     ; Else, set index to 0


LoadBitmap:
    tay
    lda P0Bitmap,Y              ; Load player bitmap slice of data

    sta GRP0                    ; Set graphics for Player 0 slice
    lda P0Color,Y               ; load and set player 0 color from lookup table
    sta COLUP0

    sta WSYNC                   ; Draw scanline and wait for WSYNC signal from TIA chip

    dex                         ; Decrement x counter
    bne Scanline                ; Loop scanlines until the x counter reaches 0

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Generate 30 ($1E) overscan lines
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Decrement P0YPos for animation
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    dec P0YPos
    inc P0XPos

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Loop by jumping to the next frame
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp NextFrame

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Defines an array of bytes to form the player sprites.
;;; We add these bytes in the last ROM addrs
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Bitmap:
    .byte #$00            ;
    .byte #$92            ; #  #  #
    .byte #$92            ; #  #  #
    .byte #$92            ; #  #  #
    .byte #$54            ;  # # #
    .byte #$54            ;  # # #
    .byte #$54            ;  # # #
    .byte #$54            ;  # # #
    .byte #$54            ;  # # #
    .byte #$54            ;  # # #
    .byte #$54            ;  # # #

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

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Put reset vectors at the last two bytes (per 6502 reqs)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start
    .word Start
