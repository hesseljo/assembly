TITLE Assignment 5a   (Hesseltine_Assignment5a.asm)

; Author: Joshua Hesseltine	 
; Course / Project ID : CS271/400               Date: 07/30/2016
; Description: Requirements are as follows:
; 1) User’s numeric input must be validated the hard way: Read the user's input as a string, and convert the
; string to numeric form. If the user enters non-digits or the number is too large for 32-bit registers, an
; error message should be displayed and the number should be discarded.
; 2) Conversion routines must appropriately use the lodsb and/or stosb operators.
; 3) All procedure parameters must be passed on the system stack.
; 4) Addresses of prompts, identifying strings, and other memory locations should be passed by address to the macros.
; 5) Used registers must be saved and restored by the called procedures and macros.
; 6) The stack must be “cleaned up” by the called procedure.

INCLUDE Irvine32.inc 

; Global Constants 
HI	= 39h
LO	= 30h
MIN = 0
MAX = 10

.data
head1		BYTE	"PROGRAMMING ASSIGNMENT 6A: Designing low-level I/O procedures", 0
head2		BYTE	"Written by: Joshua Hesseltine", 0
head3		BYTE	"Please provide 10 unsigned decimal integers. Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.", 0
askMsg  	BYTE	"Please enter an unsigned number: ", 0
errorMsg	BYTE	"ERROR: You did not enter an unsigned number or your number was too big.", 0
tryAgain	BYTE	"Please try again: ", 0
resultMsg	BYTE	"You entered the following numbers: ", 0
sumMsg		BYTE	"The sum of these numbers is: ", 0
avgMsg		BYTE	"The average is: ", 0 
byeMsg		BYTE	"Thanks for playing!!", 0
spaces		BYTE	"  ", 0
input		DWORD 10 DUP(0)
count		DWORD ?	
list		DWORD MAX DUP(?)	; code from lecture
output		db 16 dup (0)		; code from lecture

; start macros ****************************************************************************
	printMsg MACRO msg
		push edx						; push register onto stack
		mov edx, msg					; copy msg cotents to edx register
		call WriteString				; print contents of edx register
		call CRLF						; print a new line
		pop edx							; clean the stack
	ENDM

	displayString MACRO output
		push edx						; push register onto stack
		mov edx, output					; copy output contents to edx register
		call WriteString				; print contents of edx register
		pop edx							; clean the stack
	ENDM

	getString MACRO msg, input, count
		push edx						; push register onto stack
		push ecx						; push register onto stack
		push eax						; push register onto stack
		push ebx						; push register onto stack
		mov edx, OFFSET askMsg			; copy msg to edx register
		call WriteString				; print contents
		mov edx, OFFSET input			; copy input address to edx register
		mov ecx, SIZEOF input			; copy byte size of input to ecx register
		call ReadString					; read user input
		mov count, 0					; set count to 0
		mov count, eax					; copy contents to eax register
		pop ebx							; clean the stack
		pop eax							; clean the stack
		pop ecx							; clean the stack
		pop edx							; clean the stack
	ENDM
; end macros ********************************************************************************

.code 
main PROC
	; display intro msg's
	push OFFSET head3
	push OFFSET head2
	push OFFSET head1
	call intro
	call CRLF

	; read in values and store in arraylist
	push OFFSET list
	push OFFSET input
	push OFFSET count
	call readVal
	call CRLF
	
	; convert values and print list
	printMsg OFFSET resultMsg
	push OFFSET output
	push OFFSET list
	call writeVal
	call CRLF

	; calculate and print average/sum from list array
	push OFFSET list
	push OFFSET sumMsg
	push OFFSET avgMsg
	call printMath

	; say goodbye
	push OFFSET byeMsg
	call goodbye
exit 
main ENDP

;-----------------------------------------------------------------------------------------------
; Description: retrieves input from user and saves to array 
; Receives:	list, count, input
; Returns: filled list
; Peconditions: empty list
; Registers Changed: eax, edx, ebx, ecx
;-----------------------------------------------------------------------------------------------
readVal PROC
	push ebp									; set up stack
	mov ebp, esp								; copy esp register to ebp register
	mov ecx, 10									; set ecx to 10 for number of values
	mov edi, [ebp + 16]							; @list

	getInputLoop:				
		getString askMsg, input, count			; parameters to pass to getString macro
		push ecx								; set up stack
		mov esi, [ebp + 12]						; copy input starting here
		mov ecx, [ebp + 8]						; input count 
		mov ecx, [ecx]							; starting value
		cld										; iterating through list
		mov eax, 0								; cleaneax
		mov ebx, 0								; clean ebx

		convert:
			lodsb								; load one byte at a time from input
			cmp eax, LO							; compare eax to 0
			jb displayError						; if less than jump to error handling
			cmp eax, HI							; compare to high
			ja displayError						; jump if above

			sub eax, LO							; subtract 0 from eax
			push eax							; set up stack
			mov eax, ebx						; copy ebx contents to eax
			mov ebx, MAX						; copy max to ebx
			mul ebx								; multiply
			mov ebx, eax						; copy result from mul to ebx
			pop eax								; remove eax from stack
			add ebx, eax						; add eax to ebx
			mov eax, ebx						; copy ebx content to eax 

		continue:
			mov eax, 0							; set eax to 0
			loop convert						; go again if still less than 10 
			mov eax, ebx						; copy ebx to eax
			stosd								; copy eax into list array
			add esi, 4							; add 4 to stack index
			pop ecx								; remove ecx from stack
			loop getInputLoop					; loop if less than 10
			jmp finish							; jump to finsh

		displayError:
			pop ecx								; set up stack
			mov edx, OFFSET errorMsg			; copy contents at address
			call WriteString					; print contents
			call CRLF							; print line
			jmp getInputLoop					; jump back to new loop for new value

		finish: 
			pop ebp								; remove base pointer
			ret 12								; clean stack
readVal ENDP
;-----------------------------------------------------------------------------------------------
; Description: says goodbye to user
; Receives:	byeMsg
; Returns: n/a
; Peconditions: processing strings must be completed
; Registers Changed: ebp, esp, edx
;-----------------------------------------------------------------------------------------------
goodbye PROC
	push ebp									; set up stack
	mov ebp, esp								; copy esp contents to base pointer
	call CRLF									; print line
	printMsg OFFSET byeMsg						; print bye msg
	call CRLF									; print line
	pop ebp										; remove base pointer
	ret 4										; clean stack
goodbye ENDP
;-----------------------------------------------------------------------------------------------
; Description: introduction to the program, display user input instructions
; Receives:	head1, head2, head3 
; Returns: n/a
; Peconditions: n/a
; Registers Changed: ebp, esp
;-----------------------------------------------------------------------------------------------
intro PROC
	push ebp									; set up stack
	mov ebp, esp								; copy esp to base pointer
	printMsg [ebp + 8]							; call macro
	call CRLF									; print line
	printMsg [ebp + 12]							; call macro
	call CRLF									; print line
	printMsg [ebp + 16]							; call macro
	call CRLF									; print line
	pop ebp										; remove base pointer
	ret 12										; clean stack
intro ENDP

;-----------------------------------------------------------------------------------------------
; Description: converts a numeric value to a string
; Receives:	list, count
; Returns: list
; Peconditions: n/a 
; Registers Changed: ecx, edx, bx, bc, dx, eax, 
;-----------------------------------------------------------------------------------------------
writeVal PROC			
 ;utilized answers from the following sources: 
; http://stackoverflow.com/questions/27703166/how-to-convert-a-string-to-number-in-assembly-language-8086
; http://stackoverflow.com/questions/19309749/nasm-assembly-convert-input-to-integer
; http://www.dreamincode.net/forums/topic/315572-array-to-string-in-masm-x86/
	push ebp								; set up stack
	mov	ebp, esp							; copy esp to base pointer
	mov	edi, [ebp + 8]						; @list
	mov	ecx, 10								; copy 10 to count register
	L1:	
		push ecx							; set up stack
		mov	eax, [edi]						; copy list value to eax
		mov	ecx, 10							; set count to 10
		xor	bx, bx							; count the total number of values

			L2:		
				xor	edx, edx					; exclusive or 
				div	ecx							; edx containes the remainder 
				push dx							; set
				inc	bx							; count number of digits
				test eax, eax					; check if contents of eax are 0
				jnz	L2							; jump if not zero
				mov	cx, bx					    ; copy number of total inputs to cx
				lea	esi, output				    ; copy string buffer to stack index
			
			L3:
				pop	ax							; remove ax from stack
				add	ax, '0'						; convert to ASCIII
				mov	[esi], ax					; write to the output variable
				displayString OFFSET output		; call macro 
				loop L3
			
		pop	ecx								; remove ecx
		mov	edx, OFFSET spaces				; copy spaces to edx
		call WriteString					; print spaces
		mov	edx, 0							; reset edx to 0
		mov	ebx, 0							; reset ebx to 0
		add	edi, 4							; add 4 to edi
		loop L1								; go until all are written
	
	pop	ebp									; remove base pointer
	ret	8									; return to call address
writeVal ENDP

;-----------------------------------------------------------------------------------------------
; Description: converts a numeric value to a string
; Receives:	list, count
; Returns: list
; Peconditions: n/a 
; Registers Changed: ecx, edx, esi, esp, ebp
;-----------------------------------------------------------------------------------------------
printMath PROC

	push ebp							; set up stak
    mov	ebp,esp							; copy pointer to base
    mov	esi,[ebp+16]					; copy base plus 16 to index @list
    pushad								; push all register onto stack
    call CRLF							; print line
    mov	ecx, 10							; copy 10 to ecx
    mov	eax, 0							; copy 0 to eax
	calculate:
		add	eax,[esi]					; add first list value to eax
		add	 esi,4						; add 4 to index
		loop calculate					; do it again till 10
		mov	edx,[ebp+12]				; copy pointer plus 12 to edx
		call CRLF						; print line
		call WriteString				; prints sum msg
		call WriteDec					; prints sum
		call CRLF						; prints line
		mov	ebx, 10						; copy 10 to ebx
		mov	edx, 0						; copy 0 to edx
		div	ebx							; divide ebx and copy contents to edx
		mov	 edx,[ebp+8]				; copy 8 plus pointer to edx
		call WriteString				; prints average msg
		call WriteDec					; prints average
		call CRLF						; print line
		popad							; pop all register off stack
		pop	ebp							; pop ebp off stack
	ret		12							; clean stack and return to call address
printMath ENDP

END main ;end of file