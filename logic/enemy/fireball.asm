

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
    dc.w         FireballInit-FireballLogicList    
    dc.w         FireballMove1-FireballLogicList      ; move wave x
    dc.w         FireballMove2-FireballLogicList
    dc.w         FireballMove3-FireballLogicList
    dc.w         EnemyFireDeath-FireballLogicList      
    dc.w         EnemyBonusCheck-FireballLogicList
    dc.w         EnemyBonusWait-FireballLogicList     


FireballInit:                                  
    bsr          EnemyClear

    move.w       #$200,ENEMY_SpeedY(a2)
    move.b       #$50,ENEMY_OffsetY(a2)

    move.w       #-$580,d0
    moveq        #-$50,d1
    moveq        #-$10,d2
    moveq        #0,d3                                ; direction flag
    cmp.b        #$80,ENEMY_PosX(a2)
    bcs          .setval

    neg          d0
    neg          d1
    neg          d2
    moveq        #1,d3                                ; direction flag
                             
.setval
    move.w       d0,ENEMY_SpeedX(a2)
    move.b       d1,ENEMY_OffsetX(a2)
    move.b       d2,ENEMY_PosX(a2)
    move.b       d3,ENEMY_Direction(a2)
    addq.b       #1,ENEMY_Status(a2)
    rts


FireballMove1:                                 
    moveq        #0,d2
    CALCWAVEX

    ANIMATE2
    bsr          MoveEnemy
    bsr          EnemyShotLogic

    cmp.b        #$38,ENEMY_PosY(a2)
    bcs          .exit

    move.b       #$68,ENEMY_OffsetY(a2)
    move.b       #$80,ENEMY_OffsetX(a2)

    move.w       #$480,d0
    tst.b        ENEMY_Direction(a2)
    bne          .setval
    neg          d0
                                 
.setval
    move.w       d0,ENEMY_SpeedX(a2)
    move.w       #$100,ENEMY_SpeedY(a2)
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts

; ---------------------------------------------------------------------------

FireballMove2:                                 
    moveq        #0,d2
    CALCWAVEX
    moveq        #0,d2
    CALCWAVEY

    ANIMATE2
    bsr          MoveEnemy
    bsr          EnemyShotLogic

    cmp.b        #$38,ENEMY_PosY(a2)
    bcc          .exit

    move.w       #-$4E0,d0                            ; speed x
    moveq        #$50,d1                              ; offset x
    tst.b        ENEMY_Direction(a2)
    beq          .setval
    neg          d0                                   ; speed x
    neg          d1                                   ; offset x

.setval
    move.b       d1,ENEMY_OffsetX(a2)
    move.b       #$50,ENEMY_OffsetY(a2)
    move.w       #-$200,ENEMY_SpeedY(a2)
    move.w       d0,ENEMY_SpeedX(a2)
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts

; ---------------------------------------------------------------------------

FireballMove3:                                 
    moveq        #0,d0
    CALCWAVEX
    ANIMATE2
    bsr          MoveEnemy
    bra          EnemyShotLogic