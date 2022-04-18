.data
unorderedList: .word 13, 26, 44, 8, 16, 37, 23, 67, 90, 87, 29, 41, 14, 74, 39, -1

insertValues: .word 46, 85, 24, 25, 3, 33, 45, 52, 62, 17

space: .asciiz " "
newLine: .asciiz "\n"



####################################
#   4 Bytes - Value
#   4 Bytes - Address of Left Node
#   4 Bytes - Address of Right Node
#   4 Bytes - Address of Root Node
####################################

.text 
main:

    la $a0, unorderedList


    jal build
    move $s3, $v0

    move $a0, $s3
    jal print

    li $s0, 8
    li $s2, 0
    la $s1, insertValues
insertLoopMain: 
    beq $s2, $s0, insertLoopMainDone

    lw $a0, ($s1)
    move $a1, $s3
    jal insert

    addi $s1, $s1, 4
    addi $s2, $s2, 1 
    b insertLoopMain
insertLoopMainDone:

    move $a0, $s3
    jal print


    move $a0, $s3
    jal remove


    move $a0, $s3
    jal print


    li $v0, 10
    syscall 


########################################################################
# Write your code after this line
########################################################################


####################################
# Build Procedure
####################################
build:

    #load unordered list address to t0
    move $t0, $a0
    #put build function's return address to stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)    

    #malloc
    li $v0, 9
	li $a0, 16  #16 bytes for node
	syscall

    #load unordered list address back to the a0
    move $a0, $t0

    #create root node
    lw $t1, 0($a0)    #load first integer to t1
    sw $t1, 0($v0)    #save integer to v0 address
    sw $zero, 4($v0)  #save zero for left child to v0+4 address
    sw $zero, 8($v0)  #save zero for right child to v0+8 address
    sw $zero, 12($v0) #save zero for parent node to v0+12 address  
    
    subu $sp, $sp, 4 
    sw   $a0, 0($sp)  #put a0 list address to the stack
    
    insertLoop:
        lw $t1, 4($t0) #load next integer in unordered list
        beq $t1, -1, insertLoopDone #check if it is equal to -1
        move $a0, $t1 #value
        move $a1, $v0 #root node address
        jal insert    #call insert
        addi $t0, $t0, 4 #add 4 to list address
        b insertLoop

    insertLoopDone:
    	lw   $a0, 0($sp) #call a0 list address from stack
	    addu $sp, $sp, 4
        lw $ra, 0($sp)   #call return address for build function from stack
        addi $sp, $sp, 4 
        jr $ra

####################################
# Insert Procedure
####################################
insert:
    addi $sp, $sp, -8
    sw $ra, 0($sp)    #put insert function's return address to stack
    sw $a0, 4($sp)    #put insert function's a0 value to stack
    add $s4, $s4, 1   #size info of the tree 
    move $t1, $a0     #put a0 value to t1 register
    #malloc
    li $v0, 9
	li $a0, 16  #16 bytes for node
	syscall

    move $a0, $t1     #put t1 value to a0 register
    sw $a0, ($v0)     #put value of the node to the new node address
    sw $zero, 4($v0)  #save zero for left child to v0+4 address
    sw $zero, 8($v0)  #save zero for right child to v0+8 address
    sw $zero, 12($v0) #save zero for parent node to v0+12 address

    add $t2, $s4, -1  #to find parent node
    div $t2, $t2, 2   # (i - 1) / 2
    mflo $t3          #take quotient
    li $t4, 0
    addi $t4, 16      #convert to 16 byte representation
    mul $t4, $t4, $t3

    add $t4, $t4, $a1 #add to the root node address

    sw $t4, 12($v0)   #put parent node address to v0+12 address

    move $t2, $s4     #put size info to t2 register

    #((size * 16) - 16) / 2 % 16 to find if node is left child or right child
    mul $t2, $t2, 16       #convert size info to 16 byte representation
    addi	$t2, $t2, -16  #size - 16
    li $t6, 2
    div		$t2, $t6	   # /2
    mflo	$t2			   #take quotient
    li $t6, 16
    div		$t2, $t6	   # mod 16
    mfhi	$t3			   # take mod 16 result 
    beq $t3, $zero, addLeftChild # if result is 0 then node is left child
    addRightChild:               #if result is 8 then node is right child
        sw $v0, 8($t4)        #save node address to parent node's address+8 address
        move $a0, $v0         #put v0 node address to a0 for heapSort function
        jal heapSort
        j exitInsert
    addLeftChild:
        sw $v0, 4($t4)        #save node address to parent node's address+4 address
        move $a0, $v0         #put v0 node address to a0 for heapSort function
        jal heapSort
        j exitInsert
    exitInsert:
        move $t7, $a0         #put last node address to t7 register
        move $v0, $a1         #put root node address to v0 register
        lw $ra, 0($sp)        #call return address for insert function from stack
        lw $a0, 4($sp)        #call a0 value for insert function from stack
        addi $sp, $sp, 8
        jr $ra

####################################
# Remove Procedure
####################################
remove:



    jr $ra

####################################
# Print Procedure
####################################
print:
    addi $sp, $sp, -4
    sw $a0, 0($sp)    #put print function's a0 value to stack
    move $t1, $a0   #put a0 root node address to t1 register
    printLoop:
        lw $t0, ($t1)  #put node value to t0 register
        li $v0, 1      #print int
        move $a0, $t0
        syscall
        li $v0, 4
        la $a0, space
        syscall
        beq $t1, $t7, printLoopDone #if node address == last node address, exit
        addi $t1, $t1, 16  #add 16 for looking for next node
        b printLoop
    printLoopDone:
        li $v0, 4
        la $a0, newLine
        syscall
        lw $a0, 0($sp)        #call a0 value for print function from stack
        addi $sp, $sp, 4
        jr $ra

####################################
# Extra Procedures
####################################
# $a0: inserted node address
heapSort:
    addi $sp, $sp, -4
    sw $a0, 0($sp)    #put heapify function's a0 value to stack
    move $t1, $a0     #address of node which is inserted
    swapLoop:
        lw $t3, 12($t1) #put parent node address to t3 register
        beq $t3, $zero, exit #if node is root, exit
        lw $t4, ($t3)   #parent node value
        lw $t5, ($t1)   #node value
        slt $t2, $t4, $t5 #parent<child control
        beq $t2, $zero, exit # if parent is not less, exit

        sw $t5, ($t3)  #put node value to parent node address
        sw $t4, ($t1)  #put parent node value to node adress
        move $t1, $t3  #put parent node address to t1 register
        b swapLoop
    exit:
        lw $a0, 0($sp)        #call a0 value for heapify function from stack
        addi $sp, $sp, 4
        jr $ra

