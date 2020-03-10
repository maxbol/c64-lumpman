LOGO_X=124
LOGO_Y=90

CHAR0_X=LOGO_X + (24 * 0)
CHAR0_Y=LOGO_Y

CHAR1_X=LOGO_X + (24 * 1)
CHAR1_Y=LOGO_Y

CHAR2_X=LOGO_X + (24 * 2)
CHAR2_Y=LOGO_Y

CHAR3_X=LOGO_X + (24 * 3)
CHAR3_Y=LOGO_Y

sprite_0_loc = $80
sprite_1_loc = $81
sprite_2_loc = $82
sprite_3_loc = $83

init_titlescreen
    lda #$08 ; sprite multicolor 1
    sta $D025
    lda #$06 ; sprite multicolor 2
    sta $D026

_titlescr_setup_sprite_locations
    lda #CHAR0_X
    sta $d000

    lda #CHAR0_Y
    sta $d001

    lda #CHAR1_X
    sta $d002

    lda #CHAR1_Y
    sta $d003

    lda #CHAR2_X
    sta $d004

    lda #CHAR2_Y
    sta $d005

    lda #CHAR3_X
    sta $d006

    lda #CHAR3_Y
    sta $d007

_titlescr_switch_on_sprites
    +setup_sprite 0, sprite_0_loc, $1
    +setup_sprite 1, sprite_1_loc, $1
    +setup_sprite 2, sprite_2_loc, $1
    +setup_sprite 3, sprite_3_loc, $1

_titlescr_done
    rts    