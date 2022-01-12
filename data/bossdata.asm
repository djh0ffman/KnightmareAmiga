
BossEnemySpawnFrames:
    dc.b    $55, $AA, $FF
    even

BossBoxDims:
    dc.w    $24, $24, 2, 2                       ; ...
    dc.w    $1A, $20, -$4, -$5
    dc.w    8, 8, $10, $10
    dc.w    $1A, $20, 3, -$9
    dc.w    $24, $20, $0D, 2
    dc.w    $24, $25, 8, 2
    dc.w    $0C, $0C, -$6, -$6
    dc.w    $20, $20, 8, 8

BossShotType:
    dc.b    8                                    ; witch
    dc.b    0                                    ; skull uses custom shot code
    dc.b    $a                                   ; bat
    dc.b    $b                                   ; cloak
    dc.b    $C
    dc.b    $D 
    even
    
KnightSpawnTimers:
    dc.b    $33, $66, $99, $CC, $FF
    even

BossHitCountList:
    dc.b    $14, $1E, $1E, $2D, $2D, $2D, $3C    ; ...
    even 
    
BossHitBoxDimensionList:
    dc.b    $0F2, $1A, $0F8, $10                 ; ...
    dc.b    0, $10, 0, $10
    dc.b    $0FE, $0E, $0FB, $11
    dc.b    1, $0B, $0F9, 5
    dc.b    $0F4, $1C, $0F2, $0C
    dc.b    $0F5, $1D, $0F8, $12
    dc.b    6, 6, 6, $0C
    even 

BossShadowOffsets:  ; y / x
    dc.w    34,0                                 ; witch
    dc.w    50,-11                               ; skull
    dc.w    50,-11                               ; bat
    dc.w    50,-12                               ; cloak
    dc.w    42,0
    dc.w    42,0
    dc.w    50,-11                               ; not used
    dc.w    42,4

BossStartPos:  ; y / x
    dc.w    $2000,$7000
    dc.w    $2000,$7800
    dc.w    $2000,$7800
    dc.w    $2000,$7800
    dc.w    $2000,$7000
    dc.w    $2000,$7000
    dc.w    $2000,$7000
    dc.w    $2000,$6800

PlayerShotHitBoxList:
    dc.b    4, 1                                 ; ...
    dc.b    4, 1                                 ; player shot boss hit data
    dc.b    $0D, 1                               ;
    dc.b    $0D, 1                               ; +0 = shot height
    dc.b    5, 1                                 ; +1 = number of hit points
    dc.b    $0D, 1
    dc.b    $0A, 2
    dc.b    $0A, 2
    dc.b    5, 2
    dc.b    5, 2
    dc.b    5, 2
    dc.b    5, 2

    even