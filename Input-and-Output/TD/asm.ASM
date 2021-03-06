format mz
org 100h
str_inf db '-254$'
mov al,3
mov dx,str_inf

mov ah,4ch
int 21h




; �����:
; al-����� ������
; dx-����� ������
; ������:
; ax-�����
; cf=1 - ������

str_to_sword:
	push bx
	push dx

	test al,al  ; �������� ����� ������
	jz str_error ;  ���� 0, �� ������������ ������
	mov bx,dx ; bx = ����� ������
	mov bl,[bx] ; bl = ������ ������
	cmp bl,'-' ; ���������� ������ ������ � '-'
	jne str_no_sign ; ���� �� �����, �� ��������� �� ��������� ���������� ��� �����
	inc dx ;  addres++
	dec al ; lenght--

str_no_sign:
	call str_to_uword ; ����������� ������ � ����� ��� �����
	jc str_sexit
	cmp bl,'-' ; �������� ��������� ����
	jne str_splus ; ���� ������ ������ �� '-' => ����� �������������
	cmp ax,32768 ; ������ �������������� ����� ������ ���� �� ������ 32768
	ja str_serror ; ���� ������ ���������� ������
	neg ax ; ����������� �����
	jmp str_ok ; ����������� ���������

str_splus:
	cmp ax,32767 ;   �������� �� ��������
	ja str_serror ; ���� ������ �� ������������ ������

str_ok:
	clc ; CF=0
	jmp str_exit ; ������� �� ���������


str_serror:
	xor ax,ax
	stc ; cf=1


str_sexit:
	pop dx ; �������������� ���������
	pop bx
	ret


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
	jc str_error ; ���� ��������� ������ 2 ���� ������������ ������
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






