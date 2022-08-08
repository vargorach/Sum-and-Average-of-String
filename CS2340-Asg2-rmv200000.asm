#Written by Rachel Vargo for CS2340.005, assignment 2
#Started Feburary 07, 2022. NetID: rmv200000
#The purpose of this code is to read in a string from the user 
# into a buffer and convert this string into a binary integer until
# a newline character is entered ending the loop and printing out the
# sum and average of the converted integers.
	.data
	.include	"SysCalls.asm"
buffer:	.space		100
s1:	.asciiz		"Enter a Number: "
s2:	.asciiz		"\nThe sum is: "
s3:	.asciiz		"\nThe average is: "
er:	.asciiz		"\nError, this is not an integer."
	.text
initialize:					#registers are initialized here
	li	$t0, 0				#$t0 is my initializer
	li	$s2, 0				#flag for negative numbers
	li	$s0, '0'			#load character '0' into $s0 (t4
	li	$s1, '9'			#load character '9' into $t5
enterNumber:					#this loop iterates the user entering a number 				
	la	$a0, s1
	li	$v0, SysPrintString		#prints out first message
	syscall
	li	$v0, SysReadString		#reads user inputed string
	la	$a0, buffer			#address of input buffer
	li	$a1, 100			#load length of buffer 
	syscall					
	lbu	$t1, 0($a0)			#load first character
	beq	$t1, '\n', printSum		#branches to exit sequence if equal to newline character
	bne	$t1, '-', numConversion	#branches to numConversion if positive
ifnegative:					#if the first character is '-' it moves to the next character
	addi	$a0, $a0, 1			#moves to the next byte in the string
	lbu	$t1, 0($a0)			#loads second byte to convert number
	addi	$s2, $s2, 1			#flags to remember the negative
numConversion:					#checks for errors and converts to an integer
	blt	$t1, $s0, error			#branch to error message if less than '0'
	bgt	$t1, $s1, error			#branch to error message if greater than '9'
	
	subu	$t1, $t1, $s0			#subtract character '0' from string
	mul	$t0, $t0, 10			#multiply accumulator by 10
	add	$t0, $t0, $t1			#add integer to accumulator
checkNext:					#moves to next character and checks if its a newline before converting
	addiu	$a0, $a0, 1			#move to next byte in the string
	lbu	$t1, 0($a0)			#checks next char
	beq	$t1, '\n', negative		#branches to exit sequence if equal to newline character
	j	numConversion			#jump to conversion to continue number
negative:					#negative flag to convert back from positive
	beqz	$s2, totalSum			#makes the integer negative again
	mul	$t0, $t0, -1			#converts the integer back to negative
totalSum:					#calculates the ongoing sum
	addi	$t3, $t3, 1			#how many integers have been entered for average
	add	$t2, $t2, $t0			#adds the sum of integers together CHANGED T1 TO T0
	li	$t0, 0				#$t0 is my initializer HOPE THIS WORKS
	li	$s2, 0				#$s2 is my initializer
	j	enterNumber			#continues the loop of entering integers
error:
	la	$a0, er				#prints out error message
	li	$v0, SysPrintString
	syscall
	j	enterNumber			#jumps back to main loop
	
printSum:					
	la	$a0, s2				#prints out second message
	li	$v0, SysPrintString
	syscall
	
	addi	$t2, $t2, 0			#if user enters nothing on first run
	move	$a0, $t2			#moves sum into $a0
	li	$v0, SysPrintInt		#prints out sum
	syscall
	
	la	$a0, s3
	li	$v0, SysPrintString		#prints out third message
	syscall
	bgtz	$t2, printAverage		#prevents error of 0/0
	addi	$t3, $t3, 1
printAverage:
	div	$t3, $t2, $t3			#finds the average of the numbers 
	move	$a0, $t3			#moves average into $a0
	li	$v0, SysPrintInt		#prints the average
	syscall
	li	$v0, SysExit			#terminates the program
	syscall
	
