
;----------------------------------------------------------------------------
;
;  debug stats
;
;----------------------------------------------------------------------------

    include    "common.asm"

    if         DEBUG_STATS=1

DebugEnemyTypes:
    moveq      #0,d0
    moveq      #0,d1
    moveq      #0,d2
    moveq      #ENEMY_COUNT-1,d7
    lea        EnemyList(a5),a0
.loop
    moveq      #0,d0
    tst.b      ENEMY_Status(a0)
    beq        .notactive

    move.b     ENEMY_Id(a0),d0
    and.b      #$f,d0
    or.b       d0,d1
    or.b       #1,d2
.notactive
    ror.l      #4,d1
    ror.l      #4,d2
    lea        ENEMY_Sizeof(a0),a0
    dbra       d7,.loop
    move.l     d1,EnemyTypes(a5)
    move.l     d2,EnemyActive(a5)
    rts

DebugStats:
    PUSHALL
    ;bsr        DebugEnemyTypes

    lea        DebugText1(pc),a0
    lea        DebugList,a4
.loop
    move.l     (a4)+,d0
    cmp.l      #-1,d0
    beq        .exit
    
    move.l     d0,(a0)+
    moveq      #0,d0
    move.l     (a4)+,a3
    
    move.w     (a4)+,d2

    cmp.w      #DEBUG_BYTE,d2
    bne        .notbyte
    move.b     (a3),d0

.notbyte
    cmp.w      #DEBUG_WORD,d2
    bne        .notword
    move.w     (a3),d0

.notword
    cmp.w      #DEBUG_LONG,d2
    bne        .notlong
    move.l     (a3),d0

.notlong
    bsr        Hex2Ascii
    bra        .loop
.exit
    lea        DebugText1(pc),a0
    lea        Hud,a1
    bsr        TextPlot

    POPALL
    rts

Hex2Ascii:
    lea        HexLookUp(pc),a1
    moveq      #0,d1
    moveq      #8-1,d7
.loop
    rol.l      #4,d0
    move.b     d0,d1
    and.b      #$f,d1
    move.b     (a1,d1.w),(a0)+
    dbra       d7,.loop
    rts

DEBUG_BYTE = 0
DEBUG_WORD = 1
DEBUG_LONG = 2

DebugList:
    dc.b       "BPM "
    dc.l       Variables+LevelPosition
    dc.w       DEBUG_BYTE

    ;dc.b       "SPD "
    ;dc.l       mt_data+mt_Tempo
    ;dc.w       DEBUG_WORD

    ;dc.b       "L2  "
    ;dc.l       Variables+LevelId2
    ;dc.w       DEBUG_BYTE

    ;dc.b       "ETP "
    ;dc.l       Variables+EnemyTypes
    ;dc.w       DEBUG_LONG

    ;dc.b       "EAC "
    ;dc.l       Variables+EnemyActive
    ;dc.w       DEBUG_LONG

    ;dc.b       "MBC "
    ;dc.l       Variables+MapBlitCount
    ;dc.w       DEBUG_BYTE

    ;dc.b       "BNS "
    ;dc.l       Variables+BobNoShift
    ;dc.w       DEBUG_WORD

    ;dc.b       "BCN "
    ;dc.l       Variables+BobLiveCount
    ;dc.w       DEBUG_WORD

    ;dc.b       "CHK "
    ;dc.l       Variables+CheckPoint
    ;dc.w       DEBUG_BYTE

    ;dc.b       "CHK "
    ;dc.l       Variables+CheckPoint
    ;dc.w       DEBUG_BYTE

    ;cc.b       "AWP "
    ;dc.l       Variables+AttackWavePos
    ;dc.w       DEBUG_BYTE

    ;dc.b       "LPS "
    ;dc.l       Variables+LevelPosition
    ;dc.w       DEBUG_BYTE

    ;dc.b       "BOS "
    ;dc.l       Variables+BossStatus
    ;dc.w       DEBUG_BYTE


    dc.l       -1

HexLookUp: 
    dc.b       "0123456789ABCDEF"
    even

DebugText1:    
    dc.b       "                                ",0
    even

    endif