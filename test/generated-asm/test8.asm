b	main
b	label7
main:
li	$t0,4
sw	$t0,-1000($sp)
lw	$t0,-1000($sp)
sw	$t0,0($sp)
li	$t0,5
sw	$t0,-1004($sp)
lw	$t0,-1004($sp)
sw	$t0,-4($sp)
lw	$t0,0($sp)
sw	$t0,-1008($sp)
li	$t0,3
sw	$t0,-1012($sp)
lw	$t0,-1008($sp)
lw	$t1,-1012($sp)
beq	$t0,$t1,label1
li	$t3,0
sw	$t3,-1016($sp)
b	label2
label1:
li	$t4,1
sw	$t4,-1016($sp)
label2:
li	$t0,0
lw	$t1,-1016($sp)
beq	$t1,$t0,label3
b	get1
b	label4
label3:
b	get2
label4:
b	label5
get1:
li	$t0,1
sw	$t0,-1000($sp)
lw	$t0,-1000($sp)
sw	$t0,-8($sp)
li	$t0,11
sw	$t0,-1004($sp)
lw	$t0,-1004($sp)
sw	$t0,0($sp)
label5:
lw	$t0,0($sp)
sw	$t0,-1020($sp)
li	$v0,4
la	$a0, MSG
syscall
lw	$t0,-1020($sp)
li	$v0,1
move	$a0,$t0
syscall
b	label6
get2:
lw	$t0,-4($sp)
sw	$t0,-1000($sp)
li	$t0,100
sw	$t0,-1004($sp)
lw	$t0,-1000($sp)
lw	$t1,-1004($sp)
add	$t2,$t0,$t1
sw	$t2,-1000($sp)
lw	$t0,-1000($sp)
sw	$t0,-12($sp)
li	$t0,11
sw	$t0,-1008($sp)
lw	$t0,-1008($sp)
sw	$t0,0($sp)
li	$t0,101
sw	$t0,-1012($sp)
lw	$t0,-1012($sp)
sw	$t0,-4($sp)
lw	$t0,-12($sp)
sw	$t0,-1016($sp)
li	$v0,4
la	$a0, MSG
syscall
lw	$t0,-1016($sp)
li	$v0,1
move	$a0,$t0
syscall
label6:
lw	$t0,0($sp)
sw	$t0,-1024($sp)
li	$v0,4
la	$a0, MSG
syscall
lw	$t0,-1024($sp)
li	$v0,1
move	$a0,$t0
syscall
lw	$t0,-4($sp)
sw	$t0,-1028($sp)
li	$v0,4
la	$a0, MSG
syscall
lw	$t0,-1028($sp)
li	$v0,1
move	$a0,$t0
syscall
label7:
jr	$ra

	.data
MSG:	.asciiz "\n OUTPUT = "