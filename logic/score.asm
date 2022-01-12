;----------------------------------------------------------------------------
;
;  score code
;
;----------------------------------------------------------------------------

    include    "common.asm"

; d0 = score to add

AddScore:
    btst       #6,ControlConfig(a5)
    beq        .noscore
    
    swap       d0
    clr.w      d0
    swap       d0
    add.l      d0,Score(a5)
    move.l     Score(a5),d0
.noscore
    rts