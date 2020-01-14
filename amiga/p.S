openlibrary = -30-522
allocmem    = -30-168
freemem     = -30-180
startlist   = 38
execbase    = 4
planesize   = 40*256
chip        = 2
clear       = chip+$10000

BLTCPTH     = $48 
BLTDPTH     = $54
BLTCMOD     = $60
BLTDMOD     = $66
BLTAPTH     = $50
BLTAPTL     = $52
BLTAMOD     = $64
BLTBMOD     = $62
BLTCON0     = $40
BLTCON1     = $42
BLTSIZE     = $58

;-----------------------------------
;screen memory in low memory
;-----------------------------------
screen1	    = $1000
screen2     = $4000

;-----------------------------------
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

    bsr     raster_wait
    bsr     raster_wait

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

	bsr	move_out

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

leave:
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9c(a6)

    bsr     raster_wait
    bsr     raster_wait

	bsr	move_in

	move.l	stack(pc),a7
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
move_out:
	lea	$1000,a0
	lea	movebuffer,a1
	move.w	#$4000,d7
.l01	move.l	(a0), (a1)+
	clr.l	(a0)+
	dbf	d7, .l01
	rts

move_in:
	lea	$1000,a0
	lea	movebuffer,a1
	move.w	#$4000,d7
.l01	move.l	(a1)+, (a0)+
	dbf	d7, .l01
	rts

raster_wait:
	move.l	4(a6),d0
	and.l	#$1ff00,d0
	cmpi.l	#$13700,d0
	bne.s	raster_wait
	rts

;*****main program*****
dr0:
	neg.w	d0
	rts

;=================
dr1:
	neg.w	d0
	exg	d1,d0
	rts
	
;=================
dr2:
	rts

;=================
dr3:
	exg	d1,d0
	rts

oneL:	macro
	move.w	(a0)+,d6
	move.w	d6,(a1)+
	subq.w	#1,d6
	blt.s	.\@2
.\@1:
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	sub.w	d2,d0
	mulu	#40,d3
	move.w	d2,d4
	lsr.w	#3,d4
	add.w	d4,d3
	bsr	\1
	add.w	d1,d1
	and.w	#15,d2
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	moveq	#0,d0
	moveq	#0,d3

	dbf	d6,.\@1
.\@2:
	endm

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

	lea	anim_data_old,a0
	lea	anim_data_in,a1
	move.w	(a0)+,d7	;frames
	move.w	d7,(a1)+
	subq.w	#1,d7
.AL:

	oneL	dr0
	oneL	dr1
	oneL	dr2
	oneL	dr3

	dbf	d7,.AL

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

;**************** nareszcie ***************
irq:	movem.l	d0-d7/a0-a6,-(sp)
	andi.w	#$20,$dff01e
	beq.w	out
	move.w	#$20,$dff09c

; do not display on every frame
;	addq	#1, delay
;	and.w	#$3f, delay
;	bne.s	out

	bsr.w	show
	bsr	swap

	move.w	#$221,$dff180

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
addr2:	dc.l	anim_data_in+2

oneOct:	macro

	move.w	(a0)+,d7
	subq	#1,d7
	blt.s	\@3

\@1:	movem.w	(a0)+,d0-d3
	add.w	a3,d3			;potencjalnie mozna od razu to dodawac przy konwersji

	ror.l	#4,d2
	or.l	d6,d2	;magia d4
			;d1 = 2 x sdelta, d0 = 2 x ldelta

	move.w	d1,d4

	move.w	d0,d5
	add.w	a1,d5	;#$0801
	rol.w	#6,d5
	sub.w	d0,d4
	bge.s	\@2
	ori.b	#$40,d2		;SIGN
\@2:
	btst	#14,(a6)	;!!!!!!!!!!!!
	bne.s	\@2
	move.w	d1,$062-2(a6)	;d1=2*sdelta do bltbmod
	move.w	d4,$052-2(a6)
	sub.w	d0,d4		;d1-d0=2*sdelta-2*ldelta
	move.w	d4,$064-2(a6)	;d1=2*sdelta-2*ldelta=bltamod
	move.w	d3,$048+2-2(a6)	;screen addr
	move.w	d3,$054+2-2(a6)
	move.l	d2,$040-2(a6)	;16
	move.w	d5,$058-2(a6)

	dbf	d7,\@1
\@3:
	endm

; draw one animation frame
; -------------------------------
show:
	bsr	cls

	move.w	frame(pc),d6
	addq.w	#1,d6
	cmp.w	anim_data_in,d6
	bne.s	.dal
	move.l	#anim_data_in+2,addr2		;restart from frame #1
;	move.l	nolin(pc),d0
;	move.l	d0,nolin2
	moveq	#0,d6
.dal:
	move.w	d6,frame

	bsr	draw_init

	move.l	addr2(pc),a0
	move.w	#$0801,a1

	move.l	#$0bca0015,d6
	oneOct
	move.l	#$0bca0009,d6
	oneOct
	move.l	#$0bca0011,d6
	oneOct
	move.l	#$0bca0001,d6
	oneOct

	move.l	a0,(addr2)

;	move.w	#$011, $dff180

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
	move.l	drawadr(pc),a3
	move.w	#0,$048(a6)
	move.w	#0,$054(a6)
	addq.l	#2,a6
	rts




; draw a line
;--------------------------------
;  d0,d1   : x,y line start
;  d2,d3   : x,y line end
;  a4      : buffer with line addresses
;  a3      : drawadr
;--------------------------------

drawN:
	move.l	a3,d5

	moveq	#15,d4

	and.w	d2,d4
;	sub.w	d3,d1			;opt
	add.w	d3,d3
	add.w	(a4,d3.w),d5
	sub.w	d2,d0
	blt.s	.tron
	cmp.w	d0,d1
	bge.s	.prince
	moveq	#$11,d7
	bra.s	.speedy
.prince:
	moveq	#1,d7
	exg	d1,d0
	bra.s	.speedy
.tron:	neg.w	d0
	cmp.w	d0,d1
	bge.s	.only
	moveq	#$15,d7
	bra.s	.speedy
.only:	moveq	#$9,d7
	exg	d1,d0
.speedy:
;	rrrr

; FORMAT
;
; ADDR.W - adres pierwszej linii
; DX.B
; DY.B
; X1.4B

; ADDR.W 


anim_data_in:
	blk.b	230000
anim_data_old:
	incbin	'line4big256.txt.dat'

movebuffer:
	blk.b	65536,0


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
				;d0 = SDelta
	move.w	d0,d4
	add.w	d0,d4		;2*SDelta
	move.w	d4,d5
	sub.w	d1,d5		;2*SDelta - LDelta
	bpl	.SIG_OK
	bset	#6,d2
.SIG_OK:
	move.w	d5,d6
	sub.w	d1,d6

	mulu	#64,d1
	add.w	#2,d1

;	move.w	#$400,$dff096
.wb:	btst	#14,$dff002
	bne.s	.wb
;	move.w	#$8400,$dff096
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

