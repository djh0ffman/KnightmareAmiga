;----------------------------------------------------------------------------
;
; boss 1 (witch)
;
;----------------------------------------------------------------------------

    include     "common.asm"

Boss1Logic:                                    ; ...
    ;ld         a, (BossStatus)
    ;dec        a
    ;ret        m
    ;cp         2
    ;jr         nz, TileBossSkipDraw
    ;push       af
    ;call       DrawTileBoss
    ;pop        af
;    call       JumpIndex_A
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

BossLoad:                                     ; ...
    ;ld          hl, BossParams
    ;ld          de, BossParams+1
    ;ld          bc, 3Fh                    ; '?'
    ;ld          (hl), 0
    ;ldir                                   ; clear boss params
    ;ld          a, 0D8h                    ; boss start y
    ;ld          (BossPosY), a
    ;ld          a, 70h                     ; 'p'                      ; boss start x
    ;ld          (BossPosX), a
    ;ld          a, (BossId)
    ;ld          hl, TileBossIdList
    ;call        ADD_A_HL
    ;ld          a, (hl)
    ;ld          (TileBossId), a
    ;ld          hl, TIleBossDeathTimers
    ;call        ADD_AX2_HL_LDHL
    ;ld          (BossDeathTimer), hl
    ;ld          a, 80h
    ;ld          (BossAttackParams), a
    bsr         BossClearParams

    ;moveq       #0,d0
    ;move.b      BossId(a5),d0
    ;add.w       d0,d0
    ;add.w       d0,d0
    ;lea         BossBobList,a0
    ;move.l      (a0,d0.w),a0

    ;lea         BossBobPtrs(a5),a1
    ;bsr         SetDataPointers

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

BossWitchSetup:                                 ; ...
    bsr         SkullBossShadow
    ;ld          a, (GameFrame)
    ;and         3Fh                      ; '?'
    ;cp          1
    ;ret         nz
    ;ld          hl, BossPosY
    ;ld          a, (hl)
    ;add         a, 8
    ;ld          (hl), a
    ;ret         m
    ;cp          20h                      ; ' '
    ;ret         c
    ;call        ClearTileBoss            ; clears the tile boss from the screen as
                                                  ; tile bosses are integrated into the map data
                                                  ;
    ;call        TileBossSetMoveSpeed     ; sets the tile boss move speed
                                                  ; there are three different speeds depending on
                                                  ; distance to the player
    bsr         SetHealthBar

    subq.b      #1,BossTimer(a5)
    bne         .skip

    bsr         BossSetMoveSpeed
    ;jp          NextBossStatus
    ;cmp.b       #$d8,LevelPosition(a5)
    ;bne         .skip
    clr.b       BossIsSafe(a5)
    addq.b      #1,BossStatus(a5)
.skip
    rts



Boss1MoveAttack: 
    bsr         SkullBossShadow
    ;call        DecBossDeathTimer             ; decrements the boss auto death timer
    ;                                              ; tests value to set carry
    ;                                              ;
    ;jr          z, KillBoss_                  ; boss status
    ;ld          a, (GameFrame)
    ;bit         4, a
    ;ld          a, 0
    ;jr          z, TileBossMoveAttack1
    ;inc         a

;TileBossMoveAttack1: 
    ;ld          (TileBossAnimId1), a
    bsr         BossAnimate2

    ;call        SumoBossAttackMove
    ;call        RedKnightAttackMove
    bsr         SumoAttack
    
    bsr         RedKnightHelmet
    ;call        BossEnemyLogic                ; process the cloud enemies in the boss stage
    bsr         BossEnemyLogic
    ;                                              ;
    ;                                              ; only present on certain stages
    ;call        PlayerShotBossLogic           ; checks if player shots hit boss
    ;                                              ; if boss is killed, return in carry flag
    bsr         PlayerShotBossLogic
    ;jr          nz, KillBoss_                 ; boss status
    tst.b       BossDeathFlag(a5)
    bne         KillBoss

    move.b      TickCounter(a5),d0
    and.b       #$1f,d0
    bne         .skipshot
    
    ;ld          a, (BossPosY)
    ;add         a, 0Ch
    ;ld          (byte_E583), a  ; shot offset
    lea         BossFakeEnemy(a5),a2                 ; fake enemy structure for shot coords
    move.b      BossPosY(a5),d0
    add.b       #$c,d0
    move.b      d0,ENEMY_PosY(a2)

    ;ld          a, (BossPosX)
    ;add         a, 0Ah
    ;ld          (byte_E585), a

    move.b      BossPosX(a5),d0
    add.b       #$14,d0
    move.b      d0,ENEMY_PosX(a2)

    ;ld          a, (TickCounter)
    ;and         1Fh
    ;jr          nz, TileBossMoveAttack2

    ;ld          a, (TileBossId)
    ;ld          hl, TileBossShotType
    ;call        ADD_A_HL
    ;ld          b, (hl)
    ;ld          ix, BossShotList
    ;call        AddEnemyShot                  ; add enemy shot
    moveq       #0,d0
    move.b      BossId(a5),d0
    lea         BossShotType,a0
    move.b      (a0,d0.w),d0
    bsr         AddEnemyShot
    
;TileBossMoveAttack2:                              ; ...
.skipshot
    ;ld          hl, BossTimer
    ;ld          a, (hl)
    ;or          a
    ;jr          nz, DecBossTimerSetSpeed
    move.b      BossTimer(a5),d0
    tst.b       BossTimer(a5)
    bne         DecBossTimerSetSpeed

    ;ld          hl, (BossPosXDec)
    ;ld          a, h
    ;and         0FCh
    ;add         a, 0Ch
    ;ld          c, a
    ;ld          a, (BossSpeedXTemp)
    ;cp          c
    ;jr          z, SetBossTimer50

    move.b      BossPosX(a5),d0
    and.b       #$fc,d0
    add.b       #$c,d0

    move.b      BossDestX(a5),d1
    cmp.b       BossDestXOffset(a5),d0
    beq         SetBossTimer50

    ;ld          de, (BossSpeedXDec)
    ;add         hl, de
    ;ld          (BossPosXDec), hl

    move.w      BossPosX(a5),d0
    add.w       BossSpeedX(a5),d0

    ;ld          a, h
    ;cp          20h                           ; ' '
    ;ld          h, 20h                        ; ' '
    ;ld          e, 50h                        ; 'P'
    ;jr          c, TileBossMoveAttack3
    moveq       #1,d3                                ; hit edge flag
    cmp.w       #$2000,d0
    bcc         .inrangeleft
    move.b      #$50,BossDestX(a5)
    bra         .hitedge
;    bra         SetBossTimer50
.inrangeleft
    ;cp          0BF
    ;ld          h, 0BFh
    ;ld          e, 88h
    ;ret         c
    cmp.w       #$b800,d0
    bcs         .inrangeright
    move.b      #$88,BossDestX(a5)
    ;bra         SetBossTimer50
    bra         .hitedge

.inrangeright
;TileBossMoveAttack3:                              ; ...
.setpos
    ;ld          (BossPosXDec), hl
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
    ;ld          a, (BossId)
    ;cp          0
    ;jr          z, SetBossTimer50
    tst.b       BossId(a5)
    beq         SetBossTimer50

    neg.w       BossSpeedX(a5)
    move.b      BossDestX(a5),BossDestXOffset(a5)
    ;ld          a, d
    ;neg
    ;ld          (BossSpeedX), a
    ;ld          a, e
    ;ld          (BossSpeedXTemp), a
    ;ret

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
    ; remove enemy shots
    ;ld          (BossStatus2), a
    ;ld          b, 0Ah
    ;ld          hl, EnemyShotList             ; remove enemy shots
    ;ld          de, 0Dh

;KillBossShotLoop:                                 ; ...
    ;ld          (hl), 0                       ; shot status
    ;inc         hl
    ;inc         hl
    ;inc         hl
    ;ld          (hl), 0E0h                    ; shot position (off screen)
    ;add         hl, de
    ;djnz        KillBossShotLoop              ; shot status
    ;call        UpdateBossEnemyShotAttRam
    ;ld          a, 40h                        ; '@'
    ;ld          (BossDeathTimer), a
.noteyes
    move.b      #$40,BossDeathTimer(a5)
    ;ld          a, 17h
    ;jp          
    bra         KillEnemyShots                       ; remove all shots



BossDeathFlash:                                   ; ...
    ;ld          a, (BossId)
    ;cp          5
    ;jr          nz, TileBossAttack1
    ;ld          hl, BossAttackParams
    ;bit         7, (hl)
    ;call        z, SumoBossAttack1

;TileBossAttack1:                                  ; ...
    ;call        BossDeathScreenFlash
    ;ld          hl, BossDeathTimer
    ;dec         (hl)
    ;ret         nz
    ;ld          (hl), 30h                     ; '0'
    ;call        BossSpritesToVram
    ;ld          a, (BossPosX)
    ;add         a, 12h
    ;ld          (BossPosX), a
    ;jp          loc_9299

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

    ;ld          b, 0E0h
    ;call        SetBkgColor                   ; ensure black background
    ;ld          a, 6Bh                        ; 'k'
    ;call        
    ;ld          bc, 5Fh                       ; '_'
    ;call        ClearEnemySprites
    ;jp          NextBossStatus
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
