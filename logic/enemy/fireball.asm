

;----------------------------------------------------------------------------
;
;  fireball
;
;----------------------------------------------------------------------------

    include      "common.asm"

FireballLogic:
    moveq        #0,d0
    move.b       ENEMY_Status(a2),d0
    subq.b       #1,d0
    JMPINDEX     d0

FireballLogicList:
    dc.w         FireballInit-FireballLogicList       ; ...
    dc.w         FireballMove1-FireballLogicList      ; move wave x
    dc.w         FireballMove2-FireballLogicList
    dc.w         FireballMove3-FireballLogicList
    dc.w         EnemyFireDeath-FireballLogicList      
    dc.w         EnemyBonusCheck-FireballLogicList
    dc.w         EnemyBonusWait-FireballLogicList     


FireballInit:                                     ; ...
    ;call        EnemyClearParams
    bsr          EnemyClear

    ;ld          (ix+ENEMY_SpeedYDec), 0
    ;ld          (ix+ENEMY_SpeedY), 2
    move.w       #$200,ENEMY_SpeedY(a2)
    ;ld          (ix+ENEMY_SpriteId), 1Ah
    ;ld          (ix+ENEMY_OffsetY), 50h               ; 'P'
    move.b       #$50,ENEMY_OffsetY(a2)

    ;ld          a, (ix+ENEMY_PosX)
    ;cp          80h
    ;ld          bc, 0FA80h                            ; speed x
    ;ld          d, 0B0h                               ; offset x
    ;ld          e, 0F0h                               ; pos x
    move.w       #-$580,d0
    moveq        #-$50,d1
    moveq        #-$10,d2
    moveq        #0,d3                                ; direction flag
    cmp.b        #$80,ENEMY_PosX(a2)
    bcs          .setval
    ;jr          c, FireballInitSet
    ;ld          bc, 580h                              ; speed x
    ;ld          d, 50h                                ; 'P'                      ; offset x
    ;ld          e, 10h                                ; speed x
    neg          d0
    neg          d1
    neg          d2
    moveq        #1,d3                                ; direction flag

;FireballInitSet:                                  ; ...
.setval
    ;ld          (ix+ENEMY_PosX), e
    ;ld          (ix+ENEMY_SpeedXDec), c
    ;ld          (ix+ENEMY_SpeedX), b
    ;ld          (ix+ENEMY_OffsetX), d
    move.w       d0,ENEMY_SpeedX(a2)
    move.b       d1,ENEMY_OffsetX(a2)
    move.b       d2,ENEMY_PosX(a2)
    move.b       d3,ENEMY_Direction(a2)
;EnemyNextStatus______:                            ; ...
    ;jp          EnemyNextStatus_
    addq.b       #1,ENEMY_Status(a2)
    rts


FireballMove1:                                    ; ...
    ;call        CalcWaveSpeedXFull                    ; move wave x
    moveq        #0,d2
    CALCWAVEX

    ;ld          b, 1Ah                                ; sprite id
    ;call        EnemyShootAnimate
    ANIMATE2
    bsr          MoveEnemy
    bsr          EnemyShotLogic

    ;ld          a, (ix+ENEMY_PosY)
    ;cp          38h                                   ; '8'                         ; keep moving until Y is $38
    ;ret         c
    cmp.b        #$38,ENEMY_PosY(a2)
    bcs          .exit

    ;ld          (ix+ENEMY_OffsetY), 68h               ; 'h'
    ;ld          (ix+ENEMY_OffsetX), 80h
    move.b       #$68,ENEMY_OffsetY(a2)
    move.b       #$80,ENEMY_OffsetX(a2)

    ;ld          a, (ix+ENEMY_PosX)
    ;cp          80h                                   ; set speed depending current position
    ;ld          bc, 480h                              ; speed x
    ;jr          nc, FireballPrep2
    ;ld          bc, 0FB80h                            ; speed x
    move.w       #$480,d0
    tst.b        ENEMY_Direction(a2)
    bne          .setval
    neg          d0

;FireballPrep2:                                    ; ...
.setval
    ;ld          (ix+ENEMY_SpeedYDec), 0
    ;ld          (ix+ENEMY_SpeedY), 1
    ;ld          (ix+ENEMY_SpeedXDec), c
    ;ld          (ix+ENEMY_SpeedX), b
    move.w       d0,ENEMY_SpeedX(a2)
    move.w       #$100,ENEMY_SpeedY(a2)
    ;jr          EnemyNextStatus______
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts

; ---------------------------------------------------------------------------

FireballMove2:                                    ; ...
    ;call        CalcWaveSpeedXFull
    ;call        CalcWaveSpeedYFull
    moveq        #0,d2
    CALCWAVEX
    moveq        #0,d2
    CALCWAVEY

    ;ld          b, 1Ah
    ;call        EnemyShootAnimate
    ANIMATE2
    bsr          MoveEnemy
    bsr          EnemyShotLogic

    ;ld          a, (ix+ENEMY_PosY)
    ;cp          38h                                   ; '8'
    ;ret         nc
    cmp.b        #$38,ENEMY_PosY(a2)
    bcc          .exit

    ;ld          a, (ix+ENEMY_PosX)
    ;cp          80h
    ;ld          a, 50h                                ; 'P'                      ; offset x
    ;ld          bc, 0FB20h                            ; speed x
    ;jr          nc, FireballPep3
    move.w       #-$4E0,d0                            ; speed x
    moveq        #$50,d1                              ; offset x
    tst.b        ENEMY_Direction(a2)
    beq          .setval
    ;ld          a, 0B0h                               ; offset x
    ;ld          bc, 4E0h                              ; speed x
    neg          d0                                   ; speed x
    neg          d1                                   ; offset x

;FireballPep3:                                     ; ...
.setval
    ;ld          (ix+ENEMY_OffsetX), a
    ;ld          (ix+ENEMY_OffsetY), 50h               ; 'P'
    move.b       d1,ENEMY_OffsetX(a2)
    move.b       #$50,ENEMY_OffsetY(a2)
    ;ld          (ix+ENEMY_SpeedYDec), 0
    ;ld          (ix+ENEMY_SpeedY), 0FEh
    move.w       #-$200,ENEMY_SpeedY(a2)
    ;ld          (ix+ENEMY_SpeedXDec), c
    ;ld          (ix+ENEMY_SpeedX), b
    move.w       d0,ENEMY_SpeedX(a2)
    ;jp          EnemyNextStatus_
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts

; ---------------------------------------------------------------------------

FireballMove3:                                    ; ...
    ;call        CalcWaveSpeedXFull
    ;ld          b, 1Ah
    ;jp          EnemyShootAnimate
    moveq        #0,d0
    CALCWAVEX
    ANIMATE2
    bsr          MoveEnemy
    bra          EnemyShotLogic