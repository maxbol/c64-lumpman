!ifdef FILE_Basic_Macros !eof
FILE_Basic_Macros = 1

!macro set8im .address, .value {
    !if .value < 256 {
        lda #.value
        sta .address
    }
    !if .value >= 256 {
        lda .value
        sta .address
    }
}

!macro bit_on .address, .bitidx {
    lda .address
    ora #(1 << .bitidx)
    sta .address
}

!macro bit_off .address, .bitidx {
    lda .address
    and #!(1 << .bitidx)
    sta .address
}


!macro frame_sync {
    lda #$00
    cmp raster_line ; until it reaches 251th raster line ($fb)
    bne mainloop ; which is out of the inner screen area

    ; Makes sure the msb is 1
    lda #$80
    eor msb_raster_line
    and #$80
    beq mainloop
}

!macro log .address {
    ; jsr $e544
    jsr $E566
    lda #0
    ldx .address
    jsr $BDCD
}

!macro log16 .address {
    jsr $E566
    LDX .address
    LDA .address + 1
    JSR $BDCD
}