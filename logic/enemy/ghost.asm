

;----------------------------------------------------------------------------
;
;  ghost
;
;----------------------------------------------------------------------------

    include      "common.asm"

GhostLogic:
    moveq        #0,d0
    move.b       ENEMY_Status(a2),d0
    subq.b       #1,d0
    JMPINDEX     d0

GhostLogicList:
    dc.w         GhostInit-GhostLogicList
    dc.w         GhostLogic1-GhostLogicList
    dc.w         GhostLogic2-GhostLogicList
    dc.w         EnemyFireDeath-GhostLogicList      
    dc.w         EnemyBonusCheck-GhostLogicList
    dc.w         EnemyBonusWait-GhostLogicList     


GhostInit:
    bsr          EnemyClear

    move.w       #$130,ENEMY_SpeedY(a2)

    moveq        #$18,d1
    moveq        #3,d2
    move.w       #$600,d3
    cmp.b        #$80,ENEMY_PosX(a2)
    bcc          .setval

    neg          d1
    moveq        #2,d2
    neg          d3

.setval
    move.b       d1,ENEMY_OffsetX(a2)
    move.b       d1,ENEMY_PosX(a2)
    move.b       d2,ENEMY_Status(a2)
    move.w       d3,ENEMY_SpeedX(a2)
    rts

GhostLogic1:
    bsr          GhostWaveX

    cmp.b        #$e9,ENEMY_PosX(a2)
    bcs          .exit

    move.w       #$600,ENEMY_SpeedX(a2)
    move.b       #$18,ENEMY_PosX(a2)
    move.b       #$18,ENEMY_OffsetX(a2)
    addq.b       #1,ENEMY_Status(a2)
.exit
    rts

GhostLogic2:
    bsr          GhostWaveX
    
    cmp.b        #$17,ENEMY_PosX(a2)
    bcc          .exit

    move.w       #-$600,ENEMY_SpeedX(a2)
    move.b       #$e8,ENEMY_PosX(a2)
    move.b       #$e8,ENEMY_OffsetX(a2)

    subq.b       #1,ENEMY_Status(a2)
.exit
    rts

GhostWaveX: 
    moveq        #1,d2
    CALCWAVEX

    moveq        #1,d1                             ; bob id
    move.b       ENEMY_SpeedX(a2),d0
    lsl.b        #1,d0
    bcs          .setsprite
    moveq        #0,d1

.setsprite
    move.b       d1,ENEMY_BobId(a2)
    bsr          MoveEnemy
    bra          EnemyShotLogic
