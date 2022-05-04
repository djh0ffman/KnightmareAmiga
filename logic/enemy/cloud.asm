;----------------------------------------------------------------------------
;
; cloud
;
;----------------------------------------------------------------------------

    include      "common.asm"

CloudLogic:
    moveq        #0,d0
    move.b       ENEMY_Status(a2),d0
    subq.b       #1,d0
    JMPINDEX     d0

CloudLogicList:
    dc.w         CloudInit-CloudLogicList       
    dc.w         CloudFloat-CloudLogicList
    dc.w         CloudAttack-CloudLogicList
    dc.w         CloudAnimMove-CloudLogicList      ; sprite id
    dc.w         EnemyFireDeath-CloudLogicList
    dc.w         EnemyBonusCheck-CloudLogicList
    dc.w         EnemyBonusWait-CloudLogicList


CloudInit:                                     
    bsr          EnemyClear

    move.w       #$80,ENEMY_SpeedY(a2)
    move.b       #$10,ENEMY_OffsetY(a2)
    clr.b        ENEMY_Counter2(a2)

    move.w       #$1000,d1                         ; pos y
    move.w       #$100,d2                          ; speed x
    cmp.b        #$80,ENEMY_PosX(a2)
    bcc          .initset

    move.w       #$f000,d1                         ; pos y
    move.w       #-$100,d2                         ; speed x
                               
.initset
    move.w       d1,ENEMY_PosX(a2)
    move.w       d2,ENEMY_SpeedX(a2)
    addq.b       #1,ENEMY_Status(a2)
    rts

;----------------------------------------------------------------------------
;
; cloud float logic
;
;----------------------------------------------------------------------------

CloudFloat:          
    moveq        #1,d2
    CALCWAVEY
    bsr          CloudAnimMove

    move.b       ENEMY_Counter2(a2),d0
    add.b        #$10,d0
    bcc          .skipoffset

    addq.b       #1,ENEMY_OffsetY(a2)
.skipoffset
    move.b       d0,ENEMY_Counter2(a2)

    cmp.b        #$60,ENEMY_PosY(a2)
    bcc          .exit

    move.b       ENEMY_PosX(a2),d0
    move.w       #$100,d1                          ; speed x
    cmp.b        #$18,d0
    bcc          .left
    bra          .setspeed

                          
.left
    move.w       #-$100,d1                         ; speed x
    cmp.b        #$e8,d0
    bcs          .exit
                               
.setspeed
    move.w       d1,ENEMY_SpeedX(a2)
.exit
    rts

; ---------------------------------------------------------------------------
;
; cloud hit, attack player
;
; ---------------------------------------------------------------------------

CloudAttack:   
    bsr          CalcAngleToPlayer

    bsr          CalcSpeed

    asl.w        #3,d1
    move.w       d1,ENEMY_SpeedY(a2)

    asl.w        #3,d2
    move.w       d2,ENEMY_SpeedX(a2)

    addq.b       #1,ENEMY_Status(a2)

    rts
; ---------------------------------------------------------------------------
;
; cloud animate and move
;
; ---------------------------------------------------------------------------

CloudAnimMove:                                 
    ANIMATE2
    bra          MoveEnemy
