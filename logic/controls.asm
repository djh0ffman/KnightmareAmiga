;----------------------------------------------------------------------------
;
;  controls
;
;----------------------------------------------------------------------------

    include    "common.asm"

;----------------------------------------------------------------------------
;
; Read controls	status
; Update "hold" and "trigger" values
;
;----------------------------------------------------------------------------

UpdateControls:
    bsr        ReadPads                  ; read joystick / pads
    bsr        ReadFKeys                 ; Read F1-F5 and RETURN keys
    lea        FKeysHold(a5),a3 
    bsr        StoreControls             ; Update hold and trigger status
    bsr        ReadControls              ; Read controls (keyboard and joystick)

StoreControls1:
    lea        ControlsHold(a5),a3
StoreControls:
    move.b     (a3),d1
    move.b     d0,(a3)
    eor.b      d1,d0
    and.b      (a3),d0
    subq.l     #1,a3
    move.b     d0,(a3)
QuitControls:    
    rts

;-------------------------------------------------------------
;
; Read pads
;
;-------------------------------------------------------------
ReadPads:
    clr.b      Joystick(a5)
    clr.b      Joystick2(a5)

    moveq      #1,d0                     ; port 1

    bsr        _read_joystick
    move.b     d0,d1                     ; backup UDLR
    swap       d0                        ; switch to buttons
    move.b     d0,d2                     ; copy fire 1 / 2
    lsr.b      #2,d2                     ; shift into msx position
    and.b      #$30,d2                   ; clear other bits
    or.b       d2,d1                     ; OR fire bits into UDLR
    or.b       d1,Joystick(a5)  
    lsr.w      #1,d0                     ; shift down to match f keys
    and.w      #$f,d0                    ; clear other bits
    or.b       d0,Joystick2(a5)
    rts

;-------------------------------------------------------------
;
; Read controls
;
; Out:
;    A = Result
;    bit 5 = Fire2 / M
;    bit 4 = Fire / Space
;    bit 3 = Right
;    bit 2 = Left
;    bit 1 = Down
;    bit 0 = Up
;-------------------------------------------------------------

KeyTest MACRO
    tst.b      (\1,a0)
    beq.b      .\@notpressed
    bset       #\2,d0
.\@notpressed
    ENDM

ReadControls:
    moveq      #0,d0
    lea        Keys,a0

    KeyTest    $4c,0
    KeyTest    $4d,1
    KeyTest    $4f,2
    KeyTest    $4e,3
    KeyTest    $40,4
    KeyTest    $37,5

    or.b       Joystick(a5),d0

    rts

;-------------------------------------------------------------
;
; Read function	keys and RETURN
;
; Out:
;    A = 0 ESC RET F5 F4 F3 F2 F1
;-------------------------------------------------------------

ReadFKeys:       
    moveq      #0,d0
    lea        Keys,a0
    KeyTest    $50,0
    KeyTest    $51,1
    KeyTest    $52,2
    KeyTest    $53,3
    KeyTest    $54,4
    KeyTest    $44,5
    KeyTest    $45,6

    or.b       Joystick2(a5),d0

    rts

    include    "logic/readjoypad.asm"
    include    "logic/keyboard.asm"