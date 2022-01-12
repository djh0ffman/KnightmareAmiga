
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


DevilInit:                                        ; ...
    ;call        EnemyClearParams
    bsr         EnemyClear

    lea         EnemyBobLookup(a5),a0
    move.l      $c*4(a0),ENEMY_BobPtr(a2)          ; set as cloud

    ;ld          a, (ix+ENEMY_PosX)
    ;cp          80h                               ; left or right side
    ;ld          c, 2                              ; speed x move right
    ;jr          c, DevilInit2
    ;ld          c, 0FEh                           ; speed x move left
    move.w      #$200,d2
    cmp.b       #$80,ENEMY_PosX(a2)
    bcs         .setspeed
    neg.w       d2

;DevilInit2:                                       ; ...
.setspeed
    ;ld          (ix+ENEMY_SpeedX), c
    ;ld          (ix+ENEMY_SpeedY), 6
    ;ld          (ix+ENEMY_SpriteId), 6
    ;jr          EnemyNextStatus___
    move.w      d2,ENEMY_SpeedX(a2)
    move.w      #$600,ENEMY_SpeedY(a2)
    addq.b      #1,ENEMY_Status(a2)
    rts

DevilCloudIn:                                     ; ...
    ;call        MoveEnemy                         ; move into screen as cloud
    bsr         MoveEnemy

    ;ld          a, (ix+ENEMY_PosY)                ; check y range devil is in
    ;cp          8
    ;ret         c                                 ; less than 8, quit
    ;cp          0C0h
    ;ret         nc                                ; more than $c0, quit
    move.b      ENEMY_PosY(a2),d0
    cmp.b       #8,d0                              ; min
    bcs         .exit
    cmp.b       #$c0,d0                            ; max
    bcc         .exit

    ;ld          a, (PlayerY)
    ;sub         (ix+ENEMY_PosY)
    ;cp          50h                               ; 'P'                         ; greater than $50 distance from player, then quit
    ;ret         nc
    ;ld          a, 20h                            ; ' '                      ; wait $20 frames in next status
    move.b      PlayerStatus+PLAYER_PosY(a5),d1
    sub.b       d0,d1                              ; player distance Y
    cmp.b       #$50,d1
    bcc         .exit

    lea         EnemyBobLookup(a5),a0              ; set as devil
    move.l      (a0),ENEMY_BobPtr(a2) 

;DevilWaitNextStatus:                              ; ...

    ;ld          (ix+ENEMY_WaitCounter), a
    move.b      #$20,ENEMY_WaitCounter(a2)
;EnemyNextStatus___:                               ; ...
    ;jp          EnemyNextStatus
    addq.b      #1,ENEMY_Status(a2)
.exit
    rts

DevilWaitShoot:                                   ; ...
    ;call        DevilAnimateWait
    ;ret         nz                                ; wait not finished
    ANIMATE2
    bsr         UpdateEnemyBob
    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         .exit

    ;call        ShootAtPlayer
    bsr         ShootAtPlayer

    ;ld          a, 8
    ;jr          DevilWaitNextStatus
    move.b      #$20,ENEMY_WaitCounter(a2)
    addq.b      #1,ENEMY_Status(a2)
.exit
    rts

DevilCloudOut:                                    ; ...
    ;call        DevilAnimateWait
    ;ret         nz                                ; wait not finished
    ANIMATE2
    bsr         UpdateEnemyBob
    subq.b      #1,ENEMY_WaitCounter(a2)
    bne         .exit

    ;ld          (ix+ENEMY_SpeedYDec), 0
    ;ld          (ix+ENEMY_SpeedY), 0FAh
    ;ld          (ix+ENEMY_SpriteId), 6
    ;jr          EnemyNextStatus___
    lea         EnemyBobLookup(a5),a0
    move.l      $c*4(a0),ENEMY_BobPtr(a2)          ; set as cloud

    move.w      #-$600,ENEMY_SpeedY(a2)
    addq.b      #1,ENEMY_Status(a2)
.exit
    rts

DevilAnimateWait:                                 ; ...
    ;ld          b, 7
    ;call        AnimateEnemy                      ; animate enemy
    ;dec         (ix+ENEMY_WaitCounter)
    ;ret


