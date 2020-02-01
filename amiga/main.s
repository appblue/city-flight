	SECTION	MAIN,code

; jump to startup code (with callback to MAIN)
; ---------------------------------------------
	JMP	START

; main entry point
; ---------------------------------------------
MAIN:
.wait:	btst	#6, $bfe001
	bne.s	.wait
	
	rts

; v-blank interrupt service routine
; ---------------------------------------------
VBIRQ:
	rts

; copper list
; ---------------------------------------------
cladr:
	dc.w	$e0,$00
	dc.w	$e2,$00
	
	dc.w	$180,0
	dc.w	$182,$fff
	dc.w	$184,$fff

	dc.w	$ffff,$fffe
	dc.w	$ffff,$fffe

pl1h	= cladr+2
pl1l	= cladr+6

; setup hook executed before turn on DMA & IRQ
; ---------------------------------------------
SETUP:	
	move.w #$3081,$dff08e
	move.w #$30c1,$dff090
	move.w #$0038,$dff092
	move.w #$00d0,$dff094
	move.w #%0001001000000000,$dff100
	clr.w  $dff102
	clr.w  $dff104
	move.w	#00,$dff108
	move.w	#00,$dff10a

	move.l	#cladr,$dff080
	clr.w 	$dff088

	lea	plane(pc),a0
	move.l	a0,d0
	move.w	d0, pl1l
	swap	d0
	move.w	d0, pl1h

	rts

; ---------------------------------------------
	INCLUDE startup.s

; ---------------------------------------------
plane:	blk.b	40*256, 0

