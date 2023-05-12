.data
mainMenu: .asciiz "Please select an option: \n1. CLS\n2. Stave\n3. Reset Display\n4. Exit Program\n"
staveMenu: .asciiz "Please enter the line at which stave should begin: \n"


.text
addi $s0, $zero, 0		# sets $s0 to the value '0'
lui $s0, 0x1001			# sets $s0 register to 0x10010000 (address of bitmap display)
add $s7, $s0, $zero		# copies s0 value for use when resetting display word after loop(s)

addi $s1, $zero, 512		# display width
addi $s2, $zero, 256		# display height
mul $s3, $s1, $s2

li $s4, 0x000000		# black
li $s5, 0xffffff		# white
li $s6, 0xff0000		# red


main:
	li $v0, 4
	la $a0, mainMenu
	syscall

	li $v0, 5
	syscall
	move $t0, $v0
	
	beq $t0, 1, cls
	beq $t0, 2, staveInput
	beq $t0, 3, reset
	beq $t0, 4, exit

staveInput:
	li $v0, 4
	la $a0, staveMenu
	syscall
	
	li $v0, 5
	syscall

	move $t0, $v0
	
	j stave

cls:
	loopCls:
		sw $s6, 0($s0)
		addi $s0, $s0, 4
		sub $s3, $s3, 1
		bne $s3, $zero, loopCls
	mul $s3, $s1, $s2
	add $s0, $s7, $zero		# reset display (word)
	
	j main


stave:
	mul $t5, $t0, $s1
	initialWordIncrement:
		addi $s0, $s0, 4
		sub $t5, $t5, 1
		bne $t5, $zero, initialWordIncrement
	addi $t7, $zero, 5			# how many times stave should run (5)
	loopStave:
		mul $t1, $s1, 15		# creates value based on pixel width of display and declared no of lines (line above)
		loopWordIncrement:
			addi $s0, $s0, 4
			sub $t1, $t1, 1
			bne $t1, $zero, loopWordIncrement
		mul $t2, $s1, 3
		loopLineDraw:
			sw $s4, 0($s0)
			addi $s0, $s0, 4
			sub $t2, $t2, 1
			bne $t2, $zero, loopLineDraw
		sub $t7, $t7, 1
		bne $t7, $zero, loopStave
	add $s0, $s7, $zero		# reset display (word)
	
	j main

reset:
	loopReset:
		sw $s4, 0($s0)
		addi $s0, $s0, 4
		sub $s3, $s3, 1
		bne $s3, $zero, loopReset
	mul $s3, $s1, $s2
	add $s0, $s7, $zero		# reset display (word)
	
	j main


exit:
	li $v0, 10
	syscall
	
	
#jal cls
#jal stave

## Exit program
#li $v0, 10
#syscall
