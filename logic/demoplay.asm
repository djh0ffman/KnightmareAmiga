;----------------------------------------------------------------------------
;
; demo play logic
;
; reads controls from a list to move player in demo mode
;
;----------------------------------------------------------------------------

    include    "common.asm"
; demo play logic
;

DemoPlayLogic:                                    ; ...
    ;ld         hl, DemoPlayWait
    ;dec        (hl)                                                             ; sub wait counter
    ;jr         nz, DemoPlayReadControl                                          ; counter not zero, apply current control
    ;ld         (hl), 8                                                          ; reload wait counter
    ;dec        hl                                                               ; move to control index
    ;inc        (hl)                                                             ; increment control index
    ;inc        hl                                                               ; move back to wait timer
    lea        DemoPlayWait(a5),a0
    subq.b     #1,(a0)                                                          ; sub wait counter
    bne        DemoPlayReadControl                                              ; move to control index
    move.b     #8,(a0)
    addq.b     #1,DemoPlayIndex(a5)

DemoPlayReadControl:                              ; ...
    ;dec        hl                                                               ; move to control index
    ;ld         a, (hl)
    ;ld         hl, DemoPlayData                                                 ; pointer to control data
    ;call       ADD_A_HL                                                         ; add index to pointer
    ;ld         a, (hl)
    moveq      #0,d0
    move.b     DemoPlayIndex(a5),d0
    cmp.b      #$ff,d0

    lea        DemoPlayData,a0
    move.b     (a0,d0.w),d0

    bne        StoreControls1
    ;cp         0FFh                                                             ; check end of data, but this condition is never met, player always dies before
    ;jp         nz, StoreControls1                                               ; no, use this value for player control in demo
    ;xor        a
    ;ld         (GameRunning), a                                                 ;  clear game running flag to reboot game
    ;ld         a, 3Dh                                                           ; kill sound
    bsr        SfxStopAll
    clr.b      GameRunning(a5)
    rts

;----------------------------------------------------------------------------
;
; start demo
;
;----------------------------------------------------------------------------


StartDemo:                                         ; ...
    ;call        UnpackSharedGfx
    ;ld          hl, EnemyData                          ; clear all the datas
    ;ld          de, EnemyData+1
    ;ld          bc, 6E0h                               ; number of bytes
    ;ld          (hl), 0
    ;ldir
    ;xor         a
    ;ld          (Stage), a
    
    ;call        DrawHud
    ;call        InitLevel
    bsr        InitLevel
    bsr        ShowHudScreen

    ;ld          a, (Level)
    ;inc         a
    ;ld          (Stage), a
    move.b     Level(a5),d0
    addq.b     #1,d0
    move.b     d0,Stage(a5)

    ;ld          hl, 800h
    ;ld          (DemoPlayIndex), hl
    clr.b      DemoPlayIndex(a5)
    move.b     #8,DemoPlayWait(a5)

    ;ld          a, 1
    ;ld          (GameRunning), a
    move.b     #1,GameRunning(a5)
    ;ret
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
