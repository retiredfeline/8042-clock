;
; 8048 I2C routines
;
; Adapted from https://www.8051projects.net/wiki/I2C_Implementation_on_8051
;

.ifdef	.__.CPU.		; if we are using as8048 this is defined
.8048
.area	CODE	(ABS)
.endif	; .__.CPU.

;***************************************
;Ports Used for I2C Communication
;***************************************
; jbN instructions later must match
.equ	sda1mask,	0x80    ; p2.7
.equ	sda0mask,	~sda1mask
.equ	scl1mask,	0x40	; p2.6
.equ	scl0mask,	~scl1mask

	.org	0
	jmp	test

	.org	3
	dis	i
	retr

	.org	7
	retr

;
; main program
;
test:
;*****************************************
; Write to slave device with
; slave address e.g. say 0x20
.equ	slaveaddr,	0x20
;*****************************************
	; Init i2c ports first
	call	i2cinit
	; Send start condition
	call	startc
	; Send slave address
	mov	a, #slaveaddr
	call	send
	; after send call top bit of A
	; If you want to check if send was a
	; success or failure
	; Send data
	mov	a, #0x07
	call	send
	; Send another data
	mov	a, #10
	call	send
	; Send stop condition
	call	stopc
	jmp	test
 
;*****************************************
; Read from slave device with
; slave address e.g. say 0x20
;*****************************************
	; Init i2c ports first
	call	i2cinit
	; Send start condition
	call	startc
	; Send slave address with Read bit set
	; So address is 0x20 | 1 = 0x21
	mov	a, #slaveaddr|0x1
	call	send
	; Read one byte
	call	recv
	; Send ack
	call	ack
	; Read last byte
	call	recv
	; Send nak for last byte to indicate
	; End of transmission
	call	nak
	; Send stop condition
	call	stopc
	jmp	test

	.org	0x100
 
;***************************************
;Initializing I2C Bus Communication
;***************************************
i2cinit:
	orl	p2, #sda1mask
	orl	p2, #scl1mask
	ret
 
;****************************************
;ReStart Condition for I2C Communication
;****************************************
rstart:
	anl	p2, #scl0mask
	orl	p2, #sda1mask
	orl	p2, #scl1mask
	anl	p2, #sda0mask
	ret
 
;****************************************
;Start Condition for I2C Communication
;****************************************
startc:
	orl	p2, #scl1mask
	anl	p2, #sda0mask
	anl	p2, #scl0mask
	ret
 
;*****************************************
;Stop Condition For I2C Bus
;*****************************************
stopc:
	anl	p2, #scl0mask
	anl	p2, #sda0mask
	orl	p2, #scl1mask
	orl	p2, #sda1mask
	ret
 
;*****************************************
;Sending Data to slave on I2C bus
;*****************************************
send:
	mov	r7, #08
sendmore:
	anl	p2, #scl0mask
	rlc	a
;	mov	sda, c		; 8048 not as capable as 8051
	jc	send1
	anl	p2, #sda0mask
	jmp	sent
send1:
	orl	p2, #sda1mask
sent:
	orl	p2, #scl1mask
	djnz	r7, sendmore
	anl	p2, #scl0mask
	orl	p2, #sda1mask
	orl	p2, #scl1mask
;	mov	c, sda		; we return status in a instead
	in	a, p2		; b7 contains status
	anl	p2, #scl0mask
	ret
 
;*****************************************
;ACK and NAK for I2C Bus
;*****************************************
ack:
	anl	p2, #sda0mask
	orl	p2, #scl1mask
	anl	p2, #scl0mask
	orl	p2, #sda1mask
	ret
 
nak:
	orl	p2, #sda1mask
	orl	p2, #scl1mask
	anl	p2, #scl0mask
	orl	p2, #scl1mask
	ret
 
;*****************************************
;Receiving Data from slave on I2C bus
;*****************************************
recv:
	mov	r7, #08
recvmore:
	anl	p2, #scl0mask
	orl	p2, #scl1mask
;	mov	c, sda		; 8048 not as capable as 8051
	clr	c
	in	a, p2
	cpl	a		; so bits are inverted
	jb7	recv0		; means it was 0
	cpl	c
recv0:
	rlc	a
	djnz	r7, recvmore
	anl	p2, #scl0mask
	orl	p2, #sda1mask
	ret
