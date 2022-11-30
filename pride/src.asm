    processor 6502

    include "vcs.h"
    include "macro.h"

    seg Code
    org $F000

Start:
    CLEAN_START                 ; Macro to safely clean memory

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Start new frame by turning on VSYNC & VBLANK
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NextFrame:
    lda #2
    sta VSYNC
    sta VBLANK

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Generate 3 lines of VSYNC by strobing the WSYNC signal
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC
    sta WSYNC
    sta WSYNC

    lda #0
    sta VSYNC                   ; Turn off VSYNC

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Generate the 37 ($25) VBLANK Lines (req'd by NTSC) with a loop
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #$25
LoopVBlank:
    sta WSYNC                   ; Hit WSYNC as before
    dex                         ; X-- (from X = 37)
    bne LoopVBlank              ; Exit loop when Z flag triggered by dex

    lda #0
    sta VBLANK                  ; Turn off VBLANK

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Draw the 192 ($C0) visible scanlines.
;;; $26 for blue and white, $27 for pink
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #$26                    ; Width of banner
    ldy #$98                    ; Banner color
LoopBlue:
    sty COLUBK                  ; Set background color
    sta WSYNC                   ; Wait for next scanline
    dex
    bne LoopBlue


    ldx #$27
    ldy #$5C
LoopPink:
    sty COLUBK                  ; Set background color
    sta WSYNC                   ; Wait for next scanline
    dex
    bne LoopPink


    ldx #$26
    ldy #$0E
LoopWhite:
    sty COLUBK                  ; Set background color
    sta WSYNC                   ; Wait for next scanline
    dex
    bne LoopWhite


    ldx #$27
    ldy #$5C
LoopPink2:
    sty COLUBK                  ; Set background color
    sta WSYNC                   ; Wait for next scanline
    dex
    bne LoopPink2


    ldx #$26                    ; Width of banner
    ldy #$98                    ; Banner color
LoopBlue2:
    sty COLUBK                  ; Set background color
    sta WSYNC                   ; Wait for next scanline
    dex
    bne LoopBlue2

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Generate the 30 ($1E) overscan lines to complete the frame
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK

    ldx #$1E
LoopOverscan:
    sta WSYNC
    dex
    bne LoopOverscan


    jmp NextFrame               ; Jump to the next frame to start again

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fill ROM cartridge (per 6502 requirements)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start
    .word Start
