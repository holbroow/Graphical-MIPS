### SETTING UP FOR BITMAP DISPLAY USE ###
addi $s0, $zero, 0			# sets $s0 to 0
lui $s0, 0x1001				# sets the register $s0 to address '0x10010000' BITMAP ADDRESS

### SETTING UP VALUES RELATED TO THE BITMAP DISPLAY ###
addi $s5, $zero, 512			# display width in pixels
addi $s6, $zero, 256			# display height in pixels
mult $s5, $s6				# multiplies width and height values to fetch total pixel size of display
mflo $s1				# bitmap size (total pixel count) (WIDTH x HEIGHT)
mflo $zero				# reset mflo value for future use

add $t6, $zero, $s1			# copying total pixel count to temporary register for resetting after a loop
add $t7, $zero, $s5			# copying display width to temporary register for resetting after a loop
add $t8, $zero, $s6			# copying display height to temporary register for resetting after a loop

li $t9, 5				# setting register to 5 for division of pixels during 'stave'

### SETTING TEMP REGISTERS FOR HOLDING VARIOUS COLOUR VALUES ###
li $t0, 0x0000ff # BLUE COLOUR
li $t1, 0x00ff00 # GREEN COLOUR
li $t2, 0xff0000 # RED COLOUR
li $t3, 0x555555 # GREY COLOUR
li $t4, 0xffffff # WHITE COLOUR
li $t5, 0x000000 # BLACK COLOUR


### 'CLS' OPERATION ###
loop_cls:
	sw $t1, 0($s0)			# stores colour value at the bitmap address in its current word.
	addi $s0, $s0, 4		# increments to the next word in the bitmap address
	sub $s1, $s1, 1			# subtracts 1 from the previously declared total pixel count 
	bne $s1, $zero, loop_cls	# checks that the pixel count has not reached 0, ends the loop when true.
add $s1, $zero, $t6			# reset total pixel count after loop	
addi $s0, $zero, 0			# sets $s0 to 0 to return to start of display


### 'STAVE' OPAERATION (paint 5 equally spaced horizontal lines) ###
div $s1, $t9				# DIVIDES PIXEL COUNT BY 5 TO FIND OUT HOW MANY PIXELS BETWEEN EACH POTENTIAL LINE
mflo $s2				# SAVES VALUE IN REGISTER '$s2'
mflo $zero				# mflo reset

loop_fifth_display:					# loop to increment word by a fifth of the display size for first horizontal line
	addi $s0, $s0, 4
	sub $s2, $s2, 1
	bne $s2, $zero, loop_fifth_display

div $s1, $t9
mflo $s2
mflo $zero

loop_draw_line:						# loop to draw a horizontal line by the width value once
	sw $t5, 0($s0)
	addi $s0, $s0, 4
	sub $s5, $s5, 1
	bne $s5, $zero, loop_draw_line
add $s5, $zero, $t7					# resets the width pixel valuye after use within the loop

