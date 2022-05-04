;----------------------------------------------------------------------------
;
; boss 1 (witch)
;
;----------------------------------------------------------------------------

    include     "common.asm"

Boss1Logic:                                 
    moveq       #0,d0
    move.b      BossStatus(a5),d0
    bne         .run
    rts
.run
    subq.b      #1,d0
    JMPINDEX    d0

Boss1Index:
    dc.w        BossLoad-Boss1Index                  ; Boss1Load-Boss1Index
    dc.w        BossWitchSetup-Boss1Index            ; Boss1Approach-Boss1Index
    dc.w        Boss1MoveAttack-Boss1Index           ; Boss1MoveAttack-Boss1Index
    dc.w        BossDeathFlash-Boss1Index            ;  this is a spacer
    dc.w        BossDeathFlash-Boss1Index            ; Boss1Attack-Boss1Index  ; this was not labelled right
    dc.w        BossFireDeath1-Boss1Index            ; BossFireDeath1-Boss1Index
    dc.w        BossFireDeath2-Boss1Index            ; BossFireDeath2-Boss1Index
    dc.w        Boss1Dummy-Boss1Index                ; BossFireDeath3-Boss1Index

Boss1Dummy:
    rts

BossLoad:                                  
    bsr         BossClearParams

    moveq       #0,d0
    move.b      BossId(a5),d0
    add.w       d0,d0
    add.w       d0,d0
    lea         BossStartPos,a0
    add.l       d0,a0
    move.w      (a0)+,BossPosY(a5)
    move.w      (a0)+,BossPosX(a5)

    bsr         BobAllocate
    move.l      a4,BossBobSlotPtr(a5)

    moveq       #0,d0
    move.b      BossPosY(a5),d0
    move.w      d0,Bob_Y(a4)
    move.b      BossPosX(a5),d0
    move.w      d0,Bob_X(a4)

    move.l      BossBobPtrs(a5),a0
    BOBSET      a0,a4
    sf          Bob_Hide(a4)

    ; 2nd bob for big knight and sumo attack (leave it hidden)
    bsr         BobAllocate
    move.l      a4,BossBobSlotPtr2(a5)

    BOBSET      a0,a4
    moveq       #0,d0
    move.b      BossPosY(a5),d0
    add.b       #$8,d0
    move.w      d0,Bob_Y(a4)
    move.b      BossPosX(a5),d0
    add.b       #$8,d0
    move.w      d0,Bob_X(a4)


    ; shadow bob slot
    bsr         BobAllocate
    move.l      a4,BossBobShadowSlotPtr(a5)

    moveq       #0,d0
    move.b      BossPosY(a5),d0
    move.w      d0,Bob_Y(a4)
    move.b      BossPosX(a5),d0
    move.w      d0,Bob_X(a4)

    bsr         LoadBossHealth

    move.b      #120,BossTimer(a5)

    addq.b      #1,BossStatus(a5)
    move.b      #1,BossIsSafe(a5)

    rts

BossWitchSetup:                              
    bsr         SkullBossShadow

    bsr         SetHealthBar

    subq.b      #1,BossTimer(a5)
    bne         .skip

    bsr         BossSetMoveSpeed

    clr.b       BossIsSafe(a5)
    addq.b      #1,BossStatus(a5)
.skip
    rts



Boss1MoveAttack: 
    bsr         SkullBossShadow

    bsr         BossAnimate2

    bsr         SumoAttack
    
    bsr         RedKnightHelmet

    bsr         BossEnemyLogic

    bsr         PlayerShotBossLogic
    tst.b       BossDeathFlag(a5)
    bne         KillBoss

    move.b      TickCounter(a5),d0
    and.b       #$1f,d0
    bne         .skipshot
    
    lea         BossFakeEnemy(a5),a2                 ; fake enemy structure for shot coords
    move.b      BossPosY(a5),d0
    add.b       #$c,d0
    move.b      d0,ENEMY_PosY(a2)

    move.b      BossPosX(a5),d0
    add.b       #$14,d0
    move.b      d0,ENEMY_PosX(a2)

    moveq       #0,d0
    move.b      BossId(a5),d0
    lea         BossShotType,a0
    move.b      (a0,d0.w),d0
    bsr         AddEnemyShot
    
.skipshot
    move.b      BossTimer(a5),d0
    tst.b       BossTimer(a5)
    bne         DecBossTimerSetSpeed

    move.b      BossPosX(a5),d0
    and.b       #$fc,d0
    add.b       #$c,d0

    move.b      BossDestX(a5),d1
    cmp.b       BossDestXOffset(a5),d0
    beq         SetBossTimer50

    move.w      BossPosX(a5),d0
    add.w       BossSpeedX(a5),d0

    moveq       #1,d3                                ; hit edge flag
    cmp.w       #$2000,d0
    bcc         .inrangeleft
    move.b      #$50,BossDestX(a5)
    bra         .hitedge
.inrangeleft
    cmp.w       #$b800,d0
    bcs         .inrangeright
    move.b      #$88,BossDestX(a5)
    bra         .hitedge

.inrangeright
                        
.setpos
    move.w      d0,BossPosX(a5)
    moveq       #0,d3                                ; not hit edge
.hitedge
    move.l      BossBobSlotPtr(a5),a4
    moveq       #0,d0
    move.b      BossPosY(a5),d0
    move.w      d0,Bob_Y(a4)

    moveq       #0,d1
    move.b      BossPosX(a5),d1
    move.w      d1,Bob_X(a4)

    tst.b       d3
    beq         .notedge

    tst.b       BossId(a5)
    beq         SetBossTimer50

    neg.w       BossSpeedX(a5)
    move.b      BossDestX(a5),BossDestXOffset(a5)

.notedge
    cmp.b       #4,BossId(a5)
    beq         .bigknight
.exit    
    rts

.bigknight  
    move.l      BossBobSlotPtr2(a5),a4
    add.w       #8,d0
    move.w      d0,Bob_Y(a4)
    add.w       #8,d1
    move.w      d1,Bob_X(a4)
    rts

SetBossTimer50:
    move.b      #$50,BossTimer(a5)
    rts


KillBoss:
    bsr         ClearAllSprites
    
    moveq       #0,d0
    moveq       #MOD_BOSSDEATH,d1
    bsr         MusicSet
    
    move.b      #1,SfxDisable(a5)

    move.b      #5,BossStatus(a5)
    cmp.b       #7,BossId(a5)
    bne         .noteyes
    addq.b      #1,BossStatus(a5)

.noteyes
    move.b      #$40,BossDeathTimer(a5)
    bra         KillEnemyShots                       ; remove all shots



BossDeathFlash:                                
    move.w      #$000,d2
    move.b      TickCounter(a5),d0
    and.b       #2,d0
    beq         .black
    move.w      #$ddd,d2                             ; flash
.black
    subq.b      #1,BossDeathTimer(a5)
    bne         .setcolor
    moveq       #0,d2

    move.w      d2,MainPalette(a5)
    move.w      #2,PaletteDirty(a5)

    addq.b      #1,BossStatus(a5)
    move.b      #60,BossDeathTimer(a5)               ; fire time
    ; remove boss bobs
    move.l      BossBobSlotPtr(a5),a4
    clr.b       Bob_Allocated(a4)

    move.l      BossBobSlotPtr2(a5),a4
    clr.b       Bob_Allocated(a4)

    move.l      BossBobShadowSlotPtr(a5),a4
    clr.b       Bob_Allocated(a4)

    bsr         RemoveAllEnemyBoss                   ; remove all enemys
    clr.b       SfxDisable(a5)
    rts    

.setcolor
    move.w      d2,MainPalette(a5)
    move.w      #2,PaletteDirty(a5)
.exit
    rts



BossFireDeath1:
    sub.b       #1,BossDeathTimer(a5)
    beq         .next

    move.b      TickCounter(a5),d0
    and.b       #3,d0
    bne         .skip
    
    moveq       #0,d2 
    moveq       #0,d3
    move.b      BossPosY(a5),d2
    move.b      BossPosX(a5),d3
    bra         AddFireEnemy

.next
    addq.b      #1,BossStatus(a5)
    move.b      #30,BossDeathTimer(a5)
.skip
    rts

BossFireDeath2:
    subq.b      #1,BossDeathTimer(a5)
    bne         .exit
    move.b      #1,BossDeadFlag(a5)
.exit
    rts
