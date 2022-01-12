

BossBarSpr:
    incbin    "assets/boss-bar-final.spr"
    
BossBarList:
    dc.l      BossBar1aFull
    dc.l      BossBar1bFull
    dc.l      BossBar2aFull
    dc.l      BossBar2bFull
    dc.l      BossBar3aFull
    dc.l      BossBar3bFull
    dc.l      BossBar4aFull
    dc.l      BossBar4bFull



BossBarDisplayList:
    dc.l      BossHeader1a
    dc.l      BossHeader1b
    dc.l      BossHeader2a
    dc.l      BossHeader2b
    dc.l      BossBar3aFull
    dc.l      BossBar3bFull
    dc.l      BossBar4aFull
    dc.l      BossBar4bFull


BOSSBAR_SPRITE_SIZE = (10*4)+8

BossHeader1a:
    dcb.w     18,0

BossBar1aFull:     
    dcb.b     BOSSBAR_SPRITE_SIZE,0

BossHeader1b:
    dcb.w     18,0

BossBar1bFull:     
    dcb.b     BOSSBAR_SPRITE_SIZE,0

BossHeader2a:
    dcb.w     18,0

BossBar2aFull:     
    dcb.b     BOSSBAR_SPRITE_SIZE,0

BossHeader2b:
    dcb.w     18,0

BossBar2bFull:     
    dcb.b     BOSSBAR_SPRITE_SIZE,0

BossBar3aFull:     
    dcb.b     BOSSBAR_SPRITE_SIZE,0

BossBar3bFull:     
    dcb.b     BOSSBAR_SPRITE_SIZE,0

BossBar4aFull:     
    dcb.b     BOSSBAR_SPRITE_SIZE,0

BossBar4bFull:     
    dcb.b     BOSSBAR_SPRITE_SIZE,0
