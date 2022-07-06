#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#
; this header has to remain
; add your code here

		jmp	st1
 
;proteus allows you to change the reset address
;hence changing it to 00000H - so every time system is reset it will go and execute the instruction at address 00000H - which is jmp st1
         
		db	1021 dup(0)

;jmp st1 will take up 3 bytes in memory - another 509 bytes are filled with '0s'
;1021 + 3 bytes = 1024 bytes

;first 1 k of memory is IVT - 00000 -00002H will now have the jmp instruction. 00003H - 001FFH will
;have 00000 - as vector number 0 to 79H are unused

;IVT entry for 80H - address for entry is 80H x 4 is 00200H       
;code segment will be in ROM     
    
		st1:	cli 

; intialize ds, es,ss to start of RAM - that is 020000H - as you need r/w capability for DS,ES & SS
; pl note you cannot use db to store data in the RAM you have to use a MOV instruction. 
; so if you want to do dat1 db 78H - you have to say something like
; dat1 equ 0002h
; mov al,78h
; mov dat1,al
;0002H is the offset in data segmnet where you are storing the data.
;db can be used only to store data in code segment

		mov	ax,02000h
          	mov   ds,ax
          	mov   es,ax
          	mov   ss,ax
          	mov   sp,0FFFEH
          
; intialise portA as input, portB, portC as output for the first 8255

        	mov   al,10010000b	;control word      	
      	out	06h,al        

;Keep polling port A until you get 1 from the switch

POLLING :    in	al,00h    		;get input from port A of the first 8255 (for checking switch)  
         	 mov  bl,01h      
         	 cmp  bl,al 		;when switch gets on, the input changes from 00h to 01h
         	 jne 	POLLING   
                                   
TRUE:

; initialize port A,port B as output and port C is don't care for now in 2nd 8255

		mov 	al,10000000b	;control word              
          	out  	0Eh,al       	
 
          	mov 	dx,00h      	;initialize dx with starting address of test ram
                      
START:     
          	mov 	ch,11111110b   	;initialize ch with first bit 0 test case value other values are don't care
          	mov 	bh,00000001b   	;initialize bh with first bit 1 test case value other values are don't care
         
          	mov 	cl,08
          
WRITE0:	;for writing 0's

		mov 	al,10000000b     
            out 	0Eh,al

            mov 	al,dl  		;Take LSB of address from DX and put it in al
            out	0Ah,al           	;put the LSB in Port B of the second 8255            


            mov 	al,dh             ;Take MSB of Address from DX and put it in AL
            out 	0Ch,al            ;Put the LSB in Port B of the second 8255

            mov 	al,00001010b      ;BSR mode --> reset C5 bit of port C of second 8255  to enable CE' of the Test Ram
            out 	0Eh,al
            mov 	al,00001100b      ;BSR mode --> reset C6 bit of port C of second 8255  to enable WR' of the Test Ram to enable writing to the RAM
            out 	0Eh,al
            mov 	al,00001111b      ;BSR mode --> set C7 bit of port C of second 8255  to disable OE' of the Test Ram to disable reading to the RAM
            out 	0Eh,al
            mov   al,10000000b      ; control word        
            out   016h,al                                   
            mov 	al,ch             ;Write from Port A of 3rd 8255
            out 	10h,al		
            mov 	al,00001101b      ;BSR mode --> set C6 bit of port C of second 8255  to disable WR' of the Test Ram to disable writing to the RAM
            out 	0Eh,al
            mov 	al,00001011b      ;BSR mode --> set C5 bit of port C of second 8255  to disable CE' of the Test Ram
            out 	0Eh,al

READ0:	;for reading 0's

            mov 	al,10010000b	  ;initialize port A as input, Port B as output and port C is dont care for now in 2nd 8255      
            out 	0Eh,al
            mov 	al,dl               ;Take LSB of address from DX and put it in al
            out 	0Ah,al              ;put the LSB in Port B of the second 8255

            mov 	al,dh               ;Take MSB of Address from DX and put it in AL
            out 	0Ch,al              ;Put the LSB in Port B of the second 8255

            mov 	al,00001010b        ;BSR mode --> reset C5 bit of port C of second 8255  to enable CE' of the Test Ram
            out 	0Eh,al
            mov 	al,00001101b        ;BSR mode --> set C6 bit of port C of second 8255  to disable WR' of the Test Ram to disable writing to the RAM
            out 	0Eh,al
            mov 	al,00001110b        ;BSR mode --> reset C7 bit of port C of second 8255  to enable OE' of the Test Ram to able reading to the RAM
            out 	0Eh,al

            mov 	al,10010000b        ;control word      
            out 	016h,al  
            
            in 	al,10h              ;take input from port A of third 8255 
            mov 	bl,ch
            cmp 	al,bl			  ;compare with bl for the single bit 0 case				
            jnz 	FAIL                ;in case of a inconsistency of read and write, jump to the FAIL label
      
WRITE1:	;for writing 1's

            mov 	al,10000000b      
            out 	16h,al       

            mov   al,10000000b              
            out   0Eh,al

            mov 	al,dl               ;Take LSB of address from DX and put it in al
            out 	0Ah,al              ;put the LSB in Port B of the second 8255

            mov 	al,dh               ;Take MSB of Address from DX and put it in AL
            out 	0Ch,al              ;Put the LSB in Port B of the second 8255

            mov 	al,00001010b        ;BSR mode --> reset C5 bit of port C of second 8255  to enable CE' of the Test Ram
            out 	0Eh,al
            mov 	al,00001100b        ;BSR mode --> reset C6 bit of port C of second 8255  to enable WR' of the Test Ram to enable writing to the RAM
            out 	0Eh,al
            mov 	al,00001111b        ;BSR mode --> set C7 bit of port C of second 8255  to disable OE' of the Test Ram to disable reading to the RAM
            out 	0Eh,al
            mov   al,10000000b              
            out   016h,al                                    
            mov 	al,bh               ;Write from Port A of 3rd 8255
            out 	10h,al
            mov 	al,00001101b        ;BSR mode --> set C6 bit of C port of second 8255  to disable WR' of the Test Ram to disable writing to the RAM
            out 	0Eh,al
            mov 	al,00001011b        ;BSR mode --> set C5 bit of C port of second 8255  to disable CE' of the Test Ram
            out 	0Eh,al

READ1:	;for reading 1's

            mov	al,10010000b              
            out   0Eh,al

            mov 	al,dl               ;Take LSB of address from DX and put it in al
            out 	0Ah,al              ;put the LSB in Port B of the second 8255

            mov 	al,dh               ;Take MSB of Address from DX and put it in AL
            out 	0Ch,al              ;Put the LSB in Port B of the second 8255

            mov 	al,00001010b        ;BSR mode --> reset C5 bit of port C of second 8255  to enable CE' of the Test Ram
            out 	0Eh,al
            mov 	al,00001101b        ;BSR mode --> set C6 bit of port C of second 8255  to disable WR' of the Test Ram to disable writing to the RAM
            out 	0Eh,al
            mov 	al,00001110b        ;BSR mode --> reset C7 bit of port C of second 8255  to enable OE' of the Test Ram to able reading to the RAM
            out 	0Eh,al

            mov 	al,10010000b        ;initialize port A as input, port B as output and port C is dont care for now in 2nd 8255      
            out 	16h,al  
            
            in 	al,10h              ;take input from port A of third 8255 
            mov 	bl,bh		
            cmp 	al,bl			  ;compare with bl for the single bit 1 case
            jnz 	FAIL                ;in case of a inconsistency of read and write, jump to the FAIL label                 
                                         
          	ROL 	ch,1                ;Rotate the value to shift the single 0 to the next bit e.g. 11111110 becomes 11111101 --> 11111101 becomes 11111011 and so on
          	ROL 	bh,1                ;Rotate the value to shift the single 0 to the next bit e.g. 00000001 becomes 00000010 --> 00000010 becomes 00000100 and so on
         
          	dec 	cl
          	jnz 	WRITE0

		inc 	dx   
		cmp 	dx,8192d
		jz 	PASS
		jmp  	START
                                                           
; displaying FAIL on LED               
           
FAIL:     	mov 	al,00h	;all displays are turned OFF
          	out 	04,al 	;04h --> port C is connected to segments of the LEDs
          
          	mov 	al,71h	;For displaying F
          	out 	04h,al 	;04h --> port C is connected to segments of the LEDs

            mov 	al,0FEh	;enables the first LED
          	out 	02h,al	;02h --> port B is connected to enable signal of the LEDs

            mov 	al,0FFh
          	out 	02h,al
          
          	mov 	al,77h      ;For displaying A
          	out 	04h,al

            mov 	al,0Fdh	;enables the second LED for the next character
          	out 	02h,al

          	mov 	al,0FFh
          	out 	02h,al 
          
          	mov 	al,06h      ;For displaying I
          	out 	04h,al   
      
            mov 	al,0Fbh	;enables the third LED for the next character
          	out 	02h,al

          	mov 	al,0FFh
          	out 	02h,al
          
          	mov 	al,38h       ;For displaying L
          	out 	04h,al 

            mov 	al,0f7h	;enables the fourth LED for the next character
          	out 	02h,al

          	mov 	al,0FFh
          	out 	02h,al 
          
          	mov 	al,0FFh
          	out 	02h,al
          
          	mov 	al,00h
          	out	04h,al    
 
;this for the recurssion of the program 

          	in    al,00h
          	mov   bl,01h
          	cmp   bl,al 
          	jz 	TRUE  
                            
          	jmp FAIL
                         
;displaying PASS on LED       
              
PASS:		mov 	al,00h	;all displays are turned OFF
          	out 	04,al 	;04h --> port C is connected to segments of the LEDs
         
          	mov 	al,0FEh	;enables the first LED
          	out 	02h,al 	;02h --> port B is connected to enable signal of the LEDs
          
          	mov 	al,73h      ;For displaying P
          	out 	04,al 	;04h --> port C is connected to segments of the LEDs
          
          	mov 	al,0FDh	;enables the second LED for the next character
          	out 	02h,al 
          
          	mov 	al,77h      ;For displaying A
          	out 	04,al
          
          	mov 	al,0FBh	;enables the third LED for the next character
          	out 	02h,al 
          
          	mov 	al,6Dh	;for displaying S
          	out 	04,al         
          
          
          	mov 	al,0F7h	;enables the fourth LED for the next character
          	out 	02h,al 
          
          	mov 	al,6Dh	;for displaying S
          	out 	04,al 
          
          	mov 	al,0FFh
          	out 	02h,al
          
          	mov 	al,00h
          	out 	04h,al      

;this for the recurssion of the program 

		in	al,00h
          	mov   bl,01h
          	cmp   bl,al 
          	jz 	TRUE  
                            
   		jmp 	PASS