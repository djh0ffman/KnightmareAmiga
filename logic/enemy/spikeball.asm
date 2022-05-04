
;----------------------------------------------------------------------------
;
;  spike ball
;
;----------------------------------------------------------------------------

    include     "common.asm"

SpikeBallLogic:
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    JMPINDEX    d0

SpikeBallLogicList:
    dc.w        SpikeBallInit-SpikeBallLogicList      
    dc.w        SpikeBallRun-SpikeBallLogicList      
    dc.w        EnemyFireDeath-SpikeBallLogicList      
    dc.w        EnemyBonusCheck-SpikeBallLogicList
    dc.w        EnemyBonusWait-SpikeBallLogicList     

SpikeBallInit:                                 
    bsr         EnemyClear

    move.b      TickCounter(a5),d0
    lsr.b       #2,d0
    and.w       #$3,d0

    move.b      SpikeDirection(pc,d0.w),d0

    bsr         CalcAngleToPlayer1

    bsr         CalcSpeed
    asl.w       #3,d1
    move.w      d1,ENEMY_SpeedY(a2)

    asl.w       #3,d2
    move.w      d2,ENEMY_SpeedX(a2)

    addq.b      #1,ENEMY_Status(a2)
    rts

SpikeDirection:
    dc.b        $B0
    dc.b        $90
    dc.b        $70
    dc.b        $50
    
SpikeBallRun:
    bsr         EnemyShotLogic
    bra         MoveEnemy
