
WaveRepeatList:
    dc.b    1                   ; ...
    dc.b    5
    dc.b    5
    dc.b    5
    dc.b    5
    dc.b    5
    dc.b    1
    dc.b    1
    dc.b    6
    dc.b    4
    dc.b    4
    dc.b    1
    dc.b    1
    dc.b    1
    dc.b    1
    dc.b    1
    even

AttackWaveRepeatTimers:
    dc.b    $01<<1              ; ...
    dc.b    $05<<1
    dc.b    $05<<1
    dc.b    $05<<1
    dc.b    $07<<1
    dc.b    $07<<1
    dc.b    $01<<1
    dc.b    $01<<1
    dc.b    $08<<1
    dc.b    $10<<1
    dc.b    $06<<1
    dc.b    $01<<1
    dc.b    $01<<1
    dc.b    $01<<1
    dc.b    $01<<1
    dc.b    $01<<1
    even

; data length of each attack wave

AttackWaveLength:
    dc.b    $22  
    dc.b    $29  
    dc.b    $29  
    dc.b    $26  
    dc.b    $24  
    dc.b    $21  
    dc.b    $1E
    dc.b    $23  
    even 

AttackWaveLevelList:
    dc.l    AttackWaveLevel1  
    dc.l    AttackWaveLevel2
    dc.l    AttackWaveLevel3
    dc.l    AttackWaveLevel4
    dc.l    AttackWaveLevel5
    dc.l    AttackWaveLevel6
    dc.l    AttackWaveLevel7
    dc.l    AttackWaveLevel8
    
; attack wave data - byte pairs
;
; +0 = high nibble
;       7 = ?
;       6 = repeat wave ?
;       5 = ?
;       4 = ?
;      low nibble enemy id
;
; +1 = high nibble spawn count
;      low nibble ??

;$00
;$02
;$04
;$07
;$0B
;$0e
;$11
;$14
;$19


AttackWaveLevel1:
    dc.b    $0E, $60            ;$00 *                                      ; ...
    dc.b    $2E, $44            ;$01
    dc.b    $41, $10            ;$02 *
    dc.b    $41, $10            ;$03
    dc.b    $41, $10            ;$04 *
    dc.b    $0E, $40            ;$05
    dc.b    $02, $40            ;$06
    dc.b    $02, $40            ;$07 *
    dc.b    $2E, $24            ;$08
    dc.b    $01, $20            ;$09
    dc.b    $01, $40            ;$0a
    dc.b    $01, $40            ;$0b *
    dc.b    $00, $13            ;$0c
    dc.b    $09, $40            ;$0d
    dc.b    $89, $40            ;$0e *
    dc.b    $AE, $64            ;$0f
    dc.b    $81, $60            ;$10
    dc.b    $41, $10            ;$11*
    dc.b    $C1, $10            ;$12
    dc.b    $C1, $10            ;$13
    dc.b    $AE, $23            ;$14 *
    dc.b    $C2, $10            ;$15
    dc.b    $C2, $10            ;$16
    dc.b    $C2, $10            ;$17
    dc.b    $8E, $80            ;$18
    dc.b    $00, $13            ;$19 *
    dc.b    $A9, $42            ;$1a
    dc.b    $81, $40            ;$1b
    dc.b    $81, $40            ;$1c
    dc.b    $AE, $43            ;$1d
    dc.b    $81, $60            ;$1e
    dc.b    $A1, $61            ;$1f
    dc.b    $89, $40            ;$20
    dc.b    $81, $A0            ;$21
AttackWaveLevel2:
    dc.b    $2E, $52
    dc.b    $82, $60
    dc.b    $82, $60
    dc.b    $04, $40
    dc.b    $84, $40
    dc.b    $E9, $13
    dc.b    $84, $40
    dc.b    $AE, $43
    dc.b    $C9, $10
    dc.b    $C9, $10
    dc.b    $00, $13
    dc.b    $0C, $20
    dc.b    $2C, $43
    dc.b    $82, $A0
    dc.b    $07, $30
    dc.b    $AE, $44
    dc.b    $C1, $10
    dc.b    $C1, $10
    dc.b    $C1, $10
    dc.b    $A7, $34
    dc.b    $C1, $10
    dc.b    $00, $12
    dc.b    $0B, $20
    dc.b    $E1, $11
    dc.b    $0B, $20
    dc.b    $E1, $13
    dc.b    $0B, $30
    dc.b    $AE, $82
    dc.b    $0B, $30
    dc.b    $A0, $22
    dc.b    $0B, $30
    dc.b    $A0, $31
    dc.b    $0B, $40
    dc.b    $A0, $41
    dc.b    $0B, $60
    dc.b    $A1, $A1
    dc.b    $03, $80
    dc.b    $A2, $A1
    dc.b    $03, $80
    dc.b    $A3, $81
    dc.b    $0B, $60
AttackWaveLevel3:
    dc.b    $4A, $10            ; ...
    dc.b    $4A, $10
    dc.b    $4A, $10
    dc.b    $4A, $10
    dc.b    $0B, $60
    dc.b    $AE, $42
    dc.b    $03, $60
    dc.b    $83, $40
    dc.b    $E1, $12
    dc.b    $0B, $40
    dc.b    $E1, $11
    dc.b    $0B, $40
    dc.b    $E1, $11
    dc.b    $0B, $60
    dc.b    $E1, $11
    dc.b    $0B, $60
    dc.b    $2C, $44
    dc.b    $84, $40
    dc.b    $C4, $10
    dc.b    $C4, $10
    dc.b    $C4, $10
    dc.b    $AE, $22
    dc.b    $A0, $42
    dc.b    $8E, $30
    dc.b    $A7, $42
    dc.b    $8A, $A0
    dc.b    $E4, $12
    dc.b    $CA, $10
    dc.b    $E4, $12
    dc.b    $0B, $40
    dc.b    $8B, $40
    dc.b    $AE, $42
    dc.b    $8A, $80
    dc.b    $A7, $61
    dc.b    $8B, $A0
    dc.b    $2C, $41
    dc.b    $81, $A0
    dc.b    $A2, $A1
    dc.b    $8A, $A0
    dc.b    $AB, $A1
    dc.b    $87, $40
AttackWaveLevel4:
    dc.b    $AE, $42            ; ...
    dc.b    $81, $40
    dc.b    $E1, $11
    dc.b    $84, $40
    dc.b    $C1, $10
    dc.b    $E1, $11
    dc.b    $84, $60
    dc.b    $AE, $83
    dc.b    $80, $60
    dc.b    $2C, $42
    dc.b    $8A, $A0
    dc.b    $E2, $11
    dc.b    $CA, $10
    dc.b    $00, $14
    dc.b    $AE, $42
    dc.b    $0B, $60
    dc.b    $C1, $10
    dc.b    $C1, $10
    dc.b    $E1, $11
    dc.b    $8B, $60
    dc.b    $A1, $81
    dc.b    $8B, $80
    dc.b    $2C, $52
    dc.b    $80, $80
    dc.b    $E3, $11
    dc.b    $80, $60
    dc.b    $E3, $11
    dc.b    $80, $80
    dc.b    $E4, $11
    dc.b    $81, $60
    dc.b    $E4, $11
    dc.b    $82, $60
    dc.b    $A9, $41
    dc.b    $CA, $10
    dc.b    $EA, $11
    dc.b    $C3, $10
    dc.b    $EA, $11
    dc.b    $C3, $10
AttackWaveLevel5:
    dc.b    $48, $10            ; ...
    dc.b    $48, $10
    dc.b    $AE, $41
    dc.b    $48, $10
    dc.b    $AE, $62
    dc.b    $89, $40
    dc.b    $89, $41
    dc.b    $88, $A0
    dc.b    $88, $40
    dc.b    $00, $12
    dc.b    $AE, $41
    dc.b    $25, $60
    dc.b    $45, $10
    dc.b    $45, $10
    dc.b    $2C, $41
    dc.b    $87, $40
    dc.b    $2C, $41
    dc.b    $85, $80
    dc.b    $85, $60
    dc.b    $2C, $21
    dc.b    $C5, $10
    dc.b    $2C, $21
    dc.b    $C5, $10
    dc.b    $A7, $41
    dc.b    $89, $40
    dc.b    $C8, $10
    dc.b    $C8, $10
    dc.b    $E8, $11
    dc.b    $C5, $10
    dc.b    $A8, $A1
    dc.b    $C5, $10
    dc.b    $2C, $41
    dc.b    $85, $60
    dc.b    $A5, $41
    dc.b    $0C, $41
    dc.b    $88, $80
AttackWaveLevel6:
    dc.b    $89, $80            ; ...
    dc.b    $A8, $81
    dc.b    $82, $80
    dc.b    $C2, $10
    dc.b    $C2, $10
    dc.b    $E2, $11
    dc.b    $89, $40
    dc.b    $A6, $48
    dc.b    $81, $60
    dc.b    $A6, $12
    dc.b    $C1, $10
    dc.b    $C1, $10
    dc.b    $AF, $B2
    dc.b    $85, $F0
    dc.b    $E5, $11
    dc.b    $89, $60
    dc.b    $AF, $62
    dc.b    $82, $D0
    dc.b    $C5, $10
    dc.b    $C5, $10
    dc.b    $85, $81
    dc.b    $81, $A0
    dc.b    $C1, $10
    dc.b    $AF, $61
    dc.b    $85, $A0
    dc.b    $A2, $A1
    dc.b    $85, $A0
    dc.b    $A5, $41
    dc.b    $82, $60
    dc.b    $A2, $A1
    dc.b    $85, $A0
    dc.b    $A3, $A1
    dc.b    $85, $A0
AttackWaveLevel7:
    dc.b    $0D, $80            ; ...
    dc.b    $C8, $10
    dc.b    $C8, $10
    dc.b    $A0, $81
    dc.b    $8B, $80
    dc.b    $8D, $60
    dc.b    $E8, $11
    dc.b    $8B, $80
    dc.b    $C8, $10
    dc.b    $C8, $10
    dc.b    $2C, $42
    dc.b    $80, $60
    dc.b    $AD, $A2
    dc.b    $8B, $C0
    dc.b    $8D, $40
    dc.b    $2C, $41
    dc.b    $88, $40
    dc.b    $88, $60
    dc.b    $A0, $81
    dc.b    $84, $80
    dc.b    $A8, $A1
    dc.b    $8D, $A0
    dc.b    $A4, $81
    dc.b    $8D, $C0
    dc.b    $A8, $A1
    dc.b    $8B, $A1
    dc.b    $8D, $80
    dc.b    $A0, $A1
    dc.b    $8B, $A1
    dc.b    $8D, $80
AttackWaveLevel8:
    dc.b    $AB, $C3            ; ...
    dc.b    $81, $80
    dc.b    $A1, $82
    dc.b    $A9, $62
    dc.b    $8B, $40
    dc.b    $A8, $A2
    dc.b    $8B, $80
    dc.b    $A5, $42
    dc.b    $81, $40
    dc.b    $A1, $81
    dc.b    $80, $80
    dc.b    $A8, $81
    dc.b    $8B, $80
    dc.b    $00, $12
    dc.b    $2C, $41
    dc.b    $A0, $61
    dc.b    $8B, $60
    dc.b    $A1, $81
    dc.b    $A2, $81
    dc.b    $83, $80
    dc.b    $AB, $A1
    dc.b    $2C, $41
    dc.b    $AD, $62
    dc.b    $81, $40
    dc.b    $A5, $61
    dc.b    $8A, $60
    dc.b    $A8, $A1
    dc.b    $85, $80
    dc.b    $00, $11
    dc.b    $2C, $82
    dc.b    $A0, $41
    dc.b    $8B, $80
    dc.b    $AB, $81
    dc.b    $A5, $61
    dc.b    $89, $50
    even