

;; Setup player
setup_player:

    ;; Set player sprite to multicolor
    lda $D01C
    ora #1
    sta $D01C

    ;; Init player sprite
    +setup_sprite 0, 0x80, $05

    ;; Init headbutt wave sprites
    +set_sprite 1, (lumpman_lumpwave_left / $40), $0d
    +set_sprite 2, (lumpman_lumpwave_right / $40), $0d

    ;; Start on lower left corner
    +set8im $D000, 100 ;SCREEN_MIN_X
    +set8im $D001, 100 ;SCREEN_MIN_Y

    rts
