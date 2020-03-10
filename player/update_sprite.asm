;; Sets the sprite for the player based on the current status
update_player_sprite:
    clc
    lda player_status

    ; Check direction
    and #PLAYER_STATUS_DIRECTION_MASK
    bne +

    +set8im player_current_base_sprite, (lumpman_right_stand / $40)
    jmp ++

+   +set8im player_current_base_sprite, (lumpman_left_stand / $40)

++  clc
    lda player_status
    and #PLAYER_STATUS_HEADBUTT_MASK
    cmp #PLAYER_STATUS_HEADBUTT_MASK
    bne +

    ; Player is headbutting so stop moving and switch sprite
    lda player_current_base_sprite
    adc #$02
    sta $07F8
    rts


+   clc
    lda player_collision
    and #%00000100
    bne +

    lda player_current_base_sprite
    adc #$02
    sta $07F8
    rts

+   lda player_jump_timer
    cmp #$0
    beq +

    lda player_current_base_sprite
    adc #$01
    sta $07F8
    rts

+   lda player_status
    and #PLAYER_STATUS_WALKING_MASK
    beq +

    inc player_move_timer

    ldx player_move_timer
    cpx #$08
    bne ++

    clc
    lda $07F8
    cmp player_current_base_sprite
    beq +++
    +set8im $07F8, player_current_base_sprite
    jmp ++++

+++:
    inc $07F8

++++:

    +set8im player_move_timer, 0
    rts

+:
    +set8im $07F8, player_current_base_sprite

++:
    rts
