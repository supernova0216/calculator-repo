//
// X0-X2 - parameters to linux function services
// X8 - linux function number
//

//update makefile "%: %.s debug.s %.c aarch64-linux-gnu-gcc $(CFLAGS) $^ -o $@" under "all: $(TARGETS)"

.include "debug.s"
.global main

.data
	calculator_state: 	.fill 1, 1, 0 // power off or on, off = 0, on = 1
	last_operation_answer: 		.fill 1, 1, 0
	modulo_answer: 	.fill 1 ,8, 0 // used to hold last operation data
	modulo_a: 			.word 0
	modulo_b: 			.word 0
	binary_store:		.space 32
	decimal_store:		.fill 1, 8, 0
	temp_store:			.fill 1, 4, 0
	num:				.double 0.0	
	prev_result:		.double 0.0
	

	
.text

main: 
		//stp lr, x5, [sp, #-16]
		//ldp lr, x5, [sp], #16		
calculator_off:
	printStr "Please enter 1 to start calculator"
	printStr "Enter -1 to turn off"
	ldr x0, =temp_store
	bl get_input
	
	cmp w0, #1 // checks if user enter 1 to enter calculator
	beq main_menu
	cmp w0, #-1
	beq exit_program
	
	printStr "You didnt enter 1 to start calculator or -1 to exit program"
	//printStr ""
	b calculator_off

main_menu:	
	printStr "Calculator started"
	printStr " "
	
calculator_on:	
	printStr "Main Menu"
	printStr "Enter 1 to type a basic expression"
	printStr "Enter 2 to do basic arithmetic operations" 
	printStr "Enter 3 for more options (go to sub-menu)"
	printStr "Enter 4 to print out previous resuts" // it prints all arrays
	printStr "Enter 0 to Power Off"
	ldr x10, =calculator_state
	strb w0, [x10]
	
	ldr x0, =temp_store
	bl get_input
	
	cmp w0, #1
	beq calc_expression
	
	cmp w0, #2
	beq basic_arithmetic
	
	cmp w0, #3
	beq sub_menu
	
	cmp w0, #0
	beq exit_program
	
	printStr "Invalid input."
	b calculator_on

	
calc_expression:
	printStr "In calc expression"
	b calculator_on

	
basic_arithmetic:
				//start enter 2 numbers
first_num:
	ldr x0, =num
	printStr "Enter first number: "			//data type double
	bl get_num
	
	ldr x1, =num
	str d0, [x1]
	
	fmov d3, d0
	
	sub sp, sp, #16
	str d0, [sp]
	
second_num:	
	ldr x0, =num
	printStr "Enter second number: "
	bl get_num
	
	ldr x2, =num
	str d0, [x2]
	fmov d4, d0
	
	sub sp, sp, #16
	str d0, [sp]
	
	ldr d4, [sp]
	add sp, sp, #16
	ldr d3, [sp]

operations:	
	stp d3, d4, [sp, #-16]!
		
	ldr x0, =temp_store
	printStr "Enter 1 to do Addition"
	printStr "Enter 2 to do Subtraction"
	printStr "Enter 3 to do Multiplication"
	printStr "Enter 4 to do Division"
	printStr "Enter 0 to go back Main Menu"	
	bl get_input
	
	ldr x2, =temp_store
	str x0, [x2]
	
	ldp d3, d4, [sp], #16
	
	cmp x0, 0
	beq calculator_on
	
	cmp x0, 1
	beq addition
	
	cmp x0, 2
	beq subtraction
	
	cmp x0, 3
	beq multiplication
	
	cmp x0, 4
	beq division
	
	printStr "Invalid input"
	b basic_arithmetic
	
addition:
	fadd d0, d3, d4	
	stp d3, d4, [sp, #-16]! 	
	bl print

	b next

subtraction:
	fsub d0, d3, d4	
	stp d3, d4, [sp, #-16]! 	
	bl print

	b next

multiplication:
	fmul d0, d3, d4	
	stp d3, d4, [sp, #-16]! 	
	bl print

	b next

division:
	fcmp d4, 0
	beq undefined
	
	fdiv d0, d3, d4	
	stp d3, d4, [sp, #-16]! 	
	bl print

	b next
	
undefined:
	stp d3, d4, [sp, #-16]! 
	printStr "Undefined. Divisor must be not equal to 0"
	b next
	
next:	
	
	ldr x0, =temp_store
	printStr "\nEnter 1 to continue using same numbers for other operations"
	printStr "Enter 2 to input new numbers/ back to operations menu"
	printStr "Any number to go back to Main Menu"
	bl get_input
	
	ldr x2, =temp_store
	str x0, [x2]
	ldp d3, d4, [sp], #16
	
	cmp x0, #1
	beq operations
	
	cmp x0, #2
	beq basic_arithmetic
	
	b calculator_on
	
	
sub_menu:
	ldr x0, =temp_store
	
	printStr "Sub-Menu"
	printStr "Enter 1 to do Modulo ( % )"
	printStr "Enter 2 to find Square Roots"
	printStr "Enter 3 to convert Decimal to binary"
	printStr "Enter 4 to convert Binary to Decimal"
	printStr "Enter 5 to convert Decimal to Hex"
	printStr "Enter 6 to convert Hex to Decimal"
	printStr "Enter 7 for Unit Conversion"
	printStr "Enter 8 to find value of Exponent numbers"
	printStr "Enter 9 to find Factorial"
	printStr "Any number to return back to Main Menu"
	
	bl get_input
	
	cmp w0, #1
	beq calc_mod
	
	cmp w0, #2
	beq calc_sqrt
	
	cmp w0, #3
	beq convert_deci_binary
	
	cmp w0, #4
	beq convert_binary_deci
	
	cmp w0, #5
	beq convert_deci_hex
	
	cmp w0, #6
	beq convert_hex_deci
	
	cmp w0, #7
	beq convert_units
	
	cmp w0, #8
	beq exponent
	
	cmp w0, #9
	beq factorial
	
	b calculator_on
	
	//b ABNORMAL_OPERATION
	
	
calc_mod: // mod is remainder (a mod b = a - (a/b)*b
	printStr "enter two numbers to find its modulo (remainder)"
	
	// get first num
	printStr "Enter First Number"
	ldr x0, =temp_store
	bl get_modulo
	mov w20, w0
	ldr x10, =modulo_a
	str w20, [x10]
	//mov w0, w20 // USED FOR DEBUG
	//bl print_modulo // USED FOR DEBUG
	
	// get sec num
	printStr "Enter Second Number"
	ldr x0, =temp_store
	bl get_modulo
	mov w21, w0
	ldr x11, =modulo_b
	str w21, [x11]
	//mov w0, w21 // USED FOR DEBUG
	//bl print_modulo // USED FOR DEBUG
	
	// do operation
	ldr x10, =modulo_a
	ldr w10, [x10]
	ldr x11, =modulo_b
	ldr w11, [x11]
	
	//printStr "DEBUGGG"
	cmp w11, #0 // comparing if div by 0
	beq ABNORMAL_OPERATION // CAN CHANGE TO HANDLE DIV by 0
	
	sdiv w12, w10, w11 // a / b
	mul w12, w12, w11 // (a / b) * b
	sub w0, w10, w12 // a - (a / b) * b
	ldr x10, =modulo_answer
	str w0, [x10]
	bl print_modulo
	printStr ""
	b sub_menu

	
calc_sqrt:
	ldr x0, =num
	printStr "Enter a number for a square root: "
	bl get_num
	
	ldr x1, =num
	str d0, [x1]
	fcmp d0, 0
	blt error
	
	fmov d5, d0
	fsqrt d0, d5
	bl print
	sub sp, sp, #16
	str d0, [sp]
	b sub_menu

error:
	printStr "Error: Input must be positive."
	b calc_sqrt
	
convert_deci_binary:
	printStr "Enter a Decimal Number to Convert to Binary"
	
	bl print_binary
	b sub_menu

	
convert_binary_deci:
	printStr "Enter Binary Number to Convert to Decimal"
	ldr x0, =decimal_store
	mov w22, #0
	strb w22, [x0]
	
	ldr x0, =temp_store
	bl get_decimal
	
	mov w5, #1 // base
	mov w2, #2 // used to multiply by 2
	mov w6, w0 // w6 = w0, temp = input // a
	mov w7, #10 // b
	
convert_loop: // a - (a / b) * b
	sdiv w8, w6, w7 // (a / b)
	mul w8, w8, w7 // (a / b) * b
	sub w8, w6, w8 // w8 holds last digit a - (a / b) * b
	
	ldr x0, =decimal_store
	ldr w10, [x0]
	mul w8, w8, w5 // last digit * base
	add w10, w8, w10 // decimal += last digit * base
	
	ldr x0, =decimal_store
	strb w10, [x0]
	
	//printStr "BUGGGGGGG" 
	mul w5, w5, w2
	sdiv w6, w6, w7
	cmp w6, #0
	bne convert_loop
	
	ldr x0, =decimal_store
	ldr w0, [x0]
	bl print_decimal
	
	b sub_menu
	
	
convert_deci_hex:
	printStr "in convert deci to hex"
	b sub_menu
	
	
convert_hex_deci:
	printStr "in hex to deci"
	b sub_menu
	
	
convert_units:
	printStr "in convert units"
	b sub_menu
	

exponent:
	ldr x0, =num
	printStr "Enter base: "			//data type double
	bl get_num
	
	ldr x1, =num
	str d0, [x1]
	fmov d5, d0
	sub sp, sp, #16
	str d0, [sp]


	ldr x0, =num
	printStr "Enter exponent: "
	bl get_num
	
	ldr x2, =num
	str d0, [x2]
	fmov d6, d0
	
	sub sp, sp, #16
	str d0, [sp]
	
	ldr d6, [sp]
	add sp, sp, #16
	ldr d5, [sp]
	
	fmov d7, 1				//d7 stores exponential result, assign it = 1
	fmov d8, 1
	
	fcmp d6, 0
	beq special1	
	blt negative	
	
	fcmp d6, d8
	beq special2	
	
	fmov d9, 1			//d9 = 1 as d6 is positive
loop:	
	fmul d7, d7, d5 
	fsub d6, d6, d8
	fcmp d6, 0
	beq expo_result1
	
	b loop 		
	
special1:			
	fmov d0, d7
	bl print
	
	b sub_menu
	
special2:
	fmov d7, d5			
	fmov d0, d7
	bl print
	
	b sub_menu

negative:
	//printStr "Error: Calculator is now working with positive exponent only"
	//b exponent
	fmov d9, -1			//d9 = -1 as d6 is negative
	fabs d6, d6
	b loop

expo_result1:
	fcmp d9, d8
	bne expo_result2
	
	fmov d0, d7
	bl print
	
	b sub_menu

expo_result2:
	fdiv d0, d8, d7
	bl print
	
	b sub_menu
	
factorial:

	
ABNORMAL_OPERATION:
	printStr "CALCULATOR FAULT"
	//printStr "TURNING OFF NOW"
	b calculator_on
 
      
exit_program:
	printStr "Turning calculator off.."
	printStr "Calculator is OFF"
exit:        
// Setup the parameters to exit the program
// and then call Linux to do it.
        mov     X0, #0      // Use 0 return code
        mov     X8, #93     // Service command code 93 terminates this program
        svc     0           // Call linux to terminate the program
