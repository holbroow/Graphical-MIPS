# NOTE
# I had a lot of trouble getting the prompts to reappear after they initially show up and after the execution of various functions.
# The menu options for both the 'mainMenu' and the 'clsMenu' still work continuously and without fail, however visually the menu will not re-print.
# Sorry for the nuisance, I have tried to diagnose the problem numerous times for literally hours.
# This same issue meant that the initial colouring of the background on line 29 could not be done as the menu prompt would then appear as unknown characters
# (i am unsure if this is just for my machine) So therefore the background remains black before the menu is output to the console. Sorry.
# Thanks, Will


.data
mainMenu: .asciiz "Please select an option: \n1. CLS\n2. Stave\n3. Reset Display\n4. Exit Program\n\n"
staveMenu: .asciiz "Please enter the line at which stave should begin: \n\n"
clsMenu: .asciiz "Please enter an option for the CLS colour: \n1. Black\n2. White\n3. Green\n4. Grey\n5. Red\n6. Blue\n\n"


.text
addi $s0, $zero, 0			# sets $s0 to the value '0'
lui $s0, 0x1001				# sets $s0 register to 0x10010000 (address of bitmap display)
add $s7, $s0, $zero			# copies s0 value for use when resetting display word after loop(s)
addi $s1, $zero, 512			# display width
addi $s2, $zero, 256			# display height
mul $s3, $s1, $s2			# calculates the total pixel count using the declared 'width' and 'height'

li $s5, 0x000000			# black (reset+stave colour)
li $s6, 0x808080			# initial grey background colour (beginning of program)

## main program
main:
	#jal initialDisplay
	
	addi $v0, $zero, 4
	la $a0, mainMenu		# calls ther mainMenu prompt
	syscall

	li $v0, 5			# user input for their choice within the main menu
	syscall
	move $t0, $v0
	
	beq $t0, 1, clsInput		# runs the procedure aligning with the user's choice
	beq $t0, 2, staveInput
	beq $t0, 3, reset
	beq $t0, 4, exit
	
	
## procedures
# cls user-input
clsInput:				# takes user input for the colour for the cls function
	li $v0, 4
	la $a0, clsMenu			
	syscall
	
	li $v0, 5
	syscall				# takes user input as such
	move $t0, $v0
	
	beq $t0, 1, setBlack		# runs the procedure aligning with the user's choice
	beq $t0, 2, setWhite
	beq $t0, 3, setGreen	
	beq $t0, 4, setGrey
	beq $t0, 5, setRed
	beq $t0, 6, setBlue

	setBlack:
		li $s4, 0x000000	# depending on the user choice, the colour register used by 'CLS' is assigned accordingly
		j cls
	setWhite:
		li $s4, 0xffffff
		j cls
	setGreen:
		li $s4, 0x00ff00
		j cls
	setGrey:
		li $s4, 0x808080
		j cls
	setRed:
		li $s4, 0xff0000
		j cls
	setBlue:
		li $s4 0x0000ff
		j cls
		
# stave user-input
staveInput:				# takes user input for the starting line of the 'stave' lines 
	li $v0, 4
	la $a0, staveMenu
	syscall
	
	li $v0, 5
	syscall

	move $t0, $v0			# takes said input and moves it to a temporary variable to be accessed by a loop in the 'stave' function
	
	j stave

# cls program
cls:					# the CLS function clears the screen with a colour (user's choice), this can be called repeatedly
	loopCls:
		sw $s4, 0($s0)
		addi $s0, $s0, 4
		sub $s3, $s3, 1
		bne $s3, $zero, loopCls
	mul $s3, $s1, $s2
	add $s0, $s7, $zero		# reset display (word)
	
	j main


# stave program
stave:					# the stave function prints 5 equidistant lines, starting at the line number previously specified by the user in 'staveInput'
	mul $t5, $t0, $s1
	initialWordIncrement:
		addi $s0, $s0, 4
		sub $t5, $t5, 1
		bne $t5, $zero, initialWordIncrement
	addi $t7, $zero, 5			# how many times the line printing section should run (in this case, 5)
	loopStave:
		mul $t1, $s1, 15		# creates value based on (pixel width of display * declared no of lines(line above))
		loopWordIncrement:		# increments 15 lines
			addi $s0, $s0, 4
			sub $t1, $t1, 1
			bne $t1, $zero, loopWordIncrement
		mul $t2, $s1, 3
		loopLineDraw:			# draws line (width of display)  (512))
			sw $s5, 0($s0)
			addi $s0, $s0, 4
			sub $t2, $t2, 1
			bne $t2, $zero, loopLineDraw
		sub $t7, $t7, 1
		bne $t7, $zero, loopStave
	add $s0, $s7, $zero		# reset display (word)
	
	j main

# display-reset program
reset:					# reset the display (cls but always a black screen for a fresh start)
	loopReset:			# this isnt really necessary but i was using it before fully developing the CLS function and thought i'd leave it in.
		sw $s5, 0($s0)
		addi $s0, $s0, 4
		sub $s3, $s3, 1
		bne $s3, $zero, loopReset
	mul $s3, $s1, $s2
	add $s0, $s7, $zero		# reset display (word)
	
	j main
	
initialDisplay:
	initialCls:
		sw $s6, 0($s0)
		addi $s0, $s0, 4
		sub $s3, $s3, 1
		bne $s3, $zero, initialCls
	mul $s3, $s1, $s2
	add $s0, $s7, $zero		# reset display (word)
	
	jr $ra
	

# program termination
exit:					# exits the program completely, should the user want to stop using it without abrubtly quitting the process
	li $v0, 10
	syscall
