.data
promptN: .asciiz "Enter Numerator:  "
.align 2

promptD: .asciiz "Enter a Divisor: "
.align 2

eMessage: .asciiz "You can't divide by 0! "

numerator: .word

.text
la $a0, promptN
li $v0, 4
syscall

li $v0, 5
syscall

sw $v0, numerator($0)  # store address of numerator
la $a0, promptD
li $v0, 4
syscall

li $v0, 5
syscall

move  $a1, $v0 #  divisor $v0 into $a1
lw    $a0, numerator($0)  # Numerator($0) into $a0
beq   $a1, $0, error

Divide:
jal findingn # Finding the #bits of the numerator 
findingn:
addi  $sp, $sp, -12  # make room on stack
sw    $s0, 8($sp) # this is my n
sw    $a0, 4($sp) # store $a0, the numerator in the stack
sw    $ra, 0($sp) # store $ra, the return address to divide
srl   $a0, $a0, 1 # shift N to the right 1 bit
addi  $s0, $s0, 1 # add 1 to increment counter of n
beq   $a0, $0, done # when $a0 = 0, the function loop is done
jal findingn 

done: 
lw    $s0, 8($sp)
lw    $a0, 4($sp)
lw    $ra, 0($sp)
addi  $sp, $sp, 12 # restoring the stack
add   $v0, $s0, $0 # return $s0 (n) in $v0
jr $ra

error: 
la $a0, eMessage 
li $v0, 4
syscall
 
exit:
li $v0, 10
syscall 


