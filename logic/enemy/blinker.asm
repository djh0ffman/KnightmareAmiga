
;----------------------------------------------------------------------------
;
;  blinker head
;
;----------------------------------------------------------------------------

    include     "common.asm"

BlinkerLogic:
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    JMPINDEX    d0

BlinkerLogicList:
    dc.w        BlinkerInit-BlinkerLogicList
    dc.w        BlinkerLogic1-BlinkerLogicList
    dc.w        BlinkerLogic2-BlinkerLogicList
    dc.w        EnemyFireDeath-BlinkerLogicList      
    dc.w        EnemyBonusCheck-BlinkerLogicList
    dc.w        EnemyBonusWait-BlinkerLogicList     

BlinkerInit:  
    ;call        EnemyClearParams
    bsr         EnemyClear
    ;ld          (ix+ENEMY_SpriteId), 1Eh
    ;ld          (ix+ENEMY_Direction), 1
    ;jp          AttackPlayer
    move.b      #1,ENEMY_Direction(a2)
    bsr         CalcAngleToPlayer
    bsr         CalcSpeed                           ; calculates the y and x speed of a shot based on the supplied angle
    move.w      d1,ENEMY_SpeedY(a2)
    move.w      d2,ENEMY_SpeedX(a2)
    addq.b      #1,ENEMY_Status(a2)
    rts

BlinkerLogic1:
    ;call        BlinkerBaseLogic
    bsr         BlinkerBaseLogic

    ;ld          a, (ix+ENEMY_Direction)
    ;rra
    ;jr          c, loc_80C5
    ;ld          (ix+ENEMY_SpriteId), 0              ; hide blinker

    
    move.w      ENEMY_BobSlot(a2),d4
    move.b      ENEMY_Direction(a2),d0
    and.b       #1,d0
    eor.b       #1,d0
    move.b      d0,Bob_Hide(a4,d4.w)
    
;    tst.b       ENEMY_Direction(a2)6
;    bne         .donthide

;    nop                                             ; hide bob here
;loc_80C5:     
;.donthide

    ;call        CheckPlayerShotsActive
    ;ld          b, 0
    ;jr          nc, loc_80CD
    ;inc         b
;loc_80CD:     

    moveq       #0,d1                               ; shots fired!
    btst.b      #7,PlayerShot1(a5)                  ; fire shot, check all shots are free
    beq         .shotactive
    btst.b      #7,PlayerShot2(a5)                  ; fire shot, check all shots are free
    beq         .shotactive
    btst.b      #7,PlayerShot3(a5)                  ; fire shot, check all shots are free
    beq         .shotactive
    moveq       #1,d1                               ; no shots active
.shotactive

    ;ld          a, (ix+ENEMY_Direction)
    ;and         1
    ;xor         b
    ;ret         z
    move.b      ENEMY_Direction(a2),d0
    and.b       #1,d0
    eor.b       d1,d0
    beq         .exit
    ;ld          a, (ix+ENEMY_Direction)
    ;xor         1
    ;ld          (ix+ENEMY_Direction), a
    ;ld          (ix+ENEMY_WaitCounter), 8
    ;jp          EnemyNextStatus_
    eor.b       #1,ENEMY_Direction(a2)
    move.b      #16,ENEMY_WaitCounter(a2)
    addq.b      #1,ENEMY_Status(a2)
.exit
    rts


BlinkerLogic2:
    ;call        BlinkerBaseLogic
    bsr         BlinkerBaseLogic

    move.w      ENEMY_BobSlot(a2),d4
    move.b      TickCounter(a5),d0
    and.b       #1,d0
    move.b      d0,Bob_Hide(a4,d4.w)

    ;ld          a, (ix+ENEMY_WaitCounter)
    ;bit         0, a
    ;jr          z, DontHideBlinker
    ;ld          (ix+ENEMY_SpriteId), 0

;DontHideBlinker:                                  ; ...
    ;dec         (ix+ENEMY_WaitCounter)
    ;ret         nz
    ;jp          EnemyPrevStatus
    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         .exit
    subq.b      #1,ENEMY_Status(a2)
.exit
    rts


BlinkerBaseLogic:                                 ; ...
    ;ld          b, 1Eh
    ;call        EnemyShootAnimate
    ANIMATE2
    bsr         MoveEnemy
    bsr         EnemyShotLogic
    ;ld          a, (TickCounter)
    ;and         3Eh                                 ; '>'
    ;ret         nz
    ;ld          a, 8
    ;jp          SetSound2
    rts