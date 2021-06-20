; =============================================================================
; 雙線性插值法 (使用於Source.asm)
;
; Author: 謝卓均
;
; Info:
; srcX = dstX * (srcWidth/dstWidth)
; srcY = dstY * (srcHeight/dstHeight)
; 為小數時為取鄰近四點權重之
; **(x,y)=(1-u)*(1-v)*(x1,y1)+(1-u)*v*(x2,y2)+u*(1-v)*(x3,y3)+u*v*(x4,y4)
; =============================================================================

; 設定縮放尺寸
mov rez, 2

mov ebx, rez
mov eax, imageWidth
mul ebx
mov newImageWidth, eax

mov eax, imageHeight
mul ebx
mov newImageHeight, eax

mov ebx, newImageWidth
mul ebx
mov newImageSize, eax

; Index(ESI) 為 newImageSize + newImageHeight (換行) - 1
mov eax, newImageSize
add eax, newImageHeight
dec eax
mov esi, eax
mov ecx, newImageSize
mov newline, 0
lp_resize:
    ; 插入換行位置公式: (newImageSize + newImageHeight - 1 - ESI) % (newImageWidth + 1) == 0
    push ecx
    mov edx, 0
    mov eax, newImageSize
    add eax, newImageHeight
    dec eax
    sub eax, esi
    mov ecx, newImageWidth
    inc ecx
    div ecx
    cmp dx, 0
    jne new_continue_read
    new_add_newline:
        mov[newByteArray + esi], 10
        dec esi
        inc newline
    new_continue_read:

    ; 取得對應 d1(tempX,tempY)=(esi-newImageHeight+newline)/(rez^2) + (imageHeight-newline)
    mov eax, esi
    sub eax, newImageHeight
    add eax, newline
    mov ecx, rez
    mov edx, 0
    div ecx
    mov edx, 0
    div ecx
    movzx eax, ax
    add eax, imageHeight
    sub eax, newline
    mov d1, eax
    
    ; 取得對應比例=>(新座標-d1原座標*rez) [(/rez)]之後做
    ; (座標:/(width+1) = y,%(width+1)+1 = x)
    mov ecx, rez
    mov eax, d1

    mov ebx, imageWidth
    inc ebx
    mov edx, 0
    div ebx
    movzx eax, ax
    push edx
    mul ecx
    mov tempY, eax
    pop edx
    mov eax,edx
    mul ecx
    mov tempX, eax

    mov eax, esi
    mov ebx, newImageWidth
    inc ebx
    mov edx, 0
    div ebx
    movzx eax, ax
    sub eax, tempY
    mov v, eax
    sub edx, tempX
    mov u, edx

    ; 假設d4(tempX+1,tempY+1)處理越界
    ; y + 1
    add eax,imageWidth
    inc eax

    ; 防越界 => 高 => 超過總Index
    mov ebx, imageSize
    add ebx, imageHeight
    dec ebx
    ; 全體向上
    .if eax > ebx
        mov ecx, d1
        sub ecx, imageWidth
        dec ecx
        mov d1, ecx
        mov eax, d1
    .endif

    ; x + 1
    dec eax
    ; 防越界 => 寬 => 陣列值 = 換行
    ; 全體向左
    mov dl, [bytearray + eax]
    .if [byteArray + eax] == 10
        mov ecx, d1
        inc ecx
        mov d1, ecx
    .endif
    ; 產生 d2, d3, d4
    mov eax, d1

    ; d3 => x + 1
    dec eax
    mov d3, eax

    ; d4 => x + 1 y + 1
    add eax, imageWidth
    inc eax
    mov d4, eax

    ; d2 => y + 1
    inc eax
    mov d2, eax

    ; 對應 grayArray 獲得對應值
    ; = [(rez-u)*(rez-v)*d1+(rez-u)*v*d2+u*(rez-v)*d3+u*v*d4]/rez^2
    mov ebx, 0
    
    mov eax, u
    mov ecx, v

    mov ecx, d1
    mov eax, 0
    mov al, [grayArray + ecx]
    mov ecx, rez
    mov ecx, u
    mul ecx
    mov ecx, rez
    sub ecx, v
    mul ecx
    add ebx, eax

    mov ecx, d2
    mov eax, 0
    mov al, [grayArray + ecx]
    mov ecx, rez
    sub ecx, u
    mul ecx
    mov ecx, v
    mul ecx
    add ebx, eax
    
    mov ecx, d3
    mov eax, 0
    mov al, [grayArray + ecx]
    mov ecx, u
    mul ecx
    mov ecx, rez
    sub ecx, v
    mul ecx
    add ebx, eax
    
    mov ecx, d4
    mov eax, 0
    mov al, [grayArray + ecx]
    mov ecx, u
    mul ecx
    mov ecx, v
    mul ecx
    add ebx, eax

    mov eax, ebx
    mov ecx, rez
    mov edx, 0
    div ecx
    div ecx
    movzx eax, ax

    ; 轉換成字元並儲存
    mov dl, [asciiArray + eax]
    mov al,[newByteArray + esi]
    mov [newByteArray + esi], dl
    mov al, [newByteArray + esi]

    dec esi
    pop ecx
    dec ecx
    cmp ecx, 0
jne lp_resize
@