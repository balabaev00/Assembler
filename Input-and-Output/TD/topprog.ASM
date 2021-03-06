format mz
org 100h

mov ax,03h ; ������� ������
int 10h
xor ax,ax

jmp start
	
;��������� ����� ������ c �������
;  ����: AL - ������������ ����� (� �������� CR) (1-254)
; �����: AL - ����� �������� ������ (�� ������ ������� CR)
;        DX - ����� ������, ��������������� �������� CR(0Dh)
input_str:
    push cx		    ;���������� �X
    mov cx,ax		    ;���������� AX � CX
    mov ah,09h
    mov dx,str_inputs
    int 21h
    mov ah,0Ah		    ;������� DOS 0Ah - ���� ������ � �����
    mov [buffer],al	    ;������ ������������ ����� � ������ ���� ������
    mov byte[buffer+1],0    ;��������� ������� ����� (����������� �����)
    mov dx,buffer	    ;DX = a���� ������
    int 21h		    ;��������� � ������� DOS
    mov al,[buffer+1]	    ;AL = ����� �������� ������
    add dx,2		    ;DX = ����� ������
    mov ah,ch		    ;�������������� AH
    pop cx		    ;�������������� CX
    ret

; �����:
; al-����� ������
; dx-����� ������
; ������:
; ax-�����
; cf=1 - ������

check:
	test al,al  ; �������� ����� ������
	jz str_error ;  ���� 0, �� ������������ ������
	mov bx,dx ; bx = ����� ������
	mov bl,[bx] ; bl = ������ ������
	cmp bl,'-' ; ���������� ������ ������ � '-'
	jne str_to_uword ; ���� �� �����, �� ��������� �� ��������� ���������� ��� �����
	inc dx ;  addres++
	dec al ; lenght--
	mov bp,1

str_to_uword:
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
	xor dx,dx
	mov dx,1
	cmp dx,bp
	je save_neg
	ret

save_neg:
	neg ax
	ret


;����� :
;ax=a
;bx=b
;cx=c
;������ :
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

;��������� �������������� str to word (��� �����)
; ax - �����
; di - ����� ��� ������ (5 ��������)
word_to_udec_str:
    push ax
    push cx
    push dx
    push bx
    xor cx,cx		    ;��������� CX
    mov bx,10		    ;� BX �������� (10 ��� ���������� �������)
 
wtuds_lp1:		    ;���� ��������� �������� �� �������
    xor dx,dx		    ;��������� ������� ����� �������� �����
    div bx		    ;������� AX=(DX:AX)/BX, ������� � DX
    add dl,'0'		    ;�������������� ������� � ��� �������
    push dx		    ;���������� � �����
    inc cx		    ;���������� �������� ��������
    test ax,ax		    ;�������� AX
    jnz wtuds_lp1	    ;������� � ������ �����, ���� ������� �� 0.
 
wtuds_lp2:		    ;���� ���������� �������� �� �����
    pop dx		    ;�������������� ������� �� �����
    mov [di],dl 	    ;���������� ������� � ������
    inc di		    ;��������� ������ ������
    loop wtuds_lp2	    ;������� �����
 
    pop bx
    pop dx
    pop cx
    pop ax
    ret

;��������� �������������� ����� � ������ � ���������� ���� (�� ������)
; AX - �����
; DI - ����� ��� ������ (6 ��������). �������� �������� �� �����������.
word_to_sdec_str:
    push ax
    test ax,ax		    ;�������� ����� AX
    jns wtsds_no_sign	    ;���� >= 0, ����������� ��� �����������
    mov byte[di],'-'	    ;���������� ����� � ������ ������
    inc di		    ;��������� DI
    neg ax		    ;��������� ����� �������� AX
wtsds_no_sign:
    call word_to_udec_str   ;�������������� ������������ ��������
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
	mov di,buffer	; DI=����� ������
	push di 	 ; ����� � ���� �����
	call word_to_sdec_str	 ; �������������� ax to str
	mov byte[di],'$'      ; ���������� ������� ����� ������
	pop di		    ; DI = ����� ������ ������
	call print_str	     ; ����� �� �������
	pop di
	ret



start:
	mov al,5
	mov dx,0
	call input_str
	call check
	mov [s],ax
	mov ax,03h ; ������� ������
	int 10h
	mov al,5
	mov dx,0
	call input_str
	call check
	mov [t],ax
	mov ax,03h ; ������� ������
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