format mz
org 100h
str_inf db '-254$'
mov al,3
mov dx,str_inf

mov ah,4ch
int 21h




; Входы:
; al-длина строки
; dx-адрес строки
; Выходы:
; ax-слово
; cf=1 - ошибка

str_to_sword:
	push bx
	push dx

	test al,al  ; Проверка длины строки
	jz str_error ;  Если 0, то возвращается ошибка
	mov bx,dx ; bx = адрес строки
	mov bl,[bx] ; bl = первый символ
	cmp bl,'-' ; Сравниваем первый символ с '-'
	jne str_no_sign ; Если не равно, то переходим на процедуру заполнения без знака
	inc dx ;  addres++
	dec al ; lenght--

str_no_sign:
	call str_to_uword ; Преобразует строку в слово без знака
	jc str_sexit
	cmp bl,'-' ; Повторно проверяем знак
	jne str_splus ; Если первый символ не '-' => число положительное
	cmp ax,32768 ; Модуль отрицательного числа должен быть не больше 32768
	ja str_serror ; Если больше вызывается ошибка
	neg ax ; Инвертируем число
	jmp str_ok ; Заканчиваем процедуру

str_splus:
	cmp ax,32767 ;   Проверка на диапозон
	ja str_serror ; Есле больше то возвращается ошибка

str_ok:
	clc ; CF=0
	jmp str_exit ; Выходим из процедуры


str_serror:
	xor ax,ax
	stc ; cf=1


str_sexit:
	pop dx ; Восстановление регистров
	pop bx
	ret


str_to_uword:
	; Сохранение всех используемых регистров
	push cx
	push dx
	push bx
	push si
	push di
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
	pop di
	pop si
	pop bx
	pop dx
	pop cx
	ret






