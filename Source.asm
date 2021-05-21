INCLUDE Irvine32.inc

.data
; 讀取 Console 資訊相關變數
consoleInfo	CONSOLE_SCREEN_BUFFER_INFO <>
consoleRowSize DWORD ?
consoleColumnSize DWORD ?

; 開檔相關變數
imagePath BYTE "frames/image.bmp", 0
fileHandle HANDLE ?
fileType BYTE 2 DUP(?), 0
fileSize DWORD ?
dataOffset WORD ?
byteArray BYTE 10000 DUP(?), 0

; 字串常數
fileError BYTE "ERROR: Failed to open the image!", 10, 0

.code
main PROC

; -----------------------------------------------------------------------------
; 取得 Console 顯示視窗長寬
; 呼叫 GetConsoleScreenBufferInfo() 取得 consoleInfo
; consoleRowSize = consoleInfo.srWindow.Bottom - consoleInfo.srWindow.Top
; consoleColumnSize = consoleInfo.srWindow.Right - consoleInfo.srWindow.Left
; 實際大小應該還要再 +1 (可依狀況調整)

INVOKE GetStdHandle, STD_OUTPUT_HANDLE
; EAX 已存入從上面指令取得之 StdHandle
INVOKE GetConsoleScreenBufferInfo, eax, ADDR consoleInfo

movzx eax, consoleInfo.srWindow.Bottom
movzx ebx, consoleInfo.srWindow.Top
sub eax, ebx
inc eax
mov consoleRowSize, eax

movzx eax, consoleInfo.srWindow.Right
movzx ebx, consoleInfo.srWindow.Left
sub eax, ebx
mov consoleColumnSize, eax

; 測試輸出
; mov dl, 42
; mov esi, 0
; mov ecx, consoleRowSize
; L1 :
; 	push ecx
; 	mov ecx, consoleColumnSize
; 	L2 :
; 		mov byteArray[esi], dl
; 		inc esi
; 	loop L2
; 	mov byteArray[esi], 10
; 	pop ecx
; 	inc esi
; loop L1

; mov edx, OFFSET byteArray
; call WriteString
; call Crlf

; push esi
; push ecx
; mov esi, OFFSET byteArray
; mov ebx, TYPE byteArray
; mov ecx, LENGTHOF byteArray
; call DumpMem
; pop ecx
; pop esi

; -----------------------------------------------------------------------------
; 讀取 BMP 檔案
; 使用 Irvine32 Library 函式呼叫

mov edx, OFFSET imagePath
; 開啟檔案: (參數) EDX = 圖片位置 (回傳) EAX = FileHandle
call OpenInputFile
; 若無法成功開啟檔案，擲回 INVALID_HANDLE_VALUE 到 EAX
cmp eax, INVALID_HANDLE_VALUE
; 當條件不相等時跳轉 (jump-if-not-equal)
jne file_ok

; 顯示錯誤警告
file_error:
    mov edx, OFFSET fileError
    call WriteString
    jmp quit

; 成功開啟檔案
file_ok:
    mov fileHandle, eax

; 讀取資料: (參數) EAX = FileHandle
;                ECX = 讀取位元組數量
;                EDX = 緩衝區
;         (回傳) EAX = 讀取位元組數量，錯誤則擲回錯誤代碼

; 讀取檔案格式 
mov eax, fileHandle
mov ecx, 2
mov edx, OFFSET fileType
call ReadFromFile

; 讀取檔案大小
mov eax, fileHandle
mov ecx, 4
mov edx, OFFSET fileSize
call ReadFromFile

; 增加 4 Byte 偏移量
INVOKE SetFilePointer,
    fileHandle,
    4,
    0,
    FILE_CURRENT

; 讀取資料位元組偏移量
mov eax, fileHandle
mov ecx, 1
mov edx, OFFSET dataOffset
call ReadFromFile

; 關閉檔案
mov eax, fileHandle
call CloseFile

; -----------------------------------------------------------------------------

quit:
exit
main ENDP

END main