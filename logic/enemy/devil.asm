
;----------------------------------------------------------------------------
;
;  devil
;
;----------------------------------------------------------------------------

    include     "common.asm"

DevilLogic:
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    JMPINDEX    d0

DevilLogicList:
    dc.w        DevilInit-DevilLogicList
    dc.w        DevilCloudIn-DevilLogicList
    dc.w        DevilWaitShoot-DevilLogicList
    dc.w        DevilCloudOut-DevilLogicList
    dc.w        MoveEnemy-DevilLogicList
    dc.w        EnemyFireDeath-DevilLogicList      
    dc.w        EnemyBonusCheck-DevilLogicList
    dc.w        EnemyBonusWait-DevilLogicList     


DevilInit:                                     
    bsr         EnemyClear

    lea         EnemyBobLookup(a5),a0
    move.l      $c*4(a0),ENEMY_BobPtr(a2)          ; set as cloud

    move.w      #$200,d2
    cmp.b       #$80,ENEMY_PosX(a2)
    bcs         .setspeed
    neg.w       d2
                                  
.setspeed
    move.w      d2,ENEMY_SpeedX(a2)
    move.w      #$600,ENEMY_SpeedY(a2)
    addq.b      #1,ENEMY_Status(a2)
    rts

DevilCloudIn:                                  
    bsr         MoveEnemy

    move.b      ENEMY_PosY(a2),d0
    cmp.b       #8,d0                              ; min
    bcs         .exit
    cmp.b       #$c0,d0                            ; max
    bcc         .exit

    move.b      PlayerStatus+PLAYER_PosY(a5),d1
    sub.b       d0,d1                              ; player distance Y
    cmp.b       #$50,d1
    bcc         .exit

    lea         EnemyBobLookup(a5),a0              ; set as devil
    move.l      (a0),ENEMY_BobPtr(a2) 

    move.b      #$20,ENEMY_WaitCounter(a2)
    addq.b      #1,ENEMY_Status(a2)
.exit
    rts

DevilWaitShoot:                                
    ANIMATE2
    bsr         UpdateEnemyBob
    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         .exit

    bsr         ShootAtPlayer

    move.b      #$20,ENEMY_WaitCounter(a2)
    addq.b      #1,ENEMY_Status(a2)
.exit
    rts

DevilCloudOut:                                 
    ANIMATE2
    bsr         UpdateEnemyBob
    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         .exit

    lea         EnemyBobLookup(a5),a0
    move.l      $c*4(a0),ENEMY_BobPtr(a2)          ; set as cloud

    move.w      #-$600,ENEMY_SpeedY(a2)
    addq.b      #1,ENEMY_Status(a2)
.exit
    rts


