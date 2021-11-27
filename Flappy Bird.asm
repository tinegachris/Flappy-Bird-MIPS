# Program of the Flappy Bird game in MIPS assembly language
# MIPS Assembler and Runtime Simulator (MARS) IDE

.data	# Define the program data
	displayAddress: .word 0x10008000
	
	#Colors
	birdColour: .word 0xffff00 # yellow
	backgroundColour: .word 0x00ccff # blue
	darkBlue: .word 0x00008B # darkBlue
	purple: .word 0x6A0DAD	# purple
	pipeColour: .word 0x00ff00 # green

	#game info
	size: .word 4094
	strokeAdd: .word 0xffff0000 # address of if a key is pressed
	contentAdd: .word 0xffff0004 # address of ascii code of which button pressed

.text	# Define the program instructions

main:	# Label to define the main program

	lw $t0, displayAddress 		#load word
	lw $t1, backgroundColour
	lw $t2, birdColour
	lw $t3, pipeColour
	lw $a0, size
	li $a1, 0	# load immediate
	

background:			# draw the background
	add $a2, $t0, $a1 # addition with overflow: set $t1 to (sum of $t0 and $al)
	sw $t1, 0($a2)	# store word
	addi $a1, $a1, 4	# add immediate
	bge $a1, $a0, draw # branch if greater or equal to bird
	j background # keep drawing background: loop
	
draw: # draw the starting level of the game
	li $t9, 0
	#hard oode draw bird
	addi $t7, $t0 1952
	sw $t2 0($t7)
	sw $t2 4($t7)
	sw $t2 8($t7)
	sw $t2 12($t7)
	sw $t2 -128($t7)
	sw $t2 128($t7)
	sw $t2 136($t7)
	sw $t2 -120($t7)
	
	
	addi $t4, $t0, 1536 # add immediate: set $t4 to ($t0 and 1536)
	addi $t5, $t0, 2688
	
	li $t6,68 # start position
	
	addi $a0 ,$t0, 0 # Initialize beginning
	addi $a1, $t4, 0 # Initialize end

	jal drawPipe	# jump and link: set $ra to program counter (return address) then jump to drawpipe

	addi $a0, $t5, 0 # Initialize beginning
	addi $a1, $t0, 3969 # Initialize end
	jal drawPipe #jump and link (making function call)

	j game		# jump unconditionally to game

drawPipe:			# draws pipe
	startOutloop:
	bge $a0, $a1, endOutloop # branch to endOutloop if $a0 greater or equal to $a1
				#Inner loop
	add $a2, $a0, $t6 # Initialize beginning
	addi $a3, $a2,20 # Initialize end
	
	startInloop:
	bge $a2, $a3, endInloop	#branch to endInloop if $a2 greater or equal to $a3
	sw $t3,($a2)	#store $t3 contents to th effective memory  word address 
	addi $a2, $a2, 4 # Increment counter
	b startInloop	# branch unconditionally
	
	endInloop: #Inner loop
	addi $a0, $a0, 128 # Increment counter
	b startOutloop
	
	endOutloop:
	jr $ra	#jump to statement whose register is in $ra

drawMap:	# draw map
	startOutloop1:	# Inner loop
	bge $a0, $a1, endOutloop1	# branch to endOutloop if $a0 greater or equal to $a1
	add $a2, $a0, 0 # Initialize beginning
	addi $a3, $a2,200 # Initialize end
	
	startInloop1:
	bge $a2, $a3, endInloop1
	sw $t1,($a2)
	addi $a2, $a2, 4 # Increment counter
	b startInloop1	# branch to startInloop1 unconditionally
	
	endInloop1: #Inner loop
	addi $a0, $a0, 128 # Increment counter
	b startOutloop1
	endOutloop1:

	jr $ra	#jump to statement whose register is in $ra
	
ereasePipe:	# erase pipe
	EstartOutloop:
	bge $a0, $a1, EendOutloop
	#Inner loop
	add $a2,$a0, $t6 # Initialize beginning
	addi $a3, $a2, 20 # Initialize end
	
	EstartInloop:
	bge $a2, $a3, EendInloop
	sw $t1,($a2)
	addi $a2, $a2, 4 # Increment counter
	
	b EstartInloop
	EendInloop: #Inner loop
	addi $a0, $a0, 128 # Increment counter
	b EstartOutloop
	
	EendOutloop:
	jr $ra

game:
	#sleep
	li $v0, 32	# Load a 32 into $v0: sleep
	li $a0, 800	# sleep for 800 milliseconds 
	syscall		# Execute the system call specified by a value in $v0

	li $a1, 0xffff0000
	lw $a2, ($a1)
	beqz $a2, drop # drop the bird if no input
	li $a1, 0xffff0004
	lw $a2, ($a1)
	beq $a2, 102, jump # jump the bird if input f

drop:				# 
	#erease bird
	sw $t1 0($t7)
	sw $t1 4($t7)
	sw $t1 8($t7)
	sw $t1 12($t7)
	sw $t1 -128($t7)
	sw $t1 128($t7)
	sw $t1 136($t7)
	sw $t1 -120($t7)

	#erease pipe
	addi $a0, $t0, 0
	move $a1, $t4
	jal ereasePipe	# jump and link: set $ra to program counter then jump to erasePipe
	move $a0, $t5
	addi $a1, $t0, 3969
	jal ereasePipe

	#DRAWMAP
	jal loadColor
	addi $a0, $t0, 0 # Initialize beginning
	addi $a1, $t0, 3969
	jal drawMap	# jump and link: set $ra to program counter then jump to drawMap

	#draw bird
	sw $t2 128($t7)
	sw $t2 132($t7)
	sw $t2 136($t7)
	sw $t2 140($t7)
	sw $t2 0($t7)
	sw $t2 256($t7)
	sw $t2 264($t7)
	sw $t2 8($t7)
	addi $t7,$t7,128

	# redraw pipe
	addi $t6, $t6, -4
	
	move $a0, $t0
	move $a1, $t4
	jal drawPipe
	move $a0, $t5
	addi $a1, $t0, 3969
	jal drawPipe
	
	bge $t7,$t5, Reinitialize
	ble $t6, 0, new
	j game	# jump to game unconditionally

loadColor:	# load color
	beq $t9,0, loadPurple
	beq $t9,1, loadDark
	beq $t9,2, loadBlue
	load:
	move $t1, $a1
	jr $ra	

loadPurple:	# to load purple
	lw $a1, purple
	li $t9,1
	j load

loadDark:	# to load dark 
	lw $a1, darkBlue	
	li $t9,2
	j load

loadBlue:	# to load blue
	lw $a1, backgroundColour
	li $t9,0
	j load

jump: 		# if jump is called
	#erease bird
	sw $t1 0($t7)
	sw $t1 4($t7)
	sw $t1 8($t7)
	sw $t1 12($t7)
	sw $t1 -128($t7)
	sw $t1 128($t7)
	sw $t1 136($t7)
	sw $t1 -120($t7)

	#erease pipe
	addi $a0, $t0, 0
	move $a1, $t4
	jal ereasePipe
	move $a0, $t5
	addi $a1, $t0, 3969
	jal ereasePipe
	jal loadColor
	addi $a0, $t0, 0
	addi $a1, $t0, 3969
	jal drawMap

	#draw
	sw $t2 -128($t7)
	sw $t2 -124($t7)
	sw $t2 -120($t7)
	sw $t2 -116($t7)
	sw $t2 -256($t7)
	sw $t2 0($t7)
	sw $t2 8($t7)
	sw $t2 -248($t7)
	addi $t7,$t7,-128

	# redraw pipe
	addi $t6, $t6, -4
	move $a0, $t0
	move $a1, $t4
	jal drawPipe
	move $a0, $t5
	addi $a1, $t0, 3969
	jal drawPipe
	ble $t7,$t4, Reinitialize
	ble $t6, 0, new
	j game

new:		# When new is called 
	# erease
	addi $a0, $t0, 0
	move $a1, $t4
	jal ereasePipe
	move $a0, $t5
	addi $a1, $t0, 3969
	jal ereasePipe
	li $t6, 68 # change position of pipe
	addi $a0 ,$t0, 0
	addi $a1, $t4, 0
	jal drawPipe
	addi $a0, $t5, 0
	addi $a1, $t0, 3969
	jal drawPipe
	j Reinitialize

Reinitialize:			# 
	add $a1, $zero, $zero
	addi $t5, $zero, 4094

End_background:			# end background
	add $t6, $t0, $a1	# Set $t6 to ($t0 plus $al)
	sw $t1, 0($t6)		# Store the contents of $t1 into effective memory word address
	addi $a1, $a1, 4	# Set $a1 to ($a1 plus 4)
	bge $a1, $t5, Bye_text 	# Branch to Bye_text if $a1 greater or equal to $t5. 
	j End_background 	# Jump unconditionally to end background

Bye_text:			# 
	sw $t2, 1444($t0) 	# Store $t2 contents into effective word address
	sw $t2, 1572($t0)
	sw $t2, 1700($t0)
	sw $t2, 1828($t0)
	sw $t2, 1832($t0)
	sw $t2, 1836($t0)
	sw $t2, 1840($t0)
	sw $t2, 1956($t0)
	sw $t2, 2084($t0)
	sw $t2, 2212($t0)
	sw $t2, 2340($t0)
	sw $t2, 2344($t0)
	sw $t2, 2348($t0)
	sw $t2, 2352($t0)
	sw $t2, 2224($t0)
	sw $t2, 2096($t0)
	sw $t2, 1968($t0)
	sw $t2, 1852($t0)
	sw $t2, 1864($t0)
	sw $t2, 1980($t0)
	sw $t2, 2108($t0)
	sw $t2, 2236($t0)
	sw $t2, 2240($t0)
	sw $t2, 2244($t0)
	sw $t2, 1992($t0)
	sw $t2, 2120($t0)
	sw $t2, 2248($t0)
	sw $t2, 2376($t0)
	sw $t2, 2504($t0)
	sw $t2, 2500($t0)
	sw $t2, 2496($t0)
	sw $t2, 2492($t0)
	sw $t2, 1876($t0)
	sw $t2, 2004($t0)
	sw $t2, 2132($t0)
	sw $t2, 2260($t0)
	sw $t2, 2388($t0)
	sw $t2, 1880($t0)
	sw $t2, 1884($t0)
	sw $t2, 1888($t0)
	sw $t2, 2136($t0)
	sw $t2, 2140($t0)
	sw $t2, 2144($t0)
	sw $t2, 2392($t0)
	sw $t2, 2396($t0)
	sw $t2, 2400($t0)
	sw $t2, 1768($t0)
	sw $t2, 1772($t0)
	sw $t2, 1896($t0)
	sw $t2, 1900($t0)
	sw $t2, 2024($t0)
	sw $t2, 2028($t0)
	sw $t2, 2152($t0)
	sw $t2, 2156($t0)
	sw $t2, 2280($t0)
	sw $t2, 2284($t0)
	sw $t2, 2536($t0)
	sw $t2, 2540($t0)
	sw $t2, 2664($t0)
	sw $t2, 2668($t0)

done:
	li $v0, 10 		# Load a 10 (halt) into $v0: terminate the program gracefully
	syscall 		# Execute the system call specified by a value in $v0