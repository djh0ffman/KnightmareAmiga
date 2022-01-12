
;----------------------------------------------------------------------------
; 
; Power up data
; 
; stream of bytes ending with $ff
; 
; bit 7   = weapon / power-up
; bit 6-0 = position on level
;
;----------------------------------------------------------------------------

PowerUpLevelData:
    dc.l    PowerUpLevel1
    dc.l    PowerUpLevel2
    dc.l    PowerUpLevel3
    dc.l    PowerUpLevel4
    dc.l    PowerUpLevel5
    dc.l    PowerUpLevel6
    dc.l    PowerUpLevel7
    dc.l    PowerUpLevel8

PowerUpLevel1:
    dc.b    $8C, $98, $24, $30, $0B6, $3C, $0C8, $0D4, $60, $0FF 
PowerUpLevel2:
    dc.b    $8C, $98, $24, $30, $0B6, $3C, $0C8, $0D4, $60, $0FF 
PowerUpLevel3:
    dc.b    $8C, $98, $24, $30, $0B6, $3C, $0C8, $0D4, $60, $0FF 
PowerUpLevel4:
    dc.b    $8C, $98, $24, $30, $0B6, $3C, $0C8, $0D4, $60, $0FF 
PowerUpLevel5:
    dc.b    $8C, $98, $24, $30, $0B6, $3C, $0C8, $0D4, $60, $0FF 
PowerUpLevel6:
    dc.b    $8C, $92, $18, $0A4, $2A, $0B0, $36, $0C2, $48, $0CE, $54, $0DA 
    dc.b    $60, $0FF
PowerUpLevel7:
    dc.b    $8C, $92, $18, $0A4, $2A, $0B0, $36, $0C2, $48, $0CE, $54, $0DA 
    dc.b    $60, $0FF
PowerUpLevel8:
    dc.b    $8C, $92, $18, $0A4, $2A, $0B0, $36, $0C2, $48, $0CE, $54, $0DA 
    dc.b    $60, $0FF
    even

PowerUpDefaults:
    dc.b    0, 0, 0, $E0, 0, 0, $9F, 0, 0, 0, 0, $40, 0, 0, 0, 1
    even    


WeaponIdList:
    dc.b    0, 0, 0, 2, 8, 6, 4, $A                                            ; actual list
PowerUpIdList:
    dc.b    0, 0, 0, 1, 2, 3, 4
    even