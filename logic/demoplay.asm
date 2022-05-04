;----------------------------------------------------------------------------
;
; demo play logic
;
; reads controls from a list to move player in demo mode
;
;----------------------------------------------------------------------------

    include    "common.asm"

DemoPlayLogic:                             
    lea        DemoPlayWait(a5),a0
    subq.b     #1,(a0)                                                          ; sub wait counter
    bne        DemoPlayReadControl                                              ; move to control index
    move.b     #8,(a0)
    addq.b     #1,DemoPlayIndex(a5)

DemoPlayReadControl:                       
    moveq      #0,d0
    move.b     DemoPlayIndex(a5),d0
    cmp.b      #$ff,d0

    lea        DemoPlayData,a0
    move.b     (a0,d0.w),d0

    bne        StoreControls1

    bsr        SfxStopAll
    clr.b      GameRunning(a5)
    rts

;----------------------------------------------------------------------------
;
; start demo
;
;----------------------------------------------------------------------------


StartDemo:                                  
    bsr        InitLevel
    bsr        ShowHudScreen

    move.b     Level(a5),d0
    addq.b     #1,d0
    move.b     d0,Stage(a5)

    clr.b      DemoPlayIndex(a5)
    move.b     #8,DemoPlayWait(a5)

    move.b     #1,GameRunning(a5)
    rts



; ---------------------------------------------------------------------------
DemoPlayData:
    dc.b       1, 1, 9, $18, $18, 2, 5, 5, 4, $14, 4, 6, 2, $0A, 8, $11, 1 
    dc.b       1, 1, 1, 1, 8, 8, 8, 5, $14, $0A, $0A, $1A, 8, $19, $11, $14
    dc.b       $12, $1A, 8, $11, 4, 4, 6, 6, $14, $14, 4, 6, $14, 5, 4, 6
    dc.b       $16, 5, 4, $14, $14, $11, $11, 9, 9, 8, $18, $18, $0A, $1A
    dc.b       $1A, $1A, $10, $10, $10, $10, $10, $10, $12, $16, 4, 4, 4, 4
    dc.b       $15, $19, 8, $18, $18, 8, $0A, $18, $18, 9, $19, 8, 8, $19
    dc.b       9, $12, $12, 2, 4, $14, $12, 2, $19, $14, $1A, 8, 8, $0A, $11
    dc.b       $11, 8, 8, 8, $19, $18, 4, 4, 6, 6, 8, 8, -1
    EVEN
