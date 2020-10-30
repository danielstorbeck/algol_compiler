b	main
b	label3
main:
li	$t0,1
sw	$t0,-1000($sp)

li	$t0,0
lw	$t1,-1000($sp)
sub	$t2,$t0,$t1
sw	$t2,-1004($sp)
lw	$t0,-1004($sp)
sw	$t0,0($sp)
li	$t0,1
sw	$t0,-1008($sp)
lw	$t0,-1008($sp)
sw	$t0,0($sp)
label1:
li	$t0,10
sw	$t0,-1016($sp)
lw	$t0,0($sp)
lw	$t1,-1016($sp)
bge	$t0,$t1,label2
lw	$t0,0($sp)
sw	$t0,-1020($sp)
li	$v0,4
la	$a0, MSG
syscall
lw	$t0,-1020($sp)
li	$v0,1
move	$a0,$t0
syscall
li	$t0,2
sw	$t0,-1012($sp)
lw	$t0,0($sp)
lw	$t1,-1012($sp)
add	$t2,$t0,$t1
sw	$t2,0($sp)
b	label1
label2:
label3:
jr	$ra

	.data
MSG:	.asciiz "\n OUTPUT = "