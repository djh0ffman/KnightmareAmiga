
;----------------------------------------------------------------------------
;
;  attack waves
;
;----------------------------------------------------------------------------

    include    "common.asm"

AttackWaveInit:
    lea        AttackWave1(a5),a0                                       ; clear attack waves
    move.w     #(ATTACKWAVE_Sizeof*ATTACKWAVE_COUNT)-1,d7
.attclear
    clr.b      (a0)+
    dbra       d7,.attclear

    clr.b      AttackWaveActive(a5)                                     ; set attack wave not active

    lea        AttackWaveLevelList,a1
    moveq      #0,d0
    move.b     Level(a5),d0
    add.w      d0,d0
    add.w      d0,d0
    move.l     (a1,d0.w),a1                                             ; attack wave data for this level

    lea        AttackWavePos(a5),a2
    subq.b     #1,(a2)

.nextpos
    subq.b     #1,(a2)                                                  ; move back one
    moveq      #0,d0
    move.b     (a2),d0                                                  ; get position

    cmp.b      #-2,d0                                                   ; if first two, reset to 0
    bcs        .checkpos                                                ; nope, check position

    clr.b      (a2)                                                     ; reset to zero
    rts

.checkpos
    add.b      d0,d0                                                    ; * 2 (attack wave data 2 bytes)

    move.b     1(a1,d0.w),d1                                            ; get 2nd byte

    and.b      #$f,d1                                                   ; get low nibble
    bne        .nextpos                                                 ; low nibble not empty, keep moving back?

    addq.b     #1,(a2)                                                  ; moves to correct position
    rts


;----------------------------------------------------------------------------
;
;  setup next attack
;
;----------------------------------------------------------------------------

SetupAttackWave:
    move.b     AttackWaveActive(a5),d0                                  ; attack waves are active
    bne        .check

    move.b     d0,AttackWaveTimer(a5)
    rts

.check
    move.b     TickCounter(a5),d0
    and.b      #$1e,d0
    bne        SetupAttackWaveExit

    lea        AttackWaveTimer(a5),a0
    move.b     (a0),d0
    and.b      #$7f,d0                                                  ; mask top bit
    beq        SetupAttackWave2
    subq.b     #1,(a0)
    rts

SetupAttackWave2:
    move.b     (a0),d0
    lsl.b      #1,d0

    bcs        SetupAttackWave3

    tst.b      AttackWave1(a5)                                          ; attack wave parameters 1
    bne        SetupAttackWaveExit

.next1
    tst.b      AttackWave2(a5)                                          ; attack wave parameters 2
    bne        SetupAttackWaveExit
.next2
    lea        EnemyList(a5),a1                                         ; check to ensure all enemys are gone??
    moveq      #ENEMY_COUNT-1,d6

.loop
    tst.b      ENEMY_Status(a1)                                         ; find enemy slot
    bne        SetupAttackWaveExit
    lea        ENEMY_Sizeof(a1),a1
    dbra       d6,.loop
    nop

SetupAttackWave3:
    lea        AttackWave1(a5),a0
    tst.b      (a0)
    beq        SetupAttackWave4

    lea        AttackWave2(a5),a0                                       ; no spare attack wave found
    tst.b      (a0)
    bne        SetupAttackWaveExit

SetupAttackWave4:
    moveq      #8-1,d6
    move.l     a0,a1
.loop
    clr.b      (a1)+
    dbra       d6,.loop

             
    lea        AttackWaveLevelList,a1                                   ; pointer to attack waves for each level
    moveq      #0,d0
    move.b     Level(a5),d0
    add.w      d0,d0
    add.w      d0,d0
    move.l     (a1,d0.w),a1                                             ; a1 now points to attack wave data

    lea        AttackWavePos(a5),a2                                     ; move attack wave data to current level position
    moveq      #0,d0 
    move.b     (a2),d0                                                  ; current attack wave / level position
    add.w      d0,d0
    add.l      d0,a1                                                    ; move attack wave data to current level position

    move.b     (a1)+,d2                                                 ; enemy type and params
    move.b     (a1),d1
    move.b     d2,ATTACKWAVE_Type(a0)

    lsr.b      #4,d1

    tst.b      EnemyShotsActive(a5) 
    beq        SetupAttackWave5

    move.b     d1,d0
    subq.b     #1,d0
    beq        SetupAttackWave5

    addq.b     #2,d1

SetupAttackWave5:
    move.b     d1,ATTACKWAVE_SpawnTotal(a0)

    move.b     (a1),d0
    and.b      #$f,d0

    add.b      d0,d0

    btst       #5,d2
    beq        SetupAttackWave6

    bset       #7,d0

SetupAttackWave6:
    move.b     d0,AttackWaveTimer(a5)

    moveq      #0,d0
    move.b     Level(a5),d0
    lea        AttackWaveLength,a1
    move.b     (a1,d0.w),d2

    addq.b     #1,(a2)                                                  ; AttackWavePos
    move.b     (a2),d0

    cmp.b      d2,d0
    bcs        SetupAttackWave7

    clr.b      (a2)                                                     ; cycle attack wave

SetupAttackWave7:
    move.b     ATTACKWAVE_Type(a0),d0
    btst       #6,d0
    beq        SetupAttackWaveExit

    lea        WaveRepeatList,a2
    and.w      #$f,d0                                                   ; a = enemy id

    move.b     (a2,d0.w),ATTACKWAVE_RepeatAgain(a0)
SetupAttackWaveExit:
    rts



;----------------------------------------------------------------------------
;
;  attack wave logic
;
;----------------------------------------------------------------------------

AttackWaveLogic:
    cmp.b      #$d0,LevelPosition(a5)                                   ; end of level for attack waves
    bcs        .doit
    rts

.doit
    lea        AttackWave1(a5),a1
    tst.b      (a1)
    beq        .skip1
    bsr        ProcessAttackWave
.skip1
    lea        AttackWave2(a5),a1
    tst.b      (a1)
    beq        .skip2
    bsr        ProcessAttackWave
.skip2
    rts

;----------------------------------------------------------------------------
;
; process attack wave
;
; a1 = attack wave structure
;
;----------------------------------------------------------------------------

ProcessAttackWave:
    tst.b      ATTACKWAVE_RepeatCount(a1)
    bne        ProcessAttackWaveRepeat                                  ; repeat count active

    tst.b      ATTACKWAVE_WaitDelay(a1)
    beq        ProcessAttackWaitComplete

    subq.b     #1,ATTACKWAVE_WaitDelay(a1)
    rts


ProcessAttackWaveRepeat:
    tst.b      ATTACKWAVE_RepeatWait(a1)
    beq        ProcessAttackWaveRepeat1

    subq.b     #1,ATTACKWAVE_RepeatWait(a1)
    rts

ProcessAttackWaveRepeat1:
    moveq      #0,d0
    move.b     ATTACKWAVE_Type(a1),d0
    and.b      #$f,d0
    lea        AttackWaveRepeatTimers,a2
    add.l      d0,a2

    move.b     (a2),d0
    move.b     d0,ATTACKWAVE_RepeatWait(a1)
    subq.b     #1,ATTACKWAVE_RepeatCount(a1)
    bra        AddEnemy

; ---------------------------------------------------------------------------

ProcessAttackWaitComplete:
    btst       #6,ATTACKWAVE_Type(a1)
    beq        AddEnemy
    move.b     ATTACKWAVE_RepeatAgain(a1),ATTACKWAVE_RepeatCount(a1)
    rts

