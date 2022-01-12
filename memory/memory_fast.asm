;----------------------------------------------------------------------------
;
; fast ram areas
;
;----------------------------------------------------------------------------


    include    "common.asm"
  
    section    knightmare_bss_fast,bss

BlackPal:     
    ds.w       SCREEN_COLORS
PatternBuffer:
    ds.w       MAX_MODPATTERN_SIZE
Variables:    
    ds.b       Variables_SizeOf
ScoreTemp:
    ds.b       SAVE_SIZE_SECTOR*$200