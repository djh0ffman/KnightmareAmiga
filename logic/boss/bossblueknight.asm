;----------------------------------------------------------------------------
;
; boss 7 (blue knight)
;
;----------------------------------------------------------------------------

    include     "common.asm"

BossKnightsLogic:                                    ; ...
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

BossKnightsIndex:   
    dc.w        BossKnightsLoad-BossKnightsIndex           
    dc.w        BossKnightsSetup-BossKnightsIndex     
    dc.w        BossKnightsAttack-BossKnightsIndex    
    dc.w        BossDeathFlash-BossKnightsIndex     
    dc.w        BossDeathFlash-BossKnightsIndex     
    dc.w        BossFireDeath1-BossKnightsIndex     
    dc.w        BossFireDeath2-BossKnightsIndex     
    dc.w        Boss1Dummy-BossKnightsIndex   


BossKnightsLoad:
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
    ;sf          Bob_Hide(a4)

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

    lea         BossEnemy1(a5),a2
    bsr         EnemyClear

    rts

BossKnightsSetup:                                 ; ...
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

    move.l      BossBobSlotPtr(a5),a4
    st          Bob_Hide(a4)
    move.l      BossBobShadowSlotPtr(a5),a4
    st          Bob_Hide(a4)
    
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



BossKnightsAttack:
    lea         BobMatrix(a5),a4
    ;ld          a, (GameFrame)
    ;rra
    ;jr          c, loc_94B4
    ;call        UpdateEnemySprites
    ;ld          ix, BossParams
    lea         BossEnemy1(a5),a2

    ;ld          a, (GameFrame)
    ;cp          0Eh
    ;jr          nz, loc_946F
    cmp.b       #$e,GameFrame(a5)
    bne         .skipboss

    ;ld          a, (BossParams)
    ;or          a
    ;call        z, BossKnightsBossSetActive
    tst.b       ENEMY_Status(a2)
    beq         BossKnightsBossSetActive

;loc_946F:                                         ; ...
.skipboss
    ;call        WhiteKnightLogic
    bsr         WhiteKnightLogic

    ;ld          de, BossSpriteRamAtt2
    ;call        BossKnightsBossSpriteUpdate
    ;ld          ix, EnemyList                         ; blue knight boss enemy logic
    ;ld          b, 5
    lea         EnemyList(a5),a2
    moveq       #5-1,d7

;loc_947E:                                         ; ...
.loop
    ;ld          hl, BossKnightsBossEnemySpawnTimers
    ;ld          a, b
    ;call        ADD_A_HL
    ;ld          c, (hl)
    lea         KnightSpawnTimers,a0
    move.b      (a0,d7.w),d0

    ;inc         (ix+ENEMY_FrameCount)
    ;ld          a, (ix+ENEMY_FrameCount)
    ;cp          c
    ;jr          nz, loc_94A0

    btst        #0,TickCounter(a5)
    beq         .skipadd

    add.b       #1,ENEMY_FrameCount(a2)
    move.b      ENEMY_FrameCount(a2),d2
    cmp.b       ENEMY_FrameCount(a2),d0
    bne         .skipadd

    ;ld          a, (ix+ENEMY_Status)
    ;or          a
    ;jr          nz, loc_94A0
    tst.b       ENEMY_Status(a2)
    bne         .skipadd

    ;call        BossKnightsBossSetActive
    ;ld          (ix+ENEMY_Id), 9                      ; blue knight
    ;ld          (ix+ENEMY_SpriteSlotId), 0C0h
    bsr         BlueKnightSetActive
    move.b      #9,ENEMY_Id(a2)

;loc_94A0:                                         ; ...
.skipadd
    ;push        bc
    ;call        BossKnightsBossLogic
    tst.b       ENEMY_Status(a2)
    beq         .skiprun
    bsr         BlueKnightLogicBoss
    ;pop         bc
    ;push        bc
    ;call        EnemyPlayerShotLogic
    ;call        EnemyCollisionLogic
    bsr         EnemyPlayerShotLogic
    bsr         EnemyCollisionLogic
.skiprun
    ;ld          bc, 20h                               ; ' '
    ;add         ix, bc
    ;pop         bc
    ;djnz        loc_947E
    lea         ENEMY_Sizeof(a2),a2
    dbra        d7,.loop


;loc_94B4:                                         ; ...
    ;call        PlayerShotBossLogic                   ; checks if player shots hit boss
    ;jr          nz, loc_94C8
    lea         BossEnemy1(a5),a2
    move.b      ENEMY_PosY(a2),BossPosY(a5)
    move.b      ENEMY_PosX(a2),BossPosX(a5)
    bsr         PlayerShotBossLogic
    tst.b       BossDeathFlag(a5)
    bne         .killboss

    ;ld          a, (GameFrame)
    ;and         1Fh
    ;ret         nz
    ;ld          b, 1
    ;ld          ix, BossParams
    ;jp          AddEnemyShot                          ; add enemy shot
    lea         BossEnemy1(a5),a2
    cmp.b       #2,ENEMY_Status(a2)
    bne         .skipshot
    move.b      GameFrame(a5),d0
    and.b       #$1f,d0
    bne         .skipshot
    moveq       #1,d0                                    ; arrow
    bsr         AddEnemyShot
.skipshot
    rts

; ---------------------------------------------------------------------------


.killboss
;loc_94C8:                                         ; ...
    ;ld          a, 4
    ;call        KillBoss1
    ;ld          a, (BossPosY)
    ;sub         10h
    ;ld          (BossPosY), a
    ;ld          a, (BossPosX) 
    ;sub         10h
    ;ld          (BossPosX), a
    ;ret
    lea         BossEnemy1(a5),a2
    moveq       #0,d0
    moveq       #0,d1
    move.b      ENEMY_PosY(a2),d0
    move.b      ENEMY_PosX(a2),d1
    sub.b       #$10,d0                                  ; adjust position for flames
    sub.b       #$10,d1
    move.l      BossBobSlotPtr(a5),a4
    move.b      d0,Bob_Y(a4)
    move.b      d1,Bob_X(a4)

    PUSHMOST
    bsr         KillAllEnemy
    POPMOST
    
    bra         KillBoss

BossKnightsBossSetActive:
    lea         BossBobPtrs(a5),a1
    move.l      a1,ENEMY_BobPtr(a2)
    bra         BossKnightCreate

BlueKnightSetActive:
    move.l      EnemyBobLookup+(9*4)(a5),a1
    move.l      a1,ENEMY_BobPtr(a2)
    bsr         EnemyClear

BossKnightCreate:
    ;ld          (ix+ENEMY_Status), 1
    ;ld          (ix+ENEMY_PosY), 20h                     ; ' '
    ;ld          (ix+ENEMY_PosX), 7Eh                     ; '~'
    ;ret
    move.b      #3,ENEMY_HitPoints(a2)
    move.b      #1,ENEMY_Status(a2)
    clr.w       ENEMY_PosY(a2)
    move.w      #$7e00,ENEMY_PosX(a2)
    move.w      #$100,ENEMY_SpeedY(a2)
    clr.w       ENEMY_SpeedX(a2)
    move.w      #-1,ENEMY_ShadowSlot(a2)
    move.w      #-1,ENEMY_BobSlot2(a2)

    RANDOM
    move.b      d0,ENEMY_Random(a2)

    PUSH        a4
    bsr         BobAllocate
    move.w      d0,ENEMY_BobSlot(a2)



    moveq       #0,d0
    move.b      ENEMY_PosY(a2),d0
    move.w      d0,Bob_Y(a4)
    move.b      ENEMY_PosX(a2),d0
    move.w      d0,Bob_X(a4)
    move.w      #$16,Bob_TopMargin(a4)

    sf          Bob_Hide(a4)
    POP         a4
    rts

; ---------------------------------------------------------------------------
;
; white knight boss logic
;
; ---------------------------------------------------------------------------

BlueKnightLogicBoss:
    lea         BobMatrix(a5),a4
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    bpl         .doit
    rts
.doit
    JMPINDEX    d0

BlueKnightIndex2:
    dc.w        BlueKnightApproach-BlueKnightIndex2
    dc.w        BlueKnightRun-BlueKnightIndex2
    dc.w        BlueKnightRun-BlueKnightIndex2
    dc.w        EnemyFireDeath-BlueKnightIndex2          ;EnemyFireDeath1-BlueKnightLogicList
    dc.w        EnemyBonusWait-BlueKnightIndex2          ;EnemyBonusWait-BlueKnightLogicList
BlueKnightApproach:                              ; ...
    ;call        BlueKnightAnimMove
    ANIMATE2
    bsr         MoveEnemy

    ;ld          a, (BossPosY)
    ;cp          38h                                   ; '8'                         ; check screen pos y
    ;ret         c                                     ; below, quit
    ;call        WhiteKnightShoot

    cmp.b       #$20,ENEMY_PosY(a2)
    bcs         .exit

    bsr         BlueKnightAttack

    ;inc         (ix+ENEMY_Status)

    addq.b      #1,ENEMY_Status(a2)
    ;ret
.exit  
    rts

BlueKnightRun:                             ; ...
    ;call        BlueKnightAnimMove
    ANIMATE2
    bsr         MoveEnemy
    move.b      GameFrame(a5),d0
    add.b       ENEMY_Random(a2),d0
    and.b       #$3f,d0
    bne         .skipshot
    ;moveq       #1,d0                                    ; arrow
    ;bsr         AddEnemyShot
    bsr         ShootAtPlayer
.skipshot
    rts

BlueKnightAttack:                                 ; ...
    ;call        CalcAngleToPlayer
    ;call        CalcSpeed                             ; calculates the y and x speed of a shot based on the supplied angle
    bsr         CalcAngleToPlayer
    bsr         CalcSpeed

    asl.w       #1,d1
    asl.w       #1,d2

    move.w      d1,ENEMY_SpeedY(a2)
    move.w      d2,ENEMY_SpeedX(a2)  
    rts


; ---------------------------------------------------------------------------
;
; white knight boss logic
;
; ---------------------------------------------------------------------------

WhiteKnightLogic:
    lea         BobMatrix(a5),a4
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    bpl         .doit
    rts
.doit
    JMPINDEX    d0

WhiteKnightIndex:
    ;dc.w        WhiteKnightWalkOut-WhiteKnightIndex
    ;dc.w        WhiteKnightWalkOut-WhiteKnightIndex
    dc.w        WhiteKnightApproach-WhiteKnightIndex
    dc.w        WhiteKnightWaitShoot-WhiteKnightIndex


WhiteKnightApproach:                              ; ...
    ;call        BlueKnightAnimMove
    ANIMATE2
    bsr         MoveEnemy

    ;ld          a, (BossPosY)
    ;cp          38h                                   ; '8'                         ; check screen pos y
    ;ret         c                                     ; below, quit
    ;call        WhiteKnightShoot

    cmp.b       #$20,ENEMY_PosY(a2)
    bcs         .exit

    ;bsr         WhiteKnightShoot

    ;inc         (ix+ENEMY_Status)
    move.b      #1,ENEMY_WaitCounter(a2)
    addq.b      #1,ENEMY_Status(a2)
    ;ret
.exit  
    rts
; ---------------------------------------------------------------------------

WhiteKnightWaitShoot:                             ; ...
    ;call        BlueKnightAnimMove
    ANIMATE2
    bsr         MoveEnemy

    cmp.b       #$38,ENEMY_PosY(a2)
    bcs         WhiteKnightShoot
    ;dec         (ix+ENEMY_WaitCounter)
    ;ret         nz
    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         WhiteKnightExit
    
WhiteKnightShoot:                                 ; ...
    ;call        CalcAngleToPlayer
    ;call        CalcSpeed                             ; calculates the y and x speed of a shot based on the supplied angle
    bsr         CalcAngleToPlayer
    bsr         CalcSpeed

    ;ld          a, (BossHitCount)
    ;cp          14h                                   ; hit count
    ;jr          c, WhiteKnightSetSpeed                ; below $14, set speed only
    ;cp          28h                                   ; '('
    ;jr          c, WhiteKnightSpeedX2
    ;ld          h, b                        

    move.b      BossHitCount(a5),d3
    moveq       #1,d0                                    ; multiplier
    cmp.b       #$14,d3
    bcs         .setspeed
    addq.b      #1,d0
    cmp.b       #$28,d3
    bcs         .setspeed
    addq.b      #1,d0

.setspeed
    muls        d0,d1
    muls        d0,d2
    move.w      d1,ENEMY_SpeedY(a2)
    move.w      d2,ENEMY_SpeedX(a2)  
    move.b      #$60,ENEMY_WaitCounter(a2)
WhiteKnightExit:
    rts
    
