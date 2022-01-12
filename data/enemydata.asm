
EnemyStartPosY:
    dc.b    $F0                                               ; ...
    dc.b    $F0
    dc.b    $F0
    dc.b    $88
    dc.b    $F0
    dc.b    $F0
    dc.b    $F0
    dc.b    $F0
    dc.b    $F0
    dc.b    $F0
    dc.b    $10
    dc.b    $01
    dc.b    $10
    dc.b    $01
    dc.b    $F0
    dc.b    $01
    even

EnemyStartPosX1:
    dc.b    $50                                               ; P                       ; ...
    dc.b    $28                                               ; (
    dc.b    $0B0
    dc.b    $80
    dc.b    $0D8
    dc.b    $7F                                               ; 
    dc.b    $0B0
    dc.b    $28                                               ; (
    even

EnemyWaitDelay:
    dc.b    $28<<1                                            ; (                       ; ...
    dc.b    $10<<1
    dc.b    $10<<1
    dc.b    $10<<1
    dc.b    $10<<1
    dc.b    $10<<1
    dc.b    $70<<1                                            ; p
    dc.b    $50<<1                                            ; P
    dc.b    $10<<1
    dc.b    $18<<1
    dc.b    $20<<1
    dc.b    $10<<1
    dc.b    $30<<1                                            ; 0
    dc.b    $28<<1                                            ; (
    dc.b    $40<<1                                            ; @
    dc.b    $30<<1                                            ; 0
    even

EnemyShadowOffsets:
    dc.b    $00                                               ; 0 - devil
    dc.b    $0c                                               ; 1 - bats
    dc.b    $0c                                               ; 2 - more bats?
    dc.b    $0c                                               ; 3 - bat low entry
    dc.b    $0c                                               ; 4 - gargoyle
    dc.b    $00                                               ; 5 - floating head
    dc.b    $00                                               ; 6 - hoodie
    dc.b    $00                                               ; 7 - bones
    dc.b    $0e                                               ; 8 - ghost
    dc.b    $00                                               ; 9 - blue knights
    dc.b    $0c                                               ; A - fireball
    dc.b    $0a                                               ; B - spike ball
    dc.b    $0c                                               ; C - clouds
    dc.b    $00                                               ; D - floating head blinker
    dc.b    $00                                               ; E - blob
    dc.b    $00                                               ; F - kong
    even 

EnemyScores:
    dc.w    100                                               ; normal
    dc.w    050
    dc.w    050
    dc.w    050
    dc.w    050
    dc.w    200
    dc.w    050
    dc.w    200
    dc.w    100
    dc.w    100
    dc.w    100
    dc.w    300
    dc.w    000
    dc.w    200
    dc.w    010
    dc.w    100         

EnemyScoresFreeze:     ; freeze scores
    dc.w    200
    dc.w    100
    dc.w    100
    dc.w    100
    dc.w    100
    dc.w    400
    dc.w    100
    dc.w    400
    dc.w    200
    dc.w    200
    dc.w    200
    dc.w    500
    dc.w    200
    dc.w    400
    dc.w    050
    dc.w    200     
    
HoodieShotSpeeds:
    dc.w    -$300/2, $0                                       ; ...
    dc.w    -$180/2, -$1c0/2                                  ; enemy shot speeds
    dc.w    $180/2, -$1c0/2                                   ;
    dc.w    $300/2, $0                                        ; +0 = speed y
    dc.w    $180/2, $1C0/2                                    ; +2 = speed x
    dc.w    -$180/2, $1C0/2

EnemyShotIds:
    dc.b    5                                                 ; 0 - devil
    dc.b    2                                                 ; 1 - bats
    dc.b    2                                                 ; 2 - more bats?
    dc.b    2                                                 ; 3 - bat low entry
    dc.b    3                                                 ; 4 - gargoyle
    dc.b    4                                                 ; 5 - floating head
    dc.b    7                                                 ; 6 - hoodie
    dc.b    6                                                 ; 7 - bones
    dc.b    3                                                 ; 8 - ghost
    dc.b    1                                                 ; 9 - blue knights
    dc.b    3                                                 ; A - fireball
    dc.b    3                                                 ; B - spike ball
    dc.b    1                                                 ; C - clouds
    dc.b    4                                                 ; D - floating head blinker
    dc.b    3                                                 ; E - blob
    dc.b    3                                                 ; F - kong
    even 

EnemyBoxDims:  ; actually shots
    dc.w    8, 8                                              ; non-enemy
    dc.w    8, 8                                              ; ...
    dc.w    2, 3
    dc.w    4, 4
    dc.w    8, 8
    dc.w    8, 8
    dc.w    $0A, $0A
    dc.w    4, 4
    dc.w    8, 8
    dc.w    $0E, $0E
    dc.w    8, 8
    dc.w    8, 8
    dc.w    $0C, $0C
    dc.w    8, 8
    dc.w    8, 8
    dc.w    $0C, $10

EnemyShotCounterList:
    dc.l    ShotCountersA                                     ; ...
    dc.l    ShotCountersA
    dc.l    ShotCountersB
    dc.l    ShotCountersC
    dc.l    ShotCountersD
    dc.l    ShotCountersE
    dc.l    ShotCountersF
    dc.l    ShotCountersG
    dc.l    ShotCountersH
    dc.l    ShotCountersI
    dc.l    ShotCountersJ
    dc.l    ShotCountersK
    dc.l    ShotCountersA
    dc.l    ShotCountersL
    dc.l    ShotCountersM
    dc.l    ShotCountersN

EnemyDimensions:
    dc.w    $FFFA, $FFFA, $0C, $0C                            ; ...
    dc.w    $FFFC, $FFFB, $08, $0A                            ; dimension data
    dc.w    $FFFC, $FFFB, $08, $0A                            ;
    dc.w    $FFFC, $FFFB, $08, $0A                            ; +0 = offset y
    dc.w    $FFFA, $FFFA, $0C, $0C                            ; +1 = offset x
    dc.w    $FFFB, $FFFA, $0A, $0A                            ; +2 = height
    dc.w    $FFFA, $FFFA, $0C, $0C                            ; +3 = width
    dc.w    $FFFA, $FFFC, $0A, $08
    dc.w    $FFFE, $FFFC, $08, $08
    dc.w    $FFFA, $FFFA, $0C, $0C
    dc.w    $FFFC, $FFFC, $08, $08
    dc.w    $FFFB, $FFFB, $0A, $0A
    dc.w    $FFFA, $FFFA, $0C, $0C
    dc.w    $FFFB, $FFFA, $0A, $0A
    dc.w    $FFFB, $FFFB, $0A, $0A
    dc.w    $FFFB, $FFFB, $0A, $0A

EnemyShotMulti:
    dc.b    0,0                                               ; spacer 
    dc.b    3, 4                                              ; ...
    dc.b    $82, 3                                            ; enemy shot multiplier table
    dc.b    2, $82                                            ;
    dc.b    3, 4                                              ; +0 = shot speed multiplier below stage 4
    dc.b    3, 4                                              ; +1 = shot speed multiplier above stage 4
    dc.b    2, $82                                            ; $80??  unsure but it looks like its a flag that was never used
    dc.b    3, 4
    dc.b    4, 4
    dc.b    0, 0                                              ; -- what is this??
    dc.b    4, 4
    dc.b    3, 3
    dc.b    4, 4
    dc.b    4, 4
    dc.b    4, 4

EnemyDeathStatusList:
    dc.b    6                                                 ; 0 - devil
    dc.b    3                                                 ; 1 - bats
    dc.b    3                                                 ; 2 - more bats?
    dc.b    4                                                 ; 3 - bat low entry
    dc.b    4                                                 ; 4 - gargoyle
    dc.b    7                                                 ; 5 - floating head
    dc.b    3                                                 ; 6 - hoodie
    dc.b    8                                                 ; 7 - bones
    dc.b    4                                                 ; 8 - ghost
    dc.b    4                                                 ; 9 - blue knights
    dc.b    5                                                 ; A - fireball
    dc.b    3                                                 ; B - spike ball
    dc.b    5                                                 ; C - clouds
    dc.b    4                                                 ; D - floating head blinker
    dc.b    3                                                 ; E - blob
    dc.b    6                                                 ; F - kong

ShotRepeatCount:
    dc.b    1, 1, 1, 1, 4, 1, 6, 1, 1, 7, 1, 2, 1, 1 
    even

EnemyShotCounterMax:
    dc.b    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 5, 4    ; ...
    even

ShotCountersA:
    dc.b    $10, $50, $90                                     ; ...
ShotCountersB:
    dc.b    $10, $28, $48                                     ; ...
ShotCountersC:
    dc.b    $30, 8, $50                                       ; ...
ShotCountersD:
    dc.b    $0B, $28, $48                                     ; ...
ShotCountersE:
    dc.b    $10, $60, $0B0                                    ; ...
ShotCountersF:
    dc.b    $50, $0A0, $0F0                                   ; ...
ShotCountersG:
    dc.b    $18, $70, $0C0                                    ; ...
ShotCountersH:
    dc.b    $10, $38, $90                                     ; ...
ShotCountersI:
    dc.b    $18, $60, $0A8                                    ; ...
ShotCountersJ:
    dc.b    $20, $50, $80                                     ; ...
ShotCountersK:
    dc.b    2, $0C, $17                                       ; ...
ShotCountersL:
    dc.b    $10, $50, $90                                     ; ...
ShotCountersM:
    dc.b    $10, $30, $50, $70, $90                           ; ...
ShotCountersN:
    dc.b    $10, $30, $50, $70                                ; ...
    even
