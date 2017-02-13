TITLE Assignment 4    (Hesseltine_Assignment4.asm)

; Author: Joshua Hesseltine	 
; Course / Project ID : CS271/400               Date: 07/30/2016
; Description: Program will generate random list from user input. The user will be prompted to
; enter a request, the program will display random integers in a range from 10 to 999. The program
; will display the randomly generated list, then sort the list in descending order and display again.
; The program will calculate the median value and display before the descending order display
; to the nearest integer and display a introduction and farewell message. 

INCLUDE Irvine32.inc 

; Global Constants 
MIN	= 10
MAX	= 200
HI	= 999
LO	= 100

.data

;instructions/admin
head1			BYTE "Sorting Random Integers:  ", 0
head2			BYTE "Programmed by Joshua Hesseltine", 0
head3			BYTE "This program generates random numbers in the range [100 .. 999] ", 0
head4			BYTE "displays the original list, sorts the list, and calculates the ", 0
head5			BYTE "median value. Finally, it displays the list sorted in descending order.", 0
instructMsg		BYTE "How many numbers should be generated? [10 .. 200]:", 0
displayUnsort	BYTE "The unsorted random numbers: ", 0
displayMedian	BYTE "The Median is: ", 0
displaySort		BYTE "The sorted list: ", 0
errorMsg		BYTE "Invalid Input. TRY AGAIN!", 0
extra			BYTE "**EC:  ", 0

; processing variables 
input			DWORD ?
spaces			BYTE "   ", 0

;array declaration
list DWORD 200 DUP(?)

.code 
main PROC

;print background and introduction to user
call head

; push user input variable to top of stack and call procedure to retrieve input
push OFFSET input
call getInput
call Randomize

; push array on stack, push input, build out the the array list
push OFFSET list
push input
call createList

; print display message, push array and user input onto stack and print the array
mov edx, OFFSET displayUnsort
call WriteString
call CRLF
push OFFSET list
push input
call printList

; push array and user input onto the stack and perform aa selection sort on the array
push OFFSET list
push input
call selectionSort

; print display message, push array and input onto stack, and print the array in sorted order decending 
mov edx, OFFSET displaySort
call WriteString
call CRLF
push OFFSET list
push input
call printList

; push array and input onto stack and find the median/average and print it
push OFFSET list
push input
call printMedian

exit 
main ENDP

;-----------------------------------------------------------------------------------------------
; Description: performs a selection sort algorithm on list
; Receives:	list, input
; Returns: sorted list
; Peconditions: valid range
; Registers Changed: eax, ecx, ebx, edx
;-----------------------------------------------------------------------------------------------

selectionSort PROC; used some code from: http://stackoverflow.com/questions/22446331/how-do-you-do-a-selection-sort-in-masm-assembly
	push ebp							; set up stack
	mov	ebp, esp					; point to top
	mov	ecx, [ebp+8]				; number of total looping elements
	dec	ecx							; decrement ecx by 1
	outerL:
		push ecx						; save outer loop
		mov	esi, [ebp+12]			; start of array address 
	innerL:
		mov	eax, [esi]				; contents in that element of the array
		cmp	[esi +4], eax			; compare current value to next value
		jl continue				; if the next is smaller than current, jump
		xchg eax, [esi+4]			; swap
		mov	[esi], eax									
	continue:
		add	esi, 4				; move to next element
		loop innerL				; go to next element
	pop	ecx						; restore outer loop
	loop outerL					; repeat outer loop
	pop	ebp						; pop what's been pushed
	ret	8						; finished return to 0

selectionSort ENDP
;-----------------------------------------------------------------------------------------------
; Description: createList takes user input and builds the array of random numbers
; Receives:	list array and user input		
; Returns: nothing
; Peconditions: user integer must be valid range
; Registers Changed: eax, esi, ecx
;-----------------------------------------------------------------------------------------------
createList PROC
	push ebp				; set up stack
	mov ebp, esp			; point to the stack 
	mov esi, [ebp + 12]		; set address to start of list
	mov ecx, [ebp + 8]		; set ecx to iteration count
		build:
		mov eax, HI			; copy constant value of HI to eax register
		sub eax, LO			; subtract hi from low constants
		inc eax				; add one for the complete range
		call RandomRange	; Irvine library call, random interger
		add eax, LO			; instructor provided idea to create a random value
		mov [esi], eax		; copy random int in list
		add esi, 4			; add 4 to set to next element in list
		loop build			; continue building the list
	pop ebp					; clean the stack
	ret 8					; returns the call bytes 
	createList ENDP
;-----------------------------------------------------------------------------------------------
; Description:	getInput
; Receives:	user input integer value			
; Returns: saves input to input variable 
; Peconditions: must be an integer value to return
; Registers Changed: eax, edx
;-----------------------------------------------------------------------------------------------
getInput PROC
	push ebp									; start of stack frame initialization 
	mov ebp, esp								; start of ptr
	mov ebx, [ebp+8]							; instructor provided way to set ptr to input address
		getIt:
		mov edx, OFFSET instructMsg				; mov instruction message to edx register
		call WriteString						; display to user
		call CRLF								; send blank line
		call ReadInt							; store int value to top of stack
		mov [ebx], eax							; copy input
		cmp eax, MIN							; compare to lowest viable input
		jl tryAgain								; if too low, jump to tryagain 
		cmp eax, MAX							; compare to highest viable input
		jg tryAgain								; if greater than, jump to tryagain
		jmp continue							; if in correct range, jump to continue
			tryAgain:
				mov edx, OFFSET errorMsg		; copy error message to edx register
				call WriteString				; display contents of edx register
				call CRLF						; send a blank line
				jmp getIt						; return to getIt loop to try again
			continue:
				mov [ebx], eax					; set user input to address at ebx pointer 
				pop ebp							; clean the stack
				ret 4							; retrun 4 bytes pushed onto the stack when getInput was called
	getInput ENDP
;-----------------------------------------------------------------------------------------------
; Description:	displays the overview, programmer name and purpose of the program 
; Receives:	head BYTE variables 1 - 5 in order  				
; Returns: 0
; Peconditions: none 
; Registers Changed: edx, 5 times 
;-----------------------------------------------------------------------------------------------
head PROC
	mov edx, OFFSET head1						; copy head1 contents to edx register
	call WriteString							; print contents to string
	mov edx, OFFSET head2						
	call WriteString
	call CRLF
	mov edx, OFFSET head3
	call WriteString
	call CRLF
	mov edx, OFFSET head4
	call WriteString
	call CRLF
	mov edx, OFFSET head5
	call WriteString
	call CRLF
ret
head ENDP

;-----------------------------------------------------------------------------------------------
; Description: displays the list
; Receives:	list, input
; Returns: nothing
; Peconditions: int has been validated in range
; Registers Changed: ecx, ebx, edx, eax
;-----------------------------------------------------------------------------------------------
printList PROC
	push ebp							; set stack frame
	mov  ebp, esp						; point to the top
	mov	 ebx, 0							; count to 10
	mov  esi, [ebp + 12]				; start of list
	mov	 ecx, [ebp + 8]					; loop through elements in input size
	printIt:
		mov	eax, [esi]					; start with the first list[0] element
		call WriteDec					; print it to the screen
		mov	edx, OFFSET spaces			; copy spaces variable to edx
		call WriteString				; print spaces
		inc	ebx							; increment by 1/add 1
		cmp	ebx, MIN					; compare count to min 
		jl	continue					; if less than 10 jump to new line
		call CRLF						; print extra line
		mov	ebx,0						; reset ebx
		
		continue:							
		add	esi, 4						; new address
		loop printIt					; print next element in list

	endPrint:
		call CRLF						; print extra line
		pop	ebp							; pop off stack whats been pushed thus far
		ret	8							; return bytes to main call
printList ENDP
;-----------------------------------------------------------------------------------------------
; Description: print median value to the screen
; Receives:	list, input
; Returns: sorted list
; Peconditions: valid range
; Registers Changed: eax, ecx, ebx, edx
;-----------------------------------------------------------------------------------------------
printMedian PROC
	push ebp						;set up stack
	mov  ebp, esp					; point to it
	mov  esi, [ebp + 12]			; esi at start of list
	mov	 eax, [ebp + 8]				; loop counter from size
	mov  edx, 0						; start at 0
	mov	 ebx, 2						; copy 2 to ebx register
	div	 ebx						; divide by 2
	mov	 ecx, eax					; copy result to ecx register
	continue:			
		add		esi, 4				; add 4 to esi
		loop	continue			; continue to next element
	cmp	edx, 0						; compare edx value to 0
	jnz odd							; jump to odd method
	mov	eax, [esi-4]				; copy esi to eax register
	add	eax, [esi]					; add esi to eax
	mov	edx, 0						; reset edx
	mov	ebx, 2						; start back at 2
	div	ebx							; divide by 2
	mov	edx, OFFSET displayMedian	; print median message to user
	call WriteString				; print it
	call WriteDec					; print median value	
	call CRLF						; print extar line
	jmp	finished					; jump to end of procedure

		odd:								; used if its an odd after division 
		mov	eax, [esi]						; copy esi to eax
		mov	edx, OFFSET displayMedian		; copy display message to edx register
		call WriteString					; print to screen
		call WriteDec						; print odd value
		call CRLF							; print extra line for clarity

	finished:
	pop  ebp						; pop off stack whats been pushed thus far
	ret  8							; return to where stack was at time of call
printMedian ENDP

END main