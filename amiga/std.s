openlibrary = -30-522
allocmem    = -30-168
freemem     = -30-180
;graphics base

startlist   = 38

execbase    = 4
planesize   = 40*256
chip        = 2
clear       = chip+$10000

;************* pre-program *********

start:	move.l	#begin,$80.w
	trap	#0
	moveq	#0,d0
	rts

begin:	lea	$dff000,a6
	move.w	$1c(a6),wartosc1
	move.w	$02(a6),wartosc2
	move.w	$1e(a6),wartosc3
	ori.w	#$c000,wartosc1
	ori.w	#$8000,wartosc2
	ori.w	#$8000,wartosc3
.wline:	move.l	4(a6),d0
	and.l	#$1ff00,d0
	cmpi.l	#$13700,d0
	bne.s	.wline

	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9c(a6)
	move.l	$6c.w,old

	move.l	#screen1,planeadr
	move.l	#screen3,clsadr
	move.l	#screen2,midleadr
	move.w	#$8400,$dff096

	bsr.w	init
	
	move.l	planeadr,d0
	move.w	d0,pl1l
	swap	d0
	move.w	d0,pl1h
	swap 	d0

	add.l	#40,d0	
	move.w	d0,pl2l
	swap	d0
	move.w	d0,pl2h
	swap 	d0

	add.l	#40,d0	
	move.w	d0,pl3l
	swap	d0
	move.w	d0,pl3h

	move.w #$3081,$dff08e
	move.w #$30c1,$dff090
	move.w #$0038,$dff092
	move.w #$00d0,$dff094
	move.w #%0011001000000000,$dff100
	clr.w  $dff102
	clr.w  $dff104
	move.w	#80,$dff108
	move.w	#80,$dff10a

	move.l	#int,$6c.w
	move.l	a7,stack

	move.l	#copper,$dff080
	clr.w 	$dff088

	move.w	#%1000001111000000,$96(a6)
	move.w	#$c020,$9a(a6)

.mainloop:


	btst	#6,$bfe001
	bne.w	.mainloop


exit:	move.l	stack(pc),a7
	lea	$dff000,a6
	bsr.w	wblit
	move.l	old(pc),$6c.w
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9c(a6)
	move.w	wartosc3(pc),$9c(a6)
	move.w	wartosc2(pc),$96(a6)
	move.w	wartosc1(pc),$9a(a6)
	lea	grname(pc),a1
	moveq	#0,d0
	move.l	$4.w,a6
	jsr	openlibrary(a6)
	move.l	d0,a6
	lea	$dff000,a5
	move.l	startlist(a6),$dff080
	move.w	d0,$dff088
	rte

init:	move.w	#$000,$dff180
	move.w	#$fff,$dff182
	move.w	#$fff,$dff184
	move.w	#$fff,$dff186
	move.w	#$fff,$dff188
	move.w	#$fff,$dff18a
	move.w	#$fff,$dff18c
	move.w	#$fff,$dff18e

	rts

planeadr:	dc.l	0
clsadr:		dc.l	0
midleadr:	dc.l	0

flaga:		dc.l	0
counter:	dc.l	0
wartosc1:	dc.l	0
wartosc2:	dc.l	0
wartosc3:	dc.l	0
stack:		dc.l	0
old:		dc.l 0

; constants
; ----------------------------------
grname: dc.b "graphics.library",0
	even

; interrupt routine
; ----------------------------------
int:	movem.l	d0-d7/a0-a6,-(sp)
	andi.w	#$20,$dff01e
	beq.w	out
	move.w	#$20,$dff09c
	
	moveq	#10, d0
	moveq	#10, d1
	moveq	#100, d2
	moveq	#100, d3
	bsr	draw

	bsr	swap

out:	movem.l	(sp)+,d0-d7/a0-a6
	rte
	

; copper program
; ----------------------------------
copper:	dc.w	$e0
pl1h:	dc.w	0,$e2
pl1l:	dc.w	0,$e4
pl2h:	dc.w	0,$e6
pl2l:	dc.w	0,$e8
pl3h:	dc.w	0,$ea
pl3l:	dc.w	0,$ec
	dc.w	0

	dc.w	$ffff,$fffe

; swap screens
; ----------------------------------
swap:
	move.l	clsadr,d0
	move.l	planeadr,clsadr
	move.l	midleadr,planeadr
	move.l	midleadr,d1
	move.l	d0,midleadr
	move.l	d1,d0
	move.w	d0,pl1l
	swap	d0
	move.w	d0,pl1h
	swap 	d0
	add.l	#40,d0	
	move.w	d0,pl2l
	swap	d0
	move.w	d0,pl2h
	swap 	d0
	add.l	#40,d0	
	move.w	d0,pl3l
	swap	d0
	move.w	d0,pl3h
	rts

; wait for blitter ready
; ----------------------------------
wblit:	btst	#6,$dff002
	bne.s	wblit
	rts

; clear screen
; ----------------------------------
cls:
	rts

; draw line
; ----------------------------------
;    d0, d1 -x, y line start
;    d2, d3 -x, y line end
; ----------------------------------
draw:	move.l	midleadr(pc),a2
	moveq	#15,d4
	cmp.w	d1,d3
	beq.w	exit_p
	ble.s	moon
	exg	d0,d2
	exg	d1,d3
moon:	and.w	d2,d4
	move.w	d4,d5
	not.b	d5
	sub.w	d3,d1
	ext.l	d3
	add.w	d3,d3
	move.w	(a4,d3.w),d3
	sub.w	d2,d0
	blt.s	tron
	cmp.w	d0,d1
	bge.s	prince
	moveq	#$11,d7
	bra.s	speedy
prince:	moveq	#1,d7
	exg	d1,d0
	bra.s	speedy
tron:	neg.w	d0
	cmp.w	d0,d1
	bge.s	only
	moveq	#$15,d7
	bra.s	speedy
only:	moveq	#$9,d7
	exg	d1,d0
speedy: add.w   d1,d1
	lsr.w	#3,d2
;	ext.l	d2
	add.w	d2,d3
	add.w	d3,a2
	move.w	d1,d2
	swap	d4
	lsr.l	#4,d4
	or.w	#$0b6a,d4
	swap	d7
	move.w	d4,d7
	swap	d7
	move.w	d0,d6
	addq.w	#1,d6
	lsl.w	#6,d6
	addq.w	#2,d6
	sub.w	d0,d2
	or.w	#2,d7
	bge.s	wblit2
	ori.b	#$40,d7
wblit2:	btst	#14,$dff002
	bne.s	wblit2
	move.w	d1,$dff062	;d1=2*sdelta do bltbmod
	move.w	d2,d1		;d2=2*sdelta do d1
	sub.w	d0,d1		;d1-d0=2*sdelta-2*ldelta
	move.w	d1,$dff064	;d1=2*sdelta-2*ldelta=bltamod
	move.l	d7,$dff040
	move.l	a2,$dff048
	move.l	a2,$dff054
	move.w	d2,$dff052
	bchg	d5,(a2)
	move.w	d6,$dff058
exit_p	rts
		
	even
screen1:
	blk.b	3*planesize,0

	even
screen2:
	blk.b	3*planesize,0

screen3:
	blk.b	3*planesize,0
