
;----------------------------------------------------------------------------
;
;  gargoyle
;
;----------------------------------------------------------------------------

    include     "common.asm"

GargoyleLogic:
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    JMPINDEX    d0

GargoyleLogicList:
    dc.w        GargoyleInit-GargoyleLogicList       
    dc.w        GargoyleLogic1-GargoyleLogicList          
    dc.w        GargoyleLogic2-GargoyleLogicList   
    dc.w        EnemyFireDeath-GargoyleLogicList        
    dc.w        EnemyBonusCheck-GargoyleLogicList
    dc.w        EnemyBonusWait-GargoyleLogicList     

GargoyleInit:
    bsr         EnemyClear
    move.w      #$250,ENEMY_SpeedY(a2)
    addq.b      #1,ENEMY_Status(a2)
    rts

GargoyleLogic1:
    bsr         GargoyleLogic2                       ; shoot and move

    move.b      ENEMY_PosY(a2),d0
    cmp.b       #8,d0                                ; min
    bcs         .exit
    cmp.b       #$c0,d0                              ; max
    bcc         .exit

    move.b      PlayerStatus+PLAYER_PosY(a5),d1
    sub.b       d0,d1                                ; player distance Y
    cmp.b       #$50,d1
    bcc         .exit

    move.w      #$27f,d1                             ; speed x
    move.b      PlayerStatus+PLAYER_PosX(a5),d0 
    cmp.b       ENEMY_PosX(a2),d0
    bcc         .setdir
    neg.w       d1                                   ; reverse

.setdir
    move.w      d1,ENEMY_SpeedX(a2)                  ; set x speed
    addq.b      #1,ENEMY_Status(a2)                  ; move to shoot and move only
.exit
    rts

GargoyleLogic2:
    ANIMATE2
    bsr         MoveEnemy
    bra         EnemyShotLogic
