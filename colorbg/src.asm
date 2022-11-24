    processor 6502
    include "vcs.h"
    include "macro.h"
    seg Code
    org $F000

Start:

    org $FFFC
    .word Start
    .word Start
