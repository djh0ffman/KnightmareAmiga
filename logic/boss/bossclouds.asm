;----------------------------------------------------------------------------
;
; boss clouds
;
;----------------------------------------------------------------------------

    include    "common.asm"


; process the cloud enemies in the boss stage
;
; only present on certain stages

BossEnemyLogic:                                
    tst.b      BossId(a5)
    beq        BossEnemyLogic1
    rts

BossEnemyLogic1:
    lea        BossEnemy1(a5),a2
    moveq      #3-1,d7

.loop
    lea        BossEnemySpawnFrames,a0
    move.b     (a0,d7.w),d2

    addq.b     #1,ENEMY_FrameCount(a2)
    cmp.b      ENEMY_FrameCount(a2),d2
    bne        .skipinit

    tst.b      ENEMY_Status(a2)
    bne        .skipinit

    move.b     #1,ENEMY_Status(a2)
    move.b     #$c,ENEMY_Id(a2)             ; cloud
    move.w     #$1000,ENEMY_PosY(a2)

    addq.b     #1,BossEnemySpawnPosX(a5)
    move.b     BossEnemySpawnPosX(a5),d0
    and.b      #1,d0
    add.b      #$7f,d0
    clr.w      ENEMY_PosY(a2)
    move.b     d0,ENEMY_PosX(a2)

    bsr        PrepEnemyBobs

.skipinit
    tst.b      ENEMY_Status(a2)
    beq        .skiplogic
    move.b     ENEMY_Id(a2),d0
    and.w      #$f,d0
    bsr        RunEnemyLogic
    bsr        EnemyPlayerShotLogic
    bsr        EnemyCollisionLogic

.skiplogic
    lea        ENEMY_Sizeof(a2),a2
    dbra       d7,.loop
.exit
    rts

RemoveAllEnemyBoss:
    PUSH       a4
    lea        BobMatrix(a5),a4
    lea        BossEnemy1(a5),a2
    moveq      #3-1,d7
.loop1
    bsr        RemoveEnemy
    lea        ENEMY_Sizeof(a2),a2
    dbra       d7,.loop1

    lea        BobMatrix(a5),a4
    lea        EnemyList(a5),a2
    moveq      #ENEMY_COUNT-1,d7
.loop2
    bsr        RemoveEnemy
    lea        ENEMY_Sizeof(a2),a2
    dbra       d7,.loop2

    cmp.b      #7,BossId(a5)
    bne        .skipeyes

    lea        BobMatrix(a5),a4
    lea        EyeList(a5),a2
    moveq      #EYE_COUNT-1,d7
.eyeloop
    move.w     EYE_BobSlot(a2),d4
    clr.b      Bob_Allocated(a4,d4.w)
    lea        EYE_Sizeof(a2),a2
    dbra       d7,.eyeloop

.skipeyes
    POP        a4
    rts