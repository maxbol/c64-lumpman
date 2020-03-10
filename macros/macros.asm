; Constants
SYSTEM_IRQ_VECTOR = $314

!macro set16im .value, .dest {                                   ; store a 16bit constant to a memory location
    lda #<.value
    sta .dest
    lda #>.value
    sta .dest+1
}

!macro set16 .value, .dest {                                     ; copy a 16bit memory location to dest
    lda .value
    sta .dest
    lda .value+1
    sta .dest+1
}

!macro add16im .n1, .n2, .result {                               ; add a 16bit constant to a memory location, store in result
    clc                                                          ; ensure carry is clear
    lda .n1+0                                                    ; add the two least significant bytes
    adc #<.n2
    sta .result+0                                                
    lda .n1+1                                                    ; add the two most significant bytes
    adc #>.n2                                                    
    sta .result+1                                                
}

!macro sub16im .n1, .n2, .result {
    sec				; set carry for borrow purpose
	lda .n1+0
	sbc #<.n2			; perform subtraction on the LSBs
	sta .result+0
	lda .n1+1			; do the same for the MSBs, with carry
	sbc #>.n2			; set according to the previous result
	sta .result+1
}

!macro add16 .n1, .n2, .result {                                 ; add 2 16bit memory locations, store in result
    clc             
    lda .n1       
    adc .n2
    sta .result+0       
    lda .n1+1       
    adc .n2+1       
    sta .result+1
}

!macro set_raster_interrupt .line, .handler {
    sei                                                          ; disable interrupts
    lda #.line
    sta $d012                                                    ; this is the raster line register
    +set16im .handler, SYSTEM_IRQ_VECTOR                         ; set system IRQ vector to our handler
    cli                                                          ; enable interrupts
}

!macro disable_x_scroll {                                        ; set horizontal softscroll value to 0
    lda $d016
    and #$F8
    sta $d016
}

!macro update_x_scroll .xvalue {                                 ; set horizontal softscroll value to xvalue
    lda $d016
    and #$F8
    clc
    adc .xvalue
    sta $d016
}

!macro loadcharsetchunk {
        ldy #0
.loadchar:
        lda (charset_src_ptr), y
        sta (charset_dst_ptr), y
        iny
        cpy #255
        bne .loadchar
}

!macro loadcharset .charset, .to, .length {
        .chunks = .length / 255

        +set16 .charset, charset_src_ptr
        +set16im .to, charset_dst_ptr

        !for i, 0, .chunks {
            +loadcharsetchunk
            +add16im charset_src_ptr, 255, charset_src_ptr
            +add16im charset_dst_ptr, 255, charset_dst_ptr
        }
}

!macro load_level .map, .colors, .charset, .color1, .color2 {
    +set16im .map, current_map
    +set16im .colors, current_colors
    +set16im .charset, current_charset
    
    lda #.color1
    sta current_color1

    lda #.color2
    sta current_color2

    jsr level_init
}

!macro switch_sprite .spritenum, .address, .color {
    lda #.address
    sta $07F8 + .spritenum
    sta $0FF8 + .spritenum

    lda #.color
    sta $d028 + .spritenum
}

; !macro setup_sprite .spritenum, .address, .color {
;     +switch_sprite .spritenum, .address, .color
;     +activate_sprite .spritenum, 1
; }

; !macro activate_sprite .spritenum, .onoff {
;     !if .onoff = 1 {
;         lda 1 << .spritenum
;         ora $d015
;         sta $d015
;     }
; }