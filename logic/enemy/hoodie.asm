

;----------------------------------------------------------------------------
;
;  head
;
;----------------------------------------------------------------------------

    include     "common.asm"

HoodieLogic:
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    JMPINDEX    d0

HoodieLogicList:
    dc.w        HoodieInit-HoodieLogicList
    dc.w        HoodieRun-HoodieLogicList
    dc.w        EnemyFireDeath-HoodieLogicList      
    dc.w        EnemyBonusCheck-HoodieLogicList
    dc.w        EnemyBonusWait-HoodieLogicList    


HoodieInit:
    bsr         EnemyClear

    move.w      #$a0,ENEMY_SpeedY(a2)
    move.b      #5,ENEMY_HitPoints(a2)
    addq.b      #1,ENEMY_Status(a2)
    rts

HoodieRun:
    ANIMATE2
    bsr         MoveEnemy
    bra         EnemyShotLogic