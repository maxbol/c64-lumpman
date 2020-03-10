  
; Constants
screen_ptr = $04
color_ptr = $06
screen_src_ptr = $FB
color_src_ptr = $FD
screen_col = $08
screen_ptr_dest = $0a

current_map = $2B
current_colors = $2D
current_charset = $2F

charset_src_ptr = $31
charset_dst_ptr = $33  

TOTAL_ROW_COUNT=25
TOTAL_COLUMN_COUNT=40

current_color1      !byte 0
current_color2      !byte 0     

level_init
                    lda current_color1                              ; Write global color 1 to register
                    sta $d022

                    lda current_color2                              ; Write global color 2 to register
                    sta $d023

                    +loadcharset current_charset, charset_mem, 2048 ; Load charset into memory

                    +set16im 0, screen_col                          ; Clear screen column pointer

                    lda #7
                    sta xscroll

                    lda #39
                    sta xpan

                    lda #0
                    sta xpage

                    +update_x_scroll xscroll

level_render_next_col
                    +set16 screen_base, screen_ptr                  ; Point screen pointer to current screen memory/back buffer zero position
                    +set16im $d800, color_ptr                       ; Point color pointer to color memory zero position

                    +set16 current_map, screen_src_ptr            ; Set source pointer to current map zero position
                    +set16 current_colors, color_src_ptr          ; Set color source pointer to current colorset zero position

                    +add16 screen_ptr, screen_col, screen_ptr       ; Add current column number to screen pointer
                    +add16 color_ptr, screen_col, color_ptr         ; Add current column number to color pointer

                    ldx xpage                                       ; Load number of screens scrolled into X register
                    ldy screen_col                                  ; Load current column being drawn into Y register

                    clc

                    lda xpan                                        ; If the current amount of characters not scrolled on current xpage
                    sbc screen_col                                  ; is higher than the current column being drawn
                                                                    ; that means we're still on the current xpage, and thus we
                    bpl level_offset_data                           ; skip the next instructions
                    
                    inx                                             ; Increment the amount xpages scrolled in X register by 1

                    clc
                    
                    lda screen_col                                  ; Save the current column being drawn minus the amount of characters not scrolled
                    sbc xpan                                        ; to the Y-register for column shifting the source
                    tay

level_offset_data
                    dex                                             ; Loop over xpage and add 1000 bytes to the pointer for every xpage scrolled

                    bmi level_shift_col

                    +add16im screen_src_ptr, 1000, screen_src_ptr   ; Shift src data an entire xpage

                    jmp level_offset_data

level_shift_col
                    dey                                             ; Loop over the current screen col being drawn (minus xpan if we're writing to next xpage)
                                                                    ; and add 1 to source pointer every time

                    bmi level_render_col

                    +add16im screen_src_ptr, 1, screen_src_ptr      ; Shift src data by 1 byte

                    jmp level_shift_col

level_render_col    
                    inc screen_col                                  ; Increment the current column by 1
                    ldx #TOTAL_ROW_COUNT                            ; Load the total row count into X-register
                    
level_render_cells

                                                                    ; Time to actually write data to screen memory/back buffer

                    ldy #0                                          ; Clear the Y-register for indexed indirect lookups

                    lda (screen_src_ptr), y                         ; Load character index from the current level source pointer
                    sta (screen_ptr), y                             ; Store character index to the current screen pointer
                                                                    ; (Y=0)

                    tay                                             ; Copy the character index to Y-register

                    lda (color_src_ptr), y                          ; Load color for the referenced character by
                                                                    ; getting color data from color map using Y as vector
                                                                    ; (Y=character index)

                    ldy #0                                          ; Clear the Y-register again

                    sta (color_ptr), y                              ; Write color data to color memory
                                                                    ; (Y=0)

                    +add16im screen_ptr, TOTAL_COLUMN_COUNT, screen_ptr             ; Advance all pointers by a column
                    +add16im color_ptr, TOTAL_COLUMN_COUNT, color_ptr               ; thus going down to the next row
                    +add16im screen_src_ptr, TOTAL_COLUMN_COUNT, screen_src_ptr

                    dex                                             ; Decrement row count in X
                    bne level_render_cells                          ; If we're not at zero yet, do it again for next row

level_render_check
                    lda screen_col                                  ; Load current column into accumulator

                    cmp #TOTAL_COLUMN_COUNT                         ; If it's the same as the total column count...

                    beq level_render_done                           ; ...we've finished writing all columns to screen memory and can move on

                    jmp level_render_next_col                       ; Otherwise, repeat until done

level_render_done
                    rts                                             ; Return

level_render_last_col
                                                                    ; This is being called from the scrolling IRQ when scrolling
                                                                    ; from the right, to redraw the last column

                    +set16im TOTAL_COLUMN_COUNT-1, screen_col       ; Set the current screen column to the total column count minus one

                    jsr level_render_next_col                       ; Draw it

                    rts                                             ; Return