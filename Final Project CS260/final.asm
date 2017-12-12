###############################
#CS 260			      #	
#Dr. Lang		      #	
#Washington State University  #
#Jaiteg S Mundi               #
#ID: 11422441                 #   
###############################

#########################################################################             
##|	The program obeys MIPS function calling convetions.
##|	 
##|	The program accepts two arguments for function stringToInt.
##|	Argument A (testInput): address of null terminated string.
##|	Argument B (base): An integer in the range of 2 and 16.
##|	
##|	The program outputs an integer result converting the given
##|	argument a into an integer.
##|	If the second argument is not in the range of 2-16 the program 
##|	returns error message and returns the value of zero. The same 
##|	applies if the legal digits are not entered. 	  
##|
##|	Legality of the input                                                                                 
##|   	If the string has only the characters from '0' to '9'           
##|   	and from 'a' to 'f' and from 'A' to 'F'           
##|	Input starting with '-' is accetped '+' is illegal. 
##|	If the digits are not legal:              
##|   	The program prints out error message and returns value 0.  
##|	
##|   
##|_______________________________________________________________________#


#******************************Begin*************************************** 
.data
###############  Test Case ###################
  stringInput: .asciiz "-1234" 	#String        
  base:	       .byte 16	      	#Base (2-16)   
##############################################

  #Prints out error message.    
  errorMessage:  .asciiz "\nError. Please check input string."
   
.text  
###########################################################################
# Function: stringToInt
# Excepts two arguments string address and base. Loads base argument 
# into $a1 and char address into $t0. Converts string into ascii notation. 
# Checks the validity of base (between 2 and 16 incluseive) and if
# the input is negative. If negative convert it using twos complement. 
# If the base is not between 2-16 prints an error message return zero.
# Converts the string into integer. Terminates program at '\n' or '\0'. 

stringToInt: 
	
      	la $t0, stringInput	#current char address in t0
	li $t2, 0		#decimal equivalent intialized to 0
	li $t4, 1 		#power 
	lb $a1, base		#load base into register a1
	bgt $a1, 16, invalid	#checks if base is valid
	
	lb $s6, base		#loads base into register s6 
	addi $s6, $s6, 48	# converts s6 to ascii notation
	lb $s0, ($t0)	
	la $t5, stringInput
	beq $s0, '-', negSet	#checks first element of string to see if it is a minus sign
	j check			#jump to check
#_________________________________________________________________________#

###########################################################################
# Checks if the nubmer is negative. 	
negSet:
	addi $s7, $zero, 1	#s1 will store a value to check if no is negative 
	addi $t0, $t0, 1
	addi $t5, $t5, 1
#_________________________________________________________________________#

###########################################################################		
#Go till end of end of input
check:
	lb $t1, ($t0)
	beq $t1, '\n', endCheck
	beq $t1, '\0', endCheck
	add $t0, $t0, 1
	b check
	
endCheck:
#_________________________________________________________________________#

###########################################################################
# Go from last char to first, decrementing address. Compare from highest
# ascii value. If less than start address jummp to countinue4. Else invalid	
loop:
	sub $t0, $t0, 1
	blt $t0, $t5 , valid	 #if less than start address stop
	lb $t1, ($t0)
	bgt $s6, 57, continue3 	 #compare from highest ascii value
	bge $t1, $s6, invalid	 #branch to invaldi if  $t1 >= $s6
	j continue4		 #jump to continue 4

# exit point if base is greater than 10
continue3:
		
# makes sure only needed values are used	
continue4:	
	bge $t1, 'g', invalid		
	bge $t1, 'a', lower
	bge $t1, 'G', invalid
	bge $t1, 'A', upper
	bge $t1, '9', invalid
	bge $t1 , '0', digit
	 
#print error message and exit. 
invalid:
   	li $v0,1
   	li $a0,0
   	syscall
	li $v0, 4
	la $a0, errorMessage		 
	syscall
	b exit
					
#Peforms validity checks. 
#Check if the vlaue is negative. (Using twos complement) 	
valid:
   	addi $t1, $zero, 1
   	sll $t1, $t1, 31
   	and $s1, $t2, $t1 
   	bne $s1, $zero, bignegative
   	bne $s7, $zero, twosComplement	# checkes the s7 register to see if our value is negative
 
# Return point after converting to negative number if a minus sign 
# was detected. Print and exit. 	
continue2:			
	li $v0, 1		# Print content of t2
	move $a0, $t2
	syscall
	b exit	
	 
# manipulates the digit to convert and checks validity.   
digit:
	bgt $t1, '9', invalid
	sub $t3, $t1, '0' 	#get numeric digit value
	mul $t3, $t3, $t4 	#mulitply by the current power 
	add $t2, $t2, $t3
	mul $t4, $t4, $a1 	#next power 
	j loop			#jump back to loop 
	
#get numeric digit value	
lower:
	bgt $t1, 'f', invalid 
	sub $t3, $t1, 'a'
	add $t3, $t3, 10
	mul $t3, $t3, $t4 	#mulitply by the current power
	add $t2, $t2, $t3
	mul $t4, $t4, $a1 	#next power 
	b loop			#branch to loop 

#get numeric digit value	
upper:
	bgt $t1, 'F', invalid
	
	sub $t3, $t1, 'A'
	add $t3, $t3, 10
	mul $t3, $t3, $t4 	#mulitply by the current power 
	add $t2, $t2, $t3 	#add to decimal
	mul $t4, $t4, $a1	#next power 
	b loop 			#branch to loop 
	
bignegative:
	li $t7, 10		# load value 10 into register t7
	divu $t2, $t7
	mflo $t1		# move value of LO register into $t1
	mfhi $t7		# move value of HI register into $t7
	
	#Print t1
	add $a0, $t1, $zero
	li $v0, 1
	syscall
	
	# printt7
	add $a0, $t7, $zero
	li $v0, 1
	syscall

#Ends the program and exit. 	
#tell the system this is the end of stringToInt 
exit: 	
    	li $v0, 10
    	syscall
	
#Perform the twos complement by subracting zero. To convert 
#negative input. 	
twosComplement:
 	
 	sub $t2, $zero, $t2 	# convert number to negative
 	j continue2             #jump to continue2 


#_________________________________________________________________________#
    	
 
