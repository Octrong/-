.386
.model flat,stdcall
option casemap:none
includelib		msvcrt.lib
printf	PROTO C :ptr sbyte,:VARARG
.data
sFirst		db "第一层开始", 0ah, 0
sSecond		db "  第二层开始", 0ah, 0
sThird		db "    第三层开始", 0ah, 0
sFourth		db "      第四层", 0ah, 0
eFirst		db "第一层结束", 0ah, 0
eSecond		db "  第二层结束", 0ah, 0
eThird		db "    第三层结束", 0ah, 0
eFourth		db "      第四层", 0ah, 0
a			dd 0
i			dd 0
j			dd 0
k			dd 0
w			dd 0
num			dd 0
.code
start:
	mov num,1
	mov i,0
L1:	mov eax,num
	cmp i,eax
	jg Lend
	invoke printf, offset sFirst

	; 第二层
	mov k, 0
L2:	mov eax, i
	cmp k, eax
	jg L10
	invoke printf, offset sSecond

	; 第三层
	mov j, 0
L3:	mov eax, k
	cmp j, eax
	jg L20
	invoke printf, offset sThird

	; 第四层
	mov w, 0
L4:	mov eax, j
	cmp w, eax
	jg L30
	inc a
	invoke printf, offset sFourth
	inc w
	jmp L4

L30 :
	invoke printf, offset eThird
	inc j
	jmp L3
L20 :
	invoke printf, offset eSecond
	inc k
	jmp L2

L10 :	
	invoke printf, offset eFirst
	inc i
	jmp L1
Lend:
	
	ret
end start



