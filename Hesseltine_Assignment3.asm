TITLE Assignment 3    (Hesseltine_Assignment3.asm)

; Author: Joshua Hesseltine	 
; Course / Project ID : CS271/400               Date: 07/24/2016
; Description:  This program calculates composite numbers by asking the user to enter a number
; of composites to display and asked to enter an integer in a range from 1 to 400.
; the program performs data validation on user input by verifiying the range and prompting if
; false. After data validation, the program calculates and displays all the composite numbers
; The results are displayed in a uniform manner with at minimum 3 spaces between numbers and
; a maximum of 10 numbers per line

INCLUDE Irvine32.inc 

UPPERLIMIT = 400

.data

;instructions/admin
head1			BYTE "Composite Numbers", 0
head2			BYTE "Programmed by Joshua Hesseltine", 0
head3			BYTE "Enter the number of composite numbers you would like to see", 0
head4			BYTE "I'll accept orders for up to 400 composites", 0 
instructionMsg	BYTE "Enter the number of composites to display [1 .. 400]: ", 0
errorMsg		BYTE "Oops, Out of Range. TRY AGAIN!", 0
byeMsg			BYTE "Results certified by Joshua Hesseltine.  Goodbye.", 0
extra			BYTE "**EC: Aligned output columns", 0

; user and output variables
input			SDWORD ?
count			SDWORD ?
idx				SDWORD 4
spaces			BYTE "   ", 0

.code 
main PROC

	call introduction
	call getUserData
	call showComposites
	call farewell

exit 
main ENDP

; Description: procedure called to display intro message and instructions to user
; Receives: n/a
; Returns: n/a
; Peconditions: n/a
; Registers Changed: edx
	introduction PROC
		mov edx, OFFSET head1
		call WriteString
		call CRLF
		mov edx, OFFSET extra
		call WriteString
		call CRLF
		mov edx, OFFSET head2
		call WriteString
		call CRLF
		mov edx, OFFSET head3
		call WriteString
		call CRLF
		mov edx, OFFSET head4
		call WriteString
		call CRLF
		ret
	introduction ENDP

; Description: gets user input and calls validate procedure
; Receives: input SDWORD
; Returns: n/a
; Peconditions: n/a
; Registers Changed: eax, edx, ebx
	getUserData PROC
		call CRLF
		mov edx, OFFSET instructionMsg
		call WriteString
		call ReadInt						; read in user input and store in input variable
		mov input, eax						; copy input to eax register 
		call validate						; call validate procedure
		ret									; return to main 
	getUserData ENDP

		; Description: procedure called to validate user input
		; Receives: input
		; Returns: n/a
		; Peconditions: n/a
		; Registers Changed: eax, edx, ebx
		validate PROC
			mov eax, input					; copy input contents to eax register
			mov ebx, 1						; set ebx register to 1
			cmp eax, ebx					; compare input to 1
			jl error						; jump to error message if less than 1
			mov ebx, UPPERLIMIT				; copy 400 to ebx register
			cmp eax, ebx					; compare input to 400
			jg error						; if greater than 400 jump to error
			jmp validated					; jump to return call

		error:
			mov edx, OFFSET errorMsg
			call WriteString
			call getUserData				; return to getting user input
		
		validated:
			ret								; bye	
		validate ENDP

; Description: procedure called to show results after calculating composite numbers
; Receives: input
; Returns: result
; Peconditions: input
; Registers Changed: edx
	
	showComposites PROC
	
	mov ecx, input							; copy input to ecx to begin counter
	
	L1:
		call isComposite					; call isComposite function 
		mov eax, idx						; copy index to eax register (starts at 4)
		call WriteDec						; print contents of eax
		Align 2								; call align instruction
		mov edx, OFFSET spaces				; copy 3 spaces to edx register
		call WriteString					; send 3 spaces after displaying number
		inc idx								; increment index by 1
		inc count							; increment count by 1
		cmp count, 10						; compare count to 10
		je increment						; jump if equal to 10 (reached the line ending)
		loop L1								; start over if less than 10
		jmp next							; end

	increment:
		call CRLF							; increment line by one return 
		mov count, 0						; set number in line count to 0
		loop L1								; start over

	next:
		ret									; bye
	showComposites ENDP	

; Description: isComposite called only by showComposites to calculate prime numbers and add 1 within the range
; Receives: idx, count
; Returns: idx
; Preconditions: the idx must be >= 4 
; Registers Changed: edx, ebx, eax

	isComposite PROC
		mov edx, 0							; set edx to 0
		mov eax, idx						; copy index to eax register
		mov ebx, 2							; copy 2 to ebx
		div ebx								; divide by 2
		cmp edx, 0							; cmp remainder to 0
		je next								; end if equal to 0 -- go to the next number
		mov edx, 0							; set edx to 0
		mov eax, idx						; copy index to eax register
		mov ebx, 3							; copy 3 to ebx
		div ebx								; div by 3
		cmp edx, 0							; compare to 0
		je next								; end if equal to 0
		mov count, 5						; set count to 5 (first prime after 4)

	L2:
		mov edx, 0							; set edx to 0
		mov eax, idx						; copy index to eax
		mov ebx, count						; copy count to ebx
		cmp eax, ebx						; compare eax to ebx
		je primeNumber						; if equal than jump to primeNumber (registers are ==)
		div ebx								; else, divide count
		cmp edx, 0							; compare result to 0
		je next								; if equal to 0 end isComposite, return to showComposite
		add count, 2						; add 2 to count
		mov edx, 0							; set edx to 0
		mov eax, idx						; copy index to eax
		mov ebx, count						; copy count to ebx
		cmp eax, ebx						; compare count to index (remeber we added 2)
		je primeNumber						; if equal, the number is prime (add one for composite)
		div ebx								; div count
		cmp edx, 0							; compare remainder to 0
		je next								; end if 0
		add count, 4						; add 4 to count
		mov edx, 0							; set edx to 0
		mov eax, count						; set eax to count (count + 4)
		mul count							; multuply count
		cmp eax, idx						; compare count to index
		jle L2								; loop again if less than multiple or equal to it

		primeNumber:
			inc idx							; increment index by one (transform prime to composite number)
		next:
			ret								; bye
	isComposite ENDP

; Description: procedure called to display a bye message to user
; Receives: n/a
; Returns: n/a
; Preconditions: n/a
; Registers Changed: edx
	farewell PROC
		call CRLF
		mov edx, OFFSET byeMsg
		call WriteString
		call CRLF
		ret
	farewell ENDP
END main