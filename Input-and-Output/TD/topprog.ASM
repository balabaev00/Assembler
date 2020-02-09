format mz
org 100h

mov ax,03h ; Очистка экрана
int 10h
xor ax,ax

jmp start
	
;Процедура ввода строки c консоли
;  вход: AL - максимальная длина (с символом CR) (1-254)
; выход: AL - длина введённой строки (не считая символа CR)
;        DX - адрес строки, заканчивающейся символом CR(0Dh)
input_str:
    push cx		    ;Сохранение СX
    mov cx,ax		    ;Сохранение AX в CX
    mov ah,09h
    mov dx,str_inputs
    int 21h
    mov ah,0Ah		    ;Функция DOS 0Ah - ввод строки в буфер
    mov [buffer],al	    ;Запись максимальной длины в первый байт буфера
    mov byte[buffer+1],0    ;Обнуление второго байта (фактической длины)
    mov dx,buffer	    ;DX = aдрес буфера
    int 21h		    ;Обращение к функции DOS
    mov al,[buffer+1]	    ;AL = длина введённой строки
    add dx,2		    ;DX = адрес строки
    mov ah,ch		    ;Восстановление AH
    pop cx		    ;Восстановление CX
    ret

; Входы:
; al-длина строки
; dx-адрес строки
; Выходы:
; ax-слово
; cf=1 - ошибка

check:
	test al,al  ; Проверка длины строки
	jz str_error ;  Если 0, то возвращается ошибка
	mov bx,dx ; bx = адрес строки
	mov bl,[bx] ; bl = первый символ
	cmp bl,'-' ; Сравниваем первый символ с '-'
	jne str_to_uword ; Если не равно, то переходим на процедуру заполнения без знака
	inc dx ;  addres++
	dec al ; lenght--
	mov bp,1

str_to_uword:
	mov si,dx
	mov di,10 ; Сохраняем множитель
	movzx cx,al ; cx = счетчик цикла, то есть равен длине строки
	; movzx - копирование, где старшие разряды заполняются нулем
	jcxz str_error ; Если длина = 0, вовзращает ошибку
	xor ax,ax  ; ax=0
	xor bx,bx ; bx=0

str_lp:
	mov bl,[si] ; Помещаем в bl символ
	inc si
	cmp bl,'0' ; Если символ меньше '0' возвращается ошибка
	jl str_error
	cmp bl,'9'
	jg str_error ; Если символ больше '9' возвращается ошибка
	sub bl,'0' ; Преобразование символа цифры в число
	mul di ; ax=ax*10
	jc str_error ; Если результат больше 2 байт возвращается ошибка
	add ax,bx ; Прибавляем цифру
	jc str_error ; Если результат больше 2 байт возвращается ошибка
	loop str_lp ; Цикл
	jmp str_exit ; Завершение

str_error:
	xor ax,ax ; ax=0
	stc ; устанавливает флаг CF=1 и возвращает ошибку

str_exit:
	xor dx,dx
	mov dx,1
	cmp dx,bp
	je save_neg
	ret

save_neg:
	neg ax
	ret


;Входы :
;ax=a
;bx=b
;cx=c
;Выходы :
;ax=res
function_f:
	imul ax,2
	sub ax,bx
	sub ax,cx
	cmp cx,0
	jl function_true
	add cx,5
	mov dx,0
	cwd
	idiv cx
	ret

function_true:
	neg cx
	add cx,5
	mov dx,0
	cwd
	idiv cx
	ret

;Процедура преобразования str to word (без знака)
; ax - слово
; di - буфер для строки (5 символов)
word_to_udec_str:
    push ax
    push cx
    push dx
    push bx
    xor cx,cx		    ;Обнуление CX
    mov bx,10		    ;В BX делитель (10 для десятичной системы)
 
wtuds_lp1:		    ;Цикл получения остатков от деления
    xor dx,dx		    ;Обнуление старшей части двойного слова
    div bx		    ;Деление AX=(DX:AX)/BX, остаток в DX
    add dl,'0'		    ;Преобразование остатка в код символа
    push dx		    ;Сохранение в стеке
    inc cx		    ;Увеличение счетчика символов
    test ax,ax		    ;Проверка AX
    jnz wtuds_lp1	    ;Переход к началу цикла, если частное не 0.
 
wtuds_lp2:		    ;Цикл извлечения символов из стека
    pop dx		    ;Восстановление символа из стека
    mov [di],dl 	    ;Сохранение символа в буфере
    inc di		    ;Инкремент адреса буфера
    loop wtuds_lp2	    ;Команда цикла
 
    pop bx
    pop dx
    pop cx
    pop ax
    ret

;Процедура преобразования слова в строку в десятичном виде (со знаком)
; AX - слово
; DI - буфер для строки (6 символов). Значение регистра не сохраняется.
word_to_sdec_str:
    push ax
    test ax,ax		    ;Проверка знака AX
    jns wtsds_no_sign	    ;Если >= 0, преобразуем как беззнаковое
    mov byte[di],'-'	    ;Добавление знака в начало строки
    inc di		    ;Инкремент DI
    neg ax		    ;Изменение знака значения AX
wtsds_no_sign:
    call word_to_udec_str   ;Преобразование беззнакового значения
    pop ax
    ret

print_str:
	push ax
	mov ah,09h
	xchg dx,di
	int 21h
	xchg dx,di
	pop ax
	ret

print_word:
	push di
	mov di,buffer
	push di
	call word_to_udec_str
	mov byte[di],'$'
	pop di
	call print_str
	pop di
	ret

print_word_sign:
	push di
	mov di,buffer	; DI=адрес буфера
	push di 	 ; Пушим в стек адрес
	call word_to_sdec_str	 ; Преобразование ax to str
	mov byte[di],'$'      ; Добавление символа конца строки
	pop di		    ; DI = адрес начала строки
	call print_str	     ; Вывод на консоль
	pop di
	ret



start:
	mov al,5
	mov dx,0
	call input_str
	call check
	mov [s],ax
	mov ax,03h ; Очистка экрана
	int 10h
	mov al,5
	mov dx,0
	call input_str
	call check
	mov [t],ax
	mov ax,03h ; Очистка экрана
	int 10h
	mov ax,[t]
	mov bx,[s]
	imul bx,-2
	mov cx,1
	call function_f
	mov [res],ax
	mov ax,2
	mov bx,[t]
	mov cx,[s]
	mov bp,[t]
	sub cx,bp
	call function_f
	mov bx,ax
	mov ax,[res]
	add ax,bx
	mov [res],ax

	mov ah,09h
	mov dx,str_output_res
	int 21h
	mov ax,[res]
	call print_word_sign




endline_program:
	mov ah,01h
	int 21h
	mov ah,4ch
	int 21h

t dw ?
s dw ?
res dw ?
str_inputs db 'Input : $'
str_output_res db 'Output res : $'
buffer	 rb 256