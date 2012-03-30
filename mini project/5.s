#include <iregdef.h>
.data
    buffer: .space 40
    menu1: .asciiz "\n1. Dec2Hex\n"
    menu2: .asciiz "\n2. Dec2Bin\n"
    menu3: .asciiz "\n3. Bin2Dec\n"
    menu4: .asciiz "\n4. Hex2Dec\n"
    promt_decimal: .asciiz "\nEnter the decimal number to convert: "
    promt_bin: .asciiz "\nEnter the binary number: "
    promt_hex: .asciiz "\nEnter the hex number: "
    result: .space 40
    decimal_str: .asciiz "\n--------------%d-----------\n"
    ans: .asciiz "\nResult: "
.text
.globl main

main:
    la a0,menu1
    jal printf
    nop
    la a0,menu2
    jal printf
    nop
    la a0,menu3
    jal printf
    nop
    la a0,menu4
    jal printf
    nop
    jal getchar
    nop
    add a0,v0,zero
    jal putchar
    jal checkMenuAndJump
    nop
    
    j main
    nop

#a0 input choice
.ent checkMenuAndJump
checkMenuAndJump:
    addi sp,sp,-4
	sw ra,0(sp)
    beq a0,49,Dec2HexFunction
    nop
    beq a0,50,Dec2BinFunction
    nop
    beq a0,51,Bin2DecFunction
    nop
    beq a0,52,Hex2DecFunction
    nop
    lw ra,0(sp)
    addi sp,sp,4
    jr ra
    nop
.end checkMenuAndJump

.ent Dec2HexFunction
Dec2HexFunction:
    addi sp,sp,-4
	sw ra,0(sp)
    la a0,promt_decimal
    jal printf
    nop
    la a0,buffer
    add a1,zero,8
    jal InputDec
    nop
    la a0,buffer
    jal atoi
    nop
    add s0,v0,zero

    la a0,ans
    jal printf
    nop
    add a0,s0,zero
    la a1,result
    add a2,zero,8
    jal Dec2Hex
    nop
    la a0,result
    jal printf
    nop
    lw ra,0(sp)
    addi sp,sp,4
    jr ra
    nop
.end Dec2HexFunction

#input decimal string
#a0 = begining address of string
#a1 = maximum length of string
#v0 = length of string
.ent InputDec	
InputDec:
	addi sp,sp,-4
	sw ra,0(sp)
	add s0,a1,zero #load maximum size of `buffer
    add t0,a0,zero #load begining address of string
	li t1,0 #t0 as i
	cont_InputDec:
		jal getchar #get 1 char
		nop
		li v1,'\n'
		sub t2,v0,v1
		beq t2,zero,finish_InputDec #if getchar() == '\n' --> finish InputDec
		nop
        bne t1,zero,already_check_sign
        beq v0,45,check_ok
        nop
        already_check_sign:
		ble v0,47,cont_InputDec #determine what is InputDeced
		nop
		bge v0,58,cont_InputDec #determine what is InputDeced
		nop
        check_ok:
		add t2,v0,zero
		sb t2,0(t0) #save to buffer
		add a0,t2,zero
		jal putchar
		nop
		addi t0,t0,1 #i++
        addi t1,t1,1
		slt t2,s0,t1
		beq t2,zero,cont_InputDec #if i < 20 continue getchar
		nop
	finish_InputDec:
		sb zero,0(t0) #ending zero
        add v0,t0,zero
		lw ra,0(sp)
		addi sp,sp,4
		jr ra
		nop
.end InputDec


#a0 - string
#v0 = integer
.ent atoi
atoi:
		or      v0, zero, zero   # num = 0
    	or      t1, zero, zero   # isNegative = false
    	lb      t0, 0(a0)
    	bne     t0, '+', .isp_atoi      # consume a positive symbol
    	nop
    	addi    a0, a0, 1
.isp_atoi:
    	lb      t0, 0(a0)
    	bne     t0, '-', .num_atoi
    	nop
    	addi    t1, zero, 1       # isNegative = true
    	addi    a0, a0, 1
.num_atoi:
    	lb      t0, 0(a0)
    	slti    t2, t0, 58        # *str <= '9'
    	slti    t3, t0, '0'       # *str < '0'
    	beq     t2, zero, .done_atoi
    	nop
    	bne     t3, zero, .done_atoi
    	nop
    	sll     t2, v0, 1
    	sll     v0, v0, 3
    	add     v0, v0, t2       # num *= 10, using: num = (num << 3) + (num << 1)
    	addi    t0, t0, -48
    	add     v0, v0, t0       # num += (*str - '0')
    	addi    a0, a0, 1         # ++num
    	j   .num_atoi
    	nop
.done_atoi:
    	beq     t1, zero, .out_atoi    # if (isNegative) num = -num
    	nop
    	sub     v0, zero, v0
.out_atoi:
    	jr      ra         # return
	nop
.end atoi

#a0 = decimal number
#a1 = begin address of hex string
#a2 = maximum length of hex string
#v0 = 1 --> succesful
.ent Dec2Hex
Dec2Hex:
	add t0,a2,zero		        # counter
    add t3,a1,zero #begining address of hex string
	#la t3, result		# where answer will be stored
	move t2, a0
	
	Loop_t0_Dec2Hex:

		beqz t0, Exit_Dec2Hex		# branch to exit if counter is equal to zero
		nop
		rol t2, t2, 4		# rotate 4 bits to the left
		and t4, t2, 0x0000000f	        # mask with 0..001111
		ble t4, 9, Sum_Dec2Hex		# if less than or equal to nine, branch to sum
		nop
		addi t4, t4, 55        # if greater than nine, add 55

		b End_Dec2Hex
		nop
	Sum_Dec2Hex:
		addi t4, t4, 48	# add 48 to result
	End_Dec2Hex:

		sb t4, 0(t3)		# store hex digit into result
		addi t3, t3, 1		# increment address counter
		addi t0, t0, -1		# decrement loop counter

		j Loop_t0_Dec2Hex
		nop
	Exit_Dec2Hex:
        sb zero, 0(t3)
		li v0,1
		jr ra
		nop
.end Dec2Hex

.ent Dec2BinFunction
Dec2BinFunction:
	addi sp,sp,-4
	sw ra,0(sp)
    la a0,promt_decimal
    jal printf
    nop
    la a0,buffer
    add a1,zero,32
    jal InputDec
    nop
    la a0,buffer
    jal atoi
    nop
    add s0,v0,zero

    la a0,ans
    jal printf
    nop
    add a0,s0,zero
    la a1,result
    add a2,zero,32
    jal Dec2Bin
    nop
    la a0,result
    jal printf
    nop
	lw ra,0(sp)
    addi sp,sp,4
    jr ra
    nop

.end Dec2BinFunction

#a0 = decimal number
#a1 = begin address of hex string
#a2 = maximum length of hex string
#v0 = 1 --> succesful
.ent Dec2Bin
Dec2Bin:
	add t0,a2,zero		        # counter
    add t3,a1,zero #begining address of hex string
	#la t3, result		# where answer will be stored
	move t2, a0 #t2 = decimal number
	li t6,48 #char 0
	li t7,49 #char 1
	li s0,1 #s0 to store 0x1
	Loop_t0_Dec2Bin:

		beqz t0, Exit_Dec2Bin		# branch to exit if counter is equal to zero
		nop
		addi t0,t0,-1
		sll t4, s0, t0		# shift left t0 -1 bits to the left
		and t4, t4, t2	        # mask with 0..001111
		beq t4,zero,add_0_Dec2Bin
		nop
        j add_1_Dec2Bin
        nop
        add_0_Dec2Bin:
            sb t6,0(t3)
            addi t3,t3,1
            j Loop_t0_Dec2Bin
            nop
        add_1_Dec2Bin:
    		sb t7,0(t3)
            addi t3,t3,1
            j Loop_t0_Dec2Bin
            nop        

	Exit_Dec2Bin:
		sb zero,0(t3) #end with zero
		li v0,1
		jr ra
		nop
.end Dec2Bin

.ent Bin2DecFunction
Bin2DecFunction:
	addi sp,sp,-4
	sw ra,0(sp)
    la a0,promt_bin
    jal printf
    nop
    la a0,buffer
    add a1,zero,32
    jal InputBin
    nop
    add s2,zero,v0

    la a0,ans
    jal printf
    nop
    la a0,buffer
    add a1,s2,zero
    jal Bin2Dec
    nop
    la a0,decimal_str
    move a1,v0
	nop
    jal printf
    nop
	lw ra,0(sp)
	addi sp,sp,4
    jr ra
    nop
   
.end Bin2DecFunction

#a0 = begining address of string in type binary
#a1 = maximum length of string
#v0 = length of string
.ent InputBin	
InputBin:
	addi sp,sp,-4
	sw ra,0(sp)
	add s0,zero,a1 #load maximum size of `buffer
    add t0,a0,zero
	li t1,0 #t0 as i
	cont_InputBin:
		jal getchar #get 1 char
		nop
		li v1,'\n'
		sub t2,v0,v1
		beq t2,zero,finish_InputBin #if getchar() == '\n' --> finish InputBin
		nop
		ble v0,47,cont_InputBin #determine what is InputBined
		nop
		bge v0,50,cont_InputBin #determine what is InputBined
		nop
		add t2,v0,zero
		sb t2,0(t0) #save to buffer
		add a0,t2,zero
		jal putchar
		nop
		addi t1,t1,1 #i++
        addi t0,t0,1
		slt t2,s0,t1
		beq t2,zero,cont_InputBin #if i < 20 continue getchar
		nop
	finish_InputBin:
		sb zero,0(t0) #ending zero
		add v0,t1,zero
		lw ra,0(sp)
		addi sp,sp,4
		jr ra
		nop
.end InputBin

#a0 = begining of string
#a1 = length of string
#v0 = decimal number
.ent Bin2Dec
Bin2Dec:
	add t0,a0,zero #beginning of buffer
	add t2,a1,-1 #the last element of buffer
	add t1,t2,zero #t1 as j, j from (buffer.length-1) to 0
	li t3,0 #i in 2^i
	add v0,zero,zero
	loop_t1_Bin2Dec:
		add t4,t0,t1
		lb t5,0(t4) #t5 as buffer[j]
		beq t5,48,next_bit_Bin2Dec
		nop
		li t7,1 #t7 as 2^i
		beq t3,0,compute_dec_Bin2Dec
		nop
		li t7,2 #initialize the t7 = 2^1, then will compute t7
		li t6,0
		loop_t6_Bin2Dec: #loop to compute 2^i if i>0
			add t6,t6,1
			bge t6,t3,compute_dec_Bin2Dec
			nop
			add t7,t7,t7
			j loop_t6_Bin2Dec
			nop
		compute_dec_Bin2Dec:
			add v0,v0,t7
		next_bit_Bin2Dec:
            add t3,t3,1 #i++, increase level of power of 2
			add t1,t1,-1 #j--
			ble t1,-1,finish_Bin2Dec
			nop
			j loop_t1_Bin2Dec
			nop
	finish_Bin2Dec:
	jr ra
	nop
.end Bin2Dec

.ent Hex2DecFunction
Hex2DecFunction:
	addi sp,sp,-4
	sw ra,0(sp)
    la a0,promt_hex
    jal printf
    nop
    la a0,buffer
    add a1,zero,8
    jal InputHex
    nop
    add s2,v0,zero

    la a0,ans
    jal printf
    nop
    la a0,buffer
    add a1,s2,zero
    jal Hex2Dec
    la a0,decimal_str
    move a1,v0
	nop
    jal printf
    nop
	lw ra,0(sp)
	addi sp,sp,4
    jr ra
    nop
.end Hex2DecFunction

#string input in type of Hex, a0= address of string
#a0 = begin address of string
#a1 = maximum length of string
#v0 = length of string
.ent InputHex	
InputHex:
	addi sp,sp,-4
	sw ra,0(sp)
	add s0,zero,a1 #load maximum size of `buffer
    add t0,zero,a0
	li t1,0 #t0 as i
	cont_InputHex:
		jal getchar #get 1 char
		nop
		li v1,'\n'
		sub t2,v0,v1
		beq t2,zero,finish_InputHex #if getchar() == '\n' --> finish InputHex
		nop
		ble v0,47,cont_InputHex #determine what is InputHexed
		nop
		bge v0,103,cont_InputHex #determine what is InputHexed
		nop
        slt t2,v0,65  #determine what is InputHexed
        sgt t3,v0,57 #determine what is InputHexed
        and t2,t2,t3
        beq t2,1,cont_InputHex
        nop
        slt t2,v0,97 #determine what is InputHexed
        sgt t3,v0,70 #determine what is InputHexed
        and t2,t2,t3
        beq t2,1,cont_InputHex
        nop

		add t2,v0,zero
		sb t2,0(t0) #save to buffer
		add a0,t2,zero
		jal putchar
		nop
		addi t1,t1,1 #i++
        addi t0,t0,1
		slt t2,s0,t1
		beq t2,zero,cont_InputHex #if i < maximum length --> continue getchar
		nop
	finish_InputHex:
		sb zero,0(t0) #ending zero
		add v0,t1,zero
		lw ra,0(sp)
		addi sp,sp,4
		jr ra
		nop
.end InputHex

#convert Hex string to Deccimal number
#a0 = begining address of string
#a1 = length of string
#v0 = decimal number
.ent Hex2Dec
Hex2Dec:
	add t0,a0,zero #beginning of buffer
	add t2,a1,-1 #the last element of buffer
	add t1,t2,zero #t1 as j, j from (buffer.length-1) to 0
	li t3,0 #i in 2^i
	add v0,zero,zero
	loop_t1_Hex2Dec:
		add t4,t0,t1
		lb t5,0(t4) #t5 as buffer[j]
		beq t5,48,next_bit_Hex2Dec
		nop
        ble t5,57,cont_loop_t1_Hex2Dec
        nop
        add t5,t5,-7
        ble t5,70,cont_loop_t1_Hex2Dec
        nop
        add t5,t5,-32
        cont_loop_t1_Hex2Dec:
        add t5,t5,-48 #above intructions to compute the real t5 in decimal
		li t7,1 #t7 as 16^i
		beq t3,0,compute_dec_Hex2Dec
		nop
		li t7,16 #initialize the t7 = 16^1, then will compute t7
		li t6,0
		loop_t6_t3_Hex2Dec: #loop to compute 2^i if i>0
			add t6,t6,1
			bge t6,t3,compute_dec_Hex2Dec
			nop
			add t7,t7,t7 #*2
            add t7,t7,t7 #*2
            add t7,t7,t7 #*2
            add t7,t7,t7 #*2
			j loop_t6_t3_Hex2Dec
			nop
		compute_dec_Hex2Dec:
            li t6,0
            loop_t6_t7_Hex2Dec: #use to compute v0 = v0 + v0*16^i (i now is t7)
            	bge t6,t7,next_bit_Hex2Dec
            	nop
    			add v0,v0,t5
                add t6,t6,1
                j loop_t6_t7_Hex2Dec
                nop
		next_bit_Hex2Dec:
            add t3,t3,1 #i++, increase level of power of 2
			add t1,t1,-1 #j--
			ble t1,-1,finish_Hex2Dec #j < 0, so that nothing to read now
			nop
			j loop_t1_Hex2Dec
			nop
	finish_Hex2Dec:
	jr ra
	nop
.end Hex2Dec

