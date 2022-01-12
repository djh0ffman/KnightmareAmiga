
;----------------------------------------------------------------------------
;
; blitter stuff
;
;----------------------------------------------------------------------------


    include            "common.asm"



;-----------------
; 1 = Screen position (long)
; 2 = BLTSIZE (word)
; 3 = Modulo (word)
; 4 = temporary address register (long)
; 5 = height
;-----------------

QRESTORE_BLIT MACRO
    move.l             BlitQueueActivePtrs(a5),\5                                  ; store the blit parameters
    move.l             \1,(\5)+
    move.w             \2,(\5)+
    move.w             \3,(\5)+
    move.w             \4,(\5)+
    move.l             \5,BlitQueueActivePtrs(a5)
    addq.w             #1,BlitCount(a5)  
    ENDM

QDUPE_BLIT MACRO
    move.l             BlitDupePtr(a5),\4                                          ; store the blit parameters
    move.l             \1,(\4)+
    move.w             \2,(\4)+
    move.w             \3,(\4)+
    clr.w              (\4)+
    move.l             \4,BlitDupePtr(a5)
    addq.w             #1,BlitDupeCount(a5)  
    ENDM


;----------------------------------------------------------------------------
;
; Blit init
;
;----------------------------------------------------------------------------

BlitInit:
    lea                BlitQueuePtrs(a5),a0
    lea                BlitQueueActivePtrs(a5),a1
    lea                BlitQueue1(a5),a2
    lea                BlitQueue2(a5),a3
    move.l             a2,(a0)+
    move.l             a2,(a1)+
    move.l             a3,(a0)+
    move.l             a3,(a1)+

    lea                BlitCount(a5),a0 
    clr.w              (a0)+
    clr.w              (a0)+

    bsr                BlitDupeQueueInit

    bsr                BlitStrideCalc

    rts

BlitStrideCalc:
    lea                BlitStrideLookUp(a5),a0
    lea                BlitStridePtrs(a5),a1
    moveq              #0,d0                                                       ; width
.loopwidth
    moveq              #0,d1                                                       ; height
    move.w             d0,d2
    add.w              d2,d2                                                       ; word to byte
    mulu               #SCREEN_DEPTH,d2                                            ; one line
    move.l             a0,(a1)+                                                    ; store pointer to this table
.loopheight
    move.w             d1,d3                                                       ; one line
    mulu               d2,d3                                                       ; this number of lines
    move.w             d3,(a0)+
    addq.w             #1,d1                                                       ; add height
    cmp.w              #BLIT_HEIGHT_MAX,d1
    bcs                .loopheight

    addq.w             #1,d0
    cmp.w              #BLIT_WIDTH_MAX,d0
    bcs                .loopwidth
    rts

;----------------------------------------------------------------------------
;
; full screen copy - including margin so no messing about with modulo
; means we can get it done in one blit
;
;----------------------------------------------------------------------------

ScreenCopy:
    PUSHMOST
    WAITBLIT
    move.w             #$09f0,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #0,BLTAMOD(a6)
    move.w             #0,BLTDMOD(a6)
    move.l             ScreenBuffer(a5),BLTAPT(a6)
    move.l             ScreenBuffer+4(a5),BLTDPT(a6)
    move.w             #SCREEN_BLTSIZE,BLTSIZE(a6)

;    WAITBLIT
;    move.l           #ScreenSave,BLTAPT(a6)
;    move.l           #Screen2,BLTDPT(a6)
;    move.w           #SCREEN_BLTSIZE,BLTSIZE(a6)

    POPMOST
    rts

;----------------------------------------------------------------------------
;
; clears the text on the scroller
;
;----------------------------------------------------------------------------

TEXT_SCROLL_BLIT_SIZE     = ((8*SCREEN_DEPTH)<<6)+(SCREEN_WIDTH_BYTE/2)

TextScrollClear:
    PUSHMOST
    move.l             ScreenBuffer(a5),a0

    moveq              #0,d0
    move.w             MapScrollOffset(a5),d0
    subq.w             #8,d0                                                       ; y first line

    moveq              #0,d1
    move.w             MapScrollOffset(a5),d1
    add.w              #CREDITS_ROLL*8,d1                                          ; y second line

    mulu               #SCREEN_STRIDE,d0
    mulu               #SCREEN_STRIDE,d1

    add.l              ScreenBuffer(a5),d0
    add.l              ScreenBuffer(a5),d1

    WAITBLIT
    move.w             #$0100,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.w             #0,BLTDMOD(a6)
    move.l             d0,BLTDPT(a6)
    move.w             #TEXT_SCROLL_BLIT_SIZE,BLTSIZE(a6)

    WAITBLIT
    move.l             d1,BLTDPT(a6)
    move.w             #TEXT_SCROLL_BLIT_SIZE,BLTSIZE(a6)

    WAITBLIT

    POPMOST
    rts


;----------------------------------------------------------------------------
;
; shifts credits text by 4 pixels
;
;----------------------------------------------------------------------------

TextScrollShift:
    PUSHMOST
    move.l             ScreenBuffer(a5),a0

    moveq              #0,d0
    move.w             MapScrollOffset(a5),d0
    subq.w             #8,d0                                                       ; y first line

    moveq              #0,d1
    move.w             MapScrollOffset(a5),d1
    add.w              #CREDITS_ROLL*8,d1                                          ; y second line

    mulu               #SCREEN_STRIDE,d0
    mulu               #SCREEN_STRIDE,d1

    add.l              ScreenBuffer(a5),d0
    add.l              ScreenBuffer(a5),d1

    WAITBLIT
    move.w             #$49f0,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.w             #0,BLTAMOD(a6)
    move.w             #0,BLTDMOD(a6)
    move.l             d0,BLTAPT(a6)
    move.l             d0,BLTDPT(a6)
    move.w             #TEXT_SCROLL_BLIT_SIZE,BLTSIZE(a6)

    WAITBLIT
    move.l             d1,BLTAPT(a6)
    move.l             d1,BLTDPT(a6)
    move.w             #TEXT_SCROLL_BLIT_SIZE,BLTSIZE(a6)

    WAITBLIT

    POPMOST
    rts
;----------------------------------------------------------------------------
;
; full screen clear - including margin so no messing about with modulo
; means we can get it done in one blit
;
;----------------------------------------------------------------------------

ScreenClear:
    PUSHMOST
    lea                Screen1,a0
    move.w             #(SCREEN_GAME_TOTAL/2)-1,d7
.clear
    clr.l              (a0)+
    dbra               d7,.clear

    move.l             CopperBuffer(a5),a3
    move.l             CopperBuffer+4(a5),a4
    lea                COPPER_SPRITE(a3),a3
    lea                COPPER_SPRITE(a4),a4
    move.l             #NullSprite,d0    
    REPT               8
    PLANE_TO_COPPER    d0,a3
    PLANE_TO_COPPER    d0,a4
    addq.l             #8,a3
    addq.l             #8,a4
    ENDR

    POPMOST
    rts

;----------------------------------------------------------------------------
;
; Reset blit restore queue
;
;----------------------------------------------------------------------------


BlitQueueSwap:
    lea                BlitCount(a5),a0                                            ; flip count
    ROTATE_WORD        a0,2

    lea                BlitQueuePtrs(a5),a0
    ROTATE_LONG        a0,2

    lea                BlitQueueActivePtrs(a5),a0
    ROTATE_LONG        a0,2

    lea                BlitQueueMapOffset(a5),a0
    ROTATE_WORD        a0,2

    rts

;----------------------------------------------------------------------------
;
; Reset blit restore queue
;
;----------------------------------------------------------------------------

BlitQueueReset:
    move.l             BlitQueuePtrs(a5),d0
    move.l             d0,BlitQueueActivePtrs(a5)
    clr.w              BlitCount(a5)
    rts

;----------------------------------------------------------------------------
;
; Reset blit restore queue
;
; this prevents dirty screen restores when switch to menus etc.
;
;----------------------------------------------------------------------------

BlitQueueHardReset:
    clr.l              BlitCount(a5)
    rts



;----------------------------------------------------------------------------
;
; performs duplicate operations from the previous frame
;
; used for stuff that remains on the background so needs drawing on the clean
; frame then duplicating to both buffers after
;
;----------------------------------------------------------------------------

BlitDupe:
    move.w             BlitDupeCount(a5),d7
    beq                .none
    subq.b             #1,d7

    moveq              #-1,d6                                                      ; first last mask
      
    lea                BlitDupeQueue(a5),a0

    move.l             ScreenBufferClean(a5),a1                                    ; source
    move.l             ScreenBuffer(a5),a2                                         ; dest
.loop
    move.l             (a0)+,d0
    movem.w            (a0)+,d1/d2/d3                                              ; pos / size / mod

    move.l             a1,a3
    move.l             a2,a4
    add.l              d0,a3                                                       ; position source
    add.l              d0,a4                                                       ; position dest

    WAITBLIT
    move.w             #$09f0,BLTCON0(a6)                                          ; use channels A & D
    clr.w              BLTCON1(a6)                                                 ; B shift
    move.l             d6,BLTAFWM(a6)                                                    
  
    move.w             d2,BLTAMOD(a6)                                              ; source mod
    move.w             d2,BLTDMOD(a6)                                              ; destination mod

    move.l             a3,BLTAPT(a6)                                               ; source
    move.l             a4,BLTDPT(a6)                                               ; dest
    move.w             d1,BLTSIZE(a6)                                              ; BLIT!

.nodouble
    dbra               d7,.loop                      

.none

BlitDupeQueueInit:

    clr.w              BlitDupeCount(a5)
    lea                BlitDupeQueue(a5),a0
    move.l             a0,BlitDupePtr(a5)

    rts



;----------------------------------------------------------------------------
;
; Restore dirty screen sections
;
;----------------------------------------------------------------------------

BlitRestoreOne:
    tst.w              BlitCount(a5)
    beq                .none

    PUSHMOST
    ;move.l         ScreenBuffer(a5),d6
    lea                BlitHeightLookUp(a5),a1
    move.l             BlitQueuePtrs(a5),a0

    moveq              #0,d6
    move.w             Blit_X(a0),d6
    add.l              ScreenBuffer(a5),d6                                         ; screen buffer offset by X

    moveq              #0,d4                                                       ; split value
    move.w             Blit_Y(a0),d0                                               ; destination Y
    move.w             Blit_Height(a0),d1

    ; determine source position
    move.w             d0,d2                                                       ; source Y
    sub.w              #SCREEN_HEIGHT_DISPLAY,d2                                   ; half the screen
    bcc                .ynotneg

    add.w              #SCREEN_HEIGHT_GAME,d2                                      ; double
.ynotneg
    move.w             d2,d3
    add.w              d1,d3                                                       ; source end
    sub.w              #SCREEN_HEIGHT_GAME,d3                                      ; over?
    bcs                .inrange                                                    ; nope, in range single restore blit
    ;beq            .inrange                                   ; potentially not needed as d3 ends up 0

    move.w             d3,d4
    sub.w              d3,d1                                                       ; remove height difference from first blit

.inrange
    add.w              d0,d0
    add.w              d0,d0
    move.l             StrideLookUp(a5,d0.w),d0                                    ; destination
    add.l              d6,d0                                                       ; add screen

    add.w              d2,d2
    add.w              d2,d2
    move.l             StrideLookUp(a5,d2.w),d2                                    ; source
    add.l              d6,d2                                                       ; add screen

    add.w              d1,d1
    move.w             (a1,d1.w),d1                                                ; blit height loop up
    add.w              Blit_Width(a0),d1
    ;addq.w         #1,d1                                      ; blit size

    WAITBLIT
    move.w             Blit_Modulo(a0),BLTCMOD(a6)                                 ; source mod
    move.w             Blit_Modulo(a0),BLTDMOD(a6)                                 ; destination mod

    move.l             d2,BLTCPT(a6)                                               ; source
    move.l             d0,BLTDPT(a6)                                               ; dest
    move.w             d1,BLTSIZE(a6)                                              ; BLIT!

    ; second blit if required
    add.w              d4,d4                                                       ; split height remainder
    beq                .skipsplit                                                  ; nothing, skip
    move.w             (a1,d4.w),d4                                                ; blit height loop up
    add.w              Blit_Width(a0),d4
    ;addq.w         #1,d4                                      ; blit size

    move.l             d6,d2                                                       ; dest
    add.l              #SCREEN_HEIGHT_DISPLAY*SCREEN_STRIDE,d2                     ; half way down

    WAITBLITP
    move.w             #$03aa,BLTCON0(a6)                                          ; use channels C & D
    move.w             #0,BLTCON1(a6)                                              ; initial blitter setup
    move.l             d6,BLTCPT(a6)                                               ; source
    move.l             d2,BLTDPT(a6)                                               ; dest
    move.w             d4,BLTSIZE(a6)                                              ; BLIT!

.skipsplit
    lea                Blit_Sizeof(a0),a0                                          ; next blit
    move.l             a0,BlitQueuePtrs(a5)
    subq.w             #1,BlitCount(a5)
    POPMOST
.none
    rts



;----------------------------------------------------------------------------
;
; Restore dirty screen sections
;
;----------------------------------------------------------------------------

BlitRestore:
    move.w             BlitCount(a5),d7
    beq                .none
    subq.b             #1,d7

    ;move.l         ScreenBuffer(a5),d6
    lea                BlitHeightLookUp(a5),a1
    move.l             BlitQueuePtrs(a5),a0

    WAITBLITP
    move.w             #$03aa,BLTCON0(a6)                                          ; use channels C & D
    move.w             #0,BLTCON1(a6)                                              ; initial blitter setup

.mainloop
    moveq              #0,d6
    move.w             Blit_X(a0),d6
    add.l              ScreenBuffer(a5),d6                                         ; screen buffer offset by X

    moveq              #0,d4                                                       ; split value
    move.w             Blit_Y(a0),d0                                               ; destination Y
    move.w             Blit_Height(a0),d1

    ; determine source position
    move.w             d0,d2                                                       ; source Y
    sub.w              #SCREEN_HEIGHT_DISPLAY,d2                                   ; half the screen
    bcc                .ynotneg

    add.w              #SCREEN_HEIGHT_GAME,d2                                      ; double
.ynotneg
    move.w             d2,d3
    add.w              d1,d3                                                       ; source end
    sub.w              #SCREEN_HEIGHT_GAME,d3                                      ; over?
    bcs                .inrange                                                    ; nope, in range single restore blit
    ;beq            .inrange                                   ; potentially not needed as d3 ends up 0

    move.w             d3,d4
    sub.w              d3,d1                                                       ; remove height difference from first blit

.inrange
    add.w              d0,d0
    add.w              d0,d0
    move.l             StrideLookUp(a5,d0.w),d0                                    ; destination
    add.l              d6,d0                                                       ; add screen

    add.w              d2,d2
    add.w              d2,d2
    move.l             StrideLookUp(a5,d2.w),d2                                    ; source
    add.l              d6,d2                                                       ; add screen

    add.w              d1,d1
    move.w             (a1,d1.w),d1                                                ; blit height loop up
    add.w              Blit_Width(a0),d1
    ;addq.w         #1,d1                                      ; blit size

    WAITBLIT
    move.w             Blit_Modulo(a0),BLTCMOD(a6)                                 ; source mod
    move.w             Blit_Modulo(a0),BLTDMOD(a6)                                 ; destination mod

    move.l             d2,BLTCPT(a6)                                               ; source
    move.l             d0,BLTDPT(a6)                                               ; dest
    move.w             d1,BLTSIZE(a6)                                              ; BLIT!

    ; second blit if required
    add.w              d4,d4                                                       ; split height remainder
    beq                .skipsplit                                                  ; nothing, skip
    move.w             (a1,d4.w),d4                                                ; blit height loop up
    add.w              Blit_Width(a0),d4
    ;addq.w         #1,d4                                      ; blit size

    move.l             d6,d2                                                       ; dest
    add.l              #SCREEN_HEIGHT_DISPLAY*SCREEN_STRIDE,d2                     ; half way down

    WAITBLITP
    move.l             d6,BLTCPT(a6)                                               ; source
    move.l             d2,BLTDPT(a6)                                               ; dest
    move.w             d4,BLTSIZE(a6)                                              ; BLIT!

.skipsplit
    lea                Blit_Sizeof(a0),a0                                          ; next blit

    dbra               d7,.mainloop

.none
    rts




;----------------------------------------------------------------------------
;
; blit the current line of each tile
; then copys the new line below
;
;----------------------------------------------------------------------------

BlitTileLine: 
    PUSHMOST
    lea                MapBuffer(a5),a1
    move.w             MapPosition(a5),d0
    lsl.w              #3,d0
    lea                (a1,d0.w),a1                                                ; map data position

    moveq              #0,d4
    move.w             MapScrollOffset(a5),d4
    move.l             d4,d5
    move.l             d4,d6

    add.w              d5,d5
    add.w              d5,d5
    move.l             StrideLookUp(a5,d5.w),d5                                    ; screen offset

    move.l             ScreenBuffer(a5),a0
    add.l              d5,a0

    move.l             a0,a4                                                       ; store screen pointer for line copy

    and.w              #TILE_HEIGHT-1,d4
    mulu               #SCREEN_DEPTH*4,d4                                          ; tile offset

    moveq              #TILES_X-1,d7                                               
    lea                TilePointers(a5),a2

    moveq              #0,d1
    moveq              #-1,d2
.loop
    moveq              #0,d0
    move.b             (a1)+,d0
    add.w              d0,d0
    add.w              d0,d0
    move.l             (a2,d0.w),a3                                                ; tile pointer 
    add.l              d4,a3

    WAITBLIT
    move.w             #$09f0,BLTCON0(a6)
    move.w             d1,BLTCON1(a6)
    move.l             d2,BLTAFWM(a6)
    move.w             d1,BLTAMOD(a6)
    move.w             #TILE_MOD,BLTDMOD(a6)
    move.l             a3,BLTAPT(a6)
    move.l             a0,BLTDPT(a6)
    move.w             #TILE_LINE_BLTSIZE,BLTSIZE(a6)

    addq.b             #1,MapBlitCount(a5)

    addq.l             #4,a0
    dbra               d7,.loop                                                    ; loop each tile

    move.l             a4,a0
    add.l              #SCREEN_HALF,a0                                             ; pointer to bottom line
    cmp.w              #SCREEN_HEIGHT_GAME/2,d6                                    ; check if on the higest line
    bne                .notover
    move.l             ScreenBuffer(a5),a0                                         ; yes, then shift
.notover

    WAITBLIT
    move.w             #$09f0,BLTCON0(a6)                                          ; blit a copy of this line off screen
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #TILE_SCREEN_LINE_BLTMOD,BLTAMOD(a6)
    move.w             #TILE_SCREEN_LINE_BLTMOD,BLTDMOD(a6)
    move.l             a4,BLTAPT(a6)
    move.l             a0,BLTDPT(a6)
    move.w             #TILE_SCREEN_LINE_BLTSIZE,BLTSIZE(a6)

    POPMOST
    rts


;----------------------------------------------------------------------------
;
; blit entire tile row
;
; a0 = screen buffer
;
;----------------------------------------------------------------------------

BlitTileRow: 
    PUSHMOST
    ;move.l         MapPointer(a5),a1
    lea                MapBuffer(a5),a1
    move.w             MapPosition(a5),d0
    lsl.w              #3,d0
    lea                (a1,d0.w),a1

    moveq              #TILES_X-1,d7                                                     
    lea                TilePointers(a5),a2

    moveq              #0,d1
    moveq              #-1,d2
.loop
    moveq              #0,d0
    move.b             (a1)+,d0
    add.w              d0,d0
    add.w              d0,d0
    move.l             (a2,d0.w),a3                                                ; tile pointer 

    WAITBLIT
    move.w             #$09f0,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #0,BLTAMOD(a6)
    move.w             #TILE_MOD,BLTDMOD(a6)
    move.l             a3,BLTAPT(a6)
    move.l             a0,BLTDPT(a6)
    move.w             #TILE_BLTSIZE,BLTSIZE(a6)

    addq.l             #4,a0
    dbra               d7,.loop
    POPMOST
    rts


;----------------------------------------------------------------------------
;
; Remove unallocated sprites
;
; set layer position / sort
;
;----------------------------------------------------------------------------

BobClean:
    moveq              #0,d6                                                       ; new live sprite coutn
    lea                BobLivePtrs(a5),a0
    move.l             a0,a2
    move.w             BobLiveCount(a5),d7
    beq                .exit                                                       ; no sprites live

    subq.w             #1,d7                                                       ; -1 dbra
.loop
    move.l             (a0)+,a1                                                    ; current sprite
    tst.b              Bob_Allocated(a1)                                           ; is it allocated
    beq                .unallocated                                                ; no, dont store or count it

    move.w             Bob_Y(a1),d0                                                ; bob Y
    add.w              Bob_Height(a1),d0
    add.w              Bob_Layer(a1),d0                                            ; bob layer position for sorting
    move.w             d0,Bob_Sort(a1)                                             ; store it

    addq.w             #1,d6                                                       ; up the new count
    move.l             a1,(a2)+                                                    ; store this pointer
    ;bra            .next
.unallocated
    ;clr.l          Bob_Data(a1)
.next
    dbra               d7,.loop
.exit 
    move.w             d6,BobLiveCount(a5)
    move.l             a2,BobLivePtr(a5)
    clr.w              BobNoShift(a5)
    rts

;----------------------------------------------------------------------------
;
; Sort the active sprites 
;
;----------------------------------------------------------------------------

BobSort:  
    move.w             BobLiveCount(a5),d5
    subq.w             #2,d5
    bmi                .nosort
    lea                BobLivePtrs(a5),a3
.sort
    move.w             d5,d7                                                       ; restore count
    move.l             a3,a0
    moveq              #0,d6                                                       ; sort flag
.nextpair
    movem.l            (a0),a1/a2
    move.w             Bob_Sort(a1),d0
    cmp.w              Bob_Sort(a2),d0
    ble                .noswitch

    exg                a1,a2                                                       ; flip
    moveq              #-1,d6                                                      ; sort happened
    movem.l            a1/a2,(a0)                                                  ; sort switch pointers

    cmp.w              d5,d7
    beq                .sort                                                       ; early out if at start of list

    ; now go reverse
.reverse
    subq.l             #4,a0                                                       ; reverse
    movem.l            (a0),a1/a2                                                  ; get pointers
    move.w             Bob_Sort(a1),d0                                             ; compore
    cmp.w              Bob_Sort(a2),d0
    ble                .sort                                                       ; in the right order, cancel reverse and start again

    exg                a1,a2                                                       ; flip
    movem.l            a1/a2,(a0)                                                  ; sort switch pointers

    addq.w             #1,d7
    cmp.w              d5,d7
    bne                .reverse

    ;addq.l         #8,a0
    moveq              #-1,d6                                                      ; sort happened

.noswitch    
    ;subq.l         #4,a0
    addq.l             #4,a0
    dbra               d7,.nextpair
    tst.b              d6
    bne                .sort
.nosort
    rts

    
;----------------------------------------------------------------------------
;
; Flush all bobs
;
;----------------------------------------------------------------------------

BobClear:
    move.w             #BOB_COUNT-1,d7
    lea                BobMatrix(a5),a0
.clear
    st                 Bob_Hide(a0)
    clr.b              Bob_Allocated(a0)
    clr.w              Bob_MaskBlit(a0)
    lea                Bob_Sizeof(a0),a0
    dbra               d7,.clear

    clr.w              BobLiveCount(a5)    
    lea                BobLivePtrs(a5),a0
    move.l             a0,BobLivePtr(a5)

    clr.w              BobCurrentId(a5)

    bra                BlitQueueHardReset

;----------------------------------------------------------------------------
;
; bob find slot and allocate
;
; return 
; d0 = bob id / -1 failure
; a4 = bob structure
;----------------------------------------------------------------------------

BobAllocate:
    moveq              #BOB_COUNT-1,d2
    move.w             BobCurrentId(a5),d0
    move.w             d0,d1
    mulu               #Bob_Sizeof,d0
    lea                BobMatrix(a5),a4
    lea                (a4,d0.w),a4
.loop
    tst.b              Bob_Allocated(a4)
    beq                .found
    lea                Bob_Sizeof(a4),a4
    addq.w             #1,d1                                                       ; next slot
    and.w              #BOB_COUNT-1,d1
    bne                .nocycle

    DEBUG_CLICK
    moveq              #0,d1                                                       ; loop round table
    lea                BobMatrix(a5),a4                                            ; start of table again

.nocycle
    dbra               d2,.loop

    DEBUG_CLICK
    moveq              #-1,d0                                                      ; error  
    rts

.found
    move.b             #1,Bob_Allocated(a4)                                        ; allocate this bob
    st                 Bob_Hide(a4)                                                ; hide it
    clr.w              Bob_Y(a4)                                                   ; set it off screen
    clr.w              Bob_X(a4)
    clr.w              Bob_OffsetX(a4)
    clr.w              Bob_OffsetY(a4)
    clr.w              Bob_TopMargin(a4)
    clr.l              Bob_Data(a4)

    move.l             BobLivePtr(a5),a3                                           ; no, get current ptr position
    move.l             a4,(a3)+                                                    ; add it
    addq.w             #1,BobLiveCount(a5)                                         ; increase sprite count
    move.l             a3,BobLivePtr(a5)                                           ; store the new position

    move.w             d1,d0
    addq.w             #1,d1
    and.w              #BOB_COUNT-1,d1
    move.w             d1,BobCurrentId(a5)
    mulu               #Bob_Sizeof,d0
    rts

;----------------------------------------------------------------------------
;
; draw all active bobs (version 2)
; 
;----------------------------------------------------------------------------

BobDraw:
    move.w             BobLiveCount(a5),d7
    subq.w             #1,d7 
    bcs                .exit

    move.l             BlitQueueActivePtrs(a5),a3                                  ; for restore
    lea                BobLivePtrs(a5),a0
    lea                BlitHeightLookUp(a5),a1
.loop
    move.l             (a0)+,a4                                                    ; get bob pointer

    tst.b              Bob_Hide(a4)                                                ; bob is hidden, don't draw
    bne                .nextbob
    tst.l              Bob_Data(a4)                                                ; bob is not set (this is an exception really)
    bne                .ok
.broken
    nop
    bra                .nextbob
.ok
    ; y position
    moveq              #0,d1
    move.w             Bob_Y(a4),d0                                
    add.w              Bob_OffsetY(a4),d0                                          ; y position on screen
    move.w             Bob_Height(a4),d1                                           ; height

    sub.w              Bob_TopMargin(a4),d0                                        ; fake top crop

    move.w             d0,d2                                                       ; copy y position
    add.w              d1,d2                                                       ; y end on screen
    bmi                .nextbob                                                    ; negative bottom, move to next

    cmp.w              #SCREEN_HEIGHT_DISPLAY,d0                                   ; check top is in the screen
    bge                .nextbob                                                    ; nope, it is off screen

    moveq              #0,d3                                                       ; top crop value
    tst.w              d0                                                          ; check top value
    bge                .nohighcrop                                                 ; >= 0 so no top crop

    ; negative y, crop top of bob
    add.w              d0,d1                                                       ; remove top crop value from height value
    beq                .nextbob                                                    ; removes everything, dont draw it
    exg                d0,d3                                                       ; y position now zero
    neg                d3                                                          ; **top crop value here

.nohighcrop
    ; end of bob over end of screen, crop height
    add.w              Bob_TopMargin(a4),d2
    cmp.w              #SCREEN_HEIGHT_DISPLAY,d2
    bcs                .nolowcrop

    ;move.w         d2,d4                                       ; might not need this in another register
    ;sub.w          #SCREEN_HEIGHT_DISPLAY,d4
    ;sub.w          d4,d1                                       ; remove low crop from height
    sub.w              #SCREEN_HEIGHT_DISPLAY,d2
    sub.w              d2,d1
    beq                .nextbob                                                    ; nothing left, skip
.nolowcrop
    add.w              Bob_TopMargin(a4),d0                                        ; top crop move back
    ; cropping done, now lets blit it
    ; d0 = y pos ( keep for restore )
    ; d1 = height ( keep for restore )
    ; d3 = bob skip lines
    
    ; calc screen position and shift
    add.w              MapScrollOffset(a5),d0                                      ; add current scroll pos to Y
    ; store y position
    ; store height
    move.w             d0,Blit_Y(a3)
    move.w             d1,Blit_Height(a3)

    move.w             d0,d6 
    add.w              d6,d6
    add.w              d6,d6
    move.l             StrideLookUp(a5,d6.w),d6                                    ; **screen offset

    moveq              #0,d2
    move.w             Bob_X(a4),d2 
    add.w              Bob_OffsetX(a4),d2                                          ; x position
    bmi                .nextbob
    move.w             d2,d4                                                       ; copy pixel value
    and.w              #$f,d4                                                      ; 0-15 pixel shift

    add.w              d4,d4
    add.w              d4,d4

    ;move.l         BltConLookUp(pc,d4.w),d4                    ; **blt con value and shift
    lsr.w              #3,d2                                                       ; x position in bytes
    ; store x position
    move.w             d2,Blit_X(a3)

    add.l              d2,d6                                                       ; add x position (bytes) to screen position

    move.w             d1,d5                                                       ; create blit size from height (d1)
    add.w              d5,d5
    move.w             (a1,d5.w),d5                                                ; blit height loop up
    move.w             Bob_Width(a4),d1
    tst.w              d4
    beq                .noshift
    addq.b             #1,d1                                                       ; add blit width to become blit size
.noshift
    move.w             d1,Blit_Width(a3)                                           ; store the width
    add.w              d1,d5 

    add.w              d3,d3                                                       ; number of lines to crop from top
    beq                .skipcrop                                                   ; nothing, skip

    move.l             Bob_StrideLookUp(a4),a2
    move.w             (a2,d3.w),d3                                                ; byte crop value

.skipcrop

    move.w             #SCREEN_WIDTH_BYTE,d0
    sub.w              d1,d0
    sub.w              d1,d0
    move.w             d0,Blit_Modulo(a3)

    move.l             d3,d2
    add.l              Bob_Data(a4),d2
    ;add.l          d3,d1
    add.l              Bob_Mask(a4),d3
    ;add.l          d3,d2

    add.l              ScreenBuffer(a5),d6

    lea                Blit_Sizeof(a3),a3

    addq.w             #1,BlitCount(a5)  

    WAITBLITP
    tst.w              d4
    bne                .hasshift
    move.l             #$ffffffff,BLTAFWM(a6)                                      ; last word mask 
    move.w             #0,BLTAMOD(a6)                                              ; source mod
    move.w             #0,BLTBMOD(a6)                                              ; source mod
    bra                .blit

.hasshift
    move.l             #$ffff0000,BLTAFWM(a6)                                      ; last word mask 
    move.w             #-2,BLTAMOD(a6)                                             ; source mod
    move.w             #-2,BLTBMOD(a6)                                             ; source mod
.blit

    move.l             BltConLookUp(pc,d4.w),BLTCON0(a6)                           ; use channels A & D

    move.w             d0,BLTCMOD(a6)                                              ; screen dest mod
    move.w             d0,BLTDMOD(a6)                                              ; scratch destination

    move.l             d3,BLTAPT(a6)                                               ; mask
    move.l             d2,BLTBPT(a6)                                               ; item
    move.l             d6,BLTCPT(a6)                                               ; screen
    move.l             d6,BLTDPT(a6)                                               ; screen
    move.w             d5,BLTSIZE(a6)                                              ; BLIT!

.nextbob
    dbra               d7,.loop

    move.l             a3,BlitQueueActivePtrs(a5)
.exit
    rts

BltConLookUp:
    dc.l               $0fca0000
    dc.l               $1fca1000
    dc.l               $2fca2000
    dc.l               $3fca3000
    dc.l               $4fca4000
    dc.l               $5fca5000
    dc.l               $6fca6000
    dc.l               $7fca7000
    dc.l               $8fca8000
    dc.l               $9fca9000
    dc.l               $afcaa000
    dc.l               $bfcab000
    dc.l               $cfcac000
    dc.l               $dfcad000
    dc.l               $efcae000
    dc.l               $ffcaf000


;----------------------------------------------------------------------------
;
; bob draw direct
; 
; a0 = bob data
; d0 = Y pos
; d4 = X pos
;
;----------------------------------------------------------------------------

BobDrawDirect:
    ;PUSHMOST
    move.l             BlitQueueActivePtrs(a5),a3                                  ; for restore
    lea                BlitHeightLookUp(a5),a1
.loop

    ; y position
    moveq              #0,d1                            
    add.w              BobObj_OffsetY(a0),d0                                       ; y position on screen
    move.w             BobObj_Height(a0),d1                                        ; height

    move.w             d0,d2                                                       ; copy y position
    add.w              d1,d2                                                       ; y end on screen
    bmi                .exit                                                       ; negative bottom, move to next

    cmp.w              #SCREEN_HEIGHT_DISPLAY,d0                                   ; check top is in the screen
    bge                .exit                                                       ; nope, it is off screen

    moveq              #0,d3                                                       ; top crop value
    tst.w              d0                                                          ; check top value
    bge                .nohighcrop                                                 ; >= 0 so no top crop

    ; negative y, crop top of bob
    add.w              d0,d1                                                       ; remove top crop value from height value
    beq                .exit                                                       ; removes everything, dont draw it
    exg                d0,d3                                                       ; y position now zero
    neg                d3                                                          ; **top crop value here

.nohighcrop
    ; end of bob over end of screen, crop height
    cmp.w              #SCREEN_HEIGHT_DISPLAY,d2
    bcs                .nolowcrop

    sub.w              #SCREEN_HEIGHT_DISPLAY,d2
    sub.w              d2,d1
    beq                .exit                                                       ; nothing left, skip
.nolowcrop
    ; cropping done, now lets blit it
    ; d0 = y pos ( keep for restore )
    ; d1 = height ( keep for restore )
    ; d3 = bob skip lines
    
    ; calc screen position and shift
    add.w              MapScrollOffset(a5),d0                                      ; add current scroll pos to Y
    ; store y position
    ; store height
    move.w             d0,Blit_Y(a3)
    move.w             d1,Blit_Height(a3)

    move.w             d0,d6 
    add.w              d6,d6
    add.w              d6,d6
    move.l             StrideLookUp(a5,d6.w),d6                                    ; **screen offset

    add.w              BobObj_OffsetX(a0),d4                                       ; x position
    bmi                .exit
    move.l             d4,d2                                                       ; copy pixel value
    and.w              #$f,d4                                                      ; 0-15 pixel shift

    add.w              d4,d4
    add.w              d4,d4

    lsr.w              #3,d2                                                       ; x position in bytes
    ; store x position
    move.w             d2,Blit_X(a3)

    add.l              d2,d6                                                       ; add x position (bytes) to screen position

    move.w             d1,d5                                                       ; create blit size from height (d1)
    add.w              d5,d5
    move.w             (a1,d5.w),d5                                                ; blit height loop up
    move.w             BobObj_WidthWords(a0),d1
    tst.w              d4
    beq                .noshift
    addq.b             #1,d1                                                       ; add blit width to become blit size
.noshift
    move.w             d1,Blit_Width(a3)                                           ; store the width
    add.w              d1,d5 

    add.w              d3,d3                                                       ; number of lines to crop from top
    beq                .skipcrop                                                   ; nothing, skip

    moveq              #0,d7
    move.w             BobObj_WidthWords(a0),d7
    add.w              d7,d7
    add.w              d7,d7
    lea                BlitStridePtrs(a5),a2
    move.l             (a2,d7.w),a2
    move.w             (a2,d3.w),d3                                                ; byte crop value

.skipcrop

    move.w             #SCREEN_WIDTH_BYTE,d0
    sub.w              d1,d0
    sub.w              d1,d0
    move.w             d0,Blit_Modulo(a3)

    moveq              #0,d1
    move.w             BobObj_DataSize(a0),d1

    lea                BobObj_Data(a0),a0
    add.l              a0,d3

    move.l             d3,d2
    add.l              d1,d3                                                       ; bob mask

    add.l              ScreenBuffer(a5),d6

    lea                Blit_Sizeof(a3),a3
    addq.w             #1,BlitCount(a5)  
    move.l             a3,BlitQueueActivePtrs(a5)

    WAITBLITL
    tst.w              d4
    bne                .hasshift
    move.l             #$ffffffff,BLTAFWM(a6)                                      ; last word mask 
    move.w             #0,BLTAMOD(a6)                                              ; source mod
    move.w             #0,BLTBMOD(a6)                                              ; source mod
    bra                .blit

.hasshift
    move.l             #$ffff0000,BLTAFWM(a6)                                      ; last word mask 
    move.w             #-2,BLTAMOD(a6)                                             ; source mod
    move.w             #-2,BLTBMOD(a6)                                             ; source mod
.blit

    move.l             BltConLookUp2(pc,d4.w),BLTCON0(a6)                          ; use channels A & D

    move.w             d0,BLTCMOD(a6)                                              ; screen dest mod
    move.w             d0,BLTDMOD(a6)                                              ; scratch destination

    move.l             d3,BLTAPT(a6)                                               ; mask
    move.l             d2,BLTBPT(a6)                                               ; item
    move.l             d6,BLTCPT(a6)                                               ; screen
    move.l             d6,BLTDPT(a6)                                               ; screen
    move.w             d5,BLTSIZE(a6)                                              ; BLIT!
.exit
    ;POPMOST
    rts

BltConLookUp2:
    dc.l               $0fca0000
    dc.l               $1fca1000
    dc.l               $2fca2000
    dc.l               $3fca3000
    dc.l               $4fca4000
    dc.l               $5fca5000
    dc.l               $6fca6000
    dc.l               $7fca7000
    dc.l               $8fca8000
    dc.l               $9fca9000
    dc.l               $afcaa000
    dc.l               $bfcab000
    dc.l               $cfcac000
    dc.l               $dfcad000
    dc.l               $efcae000
    dc.l               $ffcaf000




;----------------------------------------------------------------------------
;
; bob draw direct
; 
; a0 = bob data
; d0 = Y pos
; d4 = X pos
;
;----------------------------------------------------------------------------

BobDrawOnly:
    ;PUSHMOST
    lea                BlitHeightLookUp(a5),a1
.loop

    ; y position
    moveq              #0,d1                            
    add.w              BobObj_OffsetY(a0),d0                                       ; y position on screen
    move.w             BobObj_Height(a0),d1                                        ; height

    move.w             d0,d2                                                       ; copy y position
    add.w              d1,d2                                                       ; y end on screen
    bmi                .exit                                                       ; negative bottom, move to next

    cmp.w              #SCREEN_HEIGHT_DISPLAY,d0                                   ; check top is in the screen
    bge                .exit                                                       ; nope, it is off screen

    moveq              #0,d3                                                       ; top crop value
    tst.w              d0                                                          ; check top value
    bge                .nohighcrop                                                 ; >= 0 so no top crop

    ; negative y, crop top of bob
    add.w              d0,d1                                                       ; remove top crop value from height value
    beq                .exit                                                       ; removes everything, dont draw it
    exg                d0,d3                                                       ; y position now zero
    neg                d3                                                          ; **top crop value here

.nohighcrop
    ; end of bob over end of screen, crop height
    cmp.w              #SCREEN_HEIGHT_DISPLAY,d2
    bcs                .nolowcrop

    sub.w              #SCREEN_HEIGHT_DISPLAY,d2
    sub.w              d2,d1
    beq                .exit                                                       ; nothing left, skip
.nolowcrop
    ; cropping done, now lets blit it
    ; d0 = y pos ( keep for restore )
    ; d1 = height ( keep for restore )
    ; d3 = bob skip lines
    
    ; calc screen position and shift
    add.w              MapScrollOffset(a5),d0                                      ; add current scroll pos to Y
    ; store y position
    ; store height

    move.w             d0,d6 
    add.w              d6,d6
    add.w              d6,d6
    move.l             StrideLookUp(a5,d6.w),d6                                    ; **screen offset

    add.w              BobObj_OffsetX(a0),d4                                       ; x position
    bmi                .exit
    move.l             d4,d2                                                       ; copy pixel value
    and.w              #$f,d4                                                      ; 0-15 pixel shift

    add.w              d4,d4
    add.w              d4,d4

    lsr.w              #3,d2                                                       ; x position in bytes
    add.l              d2,d6                                                       ; add x position (bytes) to screen position

    move.w             d1,d5                                                       ; create blit size from height (d1)
    add.w              d5,d5
    move.w             (a1,d5.w),d5                                                ; blit height loop up
    move.w             BobObj_WidthWords(a0),d1
    tst.w              d4
    beq                .noshift
    addq.b             #1,d1                                                       ; add blit width to become blit size
.noshift
    add.w              d1,d5 

    add.w              d3,d3                                                       ; number of lines to crop from top
    beq                .skipcrop                                                   ; nothing, skip

    moveq              #0,d7
    move.w             BobObj_WidthWords(a0),d7
    add.w              d7,d7
    add.w              d7,d7
    lea                BlitStridePtrs(a5),a2
    move.l             (a2,d7.w),a2
    move.w             (a2,d3.w),d3                                                ; byte crop value

.skipcrop

    move.w             #SCREEN_WIDTH_BYTE,d0
    sub.w              d1,d0
    sub.w              d1,d0

    moveq              #0,d1
    move.w             BobObj_DataSize(a0),d1

    lea                BobObj_Data(a0),a0
    add.l              a0,d3

    move.l             d3,d2
    add.l              d1,d3                                                       ; bob mask

    add.l              ScreenBuffer(a5),d6

    WAITBLITL
    tst.w              d4
    bne                .hasshift
    move.l             #$ffffffff,BLTAFWM(a6)                                      ; last word mask 
    move.w             #0,BLTAMOD(a6)                                              ; source mod
    move.w             #0,BLTBMOD(a6)                                              ; source mod
    bra                .blit

.hasshift
    move.l             #$ffff0000,BLTAFWM(a6)                                      ; last word mask 
    move.w             #-2,BLTAMOD(a6)                                             ; source mod
    move.w             #-2,BLTBMOD(a6)                                             ; source mod
.blit

    move.l             .bltconlookup(pc,d4.w),BLTCON0(a6)                          ; use channels A & D

    move.w             d0,BLTCMOD(a6)                                              ; screen dest mod
    move.w             d0,BLTDMOD(a6)                                              ; scratch destination

    move.l             d3,BLTAPT(a6)                                               ; mask
    move.l             d2,BLTBPT(a6)                                               ; item
    move.l             d6,BLTCPT(a6)                                               ; screen
    move.l             d6,BLTDPT(a6)                                               ; screen
    move.w             d5,BLTSIZE(a6)                                              ; BLIT!
.exit
    ;POPMOST
    rts

.bltconlookup
    dc.l               $0fca0000
    dc.l               $1fca1000
    dc.l               $2fca2000
    dc.l               $3fca3000
    dc.l               $4fca4000
    dc.l               $5fca5000
    dc.l               $6fca6000
    dc.l               $7fca7000
    dc.l               $8fca8000
    dc.l               $9fca9000
    dc.l               $afcaa000
    dc.l               $bfcab000
    dc.l               $cfcac000
    dc.l               $dfcad000
    dc.l               $efcae000
    dc.l               $ffcaf000

;----------------------------------------------------------------------------
;
; qblock blit
;
; a0 = qblock structure
; a1 = qblock gfx
;----------------------------------------------------------------------------

QBlockBltSize:  
    dc.w               0
    dc.w               ((1*5)<<6)+1
    dc.w               ((2*5)<<6)+1
    dc.w               ((3*5)<<6)+1
    dc.w               ((4*5)<<6)+1
    dc.w               ((5*5)<<6)+1
    dc.w               ((6*5)<<6)+1
    dc.w               ((7*5)<<6)+1
    dc.w               ((8*5)<<6)+1
    dc.w               ((9*5)<<6)+1
    dc.w               ((10*5)<<6)+1
    dc.w               ((11*5)<<6)+1
    dc.w               ((12*5)<<6)+1
    dc.w               ((13*5)<<6)+1
    dc.w               ((14*5)<<6)+1
    dc.w               ((15*5)<<6)+1
    dc.w               ((16*5)<<6)+1

BlitQBlock:
    move.l             ScreenBuffer(a5),a2

    moveq              #0,d1                                                       ; blit source offset
    moveq              #16,d2                                                      ; line count default

    moveq              #0,d3
    move.b             QBLOCK_PosY(a0),d3

    cmp.b              #$d0,d3
    bcc                .noblit                                                     ; out of range!

    cmp.b              #$c0,d3                                                     ; test bottom crop
    bcs                .nobottom

    move.w             d3,d2                                                       ; crop bottom
    addq.w             #1,d2
    neg.w              d2
    and.w              #$f,d2
    beq                .noblit
    sub.w              #15,d3
    bra                .doblit
    
.nobottom
    sub.w              #15,d3
    bpl                .doblit                                                     ; no top crop

    move.w             d3,d2
    and.w              #$f,d2                                                      ; line count reduced blit

    move.w             d2,d1
    neg                d1    
    and.w              #$f,d1                                                      ; blit source offset reduced blit

    move.w             d1,d5
    lsl.w              #3,d1
    add.w              d5,d1                                       
    add.w              d5,d1                                                       ; * 10 (blit line size of Qblock)

    moveq              #0,d3                                                       ; clear off screen offset

.doblit
    add.w              d2,d2
    move.w             QBlockBltSize(pc,d2.w),d2

    ;lsl.w          #6,d2
    ;mulu           #5,d2
    ;add.w          #1,d2                                       ; blit size

    moveq              #0,d5
    move.w             MapScrollOffset(a5),d5
    add.w              d3,d5                                                       ; add current Y position
    move.w             d5,d6                                                       ; store for buffer check on 2nd blit

    add.w              d5,d5
    add.w              d5,d5
    move.l             StrideLookUp(a5,d5.w),d5                                    ; screen offset

    moveq              #0,d4
    move.b             QBLOCK_PosX(a0),d4
    lsr.b              #3,d4
    add.l              d4,d5

    add.l              d1,a1
    add.l              d5,a2
    
    btst               #0,d5
    bne                BlitQBlockShift

    WAITBLIT
    move.w             #$09f0,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #0,BLTAMOD(a6)
    move.w             #QBLOCK_MOD,BLTDMOD(a6)
    move.l             a1,BLTAPT(a6)
    move.l             a2,BLTDPT(a6)
    move.w             d2,BLTSIZE(a6)                                              ; blit to current screen

    move.l             #SCREEN_HALF,d5
    cmp.w              #SCREEN_HEIGHT_GAME/2,d6
    bcs                .lowerhalf
    neg.l              d5
.lowerhalf
    add.l              d5,a2

    WAITBLIT
    move.l             a1,BLTAPT(a6)
    move.l             a2,BLTDPT(a6)
    move.w             d2,BLTSIZE(a6)                                              ; blit to restore screen
.noblit
    rts

    ; qblock blit shifted by 8 pixels

BlitQBlockShift:
    addq.w             #1,d2                                                       ; extra word on the blit

    WAITBLIT                                                  
    move.w             #$87ca,BLTCON0(a6)                                          ; shift by 8
    move.w             #$8000,BLTCON1(a6)
    move.l             #$ffff0000,BLTAFWM(a6)
    move.w             #$ffff,BLTADAT(a6)                                          ; mask for a & b / a ! c

    move.w             #-2,BLTBMOD(a6)
    move.w             #QBLOCK_MOD-2,BLTCMOD(a6)
    move.w             #QBLOCK_MOD-2,BLTDMOD(a6)
    move.l             a1,BLTBPT(a6)
    move.l             a2,BLTCPT(a6)
    move.l             a2,BLTDPT(a6)
    move.w             d2,BLTSIZE(a6)                                              ; blit to current screen

    move.l             #SCREEN_HALF,d5
    cmp.w              #SCREEN_HEIGHT_GAME/2,d6
    bcs                .lowerhalf
    neg.l              d5
.lowerhalf
    add.l              d5,a2

    WAITBLIT
    move.l             a1,BLTBPT(a6)
    move.l             a2,BLTCPT(a6)
    move.l             a2,BLTDPT(a6)
    move.w             d2,BLTSIZE(a6)                                              ; blit to restore screen
    rts



;----------------------------------------------------------------------------
;
; bridge blit
;
; a0 = qblock structure
; a1 = tile gfx
;----------------------------------------------------------------------------

BlitBridge:
    move.l             ScreenBuffer(a5),a2

    moveq              #0,d1                                                       ; blit source offset
    moveq              #32,d2                                                      ; line count default

    moveq              #0,d3
    move.b             QBLOCK_PosY(a0),d3
    ;sub.b          #16,d3

    cmp.b              #$c0,d3                                                     ; test bottom crop
    bcs                .nobottom

    sub.w              #15,d3
    move.w             d3,d2                                                       ; crop bottom
    and                #$1f,d2
    bra                .doblit
    
.nobottom
    sub.w              #31,d3
    bpl                .doblit                                                     ; no top crop

    move.w             d3,d2
    and.w              #$1f,d2                                                     ; line count reduced blit

    move.w             d2,d1
    neg                d1    
    and.w              #$1f,d1                                                     ; blit source offset reduced blit

    mulu               #20,d1                                                      ; * 20 tile line

    moveq              #0,d3                                                       ; clear off screen offset

.doblit
    add.w              d2,d2
    lea                BridgeBltSize(pc),a3
    move.w             (a3,d2.w),d2

    ;lsl.w          #6,d2
    ;mulu           #5,d2
    ;add.w          #1,d2                                       ; blit size

    moveq              #0,d5
    move.w             MapScrollOffset(a5),d5
    add.w              d3,d5                                                       ; add current Y position
    move.w             d5,d6                                                       ; store for buffer check on 2nd blit

    add.w              d5,d5
    add.w              d5,d5
    move.l             StrideLookUp(a5,d5.w),d5                                    ; screen offset

    moveq              #0,d4
    move.b             QBLOCK_PosX(a0),d4
    sub.b              #8,d4                                                       ; offset tile
    lsr.b              #3,d4
    add.l              d4,d5

    add.l              d1,a1
    add.l              d5,a2
    
    WAITBLIT
    move.w             #$09f0,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #0,BLTAMOD(a6)
    move.w             #TILE_MOD,BLTDMOD(a6)
    move.l             a1,BLTAPT(a6)
    move.l             a2,BLTDPT(a6)
    move.w             d2,BLTSIZE(a6)                                              ; blit to current screen

    move.l             #SCREEN_HALF,d5
    cmp.w              #SCREEN_HEIGHT_GAME/2,d6
    bcs                .lowerhalf
    neg.l              d5
.lowerhalf
    add.l              d5,a2

    WAITBLIT
    move.l             a1,BLTAPT(a6)
    move.l             a2,BLTDPT(a6)
    move.w             d2,BLTSIZE(a6)                                              ; blit to restore screen
    rts

BridgeBltSize:  
    dc.w               0
    dc.w               ((1*5)<<6)+2
    dc.w               ((2*5)<<6)+2
    dc.w               ((3*5)<<6)+2
    dc.w               ((4*5)<<6)+2
    dc.w               ((5*5)<<6)+2
    dc.w               ((6*5)<<6)+2
    dc.w               ((7*5)<<6)+2
    dc.w               ((8*5)<<6)+2
    dc.w               ((9*5)<<6)+2
    dc.w               ((10*5)<<6)+2
    dc.w               ((11*5)<<6)+2
    dc.w               ((12*5)<<6)+2
    dc.w               ((13*5)<<6)+2
    dc.w               ((14*5)<<6)+2
    dc.w               ((15*5)<<6)+2
    dc.w               ((16*5)<<6)+2
    dc.w               ((17*5)<<6)+2
    dc.w               ((18*5)<<6)+2
    dc.w               ((19*5)<<6)+2
    dc.w               ((20*5)<<6)+2
    dc.w               ((21*5)<<6)+2
    dc.w               ((22*5)<<6)+2
    dc.w               ((23*5)<<6)+2
    dc.w               ((24*5)<<6)+2
    dc.w               ((25*5)<<6)+2
    dc.w               ((26*5)<<6)+2
    dc.w               ((27*5)<<6)+2
    dc.w               ((28*5)<<6)+2
    dc.w               ((29*5)<<6)+2
    dc.w               ((30*5)<<6)+2
    dc.w               ((31*5)<<6)+2
    dc.w               ((32*5)<<6)+2


;----------------------------------------------------------------------------
;
; konami logo blit
;
;----------------------------------------------------------------------------

LOGO_WIDTH                = 12*8
LOGO_WIDTH_WORD           = LOGO_WIDTH/16
LOGO_HEIGHT               = 5*8
LOGO_BLIT_MOD             = SCREEN_STRIDE-(LOGO_WIDTH/8)
LOGO_BLIT_SIZE1           = ((LOGO_HEIGHT-14)<<6)+LOGO_WIDTH_WORD
LOGO_BLIT_SIZE2           = (LOGO_HEIGHT<<6)+LOGO_WIDTH_WORD

KonamiBlit:
    lea                KonamiLogo,a0
    move.l             ScreenBuffer(a5),a1
    
    moveq              #10,d0
    move.w             LogoPos(a5),d1
    mulu               #SCREEN_STRIDE,d1
    add.w              d1,d0
    add.l              d0,a1

    WAITBLIT
    move.w             #$09f0,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #0,BLTAMOD(a6)
    move.w             #LOGO_BLIT_MOD,BLTDMOD(a6)
    move.l             a0,BLTAPT(a6)
    move.l             a1,BLTDPT(a6)
    move.w             #LOGO_BLIT_SIZE1,BLTSIZE(a6)
    rts

KonamiBlitFinal:
    lea                KonamiLogo,a0
    move.l             ScreenBuffer(a5),a1
    
    moveq              #10,d0
    move.w             LogoPos(a5),d1
    mulu               #SCREEN_STRIDE,d1
    add.w              d1,d0
    add.l              d0,a1

    WAITBLIT
    move.w             #$09f0,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #0,BLTAMOD(a6)
    move.w             #LOGO_BLIT_MOD,BLTDMOD(a6)
    move.l             a0,BLTAPT(a6)
    move.l             a1,BLTDPT(a6)
    move.w             #LOGO_BLIT_SIZE2,BLTSIZE(a6)
    rts


KonamiClear:
    lea                KonamiLogo,a0
    move.l             ScreenBuffer(a5),a1
    
    moveq              #10,d0
    move.w             LogoPos(a5),d1
    mulu               #SCREEN_STRIDE,d1
    add.w              d1,d0
    add.l              d0,a1

    WAITBLIT
    move.w             #$0100,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #LOGO_BLIT_MOD,BLTDMOD(a6)
    move.l             a1,BLTDPT(a6)
    move.w             #LOGO_BLIT_SIZE1,BLTSIZE(a6)
    rts


;----------------------------------------------------------------------------
;
; menu logo blit
;
;----------------------------------------------------------------------------

MENU_LOGO_WIDTH           = 12*8
MENU_LOGO_WIDTH_WORD      = MENU_LOGO_WIDTH/16
MENU_LOGO_HEIGHT          = 3*8
MENU_LOGO_BLIT_MOD        = SCREEN_STRIDE-(MENU_LOGO_WIDTH/8)
MENU_LOGO_BLIT_SIZE       = (MENU_LOGO_HEIGHT<<6)+MENU_LOGO_WIDTH_WORD

MENU_LOGO_POS             = SCREEN_WIDTH_BYTE+(SCREEN_STRIDE*8*9)+10
;
;MenuLogoBlit:
;    lea                MenuLogo,a0
;    move.l             ScreenBuffer(a5),a1
;    
;    add.l              #MENU_LOGO_POS,a1
;
;    WAITBLIT
;    move.w             #$09f0,BLTCON0(a6)
;    move.w             #0,BLTCON1(a6)
;    move.l             #-1,BLTAFWM(a6)
;    move.w             #0,BLTAMOD(a6)
;    move.w             #MENU_LOGO_BLIT_MOD,BLTDMOD(a6)
;    move.l             a0,BLTAPT(a6)
;    move.l             a1,BLTDPT(a6)
;    move.w             #MENU_LOGO_BLIT_SIZE,BLTSIZE(a6)
;    rts

;----------------------------------------------------------------------------
;
; restore whole screen
; 
; d0 = line number
;
;----------------------------------------------------------------------------

RestoreScreenLine:
    PUSHMOST

    add.w              MapScrollOffset(a5),d0
    add.w              d0,d0
    add.w              d0,d0
    move.l             StrideLookUp(a5,d0.w),d0
    move.l             d0,d1
    add.l              ScreenBuffer(a5),d0
    add.l              ScreenBuffer+4(a5),d1

    WAITBLIT
    move.w             #$09f0,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #TILE_SCREEN_LINE_BLTMOD,BLTDMOD(a6)
    move.w             #TILE_SCREEN_LINE_BLTMOD,BLTAMOD(a6)
    move.l             d1,BLTAPT(a6)
    move.l             d0,BLTDPT(a6)
    move.w             #TILE_SCREEN_LINE_BLTSIZE,BLTSIZE(a6)

    POPMOST
    rts


;----------------------------------------------------------------------------
;
; clear horizontal line
; 
; d0 = line number
;
;----------------------------------------------------------------------------



LineClearHori:
    PUSHMOST
    add.w              MapScrollOffset(a5),d0

    add.w              d0,d0
    add.w              d0,d0
    move.l             StrideLookUp(a5,d0.w),d0
    add.l              ScreenBuffer(a5),d0

    WAITBLIT
    move.w             #$0100,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             #-1,BLTAFWM(a6)
    move.w             #TILE_SCREEN_LINE_BLTMOD,BLTDMOD(a6)
    move.l             d0,BLTDPT(a6)
    move.w             #TILE_SCREEN_LINE_BLTSIZE,BLTSIZE(a6)

    POPMOST
    rts

;----------------------------------------------------------------------------
;
; clear horizontal line
; 
; d0 = line number
;
;----------------------------------------------------------------------------



LineClearVert:
    PUSHMOST
    move.w             d0,d1
    and.w              #$f,d1

    move.l             #$7fff7fff,d2
    ror.l              d1,d2                                                       ; mask

    lsr.w              #3,d0                                                       ; x offset bytes

    moveq              #0,d1
    move.w             MapScrollOffset(a5),d1
    add.w              d1,d1
    add.w              d1,d1
    move.l             StrideLookUp(a5,d1),d1

    add.l              d1,d0
    add.l              ScreenBuffer(a5),d0                                         ; source and dest

    WAITBLIT
    move.w             #$09f0,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             d2,BLTAFWM(a6)
    move.w             #SCREEN_WIDTH_BYTE-2,BLTAMOD(a6)
    move.w             #SCREEN_WIDTH_BYTE-2,BLTDMOD(a6)
    move.l             d0,BLTAPT(a6)
    move.l             d0,BLTDPT(a6)
    move.w             #((SCREEN_HEIGHT_DISPLAY*SCREEN_DEPTH)<<6)+1,BLTSIZE(a6)

    POPMOST
    rts


;----------------------------------------------------------------------------
;
; clear screen horizontal
; 
; beq after call = complete
;
;----------------------------------------------------------------------------

ClearHorizontal:
    moveq              #0,d0
    move.b             Shrink(a5),d0

    moveq              #(SCREEN_HEIGHT_DISPLAY/16)-1,d7
.loop
    bsr                LineClearHori
    add.b              #16,d0
    dbra               d7,.loop

    addq.b             #1,Shrink(a5)
    cmp.b              #16,Shrink(a5)
    rts


;----------------------------------------------------------------------------
;
; hud items
;
; d0 = value??
;
;----------------------------------------------------------------------------

HUD_ITEM_WIDTH            = 32
HUD_ITEM_WIDTH_BYTE       = HUD_ITEM_WIDTH/8
HUD_ITEM_WIDTH_WORD       = HUD_ITEM_WIDTH/16

HUD_ITEM_SHIELD_HEIGHT    = 8
HUD_ITEM_SPEED_HEIGHT     = 10

HUD_ITEM_SHIELD_OFFSET    = (128/8)+(6*HUD_STRIDE)
HUD_ITEM_SPEED_OFFSET     = (176/8)+(2*HUD_STRIDE)

HUD_ITEM_SHEILD_BLIT_SIZE = ((HUD_ITEM_SHIELD_HEIGHT*HUD_DEPTH)<<6)+HUD_ITEM_WIDTH_WORD
HUD_ITEM_SPEED_BLIT_SIZE  = ((HUD_ITEM_SPEED_HEIGHT*HUD_DEPTH)<<6)+HUD_ITEM_WIDTH_WORD
HUD_ITEM_BLIT_MOD         = HUD_WIDTH_BYTE-HUD_ITEM_WIDTH_BYTE

; 25 positions

DrawHUDSpeed:
    mulu               #25,d0
    divu               #4,d0

    swap               d0
    clr.w              d0
    swap               d0
    move.l             #%11111000000000000000000000000000,d1
    asr.l              d0,d1
    or.b               #3,d1                                                       ; last two pixels

    WAITBLIT
    move.l             HUDImagePtrs+4(a5),a0
    lea                HUD,a1
    add.l              #HUD_ITEM_SPEED_OFFSET,a1
    move.w             #$09f0,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             d1,BLTAFWM(a6)
    move.w             #0,BLTAMOD(a6)
    move.w             #HUD_ITEM_BLIT_MOD,BLTDMOD(a6)
    move.l             a0,BLTAPT(a6)
    move.l             a1,BLTDPT(a6)
    move.w             #HUD_ITEM_SPEED_BLIT_SIZE,BLTSIZE(a6)
    rts

DrawHUDShield:
    mulu               #23,d0
    divu               #$1e,d0
    
    swap               d0
    clr.w              d0
    swap               d0
    move.l             #%11111111100000000000000000000000,d1
    asr.l              d0,d1

    WAITBLIT
    move.l             HUDImagePtrs(a5),a0
    lea                HUD,a1
    add.l              #HUD_ITEM_SHIELD_OFFSET,a1
    move.w             #$09f0,BLTCON0(a6)
    move.w             #0,BLTCON1(a6)
    move.l             d1,BLTAFWM(a6)
    move.w             #0,BLTAMOD(a6)
    move.w             #HUD_ITEM_BLIT_MOD,BLTDMOD(a6)
    move.l             a0,BLTAPT(a6)
    move.l             a1,BLTDPT(a6)
    move.w             #HUD_ITEM_SHEILD_BLIT_SIZE,BLTSIZE(a6)
    rts

    ; 23 positions
HUDShieldMask:
    dc.l               %11111111100000000000000000000000
