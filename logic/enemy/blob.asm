
;----------------------------------------------------------------------------
;
;  blob
;
;----------------------------------------------------------------------------

    include     "common.asm"

BlobLogic:
    moveq       #0,d0
    move.b      ENEMY_Status(a2),d0
    subq.b      #1,d0
    JMPINDEX    d0

BlobLogicList:
    dc.w        BlobInit-BlobLogicList           ; BlobInit-BlobLogicList        
    dc.w        BlobRun-BlobLogicList            ; BlobRun-BlobLogicList          
    dc.w        EnemyFireDeath-BlobLogicList      
    dc.w        EnemyBonusCheck-BlobLogicList
    dc.w        EnemyBonusWait-BlobLogicList     


BlobInit:                                      
    bsr         EnemyClear
    move.w      #$0080,ENEMY_SpeedY(a2)
    addq.b      #1,ENEMY_Status(a2)
    move.l      #AnimBlob,ENEMY_AnimPtr(a2)
    rts

BlobRun:
    bsr         AnimatePingPong
    bsr         MoveEnemy
    bra         EnemyShotLogic
