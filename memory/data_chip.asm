;----------------------------------------------------------------------------
;
; chip data
;
;----------------------------------------------------------------------------
    section    knightmare_data_chip,data_c
    cnop       0,2


TimerSpritePower1:     
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0,0

TimerSpritePower2:     
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0,0



TimerSprite1A:     
    dc.w       $0000,$0000
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0,0

TimerSprite1B:     
    dc.w       $0000,$0000
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0000,$00
    dc.w       $0,0

TimerSprite2A:   
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0,0

TimerSprite2B:   
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0,0

TimerSpriteColonA:   
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0c00,$0000
    dc.w       $0c00,$0000
    dc.w       $0000,$0000
    dc.w       $0c00,$0000
    dc.w       $0c00,$0000
    dc.w       $0000,$0000
    dc.w       $0,0

TimerSpriteColonB:   
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0000,$0000
    dc.w       $0c00,$0000
    dc.w       $0c00,$0000
    dc.w       $0000,$0000
    dc.w       $0c00,$0000
    dc.w       $0c00,$0000
    dc.w       $0000,$0000
    dc.w       $0,0

KonamiLogo:
    incbin     "assets/konamilogo.bin"


    include    "data/barsprites.asm"
    include    "data/copperlists.asm"
    include    "data/bobincludes.asm"
    include    "data/sampleschip.asm"



HUD:
    incbin     "assets/hud.raw"

SoundBank:    
    incbin     "assets/soundbankraw.bin"

