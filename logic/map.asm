
;----------------------------------------------------------------------------
;
; level map logic
;
;----------------------------------------------------------------------------


    include     "common.asm"

;----------------------------------------------------------------------------
;
; map init 
;
; draws the first full screen and does init scroll setup
;
;----------------------------------------------------------------------------

MapInit:
    moveq       #0,d0
    moveq       #0,d1
    move.b      #MAP_START,d0
    move.b      LevelPosition(a5),d1
    lsr.b       #2,d1
    sub.w       d1,d0

    move.w      d0,MapPosition(a5)
    move.w      #0,MapScrollOffset(a5)

    move.l      #Screen1,d4
    move.l      #Screen2,d5

    move.l      ScreenBuffer(a5),a0
    move.l      a0,a1
    add.l       #(TILES_Y-1)*SCREEN_TILE_SIZE,a0        ; clean buffer
    add.l       #((TILES_Y/2)-1)*SCREEN_TILE_SIZE,a1    ; display buffer 1

    lea         MapBuffer(a5),a3                        ; a3 = map data
    move.w      MapPosition(a5),d0
    lsl.w       #3,d0
    lea         (a3,d0.w),a3

    moveq       #(TILES_Y/2)-1,d7
.loop
    bsr         BlitTileRow
    exg         a0,a1
    bsr         BlitTileRow
    exg         a0,a1

    subq.w      #1,MapPosition(a5)

    lea         -SCREEN_TILE_SIZE(a0),a0
    lea         -SCREEN_TILE_SIZE(a1),a1
    dbra        d7,.loop

    addq.w      #1,MapPosition(a5)

    bsr         ScreenCopy

    move.b      #1,MapReadyFlag(a5)
    bsr         ShowGameScreen
    rts


ScrollOneOff:
    move.b      GameFrame(a5),d0
    and.b       #($40/8)-1,d0
    subq.b      #1,d0
    beq         BlitTileLine                   
    rts

ScrollLogic:
    cmp.b       #9,CheckPoint(a5)
    beq         ScrollTick

    move.b      GameFrame(a5),d0
    and.b       #($40/8)-1,d0
    beq         MapScroll
    
ScrollTick:
    tst.b       MapScrollTick(a5)
    beq         .exit
    clr.b       MapScrollTick(a5)
    bra         BlitTileLine            
.exit
    rts

;----------------------------------------------------------------------------
;
; map scroll
;
;----------------------------------------------------------------------------


MapScroll:
    tst.w       MapPosition(a5)                         ; check at end of map
    bmi         .exit                                   ; yes, dont do anything

    addq.b      #1,MapScrollTick(a5)                    ; scroll tick...  used for stuff to keep it moving on screen
    bsr         QBlockUpdate                            ; move qblocks down screen and updates the image

    subq.w      #1,MapScrollOffset(a5)
    move.w      MapScrollOffset(a5),d5                  ; move scroll params
    bpl         .nowrap
    move.w      #(SCREEN_HEIGHT_GAME/2)-1,d5 
.nowrap
    move.w      d5,d4
    moveq       #TILE_HEIGHT-1,d3
    and.b       d3,d4
    cmp.b       d3,d4
    bne         .skipmap
    subq.w      #1,MapPosition(a5)
    bmi         .mapend                                 ; end of map
.skipmap
    move.w      d5,MapScrollOffset(a5)
    and.b       #7,d5
    bne         .skip

    addq.b      #1,LevelPosition(a5)                    ; every 8 lines do this stuff

    cmp.b       #$d0,LevelPosition(a5)                  
    bne         .skipkillall

    PUSHMOST
    bsr         KillAllEnemy
    POPMOST
.skipkillall


    cmp.b       #$d4,LevelPosition(a5)
    bne         .skipgate

    move.b      #1,ModFadeStatus(a5)
    move.b      #4,ModFadeWait(a5)
    bsr         LoadLevelPal

.skipgate
    addq.b      #1,LevelCheckPoint(a5)
    move.b      LevelCheckPoint(a5),d0
    cmp.b       #3,d0
    bcs         .skip

    move.b      #1,AttackWaveActive(a5)
    cmp.b       #$18,d0
    bcs         .skip

    clr.b       LevelCheckPoint(a5)
    addq.b      #1,CheckPoint(a5)

.skip
    bsr         BlitTileLine
    bsr         ScrollMovePlayer

.exit
    rts


.mapend
    clr.w       MapPosition(a5)
    clr.b       MapReadyFlag(a5)
    rts

LoadLevelPal:
    moveq       #0,d0
    move.b      Level(a5),d0
LoadLevelPal1:
    add.w       d0,d0
    add.w       d0,d0
    lea         LevelPaletteList,a0
    cmp.b       #$d4,LevelPosition(a5)
    bcs         .notgate
    lea         LevelPaletteGateList,a0
.notgate
    move.l      (a0,d0.w),a0
    move.w      #SCREEN_COLORS,d0
    bsr         LoadPalette
    rts