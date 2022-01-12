
PlayerShotData:
    dc.b    2, 6          ; ...
    dc.b    2, 6          ; pairs
    dc.b    2, 2          ;
    dc.b    3, 2          ; +0 = max shot count / loop
    dc.b    3, 5          ; +1 = shot offset x
    dc.b    3, 2
    dc.b    2, 3
    dc.b    3, 3
    dc.b    1, 6
    dc.b    1, 6
    dc.b    2, 4
    dc.b    3, 4
    dc.b    2, 6          ; 12 gradius lazer

PlayerShotDims:
    dc.w    $04, $08      ; ...
    dc.w    $04, $08
    dc.w    $0D, $08
    dc.w    $0D, $08
    dc.w    $04, $08
    dc.w    $0D, $08
    dc.w    $0A, $08
    dc.w    $0A, $08
    dc.w    $05, $05
    dc.w    $05, $05
    dc.w    $05, $08
    dc.w    $05, $08

    dc.w    $03, $08      ; 12 gradius lazer ( height is variable )
    even


; 0/2 - arrow
; 4 - sword
; 6 - boomerang
; 8 - fireball
; $a - fire arrow

; first bob id in the shot bobs
PlayerShotBobIdList:
    dc.b    0             ; 0 arrow single
    dc.b    0             ; 1 arrow single
    dc.b    1             ; 2 arrow double
    dc.b    1             ; 3 arrow double
    dc.b    2             ; 4 sword single
    dc.b    3             ; 5 sword double
    dc.b    9             ; 6 boomerang
    dc.b    9             ; 7 boomerang
    dc.b    5             ; 8 fireball
    dc.b    5             ; 9 fireball
    dc.b    4             ; $a fire arrow single
    dc.b    4             ; $b fire arrow double
    dc.b    13            ; gradius lazer
    even

; 0/2 - arrow
; 4 - sword
; 6 - boomerang
; 8 - fireball
; $a - fire arrow
; $c - gradius lazer

PlayerShotYSpeeds:
    dc.w    -$800/2       ; arrow
    dc.w    -$800/2       ; arrow
    dc.w    -$800/2       ; arrow
    dc.w    -$800/2       ; arrow
    dc.w    -$980/2       ; sword
    dc.w    -$980/2       ; sword
    dc.w    -$100/2       ; boomerang ; special logic but temp value here
    dc.w    -$100/2       ; boomerang ; special logic but temp value here
    dc.w    -$800/2       ; fireball
    dc.w    -$800/2       ; fireball
    dc.w    -$900/2       ; fire arrow
    dc.w    -$900/2       ; fire arrow
    dc.w    -$800         ; gradius lazer

BoomerangSpeeds:
    dc.w    -($C00>>2)
    dc.w    -($C00>>2)
    dc.w    -($B00>>2)
    dc.w    -($B00>>2)
    dc.w    -($A00>>2)
    dc.w    -($A00>>2)
    dc.w    -($900>>2)
    dc.w    -($900>>2)
    dc.w    -($900>>2)
    dc.w    -($900>>2)
    dc.w    -($800>>2)
    dc.w    -($800>>2)
    dc.w    -($800>>2)
    dc.w    -($700>>2)
    dc.w    -($700>>2)
    dc.w    -($600>>2)  
    dc.w    -($600>>2)
    dc.w    -($500>>2)
    dc.w    -($400>>2)
    dc.w    -($300>>2)
    dc.w    -($200>>2)
    dc.w    -($100>>2)
    dc.w    -($100>>2)
    dc.w    ($100>>2)
    dc.w    ($200>>2)
    dc.w    ($300>>2)
    dc.w    ($400>>2)
    dc.w    ($500>>2)
    dc.w    ($600>>2)
    dc.w    ($600>>2)  
    dc.w    ($700>>2)
    dc.w    ($700>>2)
    dc.w    ($800>>2)
    dc.w    ($800>>2)
    dc.w    ($800>>2)
    dc.w    ($900>>2)
    dc.w    ($900>>2)
    dc.w    ($900>>2)
    dc.w    ($900>>2)
    dc.w    ($A00>>2)
    dc.w    ($A00>>2)
    dc.w    ($B00>>2)
    dc.w    ($B00>>2)
    dc.w    ($C00>>2)
    dc.w    0

