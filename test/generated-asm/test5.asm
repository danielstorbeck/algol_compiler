b	main
b	label1
main:
li	$t0,6
sw	$t0,-1000($sp)
lw	$t0,-1000($sp)
sw	$t0,0($sp)
li	$t0,2
sw	$t0,-1004($sp)
lw	$t0,-1004($sp)
sw	$t0,-4($sp)
li	$t0,3
sw	$t0,-1000($sp)
lw	$t0,-1000($sp)
sw	$t0,-12($sp)
li	$t0,4
sw	$t0,-1004($sp)
lw	$t0,-1004($sp)
sw	$t0,-16($sp)
lw	$t0,0($sp)
sw	$t0,-1008($sp)
lw	$t0,-4($sp)
sw	$t0,-1012($sp)
lw	$t0,-1008($sp)
lw	$t1,-1012($sp)
sub	$t2,$t0,$t1
sw	$t2,-1008($sp)
lw	$t0,-1008($sp)
sw	$t0,-16($sp)
lw	$t0,-16($sp)
sw	$t0,-1016($sp)
lw	$t0,-12($sp)
sw	$t0,-1020($sp)
lw	$t0,-1016($sp)
lw	$t1,-1020($sp)
mult	$t0,$t1
mflo	$t0
sw	$t0,-1016($sp)
lw	$t0,-1016($sp)
sw	$t0,-8($sp)
lw	$t0,-8($sp)
sw	$t0,-1024($sp)
li	$v0,4
la	$a0, MSG
syscall
lw	$t0,-1024($sp)
li	$v0,1
move	$a0,$t0
syscall
lw	$t0,0($sp)
sw	$t0,-1008($sp)
li	$v0,4
la	$a0, MSG
syscall
lw	$t0,-1008($sp)
li	$v0,1
move	$a0,$t0
syscall
lw	$t0,-4($sp)
sw	$t0,-1012($sp)
li	$v0,4
la	$a0, MSG
syscall
lw	$t0,-1012($sp)
li	$v0,1
move	$a0,$t0
syscall
lw	$t0,-8($sp)
sw	$t0,-1016($sp)
li	$v0,4
la	$a0, MSG
syscall
lw	$t0,-1016($sp)
li	$v0,1
move	$a0,$t0
syscall
label1:
jr	$ra

	.data
MSG:	.asciiz "\n OUTPUT = "