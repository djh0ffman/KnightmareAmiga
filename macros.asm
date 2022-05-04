
;----------------------------------------------------------------------------
;
; enemy wave move logic
;
; d2 = value shift count (shifts the resulting value c times)
;
;----------------------------------------------------------------------------

CALCWAVEY MACRO
            move.b     ENEMY_PosY(a2),d0
            sub.b      ENEMY_OffsetY(a2),d0
            ext        d0
            tst.b      d2
            beq        .\@skipshift
            asr.w      d2,d0
.\@skipshift
            sub.w      d0,ENEMY_SpeedY(a2)
            ENDM

;----------------------------------------------------------------------------
;
; enemy wave move logic
;
; d2 = value shift count (shifts the resulting value c times)
;
;----------------------------------------------------------------------------

CALCWAVEX MACRO
            move.b     ENEMY_PosX(a2),d0
            sub.b      ENEMY_OffsetX(a2),d0
            ext        d0
            tst.b      d2
            beq        .\@skipshift
            asr.w      d2,d0
.\@skipshift
            sub.w      d0,ENEMY_SpeedX(a2)
            ENDM

;----------------------------------------------------------------------------
;
; animate 2
;
; animates enemy for 2 frames
;
;----------------------------------------------------------------------------

ANIMATE2 MACRO
            moveq      #0,d1
            move.b     ENEMY_Random(a2),d0
            add.b      TickCounter(a5),d0
            btst       #3,d0
            beq        .\@skip
            addq.b     #1,d1
.\@skip
            move.b     d1,ENEMY_BobId(a2)
            ENDM

;----------------------------------------------------------------------------
;
; get player dim
;
; returns player dimensions in d3 / d4
; d3 = x \ y
; d4 = width \ height
;----------------------------------------------------------------------------

GETPLAYERDIM MACRO
            moveq      #0,d3
            move.b     PlayerStatus+PLAYER_PosX(a5),d3
            addq.b     #3,d3
            swap       d3
            move.b     PlayerStatus+PLAYER_PosY(a5),d3
            addq.b     #3,d3
            move.l     #$000a000a,d4
            ENDM


;----------------------------------------------------------------------------
;
; get player sheild dim
;
; returns player dimensions in d3 / d4
; d3 = x \ y
; d4 = width \ height
;----------------------------------------------------------------------------

GETSHIELDDIM MACRO
            moveq      #0,d3
            move.b     PlayerStatus+PLAYER_PosX(a5),d3
            swap       d3
            move.b     PlayerStatus+PLAYER_PosY(a5),d3
            sub.b      #9,d3
            move.l     #$00100008,d4
            ENDM


;----------------------------------------------------------------------------
;
; get player dim
;
; returns player dimensions in d3 / d4
; d3 = x \ y
; d4 = width \ height
;----------------------------------------------------------------------------

GETBOSSDIM MACRO
            moveq      #0,d1
            move.b     BossId(a5),d1
            lea        BossBoxDims,a1
            lsl.w      #3,d1
            add.l      d1,a1

            move.l     (a1)+,d2

            moveq      #0,d1
            move.b     BossPosX(a5),d1
            add.w      2(a1),d1
            swap       d1
            move.b     BossPosY(a5),d1
            add.w      (a1),d1
            ENDM




;----------------------------------------------------------------------------
;
; get enemy dim
;
; returns enemy dimensions in d1 / d2
; d1 = x \ y
; d2 = width \ height
;----------------------------------------------------------------------------

GETENEMYSHOTDIM MACRO
            moveq      #0,d1
            move.b     ENEMYSHOT_PosX(a1),d1
            swap       d1
            move.b     ENEMYSHOT_PosY(a1),d1

            lea        EnemyBoxDims,a0                         ; shot boxes
            move.b     ENEMYSHOT_Type(a1),d2
            and.w      #$f,d2
            add.w      d2,d2
            add.w      d2,d2
            move.l     (a0,d2.w),d2
            ENDM

;----------------------------------------------------------------------------
;
; get player shot dim
;
; \1 = player shot structure address
; \2 = player shot dim address
;
; returns player dimensions in d3 / d4
; d3 = x \ y
; d4 = width \ height
;----------------------------------------------------------------------------

GETPLAYERSHOTDIM MACRO
            moveq      #0,d3
            move.b     PLAYERSHOT_PosX(\1),d3
            swap       d3
            move.b     PLAYERSHOT_PosY(\1),d3
            
            move.l     PLAYERSHOT_Width(\1),d4
            
            ;moveq      #0,d4
            ;move.b     PLAYERSHOT_WeaponId(\1),d4
            ;add.w      d4,d4
            ;add.w      d4,d4
            ;lea        PlayerShotDims,\2  
            ;move.l     (\2,d4.w),d4
            
            ENDM

;----------------------------------------------------------------------------
;
; get player shot dim
;
; \1 = player shot structure address
; \2 = player shot dim address
;
; returns player dimensions in d3 / d4
; d3 = x \ y
; d4 = width \ height
;----------------------------------------------------------------------------

GETENEMYDIM MACRO
            move.b     ENEMY_Id(a2),d0
            and.w      #$f,d0
            lsl.w      #3,d0
            lea        EnemyDimensions,a0
            add.l      d0,a0
            moveq      #0,d1
            move.b     ENEMY_PosX(a2),d1
            add.w      (a0)+,d1
            swap       d1
            move.b     ENEMY_PosY(a2),d1
            add.w      (a0)+,d1
            move.l     (a0)+,d2
            ENDM

;----------------------------------------------------------------------------
;
; get power up dim
;
; returns player dimensions in d3 / d4
; d3 = x \ y
; d4 = width \ height
;----------------------------------------------------------------------------

GETPOWERUPDIM MACRO
            moveq      #0,d1
            move.b     PowerUpPosX(a5),d1
            swap       d1
            move.b     PowerUpPosY(a5),d1
            move.l     #$00100010,d2
            ENDM


;----------------------------------------------------------------------------
;
; checks collision
;
; checks box collision
; 
; in 
; d1 = object1 y \ x ( other )      - hl
; d2 = object1 height \ width       - bc 
; d3 = object2 y \ x ( player )     - temp y x
; d4 = object2 height \ width       - de
;
; bcs = no collision
; bcc = collision
;----------------------------------------------------------------------------

CHECKCOLLISION MACRO
            add.w      d4,d3                                   ; add box
            sub.w      d1,d3                                   ; sub pos
            add        d4,d2
            cmp.w      d3,d2
            bcs        .\@out

            swap       d1
            swap       d2
            swap       d3
            swap       d4

            add.w      d4,d3                                   ; add box
            sub.w      d1,d3                                   ; sub pos
            add        d4,d2
            cmp.w      d3,d2
;            bcs        .\@out

.\@out

            ENDM


;----------------------------------------------------------------------------
;
; Set bob to matrix
;
; \1 = bob data
; \2 = structure
;----------------------------------------------------------------------------

BOBSET MACRO
            move.w     BobObj_OffsetY(\1),Bob_OffsetY(\2)
            move.w     BobObj_OffsetX(\1),Bob_OffsetX(\2)
            move.w     BobObj_Height(\1),Bob_Height(\2)

            move.w     BobObj_WidthWords(\1),Bob_Width(\2)
            move.w     BobObj_Layer(\1),Bob_Layer(\2)
            move.w     BobObj_DataSize(\1),Bob_DataSize(\2)
 
            moveq      #0,d0
            move.w     BobObj_DataSize(\1),d0
            lea        BobObj_Data(\1),\1
            move.l     \1,Bob_Data(\2)
            add.l      d0,\1
            move.l     \1,Bob_Mask(\2)

            moveq      #0,d0
            move.w     Bob_Width(\2),d0
            add.w      d0,d0
            add.w      d0,d0
            lea        BlitStridePtrs(a5),\1
            move.l     (\1,d0.w),Bob_StrideLookUp(\2)
            ENDM


SPIT_HEX MACRO
            PUSHALL
            move.l     \1,d1
            POPALL
            ENDM




RANDOM MACRO
            move.l     d1,-(sp)
            move.l     RandomSeed(a5),d0
            move.l     d0,d1
            swap.w     d0
            mulu.w     #$9D3D,d1
            add.l      d1,d0
            move.l     d0,RandomSeed(a5)
            clr.w      d0
            swap.w     d0
            move.l     (sp)+,d1
            and.w      #$ff,d0
            ENDM

RANDOMWORD MACRO
            move.l     d1,-(sp)
            move.l     RandomSeed(a5),d0
            move.l     d0,d1
            swap.w     d0
            mulu.w     #$9D3D,d1
            add.l      d1,d0
            move.l     d0,RandomSeed(a5)
            clr.w      d0
            swap.w     d0
            move.l     (sp)+,d1
            ENDM

** convert to decimal
**
** \1 = source number
** \2 = digits
** \3 = result

TODECIMAL MACRO
            moveq      #\2,d7
            moveq      #0,\3
.\@loop     divu       #10,\1
            swap       \1
            or.b       \1,\3
            clr.w      \1
            swap       \1
            ror.w      #4,\3
            dbra       d7,.\@loop
            ENDM

DECIMAL2 MACRO
            moveq      #0,\2
            divu       #10,\1
            swap       \1
            move.w     \1,\2
            swap       \2
            clr.w      \1
            swap       \1
            divu       #10,\1
            swap       \1
            move.w     \1,\2
            ENDM

DBCOL MACRO
            if         DEBUG_COLORS=1
            move.w     #\1,COLOR(a6)
            endif
            ENDM
  

** Standard wait blits

BLITSKIP MACRO 
            tst.b      $02(a6)
            btst       #6,$02(a6)
            bne.b      \1
            ENDM

WAITBLITCOL	MACRO
            ;move.w     #$f00,COLOR00(a6)
            ;move.w     #BLITPRI_ENABLE,DMACON(a6)
            tst.b      $02(a6)
.\@         btst       #6,$02(a6)
            bne.b      .\@
            ;move.w     #BLITPRI_DISABLE,DMACON(a6)
            ;move.w     #$000,COLOR00(a6)
            ENDM



WAITBLITL	MACRO
            ;move.w     #$f00,COLOR00(a6)
            ;move.w     #BLITPRI_ENABLE,DMACON(a6)
            tst.b      $02(a6)
.\@         btst       #6,$02(a6)
            bne.b      .\@
            ;move.w     #BLITPRI_DISABLE,DMACON(a6)
            ;move.w     #$000,COLOR00(a6)
            ENDM


WAITBLITLAZY	MACRO
            tst.b      $02(a6)
.\@         btst       #6,$02(a6)
            bne.b      .\@
            ENDM

WAITBLIT	MACRO
            move.w     #BLITPRI_ENABLE,DMACON(a6)
            tst.b      $02(a6)
.\@         btst       #6,$02(a6)
            bne.b      .\@
            move.w     #BLITPRI_DISABLE,DMACON(a6)
            ENDM

WAITBLITP	MACRO
            move.w     #BLITPRI_ENABLE,DMACON(a6)
            tst.b      $02(a6)
.\@         btst       #6,$02(a6)
            bne.b      .\@
            move.w     #BLITPRI_DISABLE,DMACON(a6)
            ENDM

** push and pops

PUSH MACRO
            move.l     \1,-(sp)
            ENDM

POP MACRO
            move.l     (sp)+,\1
            ENDM

PUSHM MACRO
            movem.l    \1,-(sp)
            ENDM

POPM MACRO
            movem.l    (sp)+,\1
            ENDM

PUSHMOST MACRO
            movem.l    d0-a4,-(sp)
            ENDM

POPMOST MACRO
            movem.l    (sp)+,d0-a4
            ENDM

PUSHALL MACRO
            movem.l    d0-a6,-(sp)
            ENDM

POPALL MACRO
            movem.l    (sp)+,d0-a6
            ENDM

** Loads planes to existing copper list

PLANE_TO_COPPER MACRO
            move.w     \1,6(\2)
            swap       \1
            move.w     \1,2(\2)
            swap       \1
            ENDM

** Loads long pointers to copper

LONGTOCOPPER MACRO
            REPT       \3
            move.w     \1,6(\2)
            swap       \1
            move.w     \1,2(\2)
            swap       \1
            addq.l     #8,\2
            ENDR
            ENDM


     

** Loads long pointers to copper with addition
; 1 = data reg pointer to address
; 2 = address reg in copper
; 3 = number of runs
; 4 = value to add each run

LONGTOCOPPERADD MACRO
            REPT       \3
            move.w     \1,6(\2)
            swap       \1
            move.w     \1,2(\2)
            swap       \1
            addq.l     #8,\2
            add.l      \4,\1
            ENDR
            ENDM

** min

MIN     MACRO
            cmp.w      \1,\2
            bls.b      .\@skip
            move.w     \1,\2
.\@skip
            ENDM

** max

MAX     MACRO
            cmp.w      \1,\2
            bgt.b      .\@skip
            move.w     \1,\2
.\@skip
            ENDM

** get nibble
** 1 = address point
** 2 = index data
** 3 = result

GETNIBBLE MACRO
            move.w     \2,\3
            lsr.w      #1,\3
            move.b     (\1,\3.w),\3
            btst       #0,\2
            beq.b      .\@first
            and.b      #$0f,\3
            bra        .\@done
.\@first    lsr.w      #4,\3
.\@done
            ENDM



** jump index
** 1 = index

JMPINDEX MACRO
            add.w      \1,\1
            move.w     .\@jmplist(pc,\1.w),\1
            jmp        .\@jmplist(pc,\1.w)
.\@jmplist
            ENDM


** jump index
** 1 = address point
** 2 = index

;JMPINDEX MACRO
;            and.w      #$00ff,\2
;            add.w      \2,\2
;            add.w      \2,\2
;            move.l     (\1,\2.w),\1
;            jmp        (\1)
;            ENDM

SKIPFRAME MACRO
            btst       #0,TickCounter(a5)
            beq        .\@doframe
            rts
.\@doframe
            ENDM

** jump index
** 1 = address point
** 2 = index

JSRINDEX MACRO
            and.w      #$00ff,\2
            add.w      \2,\2
            add.w      \2,\2
            move.l     (\1,\2.w),\1
            jsr        (\1)
            ENDM

** Z80 replica instruction
** dec \1, if zero branch to \2
DJNZ MACRO
            subq.b     #1,\1
            beq.b      .\@exit
            bra        \2
.\@exit
            ENDM
** pointer rotate long  
** 1 = address register
** 2 = count

ROTATE_LONG MACRO 

            ifeq       \2-7
            move.l     (\2-1)*4(\1),d7
            movem.l    (\1)+,d0/d1/d2/d3/d4/d5
            addq.l     #4,\1
            movem.l    d0/d1/d2/d3/d4/d5,-(\1)
            move.l     d7,-(\1)
            endif

            ifeq       \2-6
            move.l     (\2-1)*4(\1),d7
            movem.l    (\1)+,d0/d1/d2/d3/d4
            addq.l     #4,\1
            movem.l    d0/d1/d2/d3/d4,-(\1)
            move.l     d7,-(\1)
            endif

            ifeq       \2-5
            move.l     (\2-1)*4(\1),d7
            movem.l    (\1)+,d0/d1/d2/d3
            addq.l     #4,\1
            movem.l    d0/d1/d2/d3,-(\1)
            move.l     d7,-(\1)
            endif

            ifeq       \2-4
            move.l     (\2-1)*4(\1),d7
            movem.l    (\1)+,d0/d1/d2
            addq.l     #4,\1
            movem.l    d0/d1/d2,-(\1)
            move.l     d7,-(\1)
            endif

            ifeq       \2-3
            move.l     (\2-1)*4(\1),d7
            movem.l    (\1)+,d0/d1
            addq.l     #4,\1
            movem.l    d0/d1,-(\1)
            move.l     d7,-(\1)
            endif

            ifeq       \2-2
            movem.l    (\1)+,d0/d1
            exg        d0,d1
            movem.l    d0/d1,-(\1)
            endif

            ENDM

DEBUG_CLICK MACRO
            move.w     d7,-(sp)
.\@click
            move.w     d7,$dff180
            subq.w     #1,d7
            btst       #6,$bfe001
            bne        .\@click
.\@release
            btst       #6,$bfe001
            beq        .\@release

            move.w     (sp)+,d7
            ENDM


DEBUG_ME MACRO
            move.w     d7,-(sp)
            move.w     #$100,d7
.\@color    move.w     d7,$dff180
            dbra       d7,.\@color
            move.w     (sp)+,d7
            ENDM


DEBUG_STOP MACRO
            move.w     d7,-(sp)
.\@stopit
            move.w     #$100,d7
.\@color    move.w     d7,$dff180
            dbra       d7,.\@color
            bra        .\@stopit    
            move.w     (sp)+,d7
            ENDM


** pointer rotate long  
** 1 = address register
** 2 = count

ROTATE_WORD MACRO 

            ifeq       \2-7
            move.w     (\2-1)*2(\1),d7
            movem.w    (\1)+,d0/d1/d2/d3/d4/d5
            addq.l     #2,\1
            movem.w    d0/d1/d2/d3/d4/d5,-(\1)
            move.w     d7,-(\1)
            endif

            ifeq       \2-6
            move.w     (\2-1)*2(\1),d7
            movem.w    (\1)+,d0/d1/d2/d3/d4
            addq.l     #2,\1
            movem.w    d0/d1/d2/d3/d4,-(\1)
            move.w     d7,-(\1)
            endif

            ifeq       \2-5
            move.w     (\2-1)*2(\1),d7
            movem.w    (\1)+,d0/d1/d2/d3
            addq.l     #2,\1
            movem.w    d0/d1/d2/d3,-(\1)
            move.w     d7,-(\1)
            endif

            ifeq       \2-4
            move.w     (\2-1)*2(\1),d7
            movem.w    (\1)+,d0/d1/d2
            addq.l     #2,\1
            movem.w    d0/d1/d2,-(\1)
            move.w     d7,-(\1)
            endif

            ifeq       \2-3
            move.w     (\2-1)*2(\1),d7
            movem.w    (\1)+,d0/d1
            addq.l     #2,\1
            movem.w    d0/d1,-(\1)
            move.w     d7,-(\1)
            endif

            ifeq       \2-2
            movem.w    (\1)+,d0/d1
            exg        d0,d1
            movem.w    d0/d1,-(\1)
            endif


            ENDM



; divide with 16:16 result
; \1 = value
; \2 = divider
; \3 = result
; \4 = temp1
; \5 = temp2

DIVIDE32 MACRO
            movem.l    \1/\2/\4/\5,-(sp)
            swap       \1                                      ; move val << 16
            divu       \2,\1                                   ; divide
            bvc.b      .\@ready                                ; has worked, go lets go

            swap       \1                                      ; do manual division
            move.w     \1,\5                                   ; backup original value
            divu       \2,\1
            swap       \1                                      ; move main to upper
            moveq      #0,\4                                   ; clear fraction temp
            move.w     \1,\4                                   ; move in fraction

            mulu.w     #$8000,\4                               ; mul up
            divu.w     \5,\4                                   ; divide by original
            asl.w      #1,\4                                   ; shift up now we have decimal
            move.w     \4,\1
            bra.b      .\@go
             
.\@ready    swap       \1
            clr.w      \1
            swap       \1

.\@go         
            move.l     \1,\3                                   ; move result
            movem.l    (sp)+,\1/\2/\4/\5
            endm
