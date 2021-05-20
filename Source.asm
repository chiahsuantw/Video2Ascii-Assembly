INCLUDE Irvine32.inc

.data
consoleInfo	CONSOLE_SCREEN_BUFFER_INFO <>
consoleRowSize DWORD ?
consoleColumnSize DWORD ?

output BYTE 10000 DUP(?), 0

.code
main PROC

; -----------------------------------------------------------------------------
; 取得 Console 顯示視窗長寬
; 呼叫 GetConsoleScreenBufferInfo() 取得 consoleInfo
; consoleRowSize = consoleInfo.srWindow.Bottom - consoleInfo.srWindow.Top
; consoleColumnSize = consoleInfo.srWindow.Right - consoleInfo.srWindow.Left

invoke GetStdHandle, STD_OUTPUT_HANDLE
invoke GetConsoleScreenBufferInfo, eax, addr consoleInfo

movzx eax, consoleInfo.srWindow.Bottom
movzx ebx, consoleInfo.srWindow.Top
sub eax, ebx
inc eax
mov consoleRowSize, eax

movzx eax, consoleInfo.srWindow.Right
movzx ebx, consoleInfo.srWindow.Left
sub eax, ebx
mov consoleColumnSize, eax

; Test Output
mov dl, 42
mov esi, 0
mov ecx, consoleRowSize
L1 :
	push ecx
	mov ecx, consoleColumnSize
	L2 :
		mov output[esi], dl
		inc esi
	loop L2
	mov output[esi], 10
	pop ecx
	inc esi
loop L1

mov edx, OFFSET output
call WriteString
call Crlf

;push esi
;push ecx
;mov esi, OFFSET output
;mov ebx, TYPE output
;mov ecx, LENGTHOF output
;call DumpMem
;pop ecx
;pop esi

; -----------------------------------------------------------------------------


exit
main ENDP

END main