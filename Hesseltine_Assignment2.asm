TITLE Assignment 2     (Hesseltine_assignment2.asm)

; Author: Joshua Hesseltine 
; Course / Project ID : CS271/400              Date: 06/28/2016 
; Description:  This program calculates the fibonacci sequence based on user input in a specific range
; the program will display the programmer's name, user name, utilize a post-test loop to perform data 
; validation on user input, calculate and isplay fibonacci numbers and a parting message. 

INCLUDE Irvine32.inc

; CONSTANT
	UPPER_LIMIT = 46

.data

ptitle				BYTE	"Fibonacci Numbers", 0
programmerName		BYTE	"Programmed by Joshua Hesseltine", 0
askName				BYTE	"What's your name", 0
greetUser			BYTE	"Hola! ", 0
instructions1		BYTE	"Enter the number of Fibonacci terms to be displayed", 0
instructions2		BYTE	"Make sure to enter a valid integer between [1...46]", 0
instructions3		BYTE	"-->Enter a number: ", 0
inputError			BYTE	"oops!! Number is out of range. Try again ", 0
end1				BYTE	"Results certified by Joshua Hesseltine", 0
end2				BYTE	"Later! ", 0

userName	BYTE	33 DUP(0)
userInput	DWORD	?
base	    DWORD	?
firstTerm	DWORD	?
secondTerm	DWORD	?
count		DWORD	?
extraSpace	BYTE	"     ", 0

.code 
main PROC

; display title and programmer name
	mov			edx, OFFSET ptitle			; copy prompt
	call		WriteString					; print prompt
	call		CRLF						; print line
	mov			edx, OFFSET programmerName	; copy name
	call		WriteString					; print name
	call		CRLF						; print line

; getUsername
	mov			edx, OFFSET askName			; copy prompt
	call		WriteString					; print prompt
	mov			edx, OFFSET userName		; set edx to string
	mov			ecx, 32						
	call		ReadString					; read string to userName

; say hello
	mov edx, OFFSET greetUser
	call WriteString
	mov edx, OFFSET userName
	call WriteString
	call CRLF

; display instructions
	mov edx, OFFSET instructions1		; copy prompt
	call WriteString					; print prompt
	call CRLF							; print line
	mov edx, OFFSET instructions2		; copy prompt
	call WriteString					; print prompt
	jmp getNumberFromUser				; go to function call

tryAgain:
	mov	edx, OFFSET inputError          ; copy prompt
	call WriteString					; print prompt

getNumberFromUser:
	; ask for number
	mov edx, OFFSET instructions3		; copy prompt
	call WriteString					; print prompt
	call ReadInt						; store number from user
	call CRLF							; print line
	mov userInput, eax					; copy user input to eax register

	; start validating (note: we are still in getNumberFromUser)
		; validate lower
			mov eax, userInput			; copy user input to eax register 
			mov ebx, 1					; copy the value 1 to ebx register 
			cmp eax, ebx				; compare user input to 1
			jge validateUpper			; jump if user input is greater than or equal to 1
			jmp tryAgain				; go directly to try again if jge not executed
			
		; validate upper
	validateUpper:
			mov eax, userInput			; copy user input to eax register
			mov ebx, UPPER_LIMIT		; copy 46 to ebx register 
			cmp eax, ebx				; compare user's input to 46
			jg	tryAgain				; jump if greater than 46

		; process input
			call CRLF
			mov eax, 1					; copy 1 to eax register 
			mov firstTerm, eax			; start at 1 everytime
			call WriteDec				; write out contents to cmd line
			mov edx, OFFSET extraSpace	; insert whitespace for clarity
			call WriteString			; send white space to cmdline
			mov	eax, 1					; go back to 1
			cmp eax, userInput			; compare user input to 1(we know its in range here)
			jz endProgram				; end and exit if 0
			mov eax, 1					; start at 1 again for second number
			mov secondTerm, eax			; copy 1 to second term
			call WriteDec				; write out contents
			mov edx, OFFSET extraSpace	; insert whitespace for clarity
			call WriteString			; send white space to cmdline
			mov eax, 2					; copy 2 to eax register
			cmp eax, userInput			; compare userInput to 2
			jz endProgram				; end and exit if 0 (use case is userInput <=2)
				;;else;;
				mov ecx, userInput		; start counter for post-test loop
				dec ecx					; decremnt
				dec ecx					; decrement twice
				mov eax, 2				; starting from 2 
				mov count, eax			; balance count based on output thus far

				calculate:					;(source for algorithm: http://www.codecodex.com/wiki/Calculate_the_Fibonacci_sequence#80386.2B_Assembly)
				mov eax, firstTerm			; firstTerm + secondTerm = base 
				add eax, secondTerm			; add second term to eax register 
				mov base, eax				; copy eax to new base
				call WriteDec				; write out contents
				mov edx, OFFSET extraSpace	; copy extra space (5 spaces) to edx
				call WriteString			; print out spaces
				inc count					; increment count by 1
				mov edx, 0					; copy 0 to edx
				mov eax, count				; copy count to eax
				mov ebx, 5					; set ebx to 5
				div ebx						; divide ebx contents
				cmp edx, 0					; compare an check if 0
				jmp	continue				; if greater than 0 continue
				call CRLF

				continue: ;copies terms and loops according to counter till 0				
				mov	eax, secondTerm		
				mov	firstTerm, eax		
				mov	eax, base
				mov	secondTerm, eax	
				loop calculate		
	
endProgram:
	call CRLF					; print empty line
	mov	 edx, OFFSET end1		; copy message to edx
	call WriteString			; print edx contents
	call CRLF
	mov	 edx, OFFSET end2
	call WriteString
	mov	 edx, OFFSET userName
	call WriteString

exit ; exit to operating system

main ENDP 

END main