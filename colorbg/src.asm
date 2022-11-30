    processor 6502

    include "vcs.h"
    include "macro.h"

    seg Code
    org $F000

Start:
;    CLEAN_START                 ; Macro to safely clean memory

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Set BG Luminosity to Yellow
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #$1E                    ; 1,14 NTSC is a bright yellow on the 2600
    sta COLUBK                  ; Store in the address for background luminance

    jmp Start

    org $FFFC
    .word Start
    .word Start
