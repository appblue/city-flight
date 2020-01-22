;*********************************************************
;*        STANDART BY DR.DF0  OF  ... ATD ...            *
;*             4 BITPLANY  I  SPRITE'Y                   *
;*********************************************************
Planesize=40*256


Wblit:	macro
	btst	#6,2(a6)
	bne.s	*-6
	endm



Start:
	move.l	#begin,$80.w
	trap	#0
	move.l	#0,d0
	rts

;*********************************************************
;*                   INICJALIZACJA                       *
;*********************************************************
Begin:
	lea	$dff000,a6
	move.w	$1c(a6),wart1
	move.w	$1e(a6),wart2
	move.w	$02(a6),wart3
	or.w	#$c000,wart1
	or.w	#$8000,wart2
	or.w	#$8000,wart3
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$9c(a6)
	move.w	#$7fff,$96(a6)
;	Bsr.w	Wymiana
	Bsr.w	Init
	move.l	#Copper,$80(a6)
	tst.w	$88(a6)
	move.l	$6c.w,old
	move.l	#Inter,$6c.w
	move.w	#$c020,$9a(a6)
	move.w	#%1000001111000000,$96(a6)

	movem.l	d0-d7/a0-a6,-(sp)
	Bsr.w	MyRoutine
	movem.l	(sp)+,d0-d7/a0-a6
	
	wblit
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$9c(a6)
	move.w	#$7fff,$96(a6)
	move.l	Old,$6c.w
	move.l	4.w,a6
	move.l	#name,a1
	clr.l	d0
	jsr	-408(a6)
	lea	$dff000,a6
	move.l	d0,a5
	move.l	38(a5),$80(a6)
	tst.w	$88(a6)
	move.w	wart1,$9a(a6)
	move.w	wart2,$9c(a6)
	move.w	wart3,$96(a6)
	rte

;*********************************************************
;*                     PRZERWANIA                        *
;*********************************************************
Init:
	lea	Obrazek+63*32,a0
	lea	Zeros,a1

	move.w	#63,d7
.l0:
	move.w	#31,d6
.l1:
	moveq	#0,d1
	rept	8
	add.b	d1,d1
	move.w	(a1)+,d0
	beq	*+6
	addq.w	#1,d1
	endr
	move.b	d1,(a0)+
	dbra	d6,.l1
	add.w	#64*2,a1
	sub.w	#32+32,a0

	dbra	d7,.l0

	jsr	Wymiana
	jsr	showNapis
	jsr	Wymiana
	jsr	showNapis
	jsr	Wymiana
	jsr	showNapis


	
	rts

Inter:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	$dff000,a6
	and.w	#$20,$1e(a6)
	beq.s	out
	move.w	#$20,$9c(a6)

Out:
	movem.l	(sp)+,d0-d7/a0-a6
	rte

;*********************************************************
;*                      PETLA GLOWNA                     *
;*********************************************************
MyRoutine:


.wait:
	stop	#$2000

	jsr	doMy
	jsr	Wymiana_clss

	move.w	#$218,$dff180

	btst	#6,$bfe001
	bne.w	.wait
	rts

;*********************************************************
;*                    WYMIANA EKRANOW                    *
;*********************************************************
PlaneAdre:	dc.l	Screen1
ClsAdr:		dc.l	Screen1+PlaneSize
DrawAdr:	dc.l	Screen1+2*PlaneSize

Wymiana_clss:
	lea	PlaneAdre(pc),a1
	move.l	(a1)+,d1
	move.l	(a1)+,d2
	move.l	(a1)+,d3
	move.l	d2,-(a1)
	move.l	d1,-(a1)
	move.l	d3,-(a1)

	lea	Planes+2,a0
	move.w	d3,4(a0)
	swap	d3
	move.w	d3,(a0)

	lea	$dff000,a6
ClsBlit:
	wblit

	move.l	d1,$054(a6)
	move.l	#-1,$044(a6)
	move.l	#$01000000,$040(a6)
	move.w	#0,$066(a6)
	move.w	#(256-64)*20,$058(a6) 
	rts
	
Wymiana:
	lea	PlaneAdre(pc),a1
	move.l	(a1)+,d1
	move.l	(a1)+,d2
	move.l	(a1)+,d3
	move.l	d2,-(a1)
	move.l	d1,-(a1)
	move.l	d3,-(a1)

	lea	Planes+2,a0
	move.w	d3,4(a0)
	swap	d3
	move.w	d3,(a0)

	rts


one2line:	macro
	move.l	(a4)+,a0		;sinTab
;	move.l	d4,a1			;drawAdr -> w tablicy sin sa delty :-)
	add.w	(a4)+,a1		;w ktorej linii - przesuniecie dz
	add.w	d5,a0			;d5 = whereX
	addq.w	#6,d5
	and.w	d6,d5			;d6=511 - okres sinusa
	lea	*+16+4(pc),a2

	incbin	4bit/lines_bsets_4bit_\1_v2.bin

	add.w	d7,a3		;d7=2*256 nastepna linia z tablicy przesuniec

	endm

zaslAdr:	dc.l	0	;zaslanianie
whereX:		dc.w	0
przesZeros:	dc.w	0
frameNr:	dc.w	-1

doMy:
	lea	zaslAdr(pc),a0
	move.l	(a0)+,a5

	lea	AddrsSins,a4
	lea	zeros,a3
	move.w	(a0)+,d5		;whereX(pc),d5
	add.w	(a0)+,a3		;przesZeros(pc),a3

	addq.b	#1,(a0)			;framenr
	bne.b	.ddd
	lea	zaslanianie,a5	;(zaslAdr)
.ddd:

	move.l	DrawAdr(pc),a1
	move.w	#511,d6
	move.w	#512,d7

ll1	one2line	00
ll2	one2line	01
	one2line	02
	one2line	03
	one2line	04
	one2line	05
	one2line	06
	one2line	07
	one2line	08
	one2line	09


	one2line	10
	one2line	11
	one2line	12
	one2line	13
	one2line	14
	one2line	15
	one2line	16
	one2line	17
	one2line	18
	one2line	19

	one2line	20
	one2line	21
	one2line	22
	one2line	23
	one2line	24
	one2line	25
	one2line	26
	one2line	27
	one2line	28
	one2line	29

	one2line	30
	one2line	31
	one2line	32
	one2line	33
	one2line	34
	one2line	35
	one2line	36
	one2line	37
	one2line	38
	one2line	39

	one2line	40
	one2line	41
	one2line	42
	one2line	43
	one2line	44
	one2line	45
	one2line	46
	one2line	47
	one2line	48
	one2line	49

	one2line	50
	one2line	51
	one2line	52
	one2line	53
	one2line	54
	one2line	55
	one2line	56
	one2line	57
	one2line	58
	one2line	59

	one2line	60
	one2line	61
	one2line	62
	one2line	63

;	add.w	#2*(64/4)*2,a5

xyz:
	lea	zaslAdr,a0
	move.l	a5,(a0)+	;a5,zaslAdr

	move.w	(a0),d0		;whereX,d0
	add.w	#-2,d0
	and.w	d6,d0		;#511,d0
	move.w	d0,(a0)+	;d0,whereX

	move.w	(a0),d0		;przesZeros,d0
	addq.w	#2,d0
	and.w	d6,d0		;#511,d0
	move.w	d0,(a0)		;d0,przesZeros

	rts

showNapis:
	move.l	DrawAdr,a0
	add.w	#40*(256-64)+8/2,a0
	lea	obrazek,a1
	rept	64
	movem.l	(a1)+,d0-d7
	movem.l	d0-d7,(a0)
	add.w	#40,a0
	endr
	rts

obrazek:
	blk.b	32*64,$aa



ttt:
	nop
	moveq	#0,d0


;*********************************************************
;*               CZEKAJ AZ BLITER GOTOWY                 *
;*********************************************************
	
Cls:
	move.l	ClsAdr,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7

	move.w	#32,d7
.loop:	rept 10
	movem.l	d0-d3,(a0)
	movem.l	d0-d6,12(a0)
	lea	40(a0),a0
	endr
	dbf	d7,.loop
	rts

;*********************************************************
;*                    ZMIENNE I STALE                    *
;*********************************************************

Name:		dc.b	'graphics.library',0
	even
Wart1:		dc.w	0
Wart2:		dc.w	0
Wart3:		dc.w	0
Old:		dc.l	0

;*********************************************************
;*                    SINUS TABLES                       *
;*********************************************************
zaslanianie:
	incbin	"zasl3.bin"

	even

SinTab:
	incbin	"sintabs.bin"


zeros:
	incbin	"scroll.bin"
;	blk.w	(256+64)*64*2,0

	include "sintabs.s"



;*********************************************************
;*                    PROGRAM COPPERA                    *
;*********************************************************
Copper:
Planes:	dc.w	$e0,0,$e2,0,$e4,0,$e6,0
	dc.w	$e8,0,$ea,0,$ec,0,$ee,0

	dc.w	$0180,$0000,$0182,$0fff,$0184,$000c,$0186,$0c00
	dc.w	$0188,$0400,$018a,$0800,$018c,$0008,$018e,$0008
	dc.w	$0190,$0fff,$0192,$0fff,$0194,$0fff,$0196,$0fff
	dc.w	$0198,$0fff,$019a,$0fff,$019c,$0fff,$019e,$0fff

	dc.w	$ffe1,$fffe
	dc.w	$3401,$fffe
	dc.w	$8e,$2081,$90,$20c1,$92,$38,$94,$d0
	dc.w	$100,%0001001000000000,$102,0,$104,0
	dc.w	$108,0,$10a,0
	
	dc.w	$ffff,$fffe

;*********************************************************
;*                        EKRAN                          *
;*********************************************************
Screen1:
	blk.b	3*Planesize,0


;bitmasks_4:
;	incbin	"lines_bsets_4bit.bin"
;	include "lines_bsets_4bit.s"

end:
