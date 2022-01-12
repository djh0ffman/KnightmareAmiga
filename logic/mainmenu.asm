;----------------------------------------------------------------------------
;
;  main menu initalise
;
;----------------------------------------------------------------------------



    include            "common.asm"

MainMenuInit:
    bsr                BobClear

    clr.w              TitleStatus(a5)
    clr.w              TitleFrameCount(a5)
    move.w             #128,TitleCastlePos(a5)                            ; initial castle position
    
    move.w             #51<<8,TitleYStart(a5)
    move.w             #$0010,TitleYDelta(a5)

    move.w             #TITLE_START_WIDTH,TitleWidth(a5)
    move.w             #TITLE_START_HEIGHT,TitleHeight(a5)

    bsr                HideGameScreen
    bsr                wait_raster_HUD
    bsr                ScreenClear
    WAITBLIT

    ;move.l             #Title_BufferSize,d0  ; check buffer size
    ;lea                WorkArea,a0
    ;add.l              d0,a0
    ;lea.l              WorkAreaEnd,a1

    ; setup all the pointers in our screen memory
    lea                WorkArea,a0
    lea                TitleBuffers(a5),a2                       
    move.l             a0,a1
    add.l              #Title_Buffer1,a1
    move.l             a1,(a2)+
    move.l             a0,a1
    add.l              #Title_Buffer2,a1
    move.l             a1,(a2)+
    move.l             a0,a1
    add.l              #Title_Buffer3,a1
    move.l             a1,(a2)+
    move.l             a0,a1
    add.l              #Title_Buffer4,a1
    move.l             a1,(a2)+
    move.l             a0,a1
    add.l              #Title_Buffer5,a1
    move.l             a1,(a2)+
                       
    move.l             a0,a1
    add.l              #Title_Clouds,a1
    move.l             a1,TitleCloudPtr(a5)

    move.l             a0,a1
    add.l              #Title_Castle,a1
    move.l             a1,TitleCastlePtr(a5)

    move.l             a0,a1
    add.l              #Title_CodeBuffer,a1
    move.l             a1,TitleCodeBufferPtr(a5)

    move.l             a0,a1
    add.l              #Title_JumpTable,a1
    move.l             a1,TitleJumpTablePtr(a5)

    move.l             a0,a1
    add.l              #Title_YScale1,a1
    move.l             a1,TitleYScalePtrs(a5)

    move.l             a0,a1
    add.l              #Title_YScale2,a1
    move.l             a1,TitleYScalePtrs+4(a5)

    move.l             a0,a1
    add.l              #Title_YScale3,a1
    move.l             a1,TitleYScalePtrs+8(a5)

    move.l             a0,a1
    add.l              #Title_YScale4,a1
    move.l             a1,TitleYScalePtrs+12(a5)

    move.l             a0,a1
    add.l              #Title_Copper1,a1
    move.l             a1,TitleCopperPtr(a5)

    move.l             a0,a1
    add.l              #Title_Copper2,a1
    move.l             a1,TitleCopperPtr+4(a5)

    lea                TitleSpritePtrs(a5),a2
    move.l             a0,a1
    add.l              #Title_Sprites,a1
    moveq              #8-1,d7
.sprloop
    move.l             a1,(a2)+
    lea                TITLE_SPRITE_BLOCK(a1),a1
    dbra               d7,.sprloop

    bsr                LoadCopperMenu
    
    lea                BlackPal,a0
    move.w             #SCREEN_COLORS,d0
    bsr                LoadPalette

    ;lea                cpMenuPalette,a0
    move.l             TitleCopperPtr(a5),a0
    add.l              #COPPER_MENU_PALETTE,a0
    bsr                PaletteToCopper

    move.l             TitleCopperPtr+4(a5),a0
    add.l              #COPPER_MENU_PALETTE,a0
    bsr                PaletteToCopper

    lea                TitlePal,a0
    move.w             #SCREEN_COLORS,d0
    bsr                FadeInit

    bsr                GenTitleScrollLookUp

    bsr                TitleSpritesInit
    bsr                SetMenuArrow
    bsr                RenderTitleSprites

    bsr                DeafultTitleMod

    ; unpack the graphics
    lea                TitleLogo,a0
    move.l             TitleBuffers(a5),a1                                ; unpack the image to the title buffer
    bsr                Unpack

    lea                Clouds,a0
    move.l             TitleCloudPtr(a5),a1                               ; unpack the image to the title buffer
    bsr                Unpack

    lea                Castle,a0
    move.l             TitleCastlePtr(a5),a1                              ; unpack the image to the title buffer
    bsr                Unpack


    ; generate plotting code
    bsr                TitleCodeGen

    moveq              #0,d0
    move.w             #MOD_TITLE,d1
    bsr                MusicSetHard

    ; one rotate and buffer clear to remove temp logo
    lea                TitleBuffers(a5),a0
    ROTATE_LONG        a0,4
    
    bsr                MenuCopperSetup

    ;move.l             #cpMenu,COP1LC(a6)
    ;move.l             TitleCopperPtr(a5),COP1LC(a6)



    rts    

;----------------------------------------------------------------------------
;
;  scroll value look up
;
;----------------------------------------------------------------------------

GenTitleScrollLookUp:
    lea                TitleScrollLookUp(a5),a0
    moveq              #TITLE_MAX_SCROLL-1,d7
    moveq              #0,d0                                              ; scroll val
.loop
    move.w             d0,d1    
    not                d1
    and.w              #$f,d1
    lsl.w              #$4,d1
    move.b             d1,(a0)+
    addq.w             #1,d0
    dbra               d7,.loop
    rts

;----------------------------------------------------------------------------
;
;  deafault top title modulo
;

;----------------------------------------------------------------------------
DeafultTitleMod:
    move.l             TitleYScalePtrs(a5),a0
    move.l             TitleYScalePtrs+4(a5),a1
    move.l             TitleYScalePtrs+8(a5),a2
        
    move.w             #(TITLE_WIDTH_BYTE*-1)-2,d0

    move.w             #TITLE_FIELD_HEIGHT,d7
.loop
    move.w             d0,(a0)+
    move.w             d0,(a1)+
    move.w             d0,(a2)+
    dbra               d7,.loop
    rts


;----------------------------------------------------------------------------
;
;  main menu copper setup
;
;----------------------------------------------------------------------------

MenuCopperSetup:
    move.l             #$1000000,a4                                       ; wait value move

    moveq              #0,d1                                              ; plane offset
    moveq              #0,d2

    moveq              #0,d0
    move.w             TitleYOffsets+4(a5),d0
    bmi                .nooffset

    ;move.w             TitleYStart(a5),d0
    ;bmi                .nooffset
    mulu               #TITLE_WIDTH_BYTE,d0
    move.w             d0,d1

.nooffset
    ;lea                cpMenuPlanes,a3
    move.l             TitleCopperPtr(a5),a3
    add.l              #COPPER_MENU_PLANES,a3

    add.l              TitleBuffers+16(a5),d1                             ; current screen    
    subq.l             #2,d1       
    move.l             #TITLE_WIDTH_BYTE*TITLE_HEIGHT,d2
    LONGTOCOPPERADD    d1,a3,MENU_DEPTH,d2
    
    ;lea                cpMenuDynamic,a0
    move.l             TitleCopperPtr(a5),a0
    add.l              #COPPER_MENU_HEADER,a0
    lea                TitleSinus,a1 

    move.w             TitleSinePos(a5),d0
    lea                (a1,d0.w),a1    


    ;move.l             #$2b01ff00,d0                                      ; wait value

    moveq              #0,d0
    move.b             ScreenStart(a5),d0
    subq.w             #1,d0
    lsl.w              #8,d0
    swap               d0
    or.l               #$1ff00,d0

    moveq              #0,d6                                              ; start position
    move.b             (a1)+,d6

    move.l             TitleCloudPtr(a5),d5
    move.l             d6,d4
    lsr.w              #3,d4
    add.l              d5,d4                                              ; plane pointer offset

    move.w             d6,d2
    not                d2
    and.w              #$f,d2
    lsl.w              #$4,d2                                             ; prev scroll

    moveq              #3-1,d7
    move.w             #BPL2PTH,d3
.planeloop
    swap               d4
    move.w             d3,(a0)+
    move.w             d4,(a0)+    
    addq.w             #2,d3                                              
    swap               d4
    move.w             d3,(a0)+
    move.w             d4,(a0)+    
    addq.w             #6,d3
    add.l              #CLOUDS_WIDTH_BYTE*CLOUDS_HEIGHT,d4
    dbra               d7,.planeloop

    move.w             #BPLCON1,(a0)+
    move.w             d2,(a0)+

    move.w             #BPL2MOD,(a0)+                                     ; set current adjustment value
    move.w             #CLOUDS_PLANE_MOD,(a0)+

    move.l             d0,(a0)+                                           ; store wait
    add.l              a4,d0                                              ; next line

    
    ; start of looped generation!
    ;moveq              #$f,d4                                             ; and value probably not needed
    move.w             #$fff0,d4                                          ; 16 mask
    lea                TitleScrollLookUp(a5),a2                           ; title scroll lookup

    ; -- title bar section
    move.l             TitleYScalePtrs+8(a5),a3
    move.w             #TITLE_FIELD_HEIGHT,d7
    bsr                TitleCopperBuildLoopTop                            ; build title area

    ; -- castle section

    move.w             TitleCastlePos(a5),d7
    subq.w             #1,d7
    bmi                .castlefull
    cmp.w              #CLOUDS_HEIGHT-TITLE_FIELD_HEIGHT-2,d7
    bcc                .fullwave

.visible
    bsr                TitleCopperBuildLoop
    bsr                InsertCastle
    move.w             #CLOUDS_HEIGHT-TITLE_FIELD_HEIGHT-1,d7
    sub.w              TitleCastlePos(a5),d7
    subq.w             #1,d7
    bmi                .endcopper
    bsr                TitleCopperBuildLoop
    bra                .endcopper

.castlefull
    bsr                InsertCastle
.fullwave
    move.w             #CLOUDS_HEIGHT-TITLE_FIELD_HEIGHT-2,d7
    bsr                TitleCopperBuildLoop

.endcopper

        ; copper halt
    moveq              #-1,d0
    move.l             d0,(a0)+
    move.l             d0,(a0)+

    ;move.l             a0,d0
    ;sub.l              #cpMenu,d0
    move.l             TitleCopperPtr(a5),COP1LC(a6)
    lea                TitleCopperPtr(a5),a0
    ROTATE_LONG        a0,2
    
    rts




InsertCastle:
    lea                cpMenuCastle,a3
    move.w             #((cpMenuCastleEnd-cpMenuCastle)/4)-1,d7
.castleloop
    move.l             (a3)+,(a0)+
    dbra               d7,.castleloop
    rts

;----------------------------------------------------------------------------
;
;  build the wave
;
;----------------------------------------------------------------------------

TitleCopperBuildLoop:
    moveq              #0,d5
    moveq              #0,d1
    move.w             #BPLCON1,d3
.loop
    move.l             d0,(a0)+                                           ; store wait
    add.l              a4,d0                                              ; next line

    move.b             (a1),d5                                            ; position

    move.b             (a2,d5),d1                                         ; get scroll value

    move.w             d3,(a0)+                                           ; BPLCON1
    move.w             d2,(a0)+
    
    move.w             d1,d2

    and.w              d4,d5                                              ; mask lower 16 pixels
    and.w              d4,d6
    sub.w              d6,d5                                              ; get difference from last value
    beq                .noval
    asr.w              #3,d5
.noval
    add.w              #CLOUDS_PLANE_MOD,d5                               ; add mod general offset

    move.w             #BPL2MOD,(a0)+                                     ; set current adjustment value
    move.w             d5,(a0)+

    ; previous value
    moveq              #0,d6
    move.b             (a1)+,d6

    dbra               d7,.loop
    rts



;----------------------------------------------------------------------------
;
;  build the wave and y scale logo top half title screen
;
;----------------------------------------------------------------------------

TitleCopperBuildLoopTop:
    moveq              #0,d5
    moveq              #0,d1
    move.w             #BPLCON1,d3
.loop
    move.l             d0,(a0)+                                           ; store wait
    add.l              a4,d0                                              ; next line

    move.b             (a1),d5                                            ; position

    move.b             (a2,d5),d1

    move.w             d3,(a0)+                                           ; BPLCON1
    move.w             d2,(a0)+

    move.w             d1,d2

    and.w              d4,d5                                              ; mask lower 16 pixels
    and.w              d4,d6
    sub.w              d6,d5                                              ; get difference from last value
    beq                .noval
    asr.w              #3,d5
.noval
    add.w              #CLOUDS_PLANE_MOD,d5                               ; add mod general offset

    move.w             #BPL2MOD,(a0)+                                     ; set current adjustment value
    move.w             d5,(a0)+

    move.w             #BPL1MOD,(a0)+                                     ; set current adjustment value
    move.w             (a3)+,(a0)+

    ; previous value
    moveq              #0,d6
    move.b             (a1)+,d6

    dbra               d7,.loop
    rts

;----------------------------------------------------------------------------
;
;  probably delete this?
;
;----------------------------------------------------------------------------


BlitTitleFull:
    lea                TitleLogo,a0
    move.l             ScreenBuffer(a5),a1
    addq.l             #4,a1

    WAITBLIT
    move.w             #$09f0,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #0,BLTAMOD(a6)
    move.w             #TITLE_BLIT_MOD,BLTDMOD(a6)
    move.l             a0,BLTAPT(a6)
    move.l             a1,BLTDPT(a6)
    move.w             #TITLE_BLIT_SIZE,BLTSIZE(a6)
    rts

;----------------------------------------------------------------------------
;
;  scale logo
;
;----------------------------------------------------------------------------


TitleRenderTest:
    cmp.w              #3,TitleStatus(a5)
    beq                .go
.quit
    rts
.go
    ;addq.w             #1,TitleCount
    ;move.w             TitleCount,d0
    ;and.w              #$7f,d0
    ;bne                .skipreset
;
    ;move.w             #TITLE_START_WIDTH,TitleWidth(a5)
    ;move.w             #TITLE_START_HEIGHT,TitleHeight(a5)
    ;move.w             #51<<8,TitleYStart(a5)
    ;move.w             #$0010,TitleYDelta(a5)

;.skipreset
;    move.b             InterruptCount(a5),d0
;    move.b             TitleFramePrev(a5),d1
;    cmp.b              d0,d1
;    beq                .quit
;    
;    move.b             d0,TitleFramePrev(a5)

.gofull

    bsr                TitleBufferFill

    move.w             #TITLE_WIDTH,d1
    move.w             TitleWidth(a5),d2

    DIVIDE32           d1,d2,d3,d4,d5                                     ; d3 = delta

    bsr                TitleScaleY

    moveq              #0,d1                                              ; accumulator

    move.w             TitleWidth(a5),d1
    sub.w              #TITLE_WIDTH,d1
    asr.w              #1,d1

    mulu               d3,d1                                              ; starting position

    move.l             TitleBuffers+8(a5),a0
    move.b             #$80,d0                                            ; pixel index
TitleRun1:
    move.w             #TITLE_WIDTH-1,d4
    move.w             #(TITLE_WIDTH/2)-1,d7
    move.l             TitleJumpTablePtr(a5),a2
    lea                .next(pc),a1
.loop
    move.l             d1,d2
    swap               d2
    add.w              d2,d2
    add.w              d2,d2
    move.l             (a2,d2.w),a3
    jmp                (a3)

.next
    add.l              d3,d1                                              ; add delta
    ror.b              #1,d0
    bcc                .noflow
    addq.l             #1,a0
.noflow
    dbra               d7,.loop

;    moveq              #0,d6
;    move.b             InterruptFlag(a5),d6                               ; check if over a frame
;    bne                .skipwait                                          ; yes skip wait
;
;.waitclear
;    move.w             VHPOSR(a6),d6                                      ; render occured in under a frame, wait first half of screen to prevent disappearing title logo
;    and.w              #$ff00,d6
;    cmp.w              #$8000,d6
;    bcs                .waitclear
;    move.w             #$fff,COLOR00(a6)
;
;.skipwait
;
    bsr                TitleBufferClear


TitleRun2:
    move.w             #(TITLE_WIDTH/2)-1,d7
    lea                .next(pc),a1
.loop
    move.l             d1,d2
    swap               d2
    and.w              d4,d2
    add.w              d2,d2
    add.w              d2,d2
    move.l             (a2,d2.w),a3
    jmp                (a3)

.next
    add.l              d3,d1                                              ; add delta
    ror.b              #1,d0
    bcc                .noflow
    addq.l             #1,a0
.noflow
    dbra               d7,.loop


    lea                TitleBuffers(a5),a0
    ROTATE_LONG        a0,5

    lea                TitleYScalePtrs(a5),a0                             ; switch Y value pointers
    ROTATE_LONG        a0,4

    lea                TitleYOffsets(a5),a0
    ROTATE_WORD        a0,4

    move.l             d3,TitleScale(a5)

    moveq              #0,d0
    move.w             TitleWidth(a5),d0
    mulu               #TITLE_SCALE_PERC,d0
    divu               #100,d0
    move.w             d0,TitleWidth(a5)

    cmp.w              #TITLE_WIDTH,TitleWidth(a5)
    bcc                .movedown
    move.w             #TITLE_WIDTH,TitleWidth(a5)
    addq.w             #1,TitleFrameCount(a5)
    cmp.w              #3,TitleFrameCount(a5)
    bcs                .notdone
    addq.w             #1,TitleStatus(a5)
.notdone


    rts

.movedown
    move.w             TitleYDelta(a5),d0
    sub.w              d0,TitleYStart(a5)
    add.w              #80,d0
    move.w             d0,TitleYDelta(a5)
    rts



    ; d3 = factor
TitleScaleY:
    move.l             TitleYScalePtrs(a5),a0
    move.w             #TITLE_FIELD_HEIGHT,d7
    moveq              #0,d0                                              ; starting position
    swap               d0
    moveq              #0,d2                                              ; previous value
    move.w             #TITLE_HEIGHT-1,d5                                 ; height

    moveq              #0,d0
    move.w             TitleYStart(a5),d0
    ext.l              d0
    lsl.l              #8,d0
    move.l             d0,d2
    
    swap               d2
    move.w             d2,TitleYOffsets(a5)

.scale
    move.l             d0,d1
    swap               d1

    tst.w              d1
    bpl                .positive
    move.w             #(TITLE_WIDTH_BYTE*-1)-2,(a0)+                     ; store wait
    bra                .next

.positive
    cmp.w              d5,d1                                              ; TITLE_HEIGHT-1
    bcc                .filltail
    ;bcs                .notover
    ;move.w             #(TITLE_WIDTH_BYTE*-1)-2,(a0)+                     ; store wait
    ;bra                .next

.notover
    sub.w              d1,d2                                              ; delta
    neg                d2
    move.w             d2,d4
    add.w              d4,d4
    move.w             .modulolist(pc,d4.w),(a0)+                         ; store
.next
    move.w             d1,d2 
    add.l              d3,d0                                              ; next value 
    dbra               d7,.scale
    rts


.filltail
    move.w             #(TITLE_WIDTH_BYTE*-1)-2,(a0)+    
    dbra               d7,.filltail
    rts


.modulolist
    dc.w               (TITLE_WIDTH_BYTE*-1)-2
    dc.w               (TITLE_WIDTH_BYTE*0)-2
    dc.w               (TITLE_WIDTH_BYTE*1)-2
    dc.w               (TITLE_WIDTH_BYTE*2)-2
    dc.w               (TITLE_WIDTH_BYTE*3)-2
    dc.w               (TITLE_WIDTH_BYTE*4)-2
    dc.w               (TITLE_WIDTH_BYTE*5)-2
    dc.w               (TITLE_WIDTH_BYTE*6)-2
    dc.w               (TITLE_WIDTH_BYTE*7)-2
    dc.w               (TITLE_WIDTH_BYTE*8)-2
    dc.w               (TITLE_WIDTH_BYTE*9)-2
    dc.w               (TITLE_WIDTH_BYTE*10)-2


;----------------------------------------------------------------------------
;
; title buffer vert fill
;
;----------------------------------------------------------------------------

TITLE_FILL_BLIT_SIZE  = (((TITLE_HEIGHT*TITLE_DEPTH)-1)<<6)+TITLE_WIDTH_WORD

TitleBufferFill:
    move.l             TitleBuffers+12(a5),a0
    move.l             a0,a1
    lea                TITLE_WIDTH_BYTE(a0),a1
    WAITBLITLAZY
    move.w             #$0b5a,BLTCON0(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #0,BLTCON1(a5)
    move.w             #0,BLTAMOD(a6)
    move.w             #0,BLTBMOD(a6)
    move.w             #0,BLTCMOD(a6)
    move.w             #0,BLTDMOD(a6)
    move.w             #0,BLTDMOD(a6)
    move.l             a0,BLTAPT(a6)
    move.l             a1,BLTCPT(a6)
    move.l             a1,BLTDPT(a6)
    move.w             #TITLE_FILL_BLIT_SIZE,BLTSIZE(a6)
    rts


;----------------------------------------------------------------------------
;
;  clear title buffer with copper
;
;----------------------------------------------------------------------------

TITLE_BUFFER_BLITSIZE = ((TITLE_HEIGHT*TITLE_DEPTH)<<6)+TITLE_WIDTH_WORD

TitleBufferClear:
    WAITBLITLAZY
    move.w             #$0100,BLTCON0(a6)
    move.w             #0,BLTCON1(a5)
    move.w             #0,BLTDMOD(a6)
    move.l             TitleBuffers+4(a5),BLTDPT(a6)
    move.w             #TITLE_BUFFER_BLITSIZE,BLTSIZE(a6)

    rts


;----------------------------------------------------------------------------
;
;  title code gen
;
; generates plot code from pixel columns
;
;----------------------------------------------------------------------------


TitleCodeGen:
    move.l             TitleJumpTablePtr(a5),a1
    move.l             TitleCodeBufferPtr(a5),a2
                       
    move.b             #$80,d1                                            ; pixelmask

    ;lea            TitleLogo,a0
    move.l             TitleBuffers(a5),a0
    move.w             #TITLE_WIDTH-1,d7
    moveq              #0,d5                                              ; screen offset

.colloop
    move.l             a2,(a1)+
    move.w             d5,d2                                              ; screen offset
    moveq              #0,d6
    move.w             #TITLE_HEIGHT*TITLE_DEPTH-2,d6
.lineloop
    move.b             (a0,d2.w),d3                                       ; byte of pixels
    move.b             TITLE_WIDTH_BYTE(a0,d2.w),d4                       ; byte of pixels line below
    and                d1,d3
    and                d1,d4
    eor.b              d4,d3
    beq                .nopixel

    move.w             #$8128,(a2)+                                       ; $8128xxxx  <- or.b d0,xx(a0)
    sub.w              d5,d2
    move.w             d2,(a2)+
    add.w              d5,d2

.nopixel
    add.w              #TITLE_WIDTH_BYTE,d2
    dbra               d6,.lineloop

    move.w             #$4ed1,(a2)+                                       ; jmp (a1)

    ror.b              #1,d1                                              ; rorate pixel mask
    bcc                .norot

    addq.w             #1,d5                                              ; move to next byte column
.norot
    dbra               d7,.colloop

    move.l             a2,d0
    sub.l              TitleCodeBufferPtr(a5),d0
    cmp.l              #TITLE_CODE_BUFFER_SIZE,d0
    beq                .ok
.broken
    move.w             #$f00,COLOR00(a6)
    bra                .broken
.ok
    rts




;----------------------------------------------------------------------------
;
;  title main logic
;
; does ALL the funky stuff
;
;----------------------------------------------------------------------------

TitleMainLogic:
    bsr                MenuCopperSetup
  
    addq.w             #1,TitleSinePos(a5)
    and.w              #512-1,TitleSinePos(a5)

    move.w             TitleStatus(a5),d0
    JMPINDEX           d0


TitleLogicIndex:
    dc.w               TitleFadePal-TitleLogicIndex
    dc.w               TitleMoveCastle-TitleLogicIndex
    dc.w               TitleWaitLogo-TitleLogicIndex
    dc.w               TitleMoveLogo-TitleLogicIndex
    dc.w               TitleLogoHitInit-TitleLogicIndex
    dc.w               TitleLogoHit-TitleLogicIndex
    dc.w               TitleSelect-TitleLogicIndex

TitleFadePal:
    move.b             TickCounter(a5),d0
    and.b              #3,d0
    bne                .notdone

    bsr                FadeLogic
    ;lea                cpMenuPalette,a0
    move.l             TitleCopperPtr(a5),a0
    add.l              #COPPER_MENU_PALETTE,a0
    bsr                PaletteToCopper

    move.l             TitleCopperPtr+4(a5),a0
    add.l              #COPPER_MENU_PALETTE,a0
    bsr                PaletteToCopper

    tst.w              PaletteStatus(a5)
    bne                .notdone
    addq.w             #1,TitleStatus(a5)

    lea                CastleBlackPal,a0
    moveq              #7,d0
    bsr                LoadPalette
    lea                cpMenuCastlePal,a0
    bsr                PaletteToCopper
.notdone
    rts

TitleMoveCastle:
    subq.w             #1,TitleCastlePos(a5)
    bne                .notdone
    addq.w             #1,TitleStatus(a5)
    moveq              #$39,d0
    bsr                SfxPlay
    move.b             #$80,WaitCounter(a5)
    
    lea                CastleWhitePal,a0
    moveq              #7,d0
    bsr                LoadPalette
    lea                cpMenuCastlePal,a0
    bsr                PaletteToCopper

    lea                CastlePal,a0
    moveq              #7,d0
    bsr                FadeInit

.notdone
    rts


TitleWaitLogo:
    btst               #0,TickCounter(a5)
    beq                .skipfade
    bsr                FadeLogic
.skipfade
    lea                cpMenuCastlePal,a0
    bsr                PaletteToCopper
    subq.b             #1,WaitCounter(a5)
    bne                .notyet
    addq.w             #1,TitleStatus(a5)
.notyet
    rts

TitleMoveLogo:
    rts


TITLE_WAIT            = $280

TitleLogoHitInit:
    moveq              #$39,d0
    bsr                SfxPlay
    lea                TitlePalWhite,a0
    moveq              #16,d0
    bsr                LoadPalette

    move.l             TitleCopperPtr(a5),a0
    add.l              #COPPER_MENU_PALETTE,a0
    bsr                PaletteToCopper

    move.l             TitleCopperPtr+4(a5),a0
    add.l              #COPPER_MENU_PALETTE,a0
    bsr                PaletteToCopper

    lea                TitlePal,a0
    moveq              #16,d0
    bsr                FadeInit
    addq.w             #1,TitleStatus(a5)
    move.w             #TITLE_WAIT,TitleWaitCounter(a5)
    bra                ShowTitleSprites
    
TitleLogoHit:
    tst.w              PaletteStatus(a5)
    beq                .fadedone
    btst               #0,TickCounter(a5)
    beq                .skipfade
    bsr                FadeLogic
.skipfade
    ;lea                cpMenuPalette,a0
    move.l             TitleCopperPtr(a5),a0
    add.l              #COPPER_MENU_PALETTE,a0
    bsr                PaletteToCopper
    move.l             TitleCopperPtr+4(a5),a0
    add.l              #COPPER_MENU_PALETTE,a0
    bsr                PaletteToCopper
.fadedone
    subq.w             #1,TitleWaitCounter(a5)
    bne                .notexpired

    ; wait counter expired, move to auto play mode
    bsr                HideTitleSprites
    move.w             #-1,TitleSelectPos(a5)
    bra                .exittitle

.notexpired
    move.b             ControlsTrigger(a5),d0
    and.b              #3,d0
    bne                .updown
    btst               #4,ControlsTrigger(a5)
    bne                .select
    rts

.select
    moveq              #$10,d0
    bsr                SfxPlay

    bsr                RenderTitleSelect
.exittitle
    addq.w             #1,TitleStatus(a5)
    
    move.b             #1,ModFadeStatus(a5)
    move.b             #2,ModFadeWait(a5)

    lea                BlackPal,a0
    move.w             #16,d0
    bsr                FadeInit

    rts

.updown
    move.w             #TITLE_WAIT,TitleWaitCounter(a5)

    bsr                ClearMenuArrow
    btst               #0,ControlsTrigger(a5)
    bne                .up

    cmp.w              #3-1,TitleSelectPos(a5)
    beq                .exit
    addq.w             #1,TitleSelectPos(a5)
    bra                .domove
.up
    tst.w              TitleSelectPos(a5)
    beq                .exit
    subq.w             #1,TitleSelectPos(a5)
.domove
    bsr                SetMenuArrow
    bsr                RenderTitleSprites
    moveq              #$12,d0
    bra                SfxPlay
.exit
    rts


TitleSelect:
    ;bsr                MusicFade
    tst.w              TitleSelectPos(a5)
    bmi                .skiphide

    bsr                ShowTitleSprites
    btst               #3,TickCounter(a5)
    bne                .skiphide
    bsr                HideTitleSprites
.skiphide

    move.b             TickCounter(a5),d0
    and.b              #7,d0
    bne                .skipfade
    bsr                FadeLogic
    ;lea                cpMenuPalette,a0
    move.l             TitleCopperPtr(a5),a0
    add.l              #COPPER_MENU_PALETTE,a0
    bsr                PaletteToCopper
    move.l             TitleCopperPtr+4(a5),a0
    add.l              #COPPER_MENU_PALETTE,a0
    bsr                PaletteToCopper

.skipfade

    addq.w             #1,TitleCastlePos(a5)
    cmp.w              #CASTLE_HEIGHT,TitleCastlePos(a5)
    bcs                .notdone


    ; start game
    lea                MenuPal,a0
    moveq              #SCREEN_COLORS,d0
    bsr                LoadPalette
    
    bsr                ScreenClear
    WAITBLIT
    bsr                wait_raster_HUD
    bsr                ShowGameScreen

    move.w             TitleSelectPos(a5),d0
    beq                .startgame

    ; trigger options menu
    subq.w             #1,d0
    beq                .options

    subq.w             #1,d0
    beq                .scoreboard

    ; start rolling demo
    bsr                HideTitleSprites
    move.b             #2,GameStatus(a5)
    clr.b              GameSubStatus(a5)
    rts

.scoreboard
    bsr                HideTitleSprites
    move.b             #13,GameStatus(a5)
    clr.b              GameSubStatus(a5)
    rts

.options
    bsr                HideTitleSprites
    move.b             #$a,GameStatus(a5)
    clr.b              GameSubStatus(a5)
    rts

.startgame
    move.b             #$40,ControlConfig(a5)    
    move.b             #3,GameStatus(a5)
    clr.b              GameSubStatus(a5)
.notdone
    rts

TitleStartGame:
    rts


TitleSinus:
    dc.b               31,30,29,29,28,27,26,26,25,24,23,23,22,21,21,20
    dc.b               19,18,18,17,17,16,15,15,14,14,13,13,12,12,11,11
    dc.b               10,10,10,9,9,9,8,8,8,8,7,7,7,7,7,7
    dc.b               7,7,7,7,7,7,7,7,7,7,7,8,8,8,8,8
    dc.b               9,9,9,10,10,10,11,11,11,12,12,13,13,14,14,14
    dc.b               15,15,16,16,17,17,18,18,19,19,20,20,21,21,22,22
    dc.b               23,23,23,24,24,25,25,26,26,26,27,27,27,28,28,28
    dc.b               29,29,29,29,30,30,30,30,30,31,31,31,31,31,31,31
    dc.b               31,31,31,31,31,31,31,31,30,30,30,30,30,29,29,29
    dc.b               29,28,28,28,27,27,27,26,26,25,25,25,24,24,23,23
    dc.b               22,22,21,21,20,20,19,19,18,18,18,17,17,16,16,15
    dc.b               15,14,14,13,13,12,12,12,11,11,11,10,10,10,9,9
    dc.b               9,8,8,8,8,8,7,7,7,7,7,7,7,7,7,7
    dc.b               7,7,7,7,7,7,8,8,8,8,9,9,9,9,10,10
    dc.b               11,11,11,12,12,13,13,14,15,15,16,16,17,18,18,19
    dc.b               19,20,21,22,22,23,24,24,25,26,27,28,28,29,30,31
    dc.b               31,32,33,34,34,35,36,37,38,38,39,40,40,41,42,43
    dc.b               43,44,44,45,46,46,47,47,48,49,49,50,50,51,51,51
    dc.b               52,52,53,53,53,53,54,54,54,54,55,55,55,55,55,55
    dc.b               55,55,55,55,55,55,55,55,55,55,54,54,54,54,54,53
    dc.b               53,53,52,52,52,51,51,51,50,50,50,49,49,48,48,47
    dc.b               47,46,46,45,45,44,44,44,43,43,42,42,41,41,40,40
    dc.b               39,39,38,38,37,37,37,36,36,35,35,35,34,34,34,33
    dc.b               33,33,33,32,32,32,32,32,31,31,31,31,31,31,31,31
    dc.b               31,31,31,31,31,31,31,32,32,32,32,32,33,33,33,33
    dc.b               34,34,34,35,35,35,36,36,36,37,37,38,38,39,39,39
    dc.b               40,40,41,41,42,42,43,43,44,44,45,45,46,46,47,47
    dc.b               48,48,48,49,49,50,50,51,51,51,52,52,52,53,53,53
    dc.b               54,54,54,54,54,55,55,55,55,55,55,55,55,55,55,55
    dc.b               55,55,55,55,55,55,54,54,54,54,53,53,53,52,52,52
    dc.b               51,51,50,50,49,49,48,48,47,47,46,45,45,44,44,43
    dc.b               42,41,41,40,39,39,38,37,36,36,35,34,33,33,32,31
 
    dc.b               31,30,29,29,28,27,26,26,25,24,23,23,22,21,21,20
    dc.b               19,18,18,17,17,16,15,15,14,14,13,13,12,12,11,11
    dc.b               10,10,10,9,9,9,8,8,8,8,7,7,7,7,7,7
    dc.b               7,7,7,7,7,7,7,7,7,7,7,8,8,8,8,8
    dc.b               9,9,9,10,10,10,11,11,11,12,12,13,13,14,14,14
    dc.b               15,15,16,16,17,17,18,18,19,19,20,20,21,21,22,22
    dc.b               23,23,23,24,24,25,25,26,26,26,27,27,27,28,28,28
    dc.b               29,29,29,29,30,30,30,30,30,31,31,31,31,31,31,31
    dc.b               31,31,31,31,31,31,31,31,30,30,30,30,30,29,29,29
    dc.b               29,28,28,28,27,27,27,26,26,25,25,25,24,24,23,23
    dc.b               22,22,21,21,20,20,19,19,18,18,18,17,17,16,16,15
    dc.b               15,14,14,13,13,12,12,12,11,11,11,10,10,10,9,9
    dc.b               9,8,8,8,8,8,7,7,7,7,7,7,7,7,7,7
    dc.b               7,7,7,7,7,7,8,8,8,8,9,9,9,9,10,10
    dc.b               11,11,11,12,12,13,13,14,15,15,16,16,17,18,18,19
    dc.b               19,20,21,22,22,23,24,24,25,26,27,28,28,29,30,31
    dc.b               31,32,33,34,34,35,36,37,38,38,39,40,40,41,42,43
    dc.b               43,44,44,45,46,46,47,47,48,49,49,50,50,51,51,51
    dc.b               52,52,53,53,53,53,54,54,54,54,55,55,55,55,55,55
    dc.b               55,55,55,55,55,55,55,55,55,55,54,54,54,54,54,53
    dc.b               53,53,52,52,52,51,51,51,50,50,50,49,49,48,48,47
    dc.b               47,46,46,45,45,44,44,44,43,43,42,42,41,41,40,40
    dc.b               39,39,38,38,37,37,37,36,36,35,35,35,34,34,34,33
    dc.b               33,33,33,32,32,32,32,32,31,31,31,31,31,31,31,31
    dc.b               31,31,31,31,31,31,31,32,32,32,32,32,33,33,33,33
    dc.b               34,34,34,35,35,35,36,36,36,37,37,38,38,39,39,39
    dc.b               40,40,41,41,42,42,43,43,44,44,45,45,46,46,47,47
    dc.b               48,48,48,49,49,50,50,51,51,51,52,52,52,53,53,53
    dc.b               54,54,54,54,54,55,55,55,55,55,55,55,55,55,55,55
    dc.b               55,55,55,55,55,55,54,54,54,54,53,53,53,52,52,52
    dc.b               51,51,50,50,49,49,48,48,47,47,46,45,45,44,44,43
    dc.b               42,41,41,40,39,39,38,37,36,36,35,34,33,33,32,31

 


    even