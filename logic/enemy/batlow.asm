

;----------------------------------------------------------------------------
;
;  bat low
;
;----------------------------------------------------------------------------

    include      "common.asm"

BatLowLogic:
    moveq        #0,d0
    move.b       ENEMY_Status(a2),d0
    subq.b       #1,d0
    JMPINDEX     d0

BatLowLogicList:
    dc.w         BatLowInit-BatLowLogicList      
    dc.w         BatLowLogic1-BatLowLogicList        
    dc.w         BatLowLogic2-BatLowLogicList   
    dc.w         EnemyFireDeath-BatLowLogicList      
    dc.w         EnemyBonusCheck-BatLowLogicList
    dc.w         EnemyBonusWait-BatLowLogicList     


BatLowInit:
    bsr          EnemyClear

    move.w       #-$40,ENEMY_SpeedY(a2)
    move.b       #$30,ENEMY_OffsetY(a2)
    move.b       #$80,ENEMY_OffsetX(a2)

    move.w       #$300,d1
    moveq        #$10,d2
    cmp.b        #$80,ENEMY_PosX(a2)
    bcs          .setvals
    neg.w        d1
    neg.b        d2

.setvals
    move.w       d1,ENEMY_SpeedX(a2)
    move.b       d2,ENEMY_PosX(a2)

    addq.b       #1,ENEMY_Status(a2)
    rts


BatLowLogic1:
    bsr          BatSharedLogic

    move.b       ENEMY_PosX(a2),d0
    sub.b        #$80,d0
    bcc          .edge
    neg.b        d0
                       
.edge
    cmp.b        #5,d0
    bcc          .exit

    clr.w        ENEMY_SpeedY(a2)
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts

BatLowLogic2:                                  
    moveq        #1,d2
    CALCWAVEY
    moveq        #1,d2
    bra          BatWaveLogic1