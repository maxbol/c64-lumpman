update_weapon_sprites:
    lda player_headbutt_timer
    cmp #0
    beq +

    lda player_headbutt_timer
    cmp #1
    beq ++

    dec $D002
    inc $D004
    dec $D002
    inc $D004

    dec player_headbutt_timer
    rts 

++  +activate_sprite 1, 0
    +activate_sprite 2, 0
    +set8im player_headbutt_timer, 0

+   rts