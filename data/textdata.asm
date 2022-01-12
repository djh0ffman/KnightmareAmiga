
Credits:
    dc.b     "THANK YOU FOR PLAYING",0,0,0
    dc.b     "KNIGHTMARE",0,0,0,0
    dc.b     "AN AMIGA PORT PRODUCED BY",0,0,0
    dc.b     "HOFFMAN",0,0
    dc.b     "AND",0,0
    dc.b     "TONI GALVEZ",0,0
    dc.b     "2021",0
    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    dc.b     "ORIGINAL GAME RELEASED BY",0,0,0
    dc.b     "KONAMI",0,0
    dc.b     "1986",0
    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    dc.b     "CREDITS - AMIGA",0,0,0,0
    dc.b     "CODE MUSIC AND SFX",0,0
    dc.b     "HOFFMAN",0,0,0,0
    dc.b     "GRAPHICS",0,0
    dc.b     "TONI GALVEZ",0
    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    dc.b     "# SPECIAL THANKS TO #",0,0,0
    dc.b     "MANUEL PAZOS",0,0
    dc.b     "H17CH",0,0
    dc.b     "AMIGA BILL",0,0
    dc.b     "RETRO32",0,0
    dc.b     "AMIGA FOR MORTALS",0,0
    dc.b     "GRAHAM - NAG",0,0
    dc.b     "MC GEEZER",0,0
    dc.b     "NIVRIG",0,0
    dc.b     "AMIGA GAMEDEV DISCORD",0,0
    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    dc.b     "PRESS FIRE",0,0
    dc.b     "TO CONTINUE",0,0
    dc.b     "THE ADVENTURE",0,0
    dc.b     0,0,0,0,0,0,0,0,0,0,0

    dc.b     "  ####   ####  ",0
    dc.b     " ###### ###### ",0  
    dc.b     "###############",0
    dc.b     "###############",0
    dc.b     " ############# ",0
    dc.b     "  ###########  ",0
    dc.b     "   #########   ",0
    dc.b     "    #######    ",0
    dc.b     "     #####     ",0
    dc.b     "      ###      ",0
    dc.b     "       #       ",0

    dc.b     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dc.b     -1

TextGameOver:
    dc.b     8,10
    dc.b     "GAME OVER",0

TextContinue:
    dc.b     11,10
    dc.b     "CONTINUE",0

TextGiveUp:
    dc.b     13,10
    dc.b     "EXIT",0

TextContinueClear:
    dc.b     11,10
    dc.b     "        ",0

TextGiveUpClear:
    dc.b     13,10
    dc.b     "    ",0

TextStage:
    dc.b     10,10
    dc.b     "STAGE "
TextStageNum:
    dcb.b    10,0


TextEnding1:
    dc.b     14,0
    dc.b     "YOU HAVE BEATEN ALL THE DEMONS !",0

TextEnding2:
    dc.b     18,6
    dc.b     "# LOVE IS FOREVER #",0


TextAutoFireOn:
    dc.b     2,2
    dc.b     "ON ",0

TextAutoFireOff:
    dc.b     2,2
    dc.b     "OFF",0

TextVideo1:
    dc.b     5,2
    dc.b     "DEFAULT",0
TextVideo2:
    dc.b     5,2
    dc.b     "50HZ   ",0
TextVideo3:
    dc.b     5,2
    dc.b     "60HZ   ",0


TextMenu:
    dc.b     1,2
    dc.b     "AUTOFIRE",-1

    dc.b     4,2
    dc.b     "VIDEO MODE",-1

    dc.b     7,2
    dc.b     "MUSIC TEST",-1

    dc.b     10,2
    dc.b     "SFX TEST",-1
    
    dc.b     14,2
    dc.b     "EXIT",0

TextMusicClear:
    dc.b     8,2
    dc.b     "                              ",0

TextSfxClear:
    dc.b     11,2
    dc.b     "                              ",0

TextShop:
    dc.b     01,(32-12)/2
    dc.b     "LAZARUS SHOP",0

TextShop1:
    dc.b     5,0
    dc.b     "  20K 40K 50K 50K 50K 50K",0 

TextShop2:
    dc.b     12,(32-17)/2
    dc.b     "SELECT A POWER UP",0

TextShop3:    
    dc.b     14,(32-21)/2
    dc.b     "FOR YOUR RESURRECTION",0


TextScoreBoard:
    dc.b     1,(32-28)/2
    dc.b     "KNIGHTS WHO MARE THE HARDEST",0


SCORE_CHAR_COUNT = ScoreCharsEnd-ScoreChars

ScoreChars:
    dc.b     "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .!?-#"
ScoreCharsEnd:

    even