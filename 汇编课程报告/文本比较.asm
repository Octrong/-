.386
.model flat,stdcall
option casemap:none
includelib		msvcrt.lib
include  windows.inc
include  gdi32.inc
includelib gdi32.lib
include  user32.inc
includelib user32.lib
include  kernel32.inc
includelib kernel32.lib
printf	PROTO C :ptr sbyte,:VARARG

.const
    szMsg                   db      'Hi'
    szTitle                 db      '   �ȽϽ��',0
    bufferLen               equ     1000
    same                    db      '   ��ͬ',0
    diff                    db      '��ͬ',0
    cmpbutton               dw      1
    txt1                    dw      2
    txt2                    dw      3
    lbl1                    dw      4
    lbl2                    dw      5

    szline                  db      '�� %d �г��ֲ�ͬ ',0
    szClassName             db      'FileCMP',0
    szCaptionMain           db      '�ļ��Ƚ�',0
    szButton                db      'Button',0
    szButtonText            db      '�Ƚ�',0
    szEdit                  db      'Edit',0
    szStatic                db      'Static',0
    
    szDefaultInputFile      db      'D:\3.txt',0
    szDefaultOutputFile     db      'D:\4.txt',0
    szLabel1                db      '�ļ�1',0
    szLabel2                db      '�ļ�2',0    
      
.data
    readcontext                     dd          ?
    szInputFile                     db          20 dup(?)
    szOutputFile                    db          20 dup(?)
    hInstance                       dd          ?
    hWinMain                        dd          ?
    hCmd                            dd          ?
    hTxt1                           dd          ?
    hTxt2                           dd          ?
    old_proc1                       dd          ?
    pSrcHead                        dd          ?
    hFile                           dd          ?
    strline                         db          100 dup(?)
    line                            db          0
    buf1                            db          bufferLen dup(?)
    buf2                            db          bufferLen dup(?) 
    file1Read                       dd          ?
    file2Read                       dd          ?


.code
cmpClick proc uses ebx edi esi,hWnd,uMsg,wParam,lParam
mov eax,uMsg
    .if eax == WM_LBUTTONUP
        invoke GetWindowText,hTxt1,addr szInputFile,50  ;���ı����ȡ�ļ���ַ
        invoke CreateFile, addr szInputFile, GENERIC_READ, NULL, NULL, OPEN_EXISTING, NULL, NULL
        mov hFile, eax
        invoke ReadFile, hFile, addr buf1, bufferLen, addr file1Read, NULL
        invoke CloseHandle,hFile

        invoke GetWindowText,hTxt2,addr szOutputFile,50 ;���ı����ȡ�ļ���ַ
        invoke CreateFile, addr szOutputFile, GENERIC_READ, NULL, NULL, OPEN_EXISTING, NULL, NULL
        mov hFile, eax
        invoke ReadFile, hFile, addr buf2, bufferLen, addr file2Read, NULL
        invoke CloseHandle,hFile

        mov ecx,file1Read
        xor esi,esi
    L1:
        cmp esi,file2Read;���ڵ���
        jnl Ldiff
        mov al,buf1[esi]
        cmp al,buf2[esi]
        jnz Ldiff
        cmp buf1[esi], 13
        jnz L11
        cmp esi,file1Read-1;�����Ⱦͽ���ѭ��
        jz L11
        cmp buf1[esi+1],10
        jnz L11
        inc line
    L11:
        inc esi
        loop L1
        jmp Lsame

    Ldiff:  
        inc line
        invoke wsprintf,addr strline, addr szline,line
        invoke MessageBox,hWinMain,  offset strline , offset szTitle,MB_OK
        jmp Lend
    Lsame:
        mov ecx,file2Read
        cmp ecx,file1Read
        jnz Ldiff
        invoke MessageBox,hWinMain, offset same , offset szTitle,MB_OK

Lend:   
    .endif  
invoke CallWindowProc, old_proc1, hWnd, uMsg, wParam, lParam
ret


cmpClick endp

; ����
_ProcWinMain proc uses ebx edi esi,hWnd,uMsg,wParam,lParam
    local @stPs:PAINTSTRUCT
    local @stRect:RECT
    local @hDc
    
    mov eax,uMsg
    .if     eax == WM_PAINT
     invoke BeginPaint,hWnd,addr @stPs
     invoke EndPaint,hWnd,addr @stPs

    .elseif eax == WM_CREATE

    .elseif eax == WM_CLOSE
     invoke DestroyWindow,hWinMain
     invoke PostQuitMessage,NULL
    
    .else
     invoke DefWindowProc,hWnd,uMsg,wParam,lParam
     ret
    .endif

    xor eax,eax
    ret
_ProcWinMain endp

;��������
_WinMain proc
    ; ��ȡ����ֲ�
    local @stWndClass:WNDCLASSEX
    local @stMsg:MSG
    invoke GetModuleHandle,NULL
    mov hInstance,eax
    invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass

    ; ע�ᴰ����
    invoke LoadCursor,0,IDC_ARROW
    mov @stWndClass.hCursor,eax                     ;���ڹ��
    push hInstance                                  
    pop @stWndClass.hInstance                       ;������ʵ�����
    mov @stWndClass.cbSize,sizeof WNDCLASSEX        ;�ṹ���ֽ���
    mov @stWndClass.style,CS_HREDRAW or CS_VREDRAW  ;����
    mov @stWndClass.lpfnWndProc,offset _ProcWinMain ;���ڹ��̵�ַ
    mov @stWndClass.hbrBackground,COLOR_BTNFACE + 1 ;����ɫ;COLOR_WINDOW
    mov @stWndClass.lpszClassName,offset szClassName;�����ַ����ĵ�ַ
    invoke RegisterClassEx,addr @stWndClass
    
    ; ��������ʾ����
    invoke CreateWindowEx,NULL,                     ;dwExStyle ���
            offset szClassName,offset szCaptionMain,;���������ͱ���
            WS_OVERLAPPEDWINDOW,                    ;���ڵ���������dwStyle��dwExStyle�����˴��ڵ����κ���Ϊ
            400,200,600,400,                        ;ˮƽ����ֱ���ߣ���
            NULL,NULL,hInstance,NULL    ;hWndParent�����������ĸ�����
                                        ;hMenu��������Ҫ���ֵĲ˵��ľ��
                                        ;hInstance��ģ��������ע�ᴰ����ʱһ����ָ���˴��������ĳ���ģ��
                                        ;lpParam��ָ�룬ָ��һ�����������ڵĲ������ò�������WM_CREATE��Ϣ�б���ȡ
    mov hWinMain,eax
    invoke ShowWindow,hWinMain,SW_SHOWNORMAL
    invoke UpdateWindow,hWinMain
        ;�������ť
    invoke CreateWindowEx, NULL, offset szButton, offset szButtonText, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, \
         250, 250, 70, 30, hWinMain, addr cmpbutton, hInstance, NULL
    mov hCmd, eax

    ;�������ť�Ļص�����
    invoke SetWindowLong, hCmd, GWL_WNDPROC, cmpClick
    mov old_proc1, eax

    ;�����ı���
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset szEdit, offset szDefaultInputFile, WS_CHILD or WS_VISIBLE or ES_LEFT, \
        150, 80, 280, 25, hWinMain, offset txt1, hInstance, NULL
    mov hTxt1, eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset szEdit, offset szDefaultOutputFile, WS_CHILD or WS_VISIBLE or ES_LEFT, \
        150, 140, 280, 25, hWinMain, offset txt2, hInstance, NULL
    mov hTxt2, eax
    ;������ǩ
    invoke CreateWindowEx,NULL, offset szStatic, offset szLabel1, WS_CHILD or SS_CENTER or WS_VISIBLE, \
        50,85,80,25,hWinMain,offset lbl1,hInstance,NULL
    invoke CreateWindowEx,NULL, offset szStatic, offset szLabel2, WS_CHILD or SS_CENTER or WS_VISIBLE, \
        50,145,80,25,hWinMain,offset lbl2,hInstance,NULL
    
    ; ��Ϣѭ��
    .while TRUE
      invoke GetMessage,addr @stMsg,NULL,0,0
      .break .if eax == 0
      invoke TranslateMessage,addr @stMsg
      invoke DispatchMessage,addr @stMsg
    .endw
    ret
_WinMain endp


start:
    call _WinMain
    invoke ExitProcess,NULL
end start
