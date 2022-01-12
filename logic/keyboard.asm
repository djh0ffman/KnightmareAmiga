                  include    "common.asm"

*****************************************
** keyboard system
*****************************************


KeyboardInit:       
                  movem.l    d0-a6,-(a7)
                  lea        system_variables,a0
                  move.l     sys_vectorbase(a0),a0
                  move.l     $68(a0),StoreKeyboard
                  move.b     #CIAICRF_SETCLR|CIAICRF_SP,(ciaicr+$bfe001)            ;clear all ciaa-interrupts
                  tst.b      (ciaicr+$bfe001)
                  and.b      #~(CIACRAF_SPMODE),(ciacra+$bfe001)                    ;set input mode
                  move.w     #INTF_PORTS,(intreq+$dff000)                           ;clear ports interrupt
                  move.l     #KeyboardInterrupt,$68(a0)                             ;allow ports interrupt
                  move.w     #INTF_SETCLR|INTF_INTEN|INTF_PORTS,(intena+$dff000)
                  movem.l    (a7)+,d0-a6
                  rts

KeyboardRemove:        
                  movem.l    d0-a6,-(a7)
                  lea        system_variables,a0
                  move.l     sys_vectorbase(a0),a0
                  move.w     #INTF_SETCLR|INTF_PORTS,(intena+$dff000)
                  move.l     StoreKeyboard,$68(a0)
                  movem.l    (a7)+,d0-a6
                  rts	

KeyboardInterrupt:        
                  movem.l    d0-d1/a0-a2,-(a7)
	
                  lea        $dff000,a0
                  move.w     intreqr(a0),d0
                  btst       #INTB_PORTS,d0
                  beq        .end
		
                  lea        $bfe001,a1
                  btst       #CIAICRB_SP,ciaicr(a1)
                  beq        .end

                  move.b     ciasdr(a1),d0                                          ;read key and store him
                  or.b       #CIACRAF_SPMODE,ciacra(a1)
                  not.b      d0
                  ror.b      #1,d0
                  spl        d1
                  and.w      #$7f,d0
                  lea        Keys(pc),a2
                  move.b     d1,(a2,d0.w)

                  moveq      #3-1,d1                                                ;handshake
.wait1            move.b     vhposr(a0),d0
.wait2            cmp.b      vhposr(a0),d0
                  beq        .wait2
                  dbf        d1,.wait1

         	
                  and.b      #~(CIACRAF_SPMODE),ciacra(a1)                          ;set input mode

.end              move.w     #INTF_PORTS,intreq(a0)
                  tst.w      intreqr(a0)
KeyboardPatchPtr:
                  nop
                  nop
                  nop

                  movem.l    (a7)+,d0-d1/a0-a2
                  rte

Keys:             dcb.b      $80,0

StoreKeyboard:    dc.l       0
