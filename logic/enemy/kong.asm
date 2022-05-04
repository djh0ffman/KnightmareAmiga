

;----------------------------------------------------------------------------
;
;  kong
;
;----------------------------------------------------------------------------

    include     "common.asm"

KongLogic:
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    JMPINDEX    d0

KongLogicList:
    dc.w        KongInit-KongLogicList
    dc.w        KongBigWalk-KongLogicList
    dc.w        KongHitSplit-KongLogicList
    dc.w        KongMiniLogic-KongLogicList
    dc.w        KongMiniAnimMove-KongLogicList
    dc.w        EnemyFireDeath-KongLogicList      
    dc.w        EnemyBonusCheck-KongLogicList
    dc.w        EnemyBonusWait-KongLogicList    

    
KongInit:                                      
    bsr         EnemyClear

KongAttack:
    bsr         CalcAngleToPlayer
    bsr         CalcSpeed
    move.w      d1,ENEMY_SpeedY(a2)
    move.w      d2,ENEMY_SpeedX(a2)

    addq.b      #1,ENEMY_Status(a2)
    rts

KongBigWalk:                                   
    ANIMATE2
    bsr         MoveEnemy
    bra         EnemyShotLogic


KongHitSplit:                                  
    bsr         EnemyClear

    move.w      #-$700,ENEMY_SpeedX(a2)
    move.b      #8,ENEMY_WaitCounter(a2)
    addq.b      #1,ENEMY_Status(a2)

    move.l      a2,a1                             ;backup current enemy pointer
    PUSH        a2   
    bsr         FindEnemySlot
    bcs         .notfound

    move.l      a2,a3
    moveq       #(ENEMY_Sizeof/2)-1,d0
.copyloop
    move.w      (a1)+,(a3)+
    dbra        d0,.copyloop

    move.w      #$700,ENEMY_SpeedX(a2)

    bsr         PrepEnemyBobs

.notfound
    POP         a2
    rts


; ---------------------------------------------------------------------------

KongMiniLogic:                                 
    bsr         KongMiniAnimMove

    move.b      ENEMY_PosX(a2),d0
    cmp.b       #$18,d0
    bcc         .left
    moveq       #$18,d0
.left
    cmp.b       #$e8,d0
    bcs         .right
    moveq       #-$19,d0
.right
    move.b      d0,ENEMY_PosX(a2)

    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         .exit

    bsr         CalcAngleToPlayer
    bsr         CalcSpeed
    asl.w       #1,d1
    asl.w       #1,d2
    move.w      d1,ENEMY_SpeedY(a2)
    move.w      d2,ENEMY_SpeedX(a2)
    addq.b      #1,ENEMY_Status(a2)
.exit
    rts

KongMiniAnimMove:                              
    ANIMATE2
    addq.b      #2,ENEMY_BobId(a2)
    bsr         MoveEnemy
    bra         EnemyShotLogic
