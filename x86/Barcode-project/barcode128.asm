section .data
bytes_per_row equ 1800
barcode_mapping:
    	dd 0x00212222
    	dd 0x00222122
    	dd 0x00222221
    	dd 0x00121223
    	dd 0x00121322
    	dd 0x00131222
    	dd 0x00122213
    	dd 0x00122312
    	dd 0x00132212
    	dd 0x00221213
    	dd 0x00221312
    	dd 0x00231212
    	dd 0x00112232
    	dd 0x00122132
    	dd 0x00122231
    	dd 0x00113222
    	dd 0x00123122
    	dd 0x00123221
    	dd 0x00223211
    	dd 0x00221132
    	dd 0x00221231
    	dd 0x00213212
    	dd 0x00223112
    	dd 0x00312131
    	dd 0x00311222
    	dd 0x00321122
    	dd 0x00321221
    	dd 0x00312212
    	dd 0x00322112
    	dd 0x00322211
    	dd 0x00212123
    	dd 0x00212321
    	dd 0x00232121
    	dd 0x00111323
    	dd 0x00131123
    	dd 0x00131321
    	dd 0x00112313
    	dd 0x00132113
    	dd 0x00132311
    	dd 0x00211313
    	dd 0x00231113
    	dd 0x00231311
    	dd 0x00112133
    	dd 0x00112331
    	dd 0x00132131
    	dd 0x00113123
    	dd 0x00113321
    	dd 0x00133121
    	dd 0x00313121
    	dd 0x00211331
    	dd 0x00231131
    	dd 0x00213113
    	dd 0x00213311
    	dd 0x00213131
    	dd 0x00311123
    	dd 0x00311321
    	dd 0x00331121
    	dd 0x00312113
    	dd 0x00312311
    	dd 0x00332111
    	dd 0x00314111
    	dd 0x00221411
    	dd 0x00431111
    	dd 0x00111224
    	dd 0x00111422
    	dd 0x00121124
    	dd 0x00121421
    	dd 0x00141122
    	dd 0x00141221
    	dd 0x00112214
    	dd 0x00112412
    	dd 0x00122114
    	dd 0x00122411
    	dd 0x00142112
    	dd 0x00142211
    	dd 0x00241211
    	dd 0x00221114
    	dd 0x00413111
    	dd 0x00241112
    	dd 0x00134111
    	dd 0x00111242
    	dd 0x00121142
    	dd 0x00121241
    	dd 0x00114212
  	    dd 0x00124112
    	dd 0x00124211
   	    dd 0x00411212
    	dd 0x00421112
   	    dd 0x00421211
    	dd 0x00212141
    	dd 0x00214121
    	dd 0x00412121
    	dd 0x00111143
    	dd 0x00111341
    	dd 0x00131141

start_B:
	dd 0x00211214

stop:
	dd 0x02331112


character_mapping:
    db " !",34,"#$%&",39,"()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[",47,"]^_`abcdefghijklmnopqrstuvwxyz{|}~", 0

section .text
global decode128

decode128:
    push    ebp
    mov     ebp, esp
    push    ebx
    push    esi
    push    edi
    mov     eax, [ebp+8] ;file address
    mov     ebx, [ebp+12] ;y-coordinate
    push    eax
    push    ebx
    call    first_black
	add		esp, 8
    mov     ebx, eax;
    mov     eax, [ebp+8]
    mov     ecx, 6
    push    eax
    push    ebx
    push    ecx
    call    decode
	add		esp, 12
    mov     ebx, ecx
    mov     esi, eax
    push    ecx
    call    smallest_bar
	add		esp, 4
    mov     edi, eax
    push    ebx
    push    eax
    mov     ecx, 6
    push    ecx
    call    get_code
	add		esp, 12
	mov		ecx, start_B
	cmp		eax, [ecx]
	jne		wrong_start
	mov		ecx, [ebp+16] ; string address
	push	ecx
    mov     eax, [ebp+8]
    push    eax
    push    esi
    push    edi
    call    decode_characters
	add		esp, 16
	cmp		eax, -1
	je		error_stop3
	cmp		eax, 2
	je		error_checksum2
	mov		byte[eax], 0

decode128_exit:
	mov		eax, 0
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret

wrong_start:
	mov		eax, 1
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret
error_stop3:
	mov		eax, -1
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret

error_checksum2:
	mov		eax, 2
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret

;============================================================================
;description:
;	Searches for matching barcode value then saves the coresponding character into string
;arguments:
; 	[ebp+8] - smallest pixel width bar or space
; 	[ebp+12] - current x coordinate
; 	[ebp+16] - file address
; 	[ebp+20] - output string address
;return value:
;	eax - position to put null terminator / -1 when wrong checksum or stop character
decode_characters:
    push    ebp
    mov     ebp, esp
    push    ebx
    push    esi
    push    edi
	mov  	bl, 0
	mov	    esi, 104
	mov		edi, [ebp+12]

;Loop through all the symbols
loop_characters:
	inc     bl
    mov     eax, [ebp+16]
    mov     edx, 6
    mov     ecx, edi
    push    eax
	push    ecx
    push    edx
	call	decode
	add		esp, 12
	mov		edi, eax
	cmp		edi, -1
	je		error_stop2
    mov     edx, ecx
    mov     eax, [ebp+8]
    push    edx
    push    eax
    mov     ecx, 6
    push    ecx
	call	get_code
	add		esp, 12
	mov	    ecx, eax		;code in ecx
	mov	    edx, barcode_mapping

;loop through all the barcodes
loop_barcodes:
	mov		eax, barcode_mapping
	add		eax, 380
	cmp		edx, eax		;checking if code is not incorrect (not in barcode_mapping)
	jge		error_checksum
	mov	    eax, [edx]
    cmp     ecx, eax
	je      add_character
	add 	edx, 4
	jmp	    loop_barcodes

add_character:
	mov	    cl, 4
	mov	    eax, barcode_mapping
	sub	    edx, eax
	mov		eax, edx
	div		cl
	mov		bh, al
	mov		ecx, [ebp+8]
	push	ecx
	push    eax
	movzx	eax, bl
    push    eax
	push    esi
    mov     eax, [ebp+16]
    push    eax
	push	edi
	call	checksum
	add		esp, 24
    cmp     eax, 10000000
	je	    exit_decode	;Check if the code is over
	mov  	esi, eax
	mov	    eax, character_mapping
	movzx	ecx, bh
	add	    eax, ecx	;get ascii character index
	mov     ecx, [eax]	;load character
	mov	    edx, [ebp+20]
	movzx	eax, bl
	add	    edx, eax	;adjust character position
	dec	    edx
	mov	    [edx], ecx	;save character
	jmp	    loop_characters

exit_decode:
	mov	    eax, [ebp+20]
	movzx	ecx, bl
	add	    eax, ecx
	dec		eax
	pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret

error_stop2:
	mov    	eax, -1
	pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret

error_checksum:
	mov    	eax, 2
	pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret

;============================================================================
;description:
;	Check if current character is a checksum symbol, (if it is check if the next one is stop symbol) else calculate checksum
;arguments:
; [ebp+8] - current x coordinate
; [ebp+12] - file address
; [ebp+16] - previous checksum
; [ebp+20] - character index
; [ebp+24] - character value
; [ebp+28] - smallest bar or space pixel width
;return value:
;	eax - 10000000 if current character is checksum, else checksum value

checksum:
	push    ebp
    mov     ebp, esp
    push    ebx
    push    esi
    push    edi
	mov     bh, [ebp+24] ;character value
	mov     bl, [ebp+20] ; character index
    mov     ax, [ebp+16] ; previous checksum
	mov		cl, 103
    div     cl
    cmp     ah, bh
	je	    check_stop

not_stop:
	xor 	eax, eax
	mov	    al, bh
	mov		ecx, [ebp+20]
	mul	    cl	;calculate data value times index
    mov     ebx, [ebp+16]
	add	    eax, ebx	;add to checksum
	pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret


check_stop:
	mov	    eax, [ebp+12] ;file address
    push    eax
	mov	    eax, [ebp+8] ;x coordinate
    push    eax
    mov     ecx, 7
	push    ecx
	call	decode
	add		esp, 12
	mov     edi, ecx
    push    ecx
    mov		ecx, [ebp+28]
	push	ecx
    mov     ecx, 7
    push    ecx
	call	get_code	;decode stop symbol candidate
	mov 	ecx, eax
	add		esp, 12
	mov	    edx, stop
	mov     eax, [edx]
    cmp    	eax, ecx
	jne	    not_stop	;check if the candidate is the stop symbol

equal:
    mov	    eax, 10000000
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret

;============================================================================
;description:
;	Divide the code by smallest width pixel value, save it into one register
;arguments:
; [ebp+8] - how many bars + spaces
; [ebp+12] - smallest bar or space width
; [ebp+16] - pixel width of bars and spaces
;return value:
;	eax - character code value

get_code:
	push    ebp
    mov     ebp, esp
    push    ebx
    push    esi
    push    edi
    mov     eax, [ebp+16]
    movzx   bx, [ebp+12]
    mov     edi, 0
    mov     esi, [ebp+8]
    mov     ecx, eax

loop_code:
    and 	eax, 0xF	;get least significant byte
	shr	    ecx, 4
    xor     dx, dx
	div	    bx	    ;divide by minimal pixel length
	or 	    edi, eax
	shl	    edi, 4
	dec     esi
    mov     eax, ecx
    test    esi, esi
	jnz     loop_code

end_code:
	shr	    edi, 4
	mov	    eax, edi
    pop     edi
    pop     esi
	pop     ebx
    mov     esp, ebp
    pop     ebp
    ret

;============================================================================
;description:
;	Get smallest width bar or space pixel value
;arguments:
;	 [ebp+8] - bar and spaces pixel width
;return value:
;	eax - smallest bar or space pixel width

smallest_bar:
	push    ebp
    mov     ebp, esp
    push    ebx
	mov     al, 4
    mov     ecx, [ebp+8]
    mov     edx, ecx
    shr	    ecx, 4
    mov     ebx, ecx
	and     edx, 0xF  ;current biggest

check:
    mov     ecx, ebx
    test    al,al
	jz      get_smallest_bar
	shr	    ecx, 4
    mov     ebx, ecx
	and     ecx, 0xF
	dec	    al
	cmp     ecx, edx	;check if greater
    jg      check

switch:
	mov	    edx, ecx
	jmp	    check

get_smallest_bar:
    pop     ebx
	mov	    eax, edx
	mov     esp, ebp
    pop     ebp
    ret

;============================================================================
;description:
;	Count pixel width of one symbol bars and spaces
;arguments:
;	[ebp+8] - how many bars+spaces
;	[ebp+12] - starting x coordinate
;	[ebp+16] - file address
;return value:
;	eax - end x coordinate
;	ecx - pixel length of bars and spaces

decode:
	push    ebp
    mov     ebp, esp
	sub		esp, 12
    push    ebx
    push    esi
    push    edi
    mov     esi, [ebp+8]
    mov     edx, [ebp+12]
	mov     edi, 0
    mov     cl, 0
	mov     bh, 1 		;black current bar pixels counter
	mov     ch, 1		;white current space pixels counter

bar:
	test    esi, esi       ; Check if esi is zero
    je      end
	inc     edx
    mov     eax, 25
    push    eax
    mov   	eax, edx
    push    eax
	mov     eax, [ebp+16]
    push    eax
	call    get_pixel
	add		esp, 12
	cmp	    eax, 0x00000000
	je      add_black
	movzx   eax, bh
	shl     eax, cl
	or 	    edi, eax
	mov	    bh, 1 		;reset black pixel counter
	dec     esi
	add	    cl, 4


space:
    test    esi, esi       ; Check if esi is zero
    je      end
	cmp		ch, 15
	jge		error_stop
	inc     edx
    mov     eax, 25
    push    eax
    mov     eax, edx
    push    eax
	mov     eax, [ebp+16]
    push    eax
	call    get_pixel
	add		esp, 12
	cmp	    eax, 0xFFFFFF
	je      add_white
    movzx   eax, ch
	shl     eax, cl
	or 	    edi, eax
	mov	    ch, 1 		;reset white pixel counter
	dec     esi
	add	    cl, 4
	jmp	    bar

end:
	mov 	eax, edx
    mov     ecx, edi
	pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret

add_black:
	inc	    bh
	jmp	    bar

add_white:
	inc	    ch
	jmp	    space

error_stop:
	mov 	eax, -1
	pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret

;============================================================================
;description:
;	Loop until you find first black pixel
;arguments:
;	[ebp+8] - y coordinate
;   [ebp+12] - file address
;return value:
;	eax - x coordinate of the first black pixel

first_black:
	push    ebp
    mov     ebp, esp
    push    ebx
    push    esi
    push    edi
    mov     esi, [ebp+8] ;y-coordinate
    mov     edi, [ebp+12] ;file address
    mov     ebx, 0
    push    esi
    push    ebx
    push    edi

loop_first_black:
	call    get_pixel
	add		esp, 12
	cmp	    eax, 0x00000000
    je      return_position
	inc	    ebx
    push    esi
	push    ebx
    push    edi
	jmp	    loop_first_black

return_position:
	mov	    eax, ebx
    pop     edi
    pop     esi
    pop     ebx
	mov     esp, ebp
    pop     ebp
    ret

;============================================================================
;description:
;	returns color of specified pixel
;arguments:
;	[ebp+8] - image address
;	[ebp+12] - x coordinate
;	[ebp+16] - y coordinate - (0,0) - bottom left corner
;return value:
;	eax - 0RGB - pixel color

get_pixel:
    push    ebp
    mov     ebp, esp
    push    ebx
	push	esi
	mov		esi, edx

    mov     eax, [ebp+8]
    add     eax, 10
    mov     ebx, [eax]
    mov     eax, [ebp+8]
    add     ebx, eax

    imul    eax, [ebp+16], bytes_per_row
    mov     edx, [ebp+12]
    lea     edx, [edx + edx*2]
    add     eax, edx
    add     ebx, eax

    movzx   eax, byte [ebx]    ; Load blue component
    movzx   edx, byte [ebx + 1]; Load green component
    shl     edx, 8
    or      eax, edx             ; Combine blue and green components
    movzx   edx, byte [ebx + 2]; Load red component
    shl     edx, 16
    or      eax, edx

	mov		edx, esi
	pop		esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret