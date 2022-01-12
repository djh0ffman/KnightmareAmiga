
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

SpikeBallInit:                                    ; ...
    ;call        EnemyClearParams
    bsr         EnemyClear

    ;ld          (ix+ENEMY.SpriteId), 5

    ;ld          a, (TickCounter)
    ;rra
    ;rra
    ;and         3
    move.b      TickCounter(a5),d0
    lsr.b       #2,d0
    and.w       #$3,d0

    ;ld          hl, SpikeDirection                    ; set spike direction depending on frame number
    ;call        ADD_A_HL
    ;ld          l, (hl)
    move.b      SpikeDirection(pc,d0.w),d0

    ;call        CalcAngleToPlayer1
    bsr         CalcAngleToPlayer1

;    bra         CalcSpeedFast
    bsr         CalcSpeed
    asl.w       #3,d1
    move.w      d1,ENEMY_SpeedY(a2)

    ;ld         h, d
    ;ld         l, e
    ;add        hl, hl
    ;add        hl, hl
    ;add        hl, de
    ;ld         (ix+ENEMY_SpeedXDec), l
    ;ld         (ix+ENEMY_SpeedX), h
    asl.w       #3,d2
    move.w      d2,ENEMY_SpeedX(a2)

    ;jr         EnemyNextStatus_______
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
