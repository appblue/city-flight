;*********************************************************
;*        STANDART BY DR.DF0  OF  ... ATD ...            *
;*             4 BITPLANY  I  SPRITE'Y                   *
;*********************************************************
Planesize=40*256

STEP_FR = -2
STEP_Y  =  2


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
	Bsr.w	Wymiana
	Bsr.w	Init
	jsr	mt_init
	move.w	#$2,$2e(a6)
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
	jsr	mt_end
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

init:

	jsr	Wymiana
	jsr	Wymiana
	jsr	Wymiana
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
	jsr	mt_music
	jsr	ClsBlit
	jsr	doMy
	jsr	Wymiana

	move.w	#$268,$dff180

	btst	#6,$bfe001
	bne.w	.wait
	rts

;*********************************************************
;*                    WYMIANA EKRANOW                    *
;*********************************************************
PlaneAdre:	dc.l	Screen1
ClsAdr:		dc.l	Screen1+PlaneSize
DrawAdr:	dc.l	Screen1+2*PlaneSize

ClsBlit:
	lea	$dff000,a6
	wblit

	move.l	ClsAdr,$054(a6)
	move.l	#-1,$044(a6)
	move.l	#$01000000,$040(a6)
	move.w	#0,$066(a6)
	move.w	#(256)*20,$058(a6) 

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


zaslAdr:	dc.l	0	;zaslanianie
whereX:		dc.w	0
przesZeros:	dc.w	0
frameNr:	dc.w	-1
copmvi:	macro
	move.w	#\2,(a4)+
	move.w	#\1,(a4)+
	endm
copmvd:	macro
	move.w	#\2,(a4)+
	move.w	\1,(a4)+
	endm
copmvl:	macro
	swap	\1
	move.w	#\2,(a4)+
	move.w	\1,(a4)+
	swap	\1
	move.w	#(\2+2),(a4)+
	move.w	\1,(a4)+
	endm

doMy:
	jsr	INITLINE	; Init line registers
	copmvi	$fff,$180


	move.l	#wsp,a0
	move.l	wspA,a0
.l:	movem.w	(a0)+,d0-d3

	cmp.w	#-1,d0
	beq.s	.kon
	move.l	a0,-(a7)
	BSR.W	DRAWLINE	; Draw the line
	move.l	(a7)+,a0


	bra	.l
.kon:	cmp.l	#endw,a0
	bne.s	.k2
	lea	wsp,a0
.k2:
	move.l	a0,wspA

;	move.w	#210,d0
;	move.w	#30,d1
;	move.w	#130,d2
;	move.w	#130,d3
;	bsr.w	drawline


	copmvi	$ff0,$180
	copmvi	$fffe,$3401
	copmvi	$fffe,$ffff

;	dc.w	$3401,$fffe
;	dc.w	$ffff,$fffe


	rts





wspA:	dc.l	wsp
wspA2:	dc.l	wsp

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
;********************
;*  Init line draw  *
;********************

SINGLE = 0		; 2 = SINGLE BIT WIDTH
BYTEWIDTH = 40

; The below registers only have to be set once each time
; you want to draw one or more lines.

INITLINE:
	LEA.L	$DFF000,A6
	lea	CopL1,a4

;.WAIT:	BTST	#$E,$2(A6)
;	BNE.S	.WAIT

;	MOVEQ	#-1,D1
;	MOVE.L	D1,$44(A6)		; FirstLastMask
;	MOVE.W	#$8000,$74(A6)		; BLT data A
;	MOVE.W	#BYTEWIDTH,$60(A6)	; Tot.Screen Width
;	MOVE.W	#$FFFF,$72(A6)
	move.L	DrawAdr,A5
	copmvi	0,1			; waitblit
	copmvi	-1,$44
	copmvi	-1,$46
	copmvi	$8000,$74
	copmvi	bytewidth,$60
	copmvi	-1,$72
	RTS

;*****************
;*   DRAW LINE   *
;*****************
; a4 -> tablica coppera
; USES D0/D1/D2/D3/D4/D7/A5/A6

DRAWLINE:
	SUB.W	D3,D1
	MULU	#40,D3		; ScreenWidth * D3

	MOVEQ	#$F,D4
	AND.W	D2,D4		; Get lowest bits from D2

;--------- SELECT OCTANT ---------

	SUB.W	D2,D0
	BLT.S	DRAW_DONT0146
	TST.W	D1
	BLT.S	DRAW_DONT04

	CMP.W	D0,D1
	BGE.S	DRAW_SELECT0
	MOVEQ	#$11+SINGLE,D7		; Select Oct 4
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT0:
	MOVEQ	#1+SINGLE,D7		; Select Oct 0
	EXG	D0,D1
	BRA.S	DRAW_OCTSELECTED

DRAW_DONT04:
	NEG.W	D1
	CMP.W	D0,D1
	BGE.S	DRAW_SELECT1
	MOVEQ	#$19+SINGLE,D7		; Select Oct 6
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT1:
	MOVEQ	#5+SINGLE,D7		; Select Oct 1
	EXG	D0,D1
	BRA.S	DRAW_OCTSELECTED


DRAW_DONT0146:
	NEG.W	D0
	TST.W	D1
	BLT.S	DRAW_DONT25
	CMP.W	D0,D1
	BGE.S	DRAW_SELECT2
	MOVEQ	#$15+SINGLE,D7		; Select Oct 5
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT2:
	MOVEQ	#9+SINGLE,D7		; Select Oct 2
	EXG	D0,D1
	BRA.S	DRAW_OCTSELECTED
DRAW_DONT25:
	NEG.W	D1
	CMP.W	D0,D1
	BGE.S	DRAW_SELECT3
	MOVEQ	#$1D+SINGLE,D7		; Select Oct 7
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT3:
	MOVEQ	#$D+SINGLE,D7		; Select Oct 3
	EXG	D0,D1

;---------   CALCULATE START   ---------

DRAW_OCTSELECTED:
	ADD.W	D1,D1			; 2*dy
	ASR.W	#3,D2			; x=x/8
	EXT.L	D2
	ADD.L	D2,D3			; d3 = x+y*40 = screen pos
	MOVE.W	D1,D2			; d2 = 2*dy
	SUB.W	D0,D2			; d2 = 2*dy-dx
	BGE.S	DRAW_DONTSETSIGN
	ORI.W	#$40,D7			; dx < 2*dy
DRAW_DONTSETSIGN:

;---------   SET BLITTER   ---------

;.WAIT:
;	BTST	#$E,$2(A6)		; Wait on the blitter
;	BNE.S	.WAIT

	copmvi	0,1			; waitblit
;	MOVE.W	D2,$52(A6)		; 2*dy-dx
	copmvd	d2,$52
;	MOVE.W	D1,$62(A6)		; 2*d2
	copmvd	d1,$62
	SUB.W	D0,D2			; d2 = 2*dy-dx-dx
;	MOVE.W	D2,$64(A6)		; 2*dy-2*dx
	copmvd	d2,$64

;---------   MAKE LENGTH   ---------

	ASL.W	#6,D0			; d0 = 64*dx
	ADD.W	#$0042,D0		; d0 = 64*(dx+1)+2

;---------   MAKE CONTROL 0+1   ---------

	ROR.W	#4,D4
	ORI.W	#$BEA,D4		; $B4A - DMA + Minterm
	SWAP	D7
	MOVE.W	D4,D7
	SWAP	D7
	ADD.L	A5,D3		; SCREEN PTR

;	MOVE.L	D7,$40(A6)		; BLTCON0 + BLTCON1
	copmvl	d7,$40
;	MOVE.L	D3,$48(A6)		; Source C
	copmvl	d3,$48
;	MOVE.L	D3,$54(A6)		; Destination D
	copmvl	d3,$54
;	MOVE.W	D0,$58(A6)		; Size
	copmvd	d0,$58
;	move.l	d3,blt54
;	move.w	d0,blt58

	RTS

blt52:	dc.w	0
blt62:	dc.w	0
blt64:	dc.w	0
blt58:	dc.w	0
blt40:	dc.l	0
blt48:	dc.l	0
blt54:	dc.l	0


;*********************************************************
;*                    PROGRAM COPPERA                    *
;*********************************************************
Copper:
Planes:	dc.w	$e0,0,$e2,0

	dc.w	$8e,$2081,$90,$20c1,$92,$38,$94,$d0
	dc.w	$100,%0001001000000000,$102,0,$104,0
	dc.w	$108,0,$10a,0


	dc.w	$0180,$0000,$0182,$0fff

	dc.w	$dfe1,$fffe
	dc.w	$180,$040
	dc.w	$0001,$0000

	dc.w	$180,$444
;	dc.w	$3401,$fffe
;	dc.w	$ffff,$fffe


copl1:	blk.l	512,0

	dc.w	$3401,$fffe
	dc.w	$ffff,$fffe

	dc.w	$dfe1,$fffe
	dc.w	$180,$040
	dc.w	$0001,$0000


	dc.w	$180,$f00

	dc.w	$44,$ffff,$46,$ffff
	dc.w	$74,$8000
	dc.w	$60,bytewidth
	dc.w	$72,-1
	dc.w	$52,$fff5
	dc.w	$62,$0014
	dc.w	$64,$ffd6

	dc.w	$40,$5bea,$42,$0055
	dc.w	$48,$0009,$4a,$9478
	dc.w	$54,$0009,$56,$9478

	dc.w	$58,$0802
	
	dc.w	$180,$444
	dc.w	$3401,$fffe
	dc.w	$ffff,$fffe

;copl1:
;	blk.l	512,123
;copl2:
;	blk.l	512,123


;*********************************************************
;*                        EKRAN                          *
;*********************************************************
Screen1:
	blk.b	3*Planesize,0

wsp:	incbin	wsp.bin
endw:

	include "/standarts/mt_music.s"

mt_data:
	incbin "## dead brain ##.mod"
;	incbin "/modd/## te-x-mas 5 ##.mod"


end:
