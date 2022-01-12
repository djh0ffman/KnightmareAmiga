;----------------------------------------------------------------------------
;
; boss logic
;
;----------------------------------------------------------------------------

    include     "common.asm"

BossInitLogic:
    ;ld          a, (PlayerStatus)
    ;cp          2
    ;ret         nc
    cmp.b       #PLAYERMODE_DEAD,PlayerStatus(a5)
    bcc         .exit

    ;ld          a, (BossDeadFlag)
    ;or          a
    ;jr          z, BossNotDead
    tst.b       BossDeadFlag(a5)
    beq         .notdead


    ;ld          a, 3                       ; player status boss dead, finish level
    ;ld          (PlayerStatus), a
    ;xor         a
    ;ld          (PlayerTimer), a
    move.b      #PLAYERMODE_BOSSBEAT,PlayerStatus(a5)
    clr.b       PlayerStatus+PLAYER_Timer(a5)

;BossNotDead:                                      ; ...
.notdead
    ;ld          de, LevelPosition          ; starts at zero, increments 1 per 8 pixels of the map
                                                  ; this is linked to other data to determine where items appear
                                                  ; within a level
    ;ld          a, (de)
    ;cp          0CFh
    ;ret         nz
    cmp.b       #$d8,LevelPosition(a5)                 
    bne         .exit

    ;ld          hl, BossStatus
    ;ld          a, (hl)
    ;or          a
    ;jr          nz, BossAlive              ; de = game frame
    ;ld          (hl), 1                    ; set boss alive
    tst.b       BossStatus(a5)
    bne         .exit
    move.b      #1,BossStatus(a5)
    clr.b       BossBarLoad(a5)                          ; clear health bar
    
    bsr         KillEnemyShots
;BossAlive:                                        ; ...
.bossalive
    ;dec         de                         ; de = game frame
    ;ld          a, (de)
    ;sub         0C0h
    ;cp          2
    ;ret         nc
    ;or          a
    ;ld          a, 3Dh                     ; kill sound but...  hmmm.
    ;jp          z, 
    ;jp          SetBossMusic
    bra         SetBossMusic
.exit
    rts

;----------------------------------------------------------------------------
;
; boss logic jump
;
;----------------------------------------------------------------------------

BossLogic:                                        ; ...
    ;ld         a, (BossStatus)
    ;and        a
    ;ret        z
    ;ld         a, (BossId)
    ;call       JumpIndex_A
    move.b      BossId(a5),d0
    and.w       #$7,d0
    JMPINDEX    d0

BossLogicList:
    dc.w        Boss1Logic-BossLogicList                 ; TileBossLogic
    dc.w        SkullBossLogic-BossLogicList             ; SkullBossLogic
    dc.w        BatBossLogic-BossLogicList               ; BatBossLogic
    dc.w        CloakBossLogic-BossLogicList             ; CloakBossLogic
    dc.w        BigKnightLogic-BossLogicList             ; TileBossLogic
    dc.w        SumoLogic-BossLogicList                  ; TileBossLogic
    dc.w        BossKnightsLogic-BossLogicList           ; BlueKnightBoss
    dc.w        EyesBossLogic-BossLogicList              ; EyesBossLogic

BossClearParams:
    clr.b       BossHitCount(a5)

    lea         BossHitCountList,a0
    moveq       #0,d0
    move.b      BossId(a5),d0
    move.b      (a0,d0.w),BossHitMax(a5)

    clr.b       BossDeathFlag(a5)
    rts

BossAnimate2:
    ;ld          a, (GameFrame)
    ;bit         4, a
    ;ld          a, 0
    ;jr          z, TileBossMoveAttack1
    ;inc         a
    moveq       #0,d0 
    btst        #4,GameFrame(a5)
    beq         .otherframe
    addq.b      #1,d0
.otherframe
    move.l      BossBobSlotPtr(a5),a4

    lea         BossBobPtrs(a5),a0
    add.w       d0,d0
    add.w       d0,d0
    move.l      (a0,d0.w),a0
    BOBSET      a0,a4

    cmp.b       #4,BossId(a5)
    bne         .notknight

    move.l      BossBobSlotPtr2(a5),a4
    lea         BossBobPtrs(a5),a0
    move.l      8(a0),a0
    BOBSET      a0,a4
.notknight
    rts


BossAnimateQuick:
    ;ld          a, (GameFrame)
    ;bit         4, a
    ;ld          a, 0
    ;jr          z, TileBossMoveAttack1
    ;inc         a
    moveq       #0,d0 
    btst        #2,GameFrame(a5)
    beq         .otherframe
    addq.b      #1,d0
.otherframe
    move.l      BossBobSlotPtr(a5),a4

    lea         BossBobPtrs(a5),a0
    add.w       d0,d0
    add.w       d0,d0
    move.l      (a0,d0.w),a0
    BOBSET      a0,a4

    cmp.b       #4,BossId(a5)
    bne         .notknight

    move.l      BossBobSlotPtr2(a5),a4
    lea         BossBobPtrs(a5),a0
    move.l      8(a0),a0
    BOBSET      a0,a4
.notknight
    rts

DecBossTimerSetSpeed:                             ; ...
    ;dec         (hl)
    ;ret         nz
    ;jr          TileBossSetMoveSpeed               ; sets the tile boss move speed
                                                  ; there are three different speeds depending on

    subq.b      #1,BossTimer(a5)
    bne         .quit
    bra         BossSetMoveSpeed
.quit 
    rts                                                 
;----------------------------------------------------------------------------
;
; sets the tile boss move speed
; there are three different speeds depending on
; distance to the player
;
;----------------------------------------------------------------------------

BossSetMoveSpeed:
    ;ld          a, (PlayerX)
    ;and         0FCh
    ;ld          b, a
    ;ld          a, (BossPosX)
    ;and         0FCh
    ;add         a, 0Ch
    ;cp          b
    move.b      PlayerStatus+PLAYER_PosX(a5),d1
    and.w       #$fc,d1


    move.b      BossPosX(a5),d0
    and.w       #$fc,d0
    add.b       #$c,d0
    
    move.b      d1,BossDestX(a5)

    moveq       #0,d2                                    ; speed x
    ;ld          hl, 0
    cmp.b       d1,d0
    ;jr          z, loc_8BF0
    beq         .setspeed
    ;ld          h, 1
    move.w      #$100,d2                                 ; right
    cmp.b       d0,d1
    bcc         .setspeed
    ;jr          c, loc_8BF0
    ;ld          h, 0FFh
    move.w      #-$100,d2                                ; left 

.setspeed
    ;ld          a, (BossId)
    ;cp          0
    ;jr          z, loc_8BFD
    ;ld          a, h
    ;or          a
    ;jr          nz, loc_8BFD
    ;ld          h, 1
    moveq       #0,d0
    move.b      BossId(a5),d0
    beq         .setspeed2
    
    tst.w       d2
    bne         .setspeed2
    move.w      #$100,d2

;loc_8BFD:                                         ; ...
.setspeed2
    ;ld          (BossSpeedXDec), hl
    ;inc         h
    ;ld          a, (TileBossId)
    ;ld          c, a
    ;add         a, a
    ;add         a, c                       ; * 3
    ;add         a, h
    ;ld          hl, TileBossMoveSpeeds
    ;call        ADD_A_HL
    ;ld          a, (hl)
    ;add         a, b
    ;ld          (BossSpeedXTemp), a
    ;ret    
    move.w      d2,BossSpeedX(a5)

    mulu        #3,d0
    asr.w       #8,d2
    add.w       d2,d0

    lea         BossOffsets+1(pc),a0
    move.b      (a0,d0.w),d0
    add.b       d1,d0
    move.b      d0,BossDestXOffset(a5)
    rts

BossOffsets:
    dc.b        0, 0, 0                                  ; ...
    dc.b        0, 0, 0                                  ; ...
    dc.b        0, 0, 0                                  ; ...
    dc.b        0, 0, 0                                  ; ...
    dc.b        -$20, $10, $20
    dc.b        -$30, $10, $30
    dc.b        0, 0, 0                                  ; ...
    dc.b        0, 0, 0                                  ; ...
    even


    incdir      "logic/boss"
    include     "bosswitch.asm" 
    include     "bossskull.asm"
    include     "bossbat.asm"
    include     "bosscloak.asm"
    include     "bossbigknight.asm"
    include     "bosssumo.asm"
    include     "bossblueknight.asm"
    include     "bosseyes.asm"
    
    include     "bossclouds.asm"