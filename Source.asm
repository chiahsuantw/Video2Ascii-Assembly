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
imageWidth DWORD ?
imageHeight DWORD ?
imageSize DWORD ?
buffer DWORD ?
; TODO: 動態配置，定義上限值
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

; 增加 4 Bytes 偏移量
INVOKE SetFilePointer,
    fileHandle,
    4,
    0,
    FILE_CURRENT

; 讀取資料偏移位元組數
mov eax, fileHandle
mov ecx, 1
mov edx, OFFSET dataOffset
call ReadFromFile

; 增加 7 Bytes 偏移量
INVOKE SetFilePointer,
    fileHandle,
    7, 
    0,
    FILE_CURRENT

; 讀取圖片寬度
mov eax, fileHandle
mov ecx, 4
mov edx, OFFSET imageWidth
call ReadFromFile

; 讀取圖片高度
mov eax, fileHandle
mov ecx, 4
mov edx, OFFSET imageHeight
call ReadFromFile

; 計算圖片像素數量
; imageSize = imageWidth * imageHeight
; TODO: 注意乘法範圍
mov eax, imageWidth
mov ebx, imageHeight
mul ebx
mov imageSize, eax

; 增加 {dataOffset} Bytes 偏移量
INVOKE SetFilePointer,
    fileHandle,
    dataOffset, 
    0,
    FILE_BEGIN

; 讀取色彩資料
; EDI 用來暫時儲存連續讀到的 3 個值的合
mov edi, 0
mov esi, 0
mov ecx, imageSize
lp_read_bytes:
    push ecx
    mov ecx, 3
    lp_read_rgb:
        push ecx
        ; 讀取 RGB 三色值
        mov eax, fileHandle
        mov ecx, 1
        mov edx, OFFSET buffer
        call ReadFromFile
        ; 加總三色值，待之後灰階化
        add edi, buffer
        pop ecx
    loop lp_read_rgb
    ; 進行灰階化並儲存到 byteArray
    mov edx, 0
    mov eax, edi
    mov ecx, 3
    div ecx
    mov [byteArray + esi], al
    inc esi
    pop ecx
loop lp_read_bytes

mov esi, OFFSET byteArray
mov ebx, TYPE byteArray
mov ecx, LENGTHOF byteArray
call DumpMem

; 關閉檔案
mov eax, fileHandle
call CloseFile

; -----------------------------------------------------------------------------

quit:
exit
main ENDP

END main