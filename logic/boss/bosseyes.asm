;----------------------------------------------------------------------------
;
; boss 8 (eyes)
;
;----------------------------------------------------------------------------

    include             "common.asm"

EyesBossLogic:                                    ; ...
    moveq               #0,d0
    move.b              BossStatus(a5),d0
    bne                 .run
    rts
.run
    subq.b              #1,d0
    JMPINDEX            d0

EyesBossIndex:
    dc.w                EyesBossLoad-EyesBossIndex
    dc.w                EyesBossSetup-EyesBossIndex
    dc.w                EyesBossSetSpeed-EyesBossIndex
    dc.w                EyesBossMove-EyesBossIndex
    dc.w                EyesBossWaitReset-EyesBossIndex
    dc.w                BossDeathFlash-EyesBossIndex    
    dc.w                BossFireDeath1-EyesBossIndex     
    dc.w                BossFireDeath2-EyesBossIndex     
    dc.w                Boss1Dummy-EyesBossIndex         

EyesBossLoad:
    bsr                 BossLoad
    clr.b               EyeDeathCount(a5)
    rts

EyesBossSetup:
    bsr                 SkullBossShadow

    bsr                 SetHealthBar

    subq.b              #1,BossTimer(a5)
    bne                 .skip

    bsr                 InitEyes

    bsr                 BossSetMoveSpeed
    clr.b               BossIsSafe(a5)
    addq.b              #1,BossStatus(a5)
.skip
    rts

EyesBossSetSpeed: 
    ;move.b              #1,BossDeathFlag(a5)               ; TODO: remove
    ;bra                 KillBoss
    
    bsr                 SkullBossShadow
    addq.b              #1,BossStatus(a5)
    rts

EyesBossMove:
    ;call        DecBossDeathTimer             ; decrements the boss auto death timer
    bsr                 SkullBossShadow

    bsr                 .run
    bra                 ProcessEyes
.run    
    bsr                 BossEnemyLogic1
    
    move.b              BossTimer(a5),d0
    tst.b               BossTimer(a5)
    bne                 DecBossTimerSetSpeed

    bsr                 BossAnimateQuick

    move.b              BossPosX(a5),d0
    and.b               #$fc,d0
    add.b               #$c,d0

    move.b              BossDestX(a5),d1
    cmp.b               BossDestXOffset(a5),d0
    beq                 SetBossTimer50

    move.w              BossPosX(a5),d0
    add.w               BossSpeedX(a5),d0

    moveq               #1,d3                              ; hit edge flag
    cmp.w               #$2000,d0
    bcc                 .inrangeleft
    move.b              #$50,BossDestX(a5)
    bra                 .hitedge
.inrangeleft
    cmp.w               #$b000,d0
    bcs                 .inrangeright
    move.b              #$80,BossDestX(a5)
    bra                 .hitedge

.inrangeright

    move.w              d0,BossPosX(a5)
    moveq               #0,d3                              ; not hit edge
.hitedge
    move.l              BossBobSlotPtr(a5),a4
    moveq               #0,d0
    move.b              BossPosY(a5),d0
    move.w              d0,Bob_Y(a4)

    moveq               #0,d1
    move.b              BossPosX(a5),d1
    move.w              d1,Bob_X(a4)

    tst.b               d3
    beq                 .exit

    bra                 SetBossTimer50
.exit    
    rts

EyesBossWaitReset: 
    rts

;----------------------------------------------------------------------------
;
; init the eye structures
;
;----------------------------------------------------------------------------

InitEyes:
    lea                 EyeList(a5),a2
    moveq               #EYE_COUNT-1,d7
    lea                 EyeOffsetList,a0
.loop
    move.b              #1,EYE_Status(a2)
    move.b              (a0)+,EYE_TimerOffset(a2)
    move.b              (a0)+,EYE_OffsetY(a2)
    move.b              (a0)+,EYE_OffsetX(a2)

    move.b              #$14,EYE_MaxHits(a2)
    clr.b               EYE_HitCount(a2)
    move.b              #-1,EYE_BobIdPrev(a2)

    RANDOM
    move.b              d0,EYE_Random(a2)

    lea                 EyeBobPtrs(a5),a1
    move.l              a1,EYE_BobPtr(a2)

    bsr                 BobAllocate
    move.w              d0,EYE_BobSlot(a2)

    lea                 EYE_Sizeof(a2),a2
    dbra                d7,.loop

    clr.b               EyeList+EYE_Status(a5)             ; disable last eye
    move.b              #1,EyeList+EYE_Hide(a5)

    rts

; +0 = timer offset
; +1 = offset y
; +2 = offset x

EyeOffsetList:
    dc.b                $80, $FC, $10                      ; ...
    dc.b                $30, 2, 3                          ; eye sprite offset list
    dc.b                $70, 2, $1D                        ;
    dc.b                $A0, $C, $10                       ; +0 = offset y
    dc.b                $80, $12, 3                        ; +1 = offset x
    dc.b                $E0, $12, $1D
    even

;----------------------------------------------------------------------------
;
; update position and image of eye bobs
;
;----------------------------------------------------------------------------

UpdateEyeBob:
    move.w              EYE_BobSlot(a2),d4
    lea                 (a4,d4.w),a3

    tst.b               EYE_Hide(a2)
    bne                 .hide

    moveq               #0,d0
    move.b              BossPosY(a5),d0
    add.b               EYE_OffsetY(a2),d0
    move.w              d0,Bob_Y(a3)

    moveq               #0,d0
    move.b              BossPosX(a5),d0
    add.b               EYE_OffsetX(a2),d0
    cmp.b               #5,EYE_Status(a2)
    bne                 .notonfire
    add.b               #8,d0
.notonfire
    move.w              d0,Bob_X(a3)

    moveq               #0,d0
    move.b              EYE_BobId(a2),d0
    cmp.b               EYE_BobIdPrev(a2),d0
    beq                 .exit

    ;cmp.b               #4,d0
    ;bcc                 .hide

    sf                  Bob_Hide(a3)
    move.b              d0,EYE_BobIdPrev(a2)
    add.w               d0,d0
    add.w               d0,d0
    move.l              EYE_BobPtr(a2),a0
    move.l              (a0,d0.w),a0
    BOBSET              a0,a3
.exit
    rts

.hide
    st                  Bob_Hide(a3)
    rts



;----------------------------------------------------------------------------
;
; loop eyes processing animation and collision logic
;
;----------------------------------------------------------------------------

ProcessEyes:                                      ; ...
    ;ld          a, (BossStatus)
    ;cp          3
    ;jr          c, ProcessEyesSkip
    ;ld          ix, EyeBossEyes
    ;ld          b, 6
    ;ld          de, 10h
    
    ;cmp.b               #3,BossStatus(a5)
    ;bcs                 .skip

    lea                 BobMatrix(a5),a4
    lea                 EyeList(a5),a2
    moveq               #EYE_COUNT-1,d7

;ProcessEyesLoop:                                  ; ...
.loop
    ;exx
    ;call        EyeBossEyeLogic
    bsr                 EyeLogic
    bsr                 UpdateEyeBob
    ;exx
    ;add         ix, de
    ;djnz        ProcessEyesLoop
    lea                 EYE_Sizeof(a2),a2
    dbra                d7,.loop

;ProcessEyesSkip:                                  ; ...
.skip
    ;jp          EyeBossUpdateSprites
    rts


;----------------------------------------------------------------------------
;
; eye logic
;
; a2 = eye structure
; a4 = bob matrix
;
;----------------------------------------------------------------------------

EyeLogic:
    ;ld          a, (ix+EYE.Status)
    ;dec         a
    ;ret         m                                  ; status 0 then quit
    ;call        JumpIndex_A
    moveq               #0,d0
    move.b              EYE_Status(a2),d0
    subq.b              #1,d0
    bpl                 .ok
    rts
.ok
    JMPINDEX            d0

EyeLogicIndex:
    dc.w                EyeLeftRight-EyeLogicIndex
    dc.w                EyeClose-EyeLogicIndex
    dc.w                EyeWaitOpen-EyeLogicIndex
    dc.w                EyeWaitReset-EyeLogicIndex
    dc.w                EyeFireDeath-EyeLogicIndex
    dc.w                EyeDeath-EyeLogicIndex

EyeLeftRight:
    bsr                 EyeCheckCollision
    bsr                 EyeShotLogic

    moveq               #0,d0
    move.b              EYE_Random(a2),d1
    add.b               TickCounter(a5),d1
    btst                #4,d1
    beq                 .skip
    addq.b              #1,d0
.skip
    move.b              d0,EYE_BobId(a2)

    addq.b              #1,EYE_Timer(a2)
    move.b              EYE_Timer(a2),d0
    cmp.b               EYE_TimerOffset(a2),d0
    bne                 .exit
    addq.b              #1,EYE_Status(a2)
    move.b              #4,EYE_Timer(a2)
    move.b              #2,EYE_BobId(a2)
.exit
    rts
    
EyeClose:
    bsr                 EyeCheckCollision
    subq.b              #1,EYE_Timer(a2)
    bne                 .exit
    move.b              #1,EYE_Hide(a2)
    addq.b              #1,EYE_Status(a2)
    move.b              #$20,EYE_Timer(a2)
.exit
    rts

EyeWaitOpen:
    subq.b              #1,EYE_Timer(a2)
    bne                 .exit
    clr.b               EYE_Hide(a2)
    move.b              #-1,EYE_BobIdPrev(a2)
    addq.b              #1,EYE_Status(a2)
    move.b              #4,EYE_Timer(a2)
.exit
    rts

EyeWaitReset:
    bsr                 EyeCheckCollision
    subq.b              #1,EYE_Timer(a2)
    bne                 .exit
    move.b              #1,EYE_Status(a2)
    clr.b               EYE_Timer(a2)
.exit
    rts


EyeFireDeath: 
    lea                 FireDeathBobPtrs(a5),a0
    move.l              a0,EYE_BobPtr(a2)

    moveq               #0,d0
    move.b              EYE_FireCounter(a2),d0
    btst                #0,TickCounter(a5)
    beq                 .frameone
    addq.b              #1,d0

.frameone
    move.b              d0,EYE_BobId(a2)
    subq.b              #1,EYE_Timer(a2)
    bne                 .exit

    move.b              #6,EYE_Timer(a2)    
    addq.b              #1,EYE_FireCounter(a2)
    cmp.b               #5,EYE_FireCounter(a2)
    bcs                 .exit

    addq.b              #1,EYE_Status(a2)

    move.b              #3,EYE_BobId(a2)
    move.b              #-1,EYE_BobIdPrev(a2)
    lea                 EyeBobPtrs(a5),a1
    move.l              a1,EYE_BobPtr(a2)
.exit
    rts 

EyeDeath: 
    move.b              EyeDeathCount(a5),d0
    cmp.b               #5,d0
    bcs                 .exit

    cmp.b               #6,d0
    bne                 .activatelast

    move.w              #20000,d0
    bsr                 AddScore

    move.b              #1,BossDeathFlag(a5)
    bra                 KillBoss

.activatelast
    move.b              #1,EyeList+EYE_Status(a5)
    clr.b               EyeList+EYE_Hide(a5)
.exit
    clr.b               EYE_Status(a2)
    rts


;----------------------------------------------------------------------------
;
; eye player shot collision logic
;
;----------------------------------------------------------------------------

EyeCheckCollision:
    lea                 PlayerShot1(a5),a1
    moveq               #3-1,d5
.loop
    btst                #7,PLAYERSHOT_Status(a1)
    bne                 .next

    GETPLAYERSHOTDIM    a1,a0
    moveq               #0,d1
    move.b              BossPosX(a5),d1
    add.b               EYE_OffsetX(a2),d1
    addq.b              #1,d1
    swap                d1
    move.b              BossPosY(a5),d1
    add.b               EYE_OffsetY(a2),d1
    addq.b              #4,d1
    move.l              #$000e0008,d2
    CHECKCOLLISION
    bcs                 .next
    ; eye hit

    bset                #7,PLAYERSHOT_Status(a1)
    ;move.w              PLAYERSHOT_BobSlot(a1),d4
    ;clr.b               Bob_Allocated(a4,d4.w)

    moveq               #0,d0
    move.b              PLAYERSHOT_WeaponId(a1),d0
    lsr.b               #1,d0

    move.b              EYE_HitCount(a2),d1
    add.b               EyeShotHitPoints(pc,d0.w),d1
    cmp.b               EYE_MaxHits(a2),d1
    bcs                 .storehit

    move.b              EYE_MaxHits(a2),d1                 ; setup fire sprites
    move.b              #5,EYE_Status(a2)
    clr.b               EYE_FireCounter(a2)
    move.b              #6,EYE_Timer(a2)
    move.b              #-1,EYE_BobIdPrev(a2)
    lea                 FireDeathBobPtrs(a5),a0
    move.l              a0,EYE_BobPtr(a2)

    addq.b              #1,EyeDeathCount(a5)

    move.b              d1,EYE_HitCount(a2)                ; killed
    moveq               #$d,d0
    bsr                 SfxPlay
    bra                 .next

.storehit
    move.b              d1,EYE_HitCount(a2)                ; hit
    moveq               #$37,d0
    bsr                 SfxPlay

    bsr                 CalcEyeBossHealth
.next
    lea                 PLAYERSHOT_Sizeof(a1),a1
    dbra                d5,.loop
    rts

EyeShotHitPoints:                                 ; ...
    dc.b                1, 1, 1, 2, 2, 2
    even

;----------------------------------------------------------------------------
;
; eye shot logic
;
;----------------------------------------------------------------------------

EyeShotLogic:                                     ; ...
    ;ld                  a, (ix+EYE.AnimId)
    ;and                 0FBh
    ;cp                  2
    ;ret                 nz
    tst.b               EYE_Hide(a2)
    bne                 .exit

    ;ld                  a, (BossAttackParams)
    ;ld                  c, 3Fh                             ; '?'                      ; shot timer and
    ;cp                  2
    ;jr                  c, EyeShotLogic1
    ;ld                  c, 1Fh                             ; shot timer and
    ;cp                  4
    ;jr                  c, EyeShotLogic1
    ;ld                  c, 0Fh                             ; shot timer and

    move.b              EyeDeathCount(a5),d0
    moveq               #$3f,d1
    cmp.b               #2,d0
    bcs                 .setshot
    moveq               #$1f,d1
    cmp.b               #4,d0
    bcs                 .setshot
    moveq               #$f,d1

.setshot
;EyeShotLogic1:                                    ; ...
    ;ld                  a, (ix+EYE.Timer)
    ;and                 c                                  ; and c to timer
    ;ret                 nz                                 ; no shot this time
    move.b              EYE_Timer(a2),d0
    and.b               d1,d0
    bne                 .exit

    ;ld                  hl, EyeEnemyTempY                  ; pre-load temp area with y / x data
    ;ld                  a, (ix+EYE.OffsetY)
    ;add                 a, 9
    ;ld                  (hl), a                            ; store temp y
    ;inc                 hl
    ;inc                 hl
    ;ld                  a, (ix+EYE.OffsetX)
    ;add                 a, 6
    ;ld                  (hl), a                            ; store temp x
    ;push                ix
    ;exx
    ;push                bc
    ;push                de
    ;push                hl
    ;ld                  ix, EyeEnemyTemp                   ; temp eye position info which is used to add the shot
    lea                 BossFakeEnemy(a5),a1
    
    move.b              BossPosY(a5),d0
    add.b               EYE_OffsetY(a2),d0
    add.b               #9,d0
    move.b              d0,ENEMY_PosY(a1)

    move.b              BossPosX(a5),d0
    add.b               EYE_OffsetX(a2),d0
    add.b               #6,d0
    move.b              d0,ENEMY_PosX(a1)

    ;ld                  b, 0Eh                             ; shot type
    ;call                AddEnemyShot                       ; add enemy shot
    exg                 a1,a2
    moveq               #$e,d0
    PUSHMOST
    bsr                 AddEnemyShot
    POPMOST
    exg                 a1,a2
.exit    
    rts