;; Subroutine for detecting collision with background characters in four directions.
character_collision_detection:
    
    clc
    ;; Reset collision bits
    lda #0
    sta player_collision

    ;; We store the remainder for both x and y of the division by 8 later on to be able to do some pixel tweaking
    lda $D000
    and #%00000111
    sta zp6                                     ; Remainder for x-coord

    lda $D001
    and #%00000111
    sta zp7                                     ; Remainder for y-coord

    ;; Find player x-position expressed in number of background characters
    lda $D000                                   ; Store player (sprite 0) x-position in zero page
    sta zp                                      ; as 16 bit (remember the high bit for sprite x)
    lda sprites_highbit
    and #1
    sta zp1

    +sub16im zp, SCREEN_MIN_X, zp               ; Subtracting 24 (left frame)

    clc
    lda zp
    lsr                                         ; Shift right three times to divide by 8
    lsr
    lsr
    tax                                         ; Store the value in the X-register

    clc
    lda zp1                                     ; If the x-coord high bit is set, add 31 (# chars up to 256)
    and #1
    beq +

    txa
    adc #31
    tax

+   inx                                         ; Increment X-index to get to the center of the sprite
    
    stx zp                                      ; x-wise character index stored in zp

    ;; Load y-coord to find the y index
    clc
    lda $D001
    sbc #SCREEN_MIN_Y                           ; Subtract the top border height 
    lsr                                         ; Divide by 8
    lsr
    lsr

    clc
    adc #3                                      ; Add 3 rows to get the center char under the player sprite

    asl                                         ; Since this is used to look up a value in a 16 bit
    tax                                         ; array we need to double it.
    
    clc             
    lda player_char_lut,X                       ; Looks up the added character index from the row LUT and adds the x-coord
    adc zp                                      ; to get the relative index of the character in the character set (0-1000)
    sta zp2
    inx
    lda player_char_lut,X
    adc #0 
    sta zp3

    ;; zp2 (16 bit) now points to the address with the character 0-indexed value in it (0-1000).
    
    +add16im zp2, screen_characters, zp4        ; Now get the absolute address to the character

    ldy #0                                      ; The absolute address to the character is now stored in zp2 (16 bit)
    lda (zp4),Y                                 ; Retrieve the actual character value

    cmp #CHARACTER_BLANK                        ; A register now contains the value of the character.
    bne ++                                      ; Check for space (32, empty background)

    iny                                         
    lda (zp4),Y                                 

    cmp #CHARACTER_BLANK                        
    beq +                                       

++  +bit_on player_collision, PLAYER_COLLISION_BIT_DOWN
    ; lda player_collision                        ; One of the characters was not space, set player_collision bit 2 to 1
    ; ora #PLAYER_COLLISION_MASK_DOWN                              
    ; sta player_collision

+   ;; Getting the other characters that the player might collide with (left, right and top)

    ;; Top
    clc
    ldy #0
    +sub16im zp4, 161, zp2                      ; Subtracting 4 lines and one character to get to the top left
    lda (zp2),Y
    
    cmp #CHARACTER_BLANK
    bne ++

    iny
    lda (zp2),Y                                 ; Checking top middle
    
    cmp #CHARACTER_BLANK
    bne ++

    iny
    lda (zp2),Y                                 ; Checking top right
    
    cmp #CHARACTER_BLANK
    beq +

++  +bit_on player_collision, PLAYER_COLLISION_BIT_UP
    ; lda player_collision                        ; Character was not space, set player_collision bit 0 to 1
    ; ora #PLAYER_COLLISION_MASK_UP                              
    ; sta player_collision

+   ;; Left
    ldy #0
    +sub16im zp4, 81, zp2                       ; Adding 2 lines minus two characters to get to the left middle
    lda (zp2),Y
    
    cmp #CHARACTER_BLANK
    bne ++

    +sub16im zp2, 40, zp2                       ; Adding 2 lines minus two characters to get to the left middle
    lda (zp2),Y
    
    cmp #CHARACTER_BLANK
    bne ++

    +add16im zp2, 80, zp2                       ; Adding 2 lines minus two characters to get to the left middle
    lda (zp2),Y
    
    cmp #CHARACTER_BLANK
    beq +

++  +bit_on player_collision, PLAYER_COLLISION_BIT_LEFT
    ; lda player_collision                        ; Character was not space, set player_collision bit 3 to 1
    ; ora #PLAYER_COLLISION_MASK_LEFT                              
    ; sta player_collision

+   ;; Right
    ldy #0                                      ; Compensating some pixels to adjust collision
    lda zp6
    cmp #2
    bmi +

    +sub16im zp4, 78, zp2                        ; Adding 3 characters to get to the right middle
    jmp ++

+   +sub16im zp4, 79, zp2                        ; Adding 3 characters to get to the right middle

++  lda (zp2),Y
    
    cmp #CHARACTER_BLANK
    bne ++

    +sub16im zp2, 39, zp2                       ; Adding 4 characters to get to the right middle
    lda (zp2),Y
    
    cmp #CHARACTER_BLANK
    bne ++

    +add16im zp2, 79, zp2                       ; Adding 4 characters to get to the right middle
    lda (zp2),Y
    
    cmp #CHARACTER_BLANK
    beq +

++  +bit_on player_collision, PLAYER_COLLISION_BIT_RIGHT
    ; lda player_collision                        ; One of the characters was not space, set player_collision bit 1 to 1
    ; ora #PLAYER_COLLISION_MASK_RIGHT                              
    ; sta player_collision

+   rts