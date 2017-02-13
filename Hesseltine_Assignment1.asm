TITLE Assignment 1     (Hesseljo_Assignment1.asm)

; Author: Joshua Hesseltine 
; Course / Project ID : CS271/400              Date: 6/20/2016 
; Description:  This program will display fields and calculate the sum, difference, product
; (int) quotient and remainder from two numbers provided by a user. 

INCLUDE Irvine32.inc

.data

statusProgramTitle		BYTE "This is Elementary Arithmetic", 0
statusMyName			BYTE "by Joshua K. Hesseltine", 0
statusInstructions		BYTE "Enter 2 numbers and the program will show you the sum, difference, product, quotient and remainder", 0
statusGoodbye			BYTE "Thanks for playing!, goodbye mate!", 0
promptForFirstNumber	BYTE "please enter the first number(must be largest)", 0
promptForSecondNumber	BYTE "please enter the second number", 0
extraCredit				BYTE "**EC: Program prompts user to go again"
promptRecycle			BYTE "Do you wish to try a different set of numbers? Type 1 for yes, else hit enter", 0

sum			DWORD ?
difference	DWORD ?
product		DWORD ?
quotient	DWORD ?
remainder	DWORD ?

sumString			BYTE " + ", 0
differenceString	BYTE " - ", 0
productString		BYTE " X ", 0
quotientString		BYTE " / ", 0
remainderString		BYTE " has remainder ", 0
equals				BYTE " = ", 0

firstInput		DWORD ?
secondInput		DWORD ?
choice			DWORD ?

.code 
main PROC

;introduction
	;display title and name of author
		mov		edx, OFFSET statusProgramTitle	; copy variable contents to edx register 
		call	WriteString						; write out contents of edx register
		call	CRLF							; send a carriage return to shell 
		mov		edx, OFFSET statusMyName		;repeat
		call	WriteString
		call	CRLF
		mov		edx, OFFSET extraCredit			;repeat
		call	WriteString
		call	CRLF
		call	CRLF							; extra space for clarity

	;provide instructions and get the data
		call	CRLF
		mov		edx, OFFSET statusInstructions
		call	WriteString
		call	CRLF

getAnswers:						; label for jmp loop

		; get first value
		call	CRLF
		mov		edx, OFFSET promptForFirstNumber
		call	WriteString
		call	ReadInt							;x86 function to read-in user input after user hits enter
		mov		firstInput, eax					;save user data to input variable 

		; get second value
		call	CRLF
		mov		edx, OFFSET promptForSecondNumber
		call	WriteString
		call	ReadInt
		mov		secondInput, eax
		call	CRLF

;calculate the required values

	; get the sum
	mov		ebx, firstInput		; store firstInput in base register
	mov		ecx, secondInput	; store secondInput in counter register
	add		ecx, ebx			; add both values and store in ecx
	mov		sum, ecx			; copy sum varibale to display later 

	; get delta
	mov		ebx, firstInput
	mov		ecx, secondInput
	sub		ebx, ecx			; subtract input2 from input1
	mov		difference, ebx		

	; get product
	mov		eax, firstInput
	mul		secondInput			; muliply values
	mov		product, eax		; store 

	; get remainder and qoutient 
	mov		edx, 0				; set data register to 0 to get the remainder from quotient	
	mov		eax, firstInput			
	mov		ebx, secondInput
	div		ebx
	mov		quotient, eax
	mov		remainder, edx


;display the results

	; show sum
	mov		eax, firstInput			
	call	WriteDec					; display firstInput
	mov		edx, OFFSET sumString		
	call	WriteString					; display "+" sign
	mov		eax, secondInput
	call	WriteDec					; display secondInput
	mov		edx, OFFSET equals
	call	WriteString					; display "=" sign
	mov		eax, sum		
	call	WriteDec					; display sum result variable contents
	call	CRLF

	; show difference 
	mov		eax, firstInput
	call	WriteDec
	mov		edx, OFFSET differenceString
	call	WriteString
	mov		eax, secondInput
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, difference
	call	WriteDec
	call	CRLF

	;show product
	mov		eax, firstInput
	call	WriteDec
	mov		edx, OFFSET productString
	call	WriteString
	mov		eax, secondInput
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, product
	call	WriteDec
	call	CRLF

	;display remainder & quotient
	mov		eax, firstInput							
	call	WriteDec							
	mov		edx, OFFSET quotientString
	call	WriteString						
	mov		eax, secondInput
	call	WriteDec						
	mov		edx, OFFSET equals
	call	WriteString							
	mov		eax, quotient	
	call	WriteDec							
	mov		edx, OFFSET remainderString
	call	WriteString							
	mov		eax, remainder
	call	WriteDec						
	call	CrLf

; ask if user wants to try again

	call	CRLF
	mov		edx, OFFSET promptRecycle
	call	WriteString
	call	ReadInt
	mov		choice, eax
	mov		eax, 1
	cmp		eax, choice
	je		getAnswers				; loops back to getAnswers label to start over

;say goodbye
	call	CRLF
	mov		edx, OFFSET statusGoodbye
	call	WriteString
	call	CRLF

exit ; exit to operating system

main ENDP 

END main