;----------------------------------------------------------------------------
;
; boss clouds
;
;----------------------------------------------------------------------------

    include    "common.asm"


; process the cloud enemies in the boss stage
;
; only present on certain stages

BossEnemyLogic:                                   ; ...
    ;ld      a, (BossId)
    ;cp      0
    ;ret     nz
    tst.b      BossId(a5)
    beq        BossEnemyLogic1
    rts

BossEnemyLogic1:
;BossEnemyLogic1:                                  ; ...
    ;ld      a, (GameFrame)
    ;rra
    ;ret     c
    ;ld      ix, BossEnemy1
    ;ld      b, 3
    lea        BossEnemy1(a5),a2
    moveq      #3-1,d7

;BossEnemyLoop:                                    ; ...
.loop
    ;ld      hl, BossEnemySpawnFrames    ; the frame number which each enemy gets initialized
    ;ld      a, b
    ;call    ADD_A_HL
    ;ld      c, (hl)                     ; get the init frame number

    lea        BossEnemySpawnFrames,a0
    move.b     (a0,d7.w),d2

    ;inc     (ix+ENEMY_FrameCount)
    ;ld      a, (ix+ENEMY_FrameCount)
    ;cp      c
    ;jr      nz, BossEnemyInitSkip
    addq.b     #1,ENEMY_FrameCount(a2)
    cmp.b      ENEMY_FrameCount(a2),d2
    bne        .skipinit

    ;ld      a, (ix+ENEMY_Status)
    ;or      a
    ;jr      nz, BossEnemyInitSkip       ; enemy already spawn, skip
    tst.b      ENEMY_Status(a2)
    bne        .skipinit

    ;ld      (ix+ENEMY_Status), 1        ; make enemy active
    ;ld      (ix+ENEMY_Id), 0Ch          ; enemy type cloud
    ;ld      (ix+ENEMY_PosY), 10h        ; starting Y position
    ;ld      hl, BossEnemySpawnPosX
    ;inc     (hl)
    ;ld      a, (hl)
    ;and     1
    ;add     a, 7Fh
    ;ld      (ix+ENEMY_PosX), a          ; starting pos x
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

;BossEnemyInitSkip:                                ; ...
.skipinit
    ;push    bc
    ;ld      a, (ix+ENEMY_Id)
    ;call    RunEnemyLogic
    ;call    EnemyPlayerShotLogic
    ;call    EnemyCollisionLogic
    ;bsr        EnemyPlayerShotLogic
    ;bsr        EnemyCollisionLogic

    tst.b      ENEMY_Status(a2)
    beq        .skiplogic
    move.b     ENEMY_Id(a2),d0
    and.w      #$f,d0
    bsr        RunEnemyLogic
    bsr        EnemyPlayerShotLogic
    bsr        EnemyCollisionLogic

.skiplogic

    ;pop     bc
    ;ld      a, b
    ;exx
    ;add     a, a
    ;add     a, a
    ;add     a, a
    ;ld      de, BossEnemySpriteAttRam
    ;call    ADD_A_DE
    ;ld      a, (ix+ENEMY_SpriteId)
    ;cp      1Ch
    ;ld      hl, byte_7896                ; cloud sprite att 1
    ;jr      z, BossEnemySpriteUpdate
    ;ld      hl, byte_789E                ; cloud sprite att 2

;BossEnemySpriteUpdate:                            ; ...
    ;ld      b, 2

;BossEnemySpriteLoop:                              ; ...
    ;ld      a, (ix+ENEMY_Status)
    ;or      a
    ;ld      a, (ix+ENEMY_PosY)
    ;jr      nz, BossEnemySpriteSet
    ;ld      a, 0CAh                      ; enemy not active, set sprite off screen

;BossEnemySpriteSet:                               ; ...
    ;add     a, (hl)
    ;ld      (de), a                      ; sprite y
    ;inc     hl
    ;inc     de
    ;ld      a, (ix+ENEMY_PosX)
    ;add     a, (hl)
    ;ld      (de), a                      ; sprite x
    ;inc     hl
    ;inc     de
    ;ld      a, (hl)
    ;add     a, 0C0h
    ;ld      (de), a                      ; sprite id
    ;inc     hl
    ;inc     de
    ;ldi
    ;djnz    BossEnemySpriteLoop
    ;exx
    ;ld      de, 20h                      ; ' '
    ;add     ix, de                       ; move to next enemy
    ;djnz    BossEnemyLoop                ; the frame number which each enemy gets initialized
    ;ret
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