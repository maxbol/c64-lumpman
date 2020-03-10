!macro set_sprite .spritenum, .address, .color {
    +set8im $07F8 + .spritenum, .address
    +set8im $D027 + .spritenum, .color
}

!macro setup_sprite .spritenum, .address, .color {
    +set_sprite .spritenum, .address, .color
    +activate_sprite .spritenum, 1
}

!macro activate_sprite .spritenum, .onoff {
    !if .onoff = 1 {
        +bit_on enable_sprites, .spritenum
    }
    !if .onoff = 0 {
        +bit_off enable_sprites, .spritenum
    }
}

!macro move_sprite_right .spritenum, .xrel {

    clc

    lda $D000 + (.spritenum * 2)
    ldx $D000 + (.spritenum * 2)
    adc #.xrel
    sta $D000 + (.spritenum * 2)
    cpx $D000 + (.spritenum * 2)
    bcc +
    +bit_on sprites_highbit, .spritenum

+   clc
    lda sprites_highbit
    eor #(1 << .spritenum)
    and #(1 << .spritenum)
    bne +
    lda #SCREEN_MAX_XH
    cmp $D000 + (.spritenum * 2)
    bcs +
    +set8im $D000 + (.spritenum * 2), SCREEN_MAX_XH

+

}

!macro move_sprite_left .spritenum, .xrel {

    clc
    lda $D000 + (.spritenum * 2)
    ldx $D000 + (.spritenum * 2)
    sbc #.xrel - 1
    sta $D000 + (.spritenum * 2)
    cpx $D000 + (.spritenum * 2)
    bcs +
    +bit_off sprites_highbit, .spritenum

+   clc
    lda sprites_highbit
    eor #(1 << .spritenum)
    and #(1 << .spritenum)
    beq +
    lda #SCREEN_MIN_X
    cmp $D000 + (.spritenum * 2)
    bcc +
    +set8im $D000 + (.spritenum * 2), SCREEN_MIN_X

+   nop

}
