;----------------------------------------------------------------------------
;
; sound menu
;
;----------------------------------------------------------------------------

    include     "common.asm"

SoundMenuLogic:
    JMPINDEX    d1

SoundMenuIndex:
    dc.w        SoundMenuInit-SoundMenuIndex
    dc.w        SoundMenuControl-SoundMenuIndex
    dc.w        SoundMenuClear-SoundMenuIndex

SoundMenuControl:
    move.b      ControlsTrigger(a5),d0
    and.b       #3,d0
    bne         MenuUpDown

    move.b      ControlsTrigger(a5),d0
    and.b       #$c,d0
    bne         MenuCycle

    btst        #4,ControlsTrigger(a5)
    bne         MenuSelect
    rts

SoundMenuClear:
    bsr         ClearHorizontal
    bne         .notyet
    jsr         _mt_end
    and.b       #$bf,ControlConfig(a5)                 ; set control to out of game
    bra         ResetGameStatus
.notyet
    rts

MENU_MAX_OPTIONS = 5

MenuUpDown:
    btst        #1,ControlsTrigger(a5)
    bne         .down

    ; up
    tst.b       SoundMenuId(a5)
    beq         .exit
    bsr         ClearSoundArrow
    subq.b      #1,SoundMenuId(a5)
    bra         PlotSoundArrow

.down
    cmp.b       #MENU_MAX_OPTIONS-1,SoundMenuId(a5)
    beq         .exit
    bsr         ClearSoundArrow
    addq.b      #1,SoundMenuId(a5)
    bra         PlotSoundArrow
.exit
    rts

;----------------------------------------------------------------------------
;
; draw music item
;
;----------------------------------------------------------------------------

MenuDrawMusic:
    bsr         wait_raster_HUD
    moveq       #0,d2
    move.b      MusicId(a5),d2
    lea         TextMusicClear,a1
    lea         ModNameList,a0

    add.w       d2,d2
    add.w       d2,d2
    move.l      (a0,d2.w),a0
    PUSH        a0

    move.l      a1,a0
    bsr         TextPlotMain
    POP         a0
    bra         TextPlotMain

;----------------------------------------------------------------------------
;
; draw autofire
;
;----------------------------------------------------------------------------

MenuDrawAutoFire:
    moveq       #0,d0
    lea         TextAutoFireOff,a0
    move.b      OptionAutoFire(a5),d0
    beq         TextPlotMain
    lea         TextAutoFireOn,a0
    bra         TextPlotMain


;----------------------------------------------------------------------------
;
; draw video
;
;----------------------------------------------------------------------------

MenuDrawVideo:
    bsr         SetVideoMode
    moveq       #0,d0
    lea         TextVideo1,a0
    move.b      OptionVideo(a5),d0
    beq         TextPlotMain
    lea         TextVideo2,a0
    subq.b      #1,d0
    beq         TextPlotMain
    lea         TextVideo3,a0
    bra         TextPlotMain


SetVideoMode:
    move.b      OptionVideo(a5),d0
    cmp.b       #1,d0
    beq         .hz50

    cmp.b       #2,d0
    beq         .hz60
    bra         .exit

.hz50
    move.w      #$20,$1dc(a6)

    move.b      #SCREEN_START,ScreenStart(a5)
    move.b      #SCREEN_END,ScreenEnd(a5)

    bsr         SetVertScroll

    bra         .exit

.hz60
    move.w      #$0,$1dc(a6)

    move.b      #SCREEN_START-$10,ScreenStart(a5)
    move.b      #SCREEN_END-$10,ScreenEnd(a5)

    bsr         SetVertScroll

.exit
    rts

;----------------------------------------------------------------------------
;
; draw sfx item
;
;----------------------------------------------------------------------------

MenuDrawSfx:
    bsr         wait_raster_HUD
    moveq       #0,d2
    move.b      SfxId(a5),d2
    lea         SfxNameList,a0
    lea         TextSfxClear,a1

    add.w       d2,d2
    add.w       d2,d2
    move.l      (a0,d2.w),a0
    PUSH        a0

    move.l      a1,a0
    bsr         TextPlotMain
    POP         a0
    bra         TextPlotMain


;----------------------------------------------------------------------------
;
; plot the arrow
;
;----------------------------------------------------------------------------

ClearSoundArrow:
    move.b      #" ",d2
    bra         DoSoundArrow


PlotSoundArrow:
    move.b      #"%",d2
DoSoundArrow:
    move.w      #2,d0
    move.w      #0,d1

    moveq       #0,d3
    move.b      SoundMenuId(a5),d3
    mulu        #3,d3
    add.w       d3,d0
.top
    bsr         CharPlotMain
    rts

;----------------------------------------------------------------------------
;
; sound menu init
;
;----------------------------------------------------------------------------

SoundMenuInit:
    sf          DoubleBuffer(a5)
    bsr         HideHudScreen

    clr.b       SfxId(a5)
    clr.b       MusicId(a5)

    bsr         HideGameScreen
    bsr         wait_raster_HUD
    bsr         ScreenClear
    WAITBLIT


    lea         TextMenu,a0
    bsr         TextPlotMain

    addq.b      #1,GameSubStatus(a5)

    lea         MenuPal,a0
    move.w      #SCREEN_COLORS,d0
    bsr         LoadPalette

    bsr         MenuDrawVideo
    bsr         MenuDrawAutoFire
    bsr         MenuDrawMusic
    bsr         MenuDrawSfx

    bsr         PlotSoundArrow


    bsr         ShowGameScreen

    move.b      #$40,ControlConfig(a5)    
    rts

;----------------------------------------------------------------------------
;
; menu cycle left right
;
;----------------------------------------------------------------------------

MenuCycle:
    move.b      ControlsTrigger(a5),d0
    moveq       #0,d1
    move.b      SoundMenuId(a5),d1
    JMPINDEX    d1

MenuCycleIndex:
    dc.w        MenuCycleAutoFire-MenuCycleIndex
    dc.w        MenuCycleVideo-MenuCycleIndex
    dc.w        MenuCycleMusic-MenuCycleIndex
    dc.w        MenuCycleSfx-MenuCycleIndex
    dc.w        MenuDummy-MenuCycleIndex


MenuCycleVideo:
    lea         OptionVideo(a5),a0
    move.b      #3-1,d1

    move.b      (a0),d2
    btst        #2,d0
    bne         .moveleft

    ; move right
    addq.b      #1,d2
    cmp.b       d2,d1
    bcs         .exit
    move.b      d2,(a0)
    bra         MenuDrawVideo

.moveleft
    sub.b       #1,d2
    bmi         .exit
    move.b      d2,(a0)
    bra         MenuDrawVideo
.exit
    rts

MenuCycleAutoFire:
    eor.b       #1,OptionAutoFire(a5)
    bra         MenuDrawAutoFire

MenuCycleMusic:
    lea         MusicId(a5),a0
    move.b      #MOD_COUNT-1,d1

    move.b      (a0),d2
    btst        #2,d0
    bne         .moveleft

    ; move right
    addq.b      #1,d2
    cmp.b       d2,d1
    bcs         .exit
    move.b      d2,(a0)
    bra         MenuDrawMusic

.moveleft
    sub.b       #1,d2
    bmi         .exit
    move.b      d2,(a0)
    bra         MenuDrawMusic
.exit
    rts

MenuCycleSfx:
    lea         SfxId(a5),a0
    move.b      #SFX_COUNT-1,d1

    move.b      (a0),d2
    btst        #2,d0
    bne         .moveleft

    ; move right
    addq.b      #1,d2
    cmp.b       d2,d1
    bcs         .exit
    move.b      d2,(a0)
    bra         MenuDrawSfx

.moveleft
    sub.b       #1,d2
    bmi         .exit
    move.b      d2,(a0)
    bra         MenuDrawSfx
.exit
    rts

MenuDummy:
    rts


;----------------------------------------------------------------------------
;
; menu select / fire
;
;----------------------------------------------------------------------------

MenuSelect:
    moveq       #0,d0
    move.b      SoundMenuId(a5),d0
    JMPINDEX    d0

MenuSelectIndex:
    dc.w        MenuDummy-MenuSelectIndex
    dc.w        MenuDummy-MenuSelectIndex
    dc.w        MenuPlayMusic-MenuSelectIndex
    dc.w        MenuPlaySfx-MenuSelectIndex
    dc.w        MenuExit-MenuSelectIndex

MenuPlayMusic:
    move.w      #-1,ModLastUnpacked(a5)
    moveq       #0,d0
    moveq       #0,d1
    move.b      MusicId(a5),d1
    bra         MusicSet


MenuPlaySfx:
    moveq       #0,d0
    move.b      SfxId(a5),d0
    lea         SfxIdList,a0
    move.b      (a0,d0.w),d0
    bra         SfxPlay

MenuExit:
    clr.b       Shrink(a5)
    addq.b      #1,GameSubStatus(a5)
    rts
