
;----------------------------------------------------------------------------
;
; Init Audio System
;
;----------------------------------------------------------------------------

    include     "common.asm"

AudioInit:    
    moveq       #0,d0
    move.w      PalFlag(a5),d0

    ;moveq       #1,d0                                               ; TODO : pal flag

    lea         system_variables,a0
    move.l      sys_vectorbase(a0),a0

    lea         CUSTOM,a6
    jsr         _mt_install_cia
    rts

AudioRemove:
    lea         CUSTOM,a6
    jsr         _mt_remove_cia
    rts

;----------------------------------------------------------------------------
;
; Inits the SFX sample buffer
;
; unloads any room sfx already loaded and resets the buffer
;
;----------------------------------------------------------------------------

SfxBufferInit:
;    move.w      SoundCount(a5),d0
;    beq         .empty
;
;    lea         SoundPointers(a5),a1
;    lea         SoundListLoaded(a5),a0
;    subq.b      #1,d0
;.loop
;    moveq       #0,d1
;    move.b      (a0)+,d1
;    add.w       d1,d1
;    add.w       d1,d1
;    clr.l       (a1,d1.w)
;    dbra        d0,.loop
;.empty
;    move.l      #SoundBuffer,SoundBufferPtr(a5)                   ; reset buffer poitner
;    clr.w       SoundCount(a5)                                    ; clear the sound count

SfxStopAll:
    moveq       #0,d0
    jsr         _mt_stopfx
    moveq       #1,d0
    jsr         _mt_stopfx
    moveq       #2,d0
    jsr         _mt_stopfx
    moveq       #3,d0
    jsr         _mt_stopfx

    rts

;----------------------------------------------------------------------------
;
; SfxHardStop - stop everything!
;
;----------------------------------------------------------------------------

SfxHardStop:
    clr.l       ModPatternPtr(a5)
    clr.b       _mt_Enable
    jmp         _mt_end



;----------------------------------------------------------------------------
;
; Unpack Sfx
;
; unpack an Sfx to the sound buffer and loads the pointer into the list
;
; d0 = sound id
; a3 = sound buffer pointer! (location of the long word!)
;
;----------------------------------------------------------------------------

SfxUnpack:
    PUSHMOST
    lea         SoundIndex(a5),a0
    lea         SoundPointers(a5),a2

    and.w       #$ff,d0
    add.w       d0,d0
    add.w       d0,d0
    move.l      (a0,d0.w),d1
    beq         .nosound
    move.l      d1,a0

    tst.w       Sound_Type(a0)
    bne         .nosound                                            ; not a sound effect

    move.l      (a3),a1                                             ; get current pointer position
    move.l      a1,(a2,d0.w)                                        ; store the destionation pointer for playback

    move.w      Sound_PackedSize(a0),d7
    lea         Sound_Data(a0),a0

    bsr         Delta4Unpack                                        ; unpack
    move.l      a1,(a3)                                             ; store current pointer position

    POPMOST
    rts
.nosound 
    DEBUG_ME
    POPMOST
    rts



;----------------------------------------------------------------------------
;
; Play sfx (if its unpacked)
;
; d0 = sound id
;
;----------------------------------------------------------------------------
SfxPlayAllChan:
    if          DEBUG_NOSOUND=1
    rts
    endif
    PUSHALL
    moveq       #-1,d7                                              ; channels hack
    bra         SfxPlayHack

SfxPlay:
    if          DEBUG_NOSOUND=1
    rts
    endif

    tst.b       SfxDisable(a5)
    beq         .go
    rts
.go    
    PUSHALL
    moveq       #0,d7                                               ; channels hack
SfxPlayHack:
    lea         SoundIndex(a5),a1
    lea         SoundPointers(a5),a2

    and.w       #$ff,d0
    move.w      d0,d6                                               ; backup Id

    add.w       d0,d0
    add.w       d0,d0                                               ; index value

    move.l      (a1,d0.w),d1                                        ; sound params etc.
    beq         .error                                              ; sound not yet implemented
    move.l      d1,a1

    move.l      d1,d2
    add.l       #Sound_Data,d2

    ; -- sfx processing
    lea         PtSfx_Params(a5),a0

    ;move.l      (a2,d0.w),d2
    ;beq         .error                                            ; sound data not unpacked

    move.w      Sound_Period(a1),d3                                 ; current period
    moveq       #0,d4
    move.b      Sound_Rand(a1),d4
    beq         .skiprand

    RANDOM
    and.w       d4,d0                                               ; and rand factor
    sub.w       d0,d3

.skiprand
    move.l      d2,PtSfx_Ptr(a0)                                    ; pointer
    move.w      Sound_Size(a1),PtSfx_Len(a0)   
    move.w      d3,PtSfx_Per(a0)                                    ; length (in words)
    move.w      Sound_Volume(a1),PtSfx_Vol(a0)   

    move.b      d7,PtSfx_Cha(a0)                                    ; channel hack
    bne         .allchan
    move.b      Sound_Channel(a1),PtSfx_Cha(a0)   
.allchan
    ;move.b      #-1,PtSfx_Cha(a0)   
    ;move.b      Sound_Priority(a1),PtSfx_Pri(a0)   
    move.b      d6,PtSfx_Pri(a0)   
    tst.b       Sound_Looped(a1)
    beq         .straight

    jsr         _mt_loopfx
    bra         .done
.straight
    jsr         _mt_playfx
.done            
    POPALL
    rts


.error
    nop
            ;DEBUG_ME
    POPALL
    rts


;----------------------------------------------------------------------------
;
; play powerup sfx which is a mod
; 1. store the current pattern
; 2. flag up we're playing a temporary mod
; 3. detect when the mod has finished playing
; 4. restart game music from previous position
;
; this turned out FAR more convoluted that I thought it would be!
;----------------------------------------------------------------------------

PowerUpCollectSfx:
    cmp.b       #POWERUP_GRADIUS,PlayerStatus+PLAYER_PowerUp(a5)
    beq         .exit

    tst.b       PowerUpSfxActive(a5)
    bne         .exit                                               ; already active, do not do this!

    bsr         MusicSave 

    moveq       #0,d0
    moveq       #MOD_POWERUP,d1                                     ; power up mod
    bsr         MusicSet
    move.b      #1,PowerUpSfxActive(a5)
    move.b      #1,SfxDisable(a5)
.exit
    rts

PowerUpCollectSfxCheck:
    tst.b       PowerUpSfxActive(a5)
    beq         .exit                                               ; not active, quit

    tst.b       _mt_Enable
    bne         .exit

    clr.b       SfxDisable(a5)

    tst.b       FreezeStatus(a5)
    bne         .exit

    clr.b       PowerUpSfxActive(a5)                                ; flag off
    bra         MusicRestore

.exit
    rts


MusicSave:
    move.b      mt_data+mt_SongPos,ModPreviousPat(a5)
    move.w      mt_data+mt_Tempo,ModPreviousTempo(a5)
    move.b      mt_data+mt_Speed,ModPreviousSpeed(a5)
    rts

MusicRestore:
    move.w      ModLastUnpacked(a5),d1
    moveq       #0,d0
    move.b      ModPreviousPat(a5),d0
    bsr         MusicSet
    clr.w       ModPreviousTempo(a5)                                ; remove previous tempo
    clr.b       ModPreviousSpeed(a5)
    rts

;----------------------------------------------------------------------------
;
; Load weapon sfx
;
; load sfx used everywhere
;
; d0 = selected weapon
;
;----------------------------------------------------------------------------

;SfxUnpackAll:
;    PUSHMOST
;    lea         SoundListAll,a0
;
;    lea         SoundBufferPtr(a5),a3                             ; buffer pointer
;    move.l      #SoundBuffer,(a3)
;.loop
;    move.b      (a0)+,d0
;    cmp.b       #-1,d0
;    beq         .done
;    bsr         SfxUnpack
;    bra         .loop
;.done
;    POPMOST
;    rts

;----------------------------------------------------------------------------
;
; Music set - setup music
;
; d0 = pattern start pos
; d1 = mod id
;
;----------------------------------------------------------------------------

MusicSetHard:
    PUSHMOST
    bra         MusicSet1

MusicSet:
    PUSHMOST
    btst        #6,ControlConfig(a5)
    bne         MusicSet1
    POPMOST
    rts

MusicSet1:

    PUSHM       a0/d0
    jsr         _mt_end
    POPM        a0/d0
    
    lea         ModList,a0
    move.w      d1,d2
    add.w       d2,d2
    add.w       d2,d2
    move.l      (a0,d2.w),ModPatPtr(a5)

    lea         ModPackedList,a3
    tst.b       (a3,d1.w)
    beq         .skipunpack

    bsr         ModPrepDynamicSmp
.skipunpack
    move.l      ModPatPtr(a5),a0
    lea         ModSamplePtrs(a5),a1
    move.w      ModPreviousTempo(a5),d4
    bne         .bpmok
    move.w      #125,d4
.bpmok
    move.b      ModPreviousSpeed(a5),d5
    bne         .speedok
    moveq       #6,d5
.speedok
    jsr         _mt_init
    clr.b       ModFadeStatus(a5)
    move.b      #1,_mt_Enable
.exit
    POPMOST
    rts

MusicPause:
    PUSHMOST
    clr.b       _mt_Enable
    moveq       #0,d0
    jsr         _mt_mastervol
    POPMOST
    rts

MusicPlay:
    tst.b       PowerUpSfxActive(a5)
    bne         .exit
    PUSHMOST
    move.b      #1,_mt_Enable
    moveq       #64,d0
    jsr         _mt_mastervol
    POPMOST
.exit    
    rts


MusicFade:
    move.b      ModFadeStatus(a5),d0
    beq         .exit

    subq.b      #1,d0
    beq         .fadeinit

    ; do the fade
    subq.b      #1,ModFadeCounter(a5)
    bne         .exit
    move.b      ModFadeWait(a5),ModFadeCounter(a5)

    moveq       #0,d0
    move.b      ModFadeVolume(a5),d0
    jsr         _mt_mastervol

    subq.b      #1,ModFadeVolume(a5)
    bcc         .exit
    clr.b       ModFadeStatus(a5)
    
    jsr         _mt_end

    moveq       #64,d0
    jsr         _mt_mastervol
    bra         .exit

.fadeinit
    
    addq.b      #1,ModFadeStatus(a5)
    move.b      ModFadeWait(a5),ModFadeCounter(a5)
    move.b      #64,ModFadeVolume(a5)

.exit
    rts


;----------------------------------------------------------------------------
;
; copy dynamic samples from fast to chip for mod
;
; d1 = mod id
;
;----------------------------------------------------------------------------

ModPrepDynamicSmp:
    PUSHMOST
    move.w      d1,d0
    lea         ModSmpBuffer,a3                                     ; destination

    lea         ModSmpList,a0
    add.w       d0,d0
    add.w       d0,d0
    move.l      (a0,d0.w),a0                                        ; sample id's

    cmp.w       ModLastUnpacked(a5),d1
    beq         .pointpat                                           ; matching mod id, dont unpack samples
    move.w      d1,ModLastUnpacked(a5)

    lea         SampleList,a1
    lea         ModSamplePtrs(a5),a2
.loop
    moveq       #0,d0
    move.b      (a0)+,d0
    bmi         .smpdone

    move.w      d0,d1
    mulu        #10,d1                                              ; horrid constants, yes I know!
    move.l      2(a1,d1.w),a4                                       ; sample source
    move.l      6(a1,d1.w),d7                                       ; sample length

    add.w       d0,d0
    add.w       d0,d0                                               ; sample pointer id
    move.l      a3,(a2,d0.w)                                        ; store pointer position

    lsr.l       #1,d7                                               ; half (copy words)
    subq.l      #1,d7                                               ; dbra -1
;.copyloop
;    move.w      (a4)+,(a3)+
;    dbra        d7,.copyloop

    moveq       #4,d1                                               ; shift (1st nibble)
    moveq       #$f,d2                                              ; and value (2nd nibble)
    moveq       #0,d3                                               ; source byte (1st nibble)
    moveq       #0,d4                                               ; source byte (2nd nibble)
    moveq       #0,d5                                               ; delta sample

.unpackloop    
    move.b      (a4)+,d3                                            ; get source byte
    move.b      d3,d4                                               ; copy byte 
    lsr.b       d1,d3                                               ; shift first nibble
    and         d2,d4                                               ; and second nibble
	
    sub.b       .table(pc,d3),d5                                  
    move.b      d5,(a3)+
    sub.b       .table(pc,d4),d5
    move.b      d5,(a3)+
    dbf         d7,.unpackloop

    bra         .loop

.table    
    dc.b        0,1,2,4,8,16,32,64,128,-64,-32,-16,-8,-4,-2,-1


.smpdone
    move.l      ModPatPtr(a5),a0
    lea         PatternBuffer,a1
    bsr         doynaxdepack

.pointpat
    move.l      #PatternBuffer,ModPatPtr(a5)

.exit
    POPMOST
    rts



;----------------------------------------------------------------------------
;
; prep static mod sample pointers
;
;----------------------------------------------------------------------------

ModPrepStaticSmp:
    moveq       #MODSAMPLE_COUNT-1,d7
    lea         SampleList,a0
    lea         ModSamplePtrs(a5),a1
.loop
    moveq       #0,d0

    tst.w       (a0)
    bne         .dynamic
    move.l      2(a0),d0
.dynamic
    move.l      d0,(a1)+
    lea         10(a0),a0
    dbra        d7,.loop

    move.w      #-1,ModLastUnpacked(a5)                             ; ensures mod id 0 gets unpacked

    rts

;----------------------------------------------------------------------------
;
; undelta all the samples
;
;----------------------------------------------------------------------------

UnpackDeltaSamples:
    moveq       #MODSAMPLE_COUNT-1,d7
    lea         SampleList,a0
.loop
    addq.l      #2,a0
    move.l      (a0)+,a1
    move.l      (a0)+,d6

    moveq       #0,d2                                               ; delta
.smploop
    add.b       (a1),d2
    move.b      d2,(a1)+
    subq.l      #1,d6
    bne         .smploop
    dbra        d7,.loop
    rts

;UnpackDeltaSamplesOld:
;    lea         TuneSamples,a0                                    ; undelta samples
;    move.l      a0,a1
;.next
;    move.l      (a0)+,d0
;    bmi         .done
;    move.l      (a0)+,d7                                          ; length
;
;    move.l      a1,a2
;    add.l       d0,a2                                             ; pointer to sample
;    moveq       #0,d2                                             ; delta
;.smploop
;    add.b       (a2),d2
;    move.b      d2,(a2)+
;    subq.l      #1,d7
;    bne         .smploop
;    bra         .next
;.done
;    rts
;



;----------------------------------------------------------------------------
;
; 4 Bit PCM delta unpacker
;
; a0 = source
; a1 = destination
; d7 = data length
;
;----------------------------------------------------------------------------


Delta4Unpack:
    subq        #1,d7                                               ; dbra!

    moveq       #4,d1                                               ; shift (1st nibble)
    moveq       #$f,d2                                              ; and value (2nd nibble)
    moveq       #0,d3                                               ; source byte (1st nibble)
    moveq       #0,d4                                               ; source byte (2nd nibble)
    moveq       #0,d5                                               ; delta sample

.unpackloop    
    move.b      (a0)+,d3                                            ; get source byte
    move.b      d3,d4                                               ; copy byte 
    lsr.b       d1,d3                                               ; shift first nibble
    and         d2,d4                                               ; and second nibble
	
    sub.b       .table(pc,d3),d5                                  
    move.b      d5,(a1)+
    sub.b       .table(pc,d4),d5
    move.b      d5,(a1)+
    dbf         d7,.unpackloop

    rts

.table    
    dc.b        0,1,2,4,8,16,32,64,128,-64,-32,-16,-8,-4,-2,-1
