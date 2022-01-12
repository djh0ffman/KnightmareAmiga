vasmm68k_mot knightmare.asm -o knightmare.o -m68000 -Fhunk -ignore-mult-inc -nowarn=2047
vlink knightmare.o -bamigahunk -oknightmare.exe -bamigahunk -Bstatic
