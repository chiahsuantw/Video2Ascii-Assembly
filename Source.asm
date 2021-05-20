INCLUDE Irvine32.inc

.data
consoleInfo	CONSOLE_SCREEN_BUFFER_INFO <>
consoleRowSize DWORD ?
consoleColumnSize DWORD ?

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
mov consoleRowSize, eax

movzx eax, consoleInfo.srWindow.Right
movzx ebx, consoleInfo.srWindow.Left
sub eax, ebx
mov consoleColumnSize, eax
; -----------------------------------------------------------------------------



exit
main ENDP

END main