.386
.model flat,stdcall
option casemap:none
includelib		msvcrt.lib
printf	PROTO C :ptr sbyte,:VARARG
.data
	A		DB		"5837857535874708464144660589738524617485667413156960060103966841824524183326315382114787359668488502",0		;����a
	alen	DD		$-A-1				;����a����
	AS		DB		100 DUP(0)			;ת��λ����
	B		DB		"7332275419654765337001340479291812746271866311885185364864878571675280328640823623559171293883555056",0		;����b����;
	blen	DD		$-B-1				;����b����
	BS		DB		100 DUP(0)
	ANS		DB		20000 DUP(0)
	answs	DD		0					;���λ��
	anszj	DD		0					;ÿλ��������ۼ�����
	zj		DB		20000 DUP(0)		;�м���
	ws		DD		0					;�м���λ��
	cz		DD		0					;ÿ�γ�Ҫǰ���ĳ�ֵ
	jw		DB		0					;��λ
	ys		DB		0					;����
	s		DB		0
	dwdw	DW		0					;x * x
	dddd	DD		0
	dbdb	DB		0
	count	DD		0
	pNum1	DB		"[����1]��",0
	pNum2	DB		"[����2]��",0
	pAns	DB		"[���]��",0
	nextline DB		" ",0ah,0
	p		DB		"%d",0
.code
start:
	mov ecx,alen
	mov eax, 0
L1:;������1���ַ�תΪ����
	mov bl,A[eax]
	sub bl,'0'
	mov AS[ecx-1],bl
	inc eax
	loop L1

	mov ecx,blen
	mov eax, 0
L2:;������2���ַ�תΪ����
	mov bl,B[eax]
	sub bl,'0'
	mov BS[ecx-1],bl
	inc eax
	loop L2

L3:;edx  ����1��ÿһλ,ע��һ�����Ϊ0������L4
	mov edx,0   
L0:	
	mov ws,0  ;�ճ�ÿ�γ˿�ͷ��λ��
	cmp edx,0
	jz L5
	mov ecx, edx; ѭ��edx(i)��,�ճ�edx(i)��
	mov ebx,0
	
L4:
	mov zj[ebx],0
	inc ebx
	inc ws
	loop L4

L5:;���е�λ�˷�
	mov jw, 0
	mov ecx, blen
	mov ebx,0		;����2��ÿһλ
L51:
	mov ah,0
	mov  al, AS[edx]
	mul BS[ebx]
	add al, jw
	inc ws
	mov dbdb,10
	DIV dbdb
	mov jw, AL
	mov esi,ws
	mov zj[esi-1], ah
	inc count
	inc ebx
	loop L51

	;�������Ľ�λ
	cmp jw,0
	jz L6
	mov esi,ws
	mov al,jw
	mov zj[esi],al
	inc ws
	

	;����ۼ�
L6:
	mov ecx, ws
	mov esi, 0
	mov jw, 0

L61:
	mov al, ANS[esi]
	add al, zj[esi]
	add al, jw
	mov ah, 0
	mov dbdb,10
	DIV  dbdb
	mov jw, AL
	mov ANS[esi], ah
	inc esi
	loop L61
	
	mov eax, ws
	cmp eax,answs
	jg L7
	jmp L8
L7:
	mov answs, eax
L8:
	cmp jw,0
	jg L9
	jmp L10
L9:;�������λ
	inc answs
	mov esi,answs
	mov al,jw
	mov ANS[esi-1],al
L10:
	inc edx
	cmp edx,alen
	jnz L0
;��ӡ����
	invoke printf ,offset pNum1
	invoke printf ,offset A
	invoke printf,offset nextline
	invoke printf ,offset pNum1
	invoke printf ,offset B
	invoke printf,offset nextline
	invoke printf ,offset pAns
L100:
	mov ecx, answs
L101:
	push ecx
	invoke printf, offset p,ANS[ecx-1]
	pop ecx
	loop L101

	invoke printf,offset nextline
	ret

end start
