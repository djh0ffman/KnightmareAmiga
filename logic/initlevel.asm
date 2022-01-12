;----------------------------------------------------------------------------
;
;  level initalise
;
;----------------------------------------------------------------------------

    include    "common.asm"


InitLevel:    
    bsr        HideGameScreen
    lea        BlackPal,a0
    move.w     #SCREEN_COLORS,d0
    bsr        LoadPalette
    bsr        LoadCopperScroll
    bsr        LoadCopperScroll

    bsr        BobClear
    bsr        KillEnemyShots
    clr.b      PowerUpStatus(a5)
    
    bsr        UnpackCollisionMap
    bsr        UnpackLevel
    st         DoubleBuffer(a5)

    clr.b      BossDeadFlag(a5)
    clr.b      BossStatus(a5)

    bsr        ClearQBlocks

    bsr        ClearEnemies

    move.b     #$80,BossAttackFlag(a5)

InitNotLevel6:
    clr.b      BossEnemy1(a5)
    clr.b      BossEnemy2(a5)
    clr.b      BossEnemy3(a5)

    tst.b      LevelInitFlag(a5)
    bne        InitPlayerPos
    
    move.b     #DEBUG_CHECKPOINT,CheckPoint(a5)
    move.b     #0,AttackWavePos(a5)
    move.b     #1,LevelInitFlag(a5)
    
    move.b     Level(a5),BossId(a5)

InitPlayerPos: 
    lea        PlayerStatus(a5),a0
    move.w     #$8700,PLAYER_PosY(a0)
    move.w     #$7800,PLAYER_PosX(a0)
    move.b     #PLAYERMODE_PLAY,PlayerStatus(a5)

    bsr        BobAllocate
    sf         Bob_Hide(a4)
    move.w     d0,PLAYER_BobSlot(a0)

    lea        PlayerBobPtrs(a5),a1

    bsr        ClearPlayerShots

    bsr        AttackWaveInit

PrepLevelDataPtrs:
    clr.b      GameFrame(a5)
    clr.b      LevelCheckPoint(a5)

    move.b     CheckPoint(a5),d0                    ; A * $18
    mulu       #$18,d0                              ; starts at zero, increments 1 per 8 pixels of the map
    move.b     d0,LevelPosition(a5)

    bsr        LoadLevelPal

RenderScreenLoop: 
    bsr        HideGameScreen
    bsr        ClearAllSprites
    bsr        MapInit

    cmp.b      #9,CheckPoint(a5)                    ; boss init will set this
    beq        .skipmusic

    bsr        SetLevelMusic
.skipmusic

    bra        QBlockInit

;----------------------------------------------------------------------------
;
;  set music
;
;----------------------------------------------------------------------------

SetLevelMusic:
    lea        LevelMusicList(pc),a0

SetMusic:
    moveq      #0,d1
    move.b     Level(a5),d1
    move.b     (a0,d1.w),d1

    moveq      #0,d0                                ; pattern start position
    bra        MusicSet

SetBossMusic:
    lea        BossMusicList(pc),a0
    bra        SetMusic

;----------------------------------------------------------------------------
;
;  unpack level
;
;----------------------------------------------------------------------------

UnpackTiles:
    moveq      #0,d0
    move.b     Level(a5),d0
    add.w      d0,d0
    add.w      d0,d0
    lea        LevelTilesList,a0
    move.l     (a0,d0.w),a0

    cmp.l      LastTileBuffer(a5),a0
    beq        .skip

    move.l     a0,LastTileBuffer(a5)
    lea        TileBuffer,a1
    sub.l      a2,a2
    bsr        ShrinklerDecompress
.skip
    rts

;----------------------------------------------------------------------------
;
;  unpack level
;
;----------------------------------------------------------------------------

UnpackLevel:
    lea        TileBuffer,a0
    lea        TilePointers(a5),a1
    bsr        SetDataPointers

    if         DEBUG_NOTILE=1
    lea        TileBuffer,a0
    move.w     #MAX_TILE_BIN-1,d7
.cleartiles
    clr.b      (a0)+
    dbra       d7,.cleartiles
    endif

    moveq      #0,d0
    move.b     Level(a5),d0
    add.w      d0,d0
    add.w      d0,d0
    lea        LevelMapList,a0
    move.l     (a0,d0.w),a0

    lea        MapBuffer(a5),a1
    bsr        doynaxdepack


    moveq      #0,d0
    move.b     Level(a5),d0
    add.w      d0,d0
    add.w      d0,d0
    lea        BossBobList,a0
    move.l     (a0,d0.w),a0

    lea        BossBuffer,a1
    bsr        doynaxdepack

    lea        BossBuffer,a0
    lea        BossBobPtrs(a5),a1
    bsr        SetDataPointers


    rts

; ---------------------------------------------------------------------------
LevelMusicList: 
    dc.b       MOD_BGM1
    dc.b       MOD_BGM2
    dc.b       MOD_BGM3
    dc.b       MOD_BGM4
    dc.b       MOD_BGM5
    dc.b       MOD_BGM6
    dc.b       MOD_BGM7
    dc.b       MOD_BGM8

BossMusicList: 
    dc.b       MOD_BOSS1
    dc.b       MOD_BOSS2
    dc.b       MOD_BOSS3
    dc.b       MOD_BOSS4
    dc.b       MOD_BOSS5
    dc.b       MOD_BOSS6
    dc.b       MOD_BOSS7
    dc.b       MOD_BOSS8
