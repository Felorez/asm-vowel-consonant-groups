; Написать программу на языке Ассемблера, которая позволяет ввести с клавиатуры
; две строки букв. Вывести на экран последовательность строк,
; полученных путем присоединения к гласной букве (подряд идущим гласным буквам)
; первой строки поочередно согласной буквы (подряд идущие согласные буквы)
; второй строки. При этом символы первой строки вывести одним цветом,
; а символы второй строки – другим. Цвета выбираются самостоятельно.

d_s	segment
eol equ 0dh
col1	db 27,"[1;34m$"
col0	db 27,"[0m$"
count_word db 0
count_glas db 0
count_soglas db 0
result db "Result: $"
result_letters db "All word: $"
result_glas db "Number of vowels: $"
result_soglas db "Number of consonants: $"
error_wrong_format db "The string does not consist of letters $"
otst db '', 0Dh, 0Ah, '$'

line1par label byte
maxlen1 db 100
actlen1 db ?
line1 db 100 dup("$")

line2par label byte
maxlen2 db 100
actlen2 db ?
line2 db 100 dup("$")

p1	dw 0
d_s	ends

c_s	segment
assume cs:c_s, ds:d_s

setcol1:push ax
	push dx
	mov dx,offset col1
	mov ah,9
	int 21h
	pop dx
	pop ax
	ret

setcol0:push ax
	push dx
	mov dx,offset col0
	mov ah,9
	int 21h
	pop dx
	pop ax
	ret

; это гласная буква ?
glas:	cmp al,"a"
	jc retno
	cmp al,"z"+1
	jnc retno
	cmp al,"a"
	jz retyes
	cmp al,"e"
	jz retyes
	cmp al,"i"
	jz retyes
	cmp al,"o"
	jz retyes
	cmp al,"u"
	jz retyes
	jmp retno
retyes: clc
	ret
retno:	stc
	ret

; это согласная буква ?
soglas: cmp al,"a"
	jc retno
	cmp al,"z"+1
	jnc retno
	call glas
	cmc
	ret

; основная программа
start:	
    mov ax,d_s
	mov ds,ax
	mov es,ax
    xor cx, cx

    lea dx, line1par
    mov ah, 0Ah
    int 21h

    mov al, actlen1

    lea di, line1
    add di, ax

    mov byte ptr [di], '$'

    inc actlen1

    lea dx, otst
    mov ah, 09h
    int 21h

    lea dx, line2par
    mov ah, 0Ah
    int 21h

    lea dx, otst
    mov ah, 09h
    int 21h

    lea dx, result
    mov ah, 09h
    int 21h

	mov si,offset line1
	mov di,offset line2
m0: 
	cmp byte ptr [si],eol ; начало цикла. конец строки ?
	jz exdos
	call propusk_soglas   ; пропустить согласные в 1ой строке
	cmp byte ptr [si],eol
	jz exdos
	call print_glas       ; напечатать гласные в 1ой строке
        cmp byte ptr [si],eol
	jz exdos
	call setcol1          ; цвет 1
	call dob_soglas2      ; добавить согласные из 2ой строки
	call setcol0          ; цвет 0
	jmp m0		      ; конец цикла
exdos:
      lea dx, otst
      mov ah, 09h
      int 21h

      lea dx, result_letters
      int 21h
      
      mov al, count_glas
      add al, count_soglas
      call convertnumtostr

      lea dx, otst
      mov ah, 09h
      int 21h

      lea dx, result_glas
      int 21h
      
      mov al, count_glas
      call convertnumtostr

      lea dx, otst
      mov ah, 09h
      int 21h

      lea dx, result_soglas
      int 21h
      
      mov al, count_soglas
      call convertnumtostr

      int 20h

propusk_soglas:
	mov al,[si]
	cmp al,eol
	jz ret1
	call soglas
	inc si
	jnc propusk_soglas
	dec si
ret1:	ret

print_glas:
	mov al,[si]
	cmp al,eol
	jz ret2
	call glas
	inc si
	jc ret2a
    mov bl, count_glas
    inc bl
    mov count_glas, bl
	call putchar
	jmp print_glas
ret2a:	dec si
ret2:	ret

; добавление согласных из 2ой строки
dob_soglas2:mov p1,si  ; сохраняем si
	mov si,di
m1:	cmp byte ptr [si],eol
	jz retsub
	call propusk_glas ; пропускаем гласные во 2ой строке
	cmp byte ptr [si],eol
	jz retsub
	call print_soglas ; печатаем согласные из 2ой строки
        cmp byte ptr [si],eol
	jz retsub
;;;	jmp m1 !!! здесь была ошибка - цикла быть не должно
retsub: mov di,si   ; di=указатель во второй строке
	mov si,p1   ; si=указатель в первой строке
	ret

propusk_glas:
	mov al,[si]
	cmp al,eol
	jz ret3
	call glas
	inc si
	jnc propusk_glas
	dec si
ret3:	ret

print_soglas:
	mov al,[si]
	cmp al,eol
	jz ret4
	call soglas
	inc si
	jc ret4a
    mov bl, count_soglas
    inc bl
    mov count_soglas, bl
	call putchar
	jmp print_soglas
ret4a:	dec si
ret4:	ret

; вывод символа на печать
putchar:push ax
	push dx
	mov dl,al
	mov ah,2
	int 21h
	pop dx
	pop ax
	ret

convertnumtostr:
    mov ah, 0
    mov bx, 10
    mov cx, 0

convert_to_string:xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz convert_to_string

print_digits:pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_digits

    ret

c_s	ends
	end start

