����                                        openlibrary = -30-522
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
splo:	move.l	4(a6),d0
	and.l	#$1ff00,d0
	cmpi.l	#$13700,d0
	bne.s	splo

	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9c(a6)
	move.l	$6c.w,old

	move.l	#screen1,drawadr
	move.l	#screen2,dispadr
	move.w	#$8400,$dff096
	bsr.w	init
	
	move.l	dispadr,d0
	move.w	d0,pl1l
	swap	d0
	move.w	d0,pl1h
	swap 	d0

;	add.l	#40,d0	
;	move.w	d0,pl2l
;	swap	d0
;	move.w	d0,pl2h
;	swap 	d0
;
;	add.l	#40,d0	
;	move.w	d0,pl3l
;	swap	d0
;	move.w	d0,pl3h

	move.w #$3081,$dff08e
	move.w #$30c1,$dff090
	move.w #$0038,$dff092
	move.w #$00d0,$dff094
	move.w #%0001001000000000,$dff100
	clr.w  $dff102
	clr.w  $dff104
	move.w	#00,$dff108
	move.w	#00,$dff10a

	move.l	#irq,$6c.w
	move.l	a7,stack

	move.l	#cladr,$dff080
	clr.w 	$dff088

	move.w	#%1000001111000000,$96(a6)
	move.w	#$c020,$9a(a6)

mainloop:

	btst	#6,$bfe001
	bne.w	mainloop

leave:	move.l	stack(pc),a7
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

;*****main program*****

init:
	move.w	#$0,$dff180
	move.w	#$fff,$dff182

	lea	buff(pc),a0
	moveq	#0,d0
	move.w	#40,d1
	move.l	#256,d2
.l1:	move.w	d0,(a0)+
	add.w	d1,d0
	dbf	d2,.l1

	rts

;variables

dispadr:	dc.l	0
drawadr:	dc.l	0

wartosc1:	dc.l	0
wartosc2:	dc.l	0
wartosc3:	dc.l	0

stack:		dc.l	0

;constants
; -----------------------------------------	
grname: dc.b "graphics.library",0
	even

BLTCPTH = $48 
BLTDPTH = $54
BLTCMOD = $60
BLTDMOD = $66
BLTAPTH = $50
BLTAPTL = $52
BLTAMOD = $64
BLTBMOD = $62
BLTCON0 = $40
BLTCON1 = $42
BLTSIZE = $58

onel:	macro
	move.w	#\1,d0
	move.w	#\2,d1
	move.w	#\3,d2
	move.w	#\4,d3
	bsr	draw_scp
	endm

;**************** nareszcie ***************
irq:	movem.l	d0-d7/a0-a6,-(sp)
	andi.w	#$20,$dff01e
	beq.w	out
	move.w	#$20,$dff09c

;	addq	#1, delay
;	and.w	#$3f, delay
;	bne.s	out

;	bsr.w	show

	bsr	draw_init

	move.l	#-1,$dff044
	move.l	#$ffff8000,$dff072
	move.w	#40, BLTCMOD(a6)
	move.w  #40, BLTDMOD(a6)

	move.l	#660, d7
.l01	move.l	d7, -(sp)

;	move.w	#$400,$dff096
.wb	btst	#6,$dff002
	bne.s	.wb
;	bsr.w	wblit
;	move.w	#$8400,$dff096


	move.l	drawadr(pc),a2

	move.l	a2, BLTCPTH(a6)
	move.l  a2, BLTDPTH(a6)
	move.w	#$0F, BLTAPTL(a6)
	move.w	#$00, BLTAMOD(a6)
	move.w	#$1E, BLTBMOD(a6)
	move.w	#$9BCA, BLTCON0(a6)
	move.w	#$51, BLTCON1(a6)
	move.w	#$3C2, BLTSIZE(a6)

	move.l	(sp)+, d7
	dbf	d7, .l01
	
	move.w	#$222,$dff180

	bsr	swap


out:	movem.l	(sp)+,d0-d7/a0-a6
	rte
	
old:	dc.l 0
delay:	dc.l 0

cladr:
	dc.w	$e0
pl1h:	dc.w	0,$e2
pl1l:	dc.w	0,$e4
pl2h:	dc.w	0,$e6
pl2l:	dc.w	0,$e8
pl3h:	dc.w	0,$ea
pl3l:	dc.w	0,$ec
	dc.w	0
	dc.w	$180,0

	dc.w	$ffff,$fffe

;*************** pozostale dane ****************

frame:	dc.w	0
addr2:	dc.l	anim_data+2

nolin:	dc.w	0

; draw one animation frame
; -------------------------------
show:	
	bsr	cls

	move.w	frame,d6
	add.w	#1,d6
	move.w	anim_data,d0
	cmp.w	d0,d6
	bne.s	.dal
	move.l	#anim_data+2,addr2
	moveq	#0,d6
.dal:
	move.w	d6,frame
	
	bsr	draw_init

	move.l	addr2,a0
	move.w	(a0)+,d7
	subq	#1,d7

	move.w	#0,nolin

.ll:	move.w	d7,-(a7)
	
	movem.w	(a0)+,d0-d3
		
	move.l	a0,-(a7)
	move.w	nolin,d6
;	cmp.w	#100,d6
;	beq	.sd
	addq.w	#1,d6
	move.w	d6,nolin
	bsr	draw
.sd:

	move.w	#100,d0
	move.w	#12,d1
	move.w	#200,d2
	move.w	#13,d3
;	bsr	draw
;	bsr	draw_scp

	move.l	(a7)+,a0

	move.w	(a7)+,d7
	dbf	d7,.ll

	move.l	a0,(addr2)

;OK:
	onel	100,2,200,3
;	onel	100,2,200,22
;	onel	100,2,200,82
;	onel	100,2,200,102

;OK:
;	onel	102,2,2,2
;	onel	102,2,2,22
;	onel	102,2,2,82
;	onel	102,2,2,102

;OK:
;	onel	102,2,102,102
;	onel	102,2,122,102
;	onel	102,2,182,102
;	onel	102,2,202,102

;OK:
;	onel	102,2,102,102
;	onel	102,2,82,102
;	onel	102,2,22,102
;	onel	102,2,2,102


;	move.w	#$220,$dff180

	rts

; swap screens
; -------------------------------
swap:
	move.l	dispadr,d0
	move.l	drawadr,dispadr
	move.l	d0,drawadr
	move.l	dispadr,d0
	move.w	d0,pl1l
	swap	d0
	move.w	d0,pl1h
	swap 	d0
	rts

buff:	blk.l	400,0

; wait for blitter
; -------------------------------
wblit:
	btst	#6,$dff002
	bne.s	wblit
	rts

; clear screen
; -------------------------------
cls:	move.l	#$dff000,a6
	move.l	drawadr,a0
	move.w	#$400,$dff096
	bsr.w	wblit
	move.w	#$8400,$dff096
	move.l	#-1,$44(a6)
	move.w	#0,$dff066
	move.l	a0,$dff054
	move.l	#$01000000,$dff040
	move.w	#212*64+20,$dff058

	rts

; draw line init
;--------------------------------
draw_init:
	lea	$dff000,a6
	lea	buff(pc),a4
	move.w	#$400,$dff096
	bsr.w	wblit
	move.w	#$8400,$dff096
	move.l	#-1,$dff044
	move.l	#$ffff8000,$dff072
	move.w	#40,$dff060
	move.w	#40,$dff066
	rts

;d0-x1
;d1-y1
;d2-x2
;d3-y2
draw_scp:
	lea	$dff000, a6
	move.l	drawadr, a2

	sub.w	d1,d3
	bpl	.super
	add.w	d1,d3
	exg	d0,d2
	exg	d1,d3
	sub.w	d1,d3
.super:
	sub.w	d0,d2

	cmp	d2,d3
	bne	.dal
	tst.w	d2
	bne	.dal
	rts

.dal:

	mulu	#40,d1
	move.w	d0,d4
	lsr.w	#4,d4
	lsl.w	#1,d4
	add.w	d4,d1
	add.l	d1,a2

	move.w	d3,d1	;dy
	move.w	d0,d3	;przechowaj x1
	move.w	d2,d0
	
	and.w	#15,d3
	ror.w	#4,d3
	or.w	#$BCA,d3


;	move.w	#120,d0
;	move.w	#30,d1


	moveq	#%00001,d2
	tst.w	d0
	bpl	.dx_pos
	neg.w	d0
	moveq	#%10101,d2
	cmp.w	d1,d0
	bpl	.SUD_OK_ex
	moveq	#%01001,d2
	bra	.SUD_OK

.dx_pos:
	cmp.w	d1,d0
	bmi	.SUD_OK
	bset	#4,d2
.SUD_OK_ex:
	exg	d1,d0
.SUD_OK:

;	move.l	d0,aa
;	move.l	d1,bb
;	move.l	d2,cc
;	rts

					;d1 = LDelta
					;d0 = SDelta
	move.w	d0,d4
	add.w	d0,d4		;2*SDelta
	move.w	d4,d5
	sub.w	d1,d5		;2*SDelta - LDelta
	bmi	.SIG_OK
	bset	#6,d2
.SIG_OK:
	move.w	d5,d6
	sub.w	d1,d6

	mulu	#64,d1
	add.w	#2,d1

	move.w	#$400,$dff096
	bsr.w	wblit
	move.w	#$8400,$dff096
	move.l	#-1,$dff044
	move.l	#$ffff8000,$dff072

	move.l	a2, BLTCPTH(a6)
	move.l  a2, BLTDPTH(a6)
	move.w	#40, BLTCMOD(a6)
	move.w  #40, BLTDMOD(a6)
	move.w	d5, BLTAPTL(a6)
	move.w	d6, BLTAMOD(a6)
	move.w	d4, BLTBMOD(a6)
	move.w	d3, BLTCON0(a6)
	move.w	d2, BLTCON1(a6)
	move.w	d1, BLTSIZE(a6)
	rts

aa:	dc.l	0
bb:	dc.l	0
cc:	dc.l	0



; draw a line
;--------------------------------
;  d0,d1   : x,y line start
;  d2,d3   : x,y line end
;  a4      : buffer with line addresses
;--------------------------------
draw:
	move.l	drawadr(pc),a2
	moveq	#15,d4
	cmp.w	d1,d3
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
	or.w	#$0bca,d4
	swap	d7
	move.w	d4,d7
	swap	d7
	move.w	d0,d6
	addq.w	#1,d6
	lsl.w	#6,d6
	addq.w	#2,d6
	sub.w	d0,d2
;	or.w	#2,d7		;lines for blitter filling
	bge.s	wblit2
	ori.b	#$40,d7
wblit2:	btst	#14,$dff002
	bne.s	wblit2
	move.w	d1,$dff062	;d1=2*sdelta do bltbmod
	move.w	d2,d1		;d2=2*sdelta do d1
	sub.w	d0,d1		;d1-d0=2*sdelta-2*ldelta
	move.w	d1,$dff064	;d1=2*sdelta-2*ldelta=bltamod
;	swap	d7
;	move.b	#$ca,d7		;drawing with OR mode
;	swap	d7
	move.l	d7,$dff040
	move.l	a2,$dff048
	move.l	a2,$dff054
	move.w	d2,$dff052
;	bchg	d5,(a2)		;needed only for filling
	move.w	d6,$dff058
exit_p:	rts

; FORMAT
;
; ADDR.W - adres pierwszej linii
; DX.B
; DY.B
; X1.4B

; ADDR.W 


anim_data:
	incbin	'test4s.dat'

	even	
screen1:
	blk.b	planesize,0

screen2:
	blk.b	planesize,0

screen3:
	blk.b	planesize,0
