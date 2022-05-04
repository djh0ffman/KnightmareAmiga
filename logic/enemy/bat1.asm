
;----------------------------------------------------------------------------
;
;  bat 1
;
;----------------------------------------------------------------------------

    include      "common.asm"

Bat1Logic:
    moveq        #0,d0
    move.b       ENEMY_Status(a2),d0
    subq.b       #1,d0
    JMPINDEX     d0

Bat1LogicList:
    dc.w         BatWaveInit-Bat1LogicList         ; BatWaveInit-BlobLogicList        
    dc.w         BatWaveLogic-Bat1LogicList        ; BatWaveLogic-BlobLogicList          
    dc.w         EnemyFireDeath-Bat1LogicList      
    dc.w         EnemyBonusCheck-Bat1LogicList
    dc.w         EnemyBonusWait-Bat1LogicList     

BatWaveInit: 
    bsr          EnemyClear

    move.w       #$130,ENEMY_SpeedY(a2)
    move.b       #$80,ENEMY_OffsetX(a2)

    moveq        #6,d1
    lea          BatWaveStartX(pc),a0
    move.b       ENEMY_PosX(a2),d0
                        
.loop
    cmp.b        (a0)+,d0
    beq          .setx
    subq.b       #1,d1
    bne          .loop
    rts

.setx
    moveq        #6,d0
    sub.b        d1,d0

    lea          BatWaveSpeedX(pc),a0

    move.b       (a0,d0.w),d0

    move.b       d0,ENEMY_SpeedX(a2)
    addq.b       #1,ENEMY_Status(a2)
    rts

BatWaveStartX:
    dc.b         $28, $50, $7F, $80, $0B0, $0D8
BatWaveSpeedX:
    dc.b         0, 5, $0FA, 6, $0FB, $0FF 



BatWaveLogic:                                  
    moveq        #0,d2

BatWaveLogic1:                                 
    CALCWAVEX

; =============== S U B R O U T I N E =======================================


BatSharedLogic:
    ANIMATE2
    addq.b       #1,ENEMY_FrameCount(a2)
    move.b       ENEMY_FrameCount(a2),d1
    and.b        #$f,d1
    bne          .skipsfx
    moveq        #1,d0
    tst.b        ENEMY_SpeedX(a2)
    bmi          .dosfx
    moveq        #2,d0
.dosfx
    bsr          SfxPlay
.skipsfx
    bsr          EnemyShotLogic
    bra          MoveEnemy