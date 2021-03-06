format mz
org 100h

str_inf db '254$'
mov al,4
mov dx,str_inf

; �����:
; al-����� ������
; dx-����� ������
; ������:
; ax-�����
; cf=1 - ������

str_to_uword:
        ; ���������� ���� ������������ ���������
        push cx
        push dx
        push bx
        push si
        push di

        mov si,dx
        mov di,10 ; ��������� ���������
        movzx cx,al ; cx = ������� �����, �� ���� ����� ����� ������
        ; movzx - �����������, ��� ������� ������� ����������� �����
        jcxz str_error ; ���� ����� = 0, ���������� ������
        xor ax,ax  ; ax=0
        xor bx,bx ; bx=0

str_lp:
        mov bl,[si] ; �������� � bl ������
        inc si
        cmp bl,'0' ; ���� ������ ������ '0' ������������ ������
        jl str_error
        cmp bl,'9'
        jg str_error ; ���� ������ ������ '9' ������������ ������
        sub bl,'0' ; �������������� ������� ����� � �����
        mul di ; ax=ax*10
        jc str_error ; ���� ��������� ������ 2 ���� ������������ ������
        add ax,bx ; ���������� �����
        loop str_lp ; ����
        jmp str_exit ; ����������

str_error:
        xor ax,ax ; ax=0
        stc ; ������������� ���� CF=1 � ���������� ������

str_exit:
        pop di
        pop si
        pop bx
        pop dx
        pop cx
        ret

