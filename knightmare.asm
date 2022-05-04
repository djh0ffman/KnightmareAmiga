    section    knightmare_code_fast,code
;----------------------------------------------------------------------------
;
; Knightmare - Amiga Port
;
; by Hoffman
;
;----------------------------------------------------------------------------

    incdir     include
    include    hw.i
    include    hardware/cia.i
    include    hardware/intbits.i

    include    "common.asm"



Main:    
    bra.w      .start

    dc.l       LoadGameDataPtr-Main                             ; WHDLoad patch offsets
    dc.l       SaveGameDataPtr-Main
    dc.l       KeyboardPatchPtr-Main 

.start
    PUSHALL

    bsr        system_disable
    tst.w      d0
    bne.b      .error

    bsr        MainThread

    bsr        system_enable
.error
    POPALL
    rts


;----------------------------------------------------------------------------
;
; main background thread (game runs on vblank interrupt)
;
;----------------------------------------------------------------------------

MainThread:
    lea        Variables,a5
    lea        CUSTOM,a6 
    

    bsr        Init

    move.b     #DEBUG_STARTSTATUS,GameStatus(a5)

    if         DEBUG_STARTSTATUS=9
    move.b     #7,Level(a5)
    bsr        InitLevel
    endif

         ;bsr        Install

    bsr        ReadControls                                     ; initial read as we get rubbish on first run
    move.l     #InterruptTick,vblank_pointer                    ; vblank int
    bra        GameMain
;----------------------------------------------------------------------------
;
; oops up
;
;----------------------------------------------------------------------------

Install:
    sub.l      a0,a0
    lea        Catch(pc),a1 
    move.l     a1,$c(a0)
    lea        Catch(pc),a1 
    move.l     a1,$10(a0)
    lea        Catch(pc),a1 
    move.l     a1,$14(a0)
    lea        Catch(pc),a1 
    move.l     a1,$18(a0)
    rts

Catch:
    nop
    rte

;----------------------------------------------------------------------------
;
; init phase
;
;----------------------------------------------------------------------------


Init:
    move.l     #$BABEFEED,RandomSeed(a5)

    jsr        AudioInit

    bsr        KeyboardInit   

    ;bsr        UnpackDeltaSamples
    bsr        ModPrepStaticSmp

    bsr        CalcStrideLookUp
    bsr        CalcScreenDepthLookUp
    bsr        CalcBlitHeightLookUp


    bsr        BlitInit
    bsr        BobClear

    bsr        InitHealthBar

    bsr        PlayerInitBobPtrs                          
    
    lea        BobQBlocks,a0
    lea        QBlockBobPtrs(a5),a1
    bsr        SetDataPointers

    lea        BobShadow,a0
    lea        ShadowBobPtrs(a5),a1
    bsr        SetDataPointers

    lea        BobPlayerShots,a0
    lea        PlayerShotBobPtrs(a5),a1
    bsr        SetDataPointers

    lea        BobPowerUp,a0
    lea        PowerUpBobPtrs(a5),a1
    bsr        SetDataPointers

    lea        BobPowerUp1,a0
    lea        PowerUpBobPtrs1(a5),a1
    bsr        SetDataPointers

    lea        BobPowerUp2,a0
    lea        PowerUpBobPtrs2(a5),a1
    bsr        SetDataPointers

    lea        BobWeaponPowerUp1,a0
    lea        WeaponPowerUpBobPtrs1(a5),a1
    bsr        SetDataPointers

    lea        BobWeaponPowerUp2,a0
    lea        WeaponPowerUpBobPtrs2(a5),a1
    bsr        SetDataPointers

    lea        BobFireDeath,a0
    lea        FireDeathBobPtrs(a5),a1
    bsr        SetDataPointers

    lea        BobBossSkullShadow,a0    
    lea        BossBobShadowPtrs(a5),a1
    bsr        SetDataPointers

    lea        BobEye,a0    
    lea        EyeBobPtrs(a5),a1
    bsr        SetDataPointers

    lea        BobHUD,a0    
    lea        HUDImagePtrs(a5),a1
    bsr        SetDataPointers

    bsr        SetupEnemyBobs

    bsr        FreezeTimerColonRender

    move.b     #DEBUG_AUTOFIRE,OptionAutoFire(a5)

    lea        SoundBank,a0    
    lea        SoundIndex(a5),a1
    bsr        SetDataPointers
    ;bsr        SfxBufferInit
    ;bsr        SfxUnpackAll

    move.l     #Screen1+SCREEN_EDGE,ScreenBuffer(a5)
    move.l     #Screen2+SCREEN_EDGE,ScreenBuffer+4(a5)
         ;move.l     #ScreenSave+SCREEN_EDGE,ScreenBufferClean(a5)

    move.b     #SCREEN_START,ScreenStart(a5)
    move.b     #SCREEN_END,ScreenEnd(a5)

    tst.w      PalFlag(a5)
    bne        .ntsc              

    move.b     #SCREEN_START+SCREEN_OFFSET60,ScreenStart(a5)
    move.b     #SCREEN_END+SCREEN_OFFSET60,ScreenEnd(a5)
.ntsc
    bsr        CopperInit

    bsr        SetVertScroll

    bsr        ClearAllSprites
    lea        MenuPal,a0
    move.w     #SCREEN_COLORS,d0
    bsr        LoadPalette
         
    bsr        DirtyHud

    bsr        ScoreBoardInit

    bsr        LoadCopperScroll
    bsr        LoadCopperScroll
         
;         move.l     CopperBuffer(a5),d0
;         move.l     CopperBuffer(a5),COP1LC(a6)                      ; load copper
    move.w     #INIT_DMA,DMACON(a6)                             ; kick off DMA
    ;move.w         #0,COPJMP1(a6)

    rts

;----------------------------------------------------------------------------
;
; enemy bob pointer setup
;
;----------------------------------------------------------------------------

SetupEnemyBobs:
    lea        EnemyBobList,a0
    lea        EnemyBobPtrs(a5),a1
    lea        EnemyBobLookup(a5),a2
    moveq      #16-1,d7
    bsr        InitBobArray

    lea        EnemyShotBobList,a0
    lea        EnemyShotBobPtrs(a5),a1
    lea        EnemyShotBobLookup(a5),a2
    moveq      #17-1,d7
    bsr        InitBobArray

    rts


;----------------------------------------------------------------------------
;
; bob array loader
;
; a0 = bob list
; a1 = array
; a2 = pointer list
; d7 = count - 1
;----------------------------------------------------------------------------


InitBobArray:
    move.l     a1,(a2)+

    move.l     (a0)+,a3                                         ; data chunk

    moveq      #0,d0
    move.w     (a3)+,d6
    subq.w     #1,d6                                            ; count of data items
.loop
    move.w     (a3)+,d0                                         ; length of this chunk
    move.l     a3,(a1)+                                         ; store this pointer
    add.l      d0,a3                                            ; move to next items
    dbra       d6,.loop
         
    dbra       d7,InitBobArray
    rts
;----------------------------------------------------------------------------
;
; screen height look up
;
;----------------------------------------------------------------------------

CalcStrideLookUp:
    lea        StrideLookUp(a5),a0
    moveq      #0,d0
    move.w     #SCREEN_HEIGHT_GAME-1,d7
.loop
    move.w     d0,d1
    mulu       #SCREEN_STRIDE,d1
    move.l     d1,(a0)+
    addq.w     #1,d0
    dbra       d7,.loop
    rts


;----------------------------------------------------------------------------
;
; screen height look up
;
;----------------------------------------------------------------------------

CalcBlitHeightLookUp:
    lea        BlitHeightLookUp(a5),a0
    moveq      #0,d0
    move.w     #BLIT_HEIGHT_MAX-1,d7
.loop
    move.w     d0,d1
    mulu       #SCREEN_DEPTH,d1
    lsl.w      #6,d1
    move.w     d1,(a0)+
    addq.w     #1,d0
    dbra       d7,.loop
    rts


;----------------------------------------------------------------------------
;
; screen depth look up
;
;----------------------------------------------------------------------------

CalcScreenDepthLookUp:
    lea        ScreenDepthLookUp(a5),a0
    moveq      #0,d0
    move.w     #SCREEN_DEPTH_LOOKUP-1,d7
.loop
    move.w     d0,d1
    mulu       #SCREEN_DEPTH,d1
    move.w     d1,(a0)+
    addq.w     #1,d0
    dbra       d7,.loop
    rts


;----------------------------------------------------------------------------
;
; vblank interrupt
;
;----------------------------------------------------------------------------

InterruptTick:
    move.b     #1,InterruptFlag(a5)
    lea        CUSTOM,a6
    lea        Variables,a5
    cmp.b      #1,GameStatus(a5)
    bne        .skipmenu
    bsr        TitleMainLogic
.skipmenu
    addq.b     #1,InterruptCount(a5)
    rts

GameMain:
    lea        Variables,a5
    lea        CUSTOM,a6

.norequest
    ;move.b     InterruptCount(a5),d0
    ;move.b     InterruptPrev(a5),d1
    ;cmp.b      d0,d1
    ;beq        .norequest

    ;move.b     d0,InterruptPrev(a5)
    ;sub.b      d1,d0
    ;cmp.b      #1,d0
    ;beq        .ok                                        ; frame has not over run
    move.b     InterruptFlag(a5),d0
    beq        .norequest

    cmp.b      #1,GameStatus(a5)                                ; title screen allows roll over
    beq        .skipthrottle                                    ; skip frame trottling

    cmp.b      #2,d0
    beq        .norequest                                       ; overrun the frame

.skipthrottle    
    clr.b      InterruptFlag(a5)

    bsr        UpdateControls

    tst.b      PauseFlag(a5)
    beq        .notpaused

    btst       #0,FKeysTrigger(a5)
    beq        GameMain

    clr.b      PauseFlag(a5)
    bsr        MusicPlay
    bra        GameMain

.notpaused
    cmp.b      #11,GameStatus(a5)
    beq        .inshop

    bsr        BlitQueueSwap
    bsr        BlitRestore
    bsr        PowerUpCollectSfxCheck
    bsr        BlitQueueReset
.inshop

    bsr        GameStatusLogic

    cmp.b      #1,GameStatus(a5)                                ; skip copper loading if in menu
    beq        .skipcopper
    tst.b      DisableCopper(a5)
    bne        .skipcopper
    bsr        LoadCopperScroll
.skipcopper

    if         DEBUG_STATS=1
    bsr        DebugStats
    else
    bsr        TextHudStats
    endif

    bsr        MusicFade

    if         DEBUG_CHEAT=1
    bsr        Cheat
    endif

    tst.b      InterruptFlag(a5)
    beq        GameMain

    addq.b     #1,InterruptFlag(a5)                             ; 

    ;move.w     #$006,COLOR00(a6)
    bra        GameMain

Cheat:
    btst       #4,FKeysTrigger(a5)
    beq        .skip
    ;move.b     #$ff,PowerUpTimerHi(a5)                                 ; TODO: correct values here?!
    ;move.b     #$ff,PowerUpTimerLo(a5)                                 ; TODO: hz value
    ;move.b     #POWERUP_TRANSPARENT,PlayerStatus+PLAYER_PowerUp(a5)
    ;bsr        PowerTimerDisplay
    ;move.w     #$fff,COLOR00(a6)
    move.b     #1,FreezeFlag(a5)
    move.b     #1,FreezeStatus(a5)
    move.b     #5,FreezeTimerHi(a5)
    clr.b      FreezeTimerLo(a5)
    move.b     GameFrame(a5),FreezeTimeGameFrame(a5)

    bsr        FreezeTimerDisplay
.skip
    rts

    include    "logic/demoplay.asm"
    include    "logic/controls.asm"
    include    "logic/initlevel.asm"
    include    "logic/playerlogic.asm"
    include    "logic/gamelogic.asm"
    include    "logic/qblocklogic.asm"
    include    "logic/powerup.asm"
    include    "logic/playershots.asm"
    include    "logic/collision.asm"
    include    "logic/attackwave.asm"

    include    "logic/enemylogic.asm"
    include    "logic/bosslogic.asm"

    include    "logic/gamestatuslogic.asm"

    include    "logic/map.asm"
    include    "logic/copper.asm"
    include    "logic/palette.asm"
    include    "logic/text.asm"
    include    "logic/score.asm"
    include    "logic/sprites.asm"
    include    "logic/ending.asm"

    include    "logic/soundmenu.asm"
    include    "logic/shoplogic.asm"
    include    "logic/scoreboard.asm"

    include    "logic/mainmenu.asm"

    include    "logic/endcredits.asm"

    include    "logic/blitter.asm"
    include    "utils/unpack.asm"
    include    "logic/shared.asm"
    include    "utils/oskill.asm"
  
    include    "utils/doynax.asm"
    include    "utils/shrinkler.asm"
    include    "utils/serial.asm"
    include    "utils/binary2decimal.asm"
    include    "utils/rnc.asm"

    include    "logic/audio.asm"

    include    "logic/debug.asm"

    include    "memory/data_chip.asm"
    include    "memory/data_fast.asm"
    include    "memory/memory_chip.asm"
    include    "memory/memory_fast.asm"
  
    include    "utils/ptplayer.asm"