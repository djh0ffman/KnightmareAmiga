

;----------------------------------------------------------------------------
;
;  head
;
;----------------------------------------------------------------------------

    include      "common.asm"

HeadLogic:
    moveq        #0,d0
    move.b       ENEMY_Status(a2),d0
    subq.b       #1,d0
    JMPINDEX     d0

HeadLogicList:
    dc.w         HeadInit-HeadLogicList
    dc.w         HeadLogic1-HeadLogicList
    dc.w         HeadLogic2-HeadLogicList
    dc.w         HeadLogic3-HeadLogicList
    dc.w         HeadLogic4-HeadLogicList
    dc.w         HeadShootAnimate-HeadLogicList
    dc.w         EnemyFireDeath-HeadLogicList      
    dc.w         EnemyBonusCheck-HeadLogicList
    dc.w         EnemyBonusWait-HeadLogicList     

    
HeadInit:
    bsr          EnemyClear

    move.w       #$300,ENEMY_SpeedY(a2)

    moveq        #$20,d0
    cmp.b        #$80,ENEMY_PosX(a2)
    bcc          .setval
    neg          d0

.setval
    move.b       d0,ENEMY_PosX(a2)
    addq.b       #1,ENEMY_Status(a2)
    rts

HeadLogic1:          
    bsr          HeadShootAnimate

    move.b       ENEMY_PosY(a2),d0
    cmp.b        #$e0,d0
    bcc          .exit
    cmp.b        #$50,d0
    bcs          .exit

    move.b       #$50,ENEMY_OffsetY(a2)

    moveq        #-$70,d0
    cmp.b        #$80,ENEMY_PosX(a2)
    bcc          .setval
    neg          d0

.setval
    move.b       d0,ENEMY_OffsetX(a2)

    addq.b       #1,ENEMY_Status(a2)
.exit
    rts


HeadLogic2:          
    bsr          HeadWaveShootAnimate

    cmp.b        #$4f,ENEMY_PosY(a2)
    bcc          .exit

    move.b       #$80,ENEMY_OffsetX(a2)

    clr.w        ENEMY_SpeedX(a2)
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts

HeadLogic3:          
    bsr          HeadWaveShootAnimate

    cmp.b        #$50,ENEMY_PosY(a2)
    bcs          .exit

    moveq        #$70,d0
    cmp.b        #$80,ENEMY_PosX(a2)
    bcc          .setval

    neg          d0
.setval
    move.b       d0,ENEMY_OffsetX(a2)
    clr.w        ENEMY_SpeedX(a2)
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts


HeadLogic4:          
    bsr          HeadWaveShootAnimate

    cmp.b        #$4f,ENEMY_PosY(a2)
    bcc          .exit
    clr.w        ENEMY_SpeedX(a2)
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts
; ---------------------------------------------------------------------------

HeadWaveShootAnimate:
    moveq        #2,d2
    CALCWAVEX
    moveq        #2,d2
    CALCWAVEY
    

HeadShootAnimate:    
    ANIMATE2
    bsr          MoveEnemy
    bra          EnemyShotLogic