format mz
org 100h

str_inf db '254$'
mov al,4
mov dx,str_inf

; Входы:
; al-длина строки
; dx-адрес строки
; Выходы:
; ax-слово
; cf=1 - ошибка

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

