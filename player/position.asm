;; This subroutine updates the position of the 
;; player based on the current status
update_player_position:

    ; Check if player is headbutting
    clc
    lda player_status
    and #PLAYER_STATUS_HEADBUTT_MASK
    beq +

    jmp ++

+   ; Check if player is walking
    clc
    lda player_status
    and #PLAYER_STATUS_WALKING_MASK
    bne +
    jmp ++

+  ; Player is walking, check if we should start animation (if this is the "first" walk)
    clc
    lda player_prev_status
    and #PLAYER_STATUS_WALKING_MASK
    bne +

    ; First walk move so initialize the walk timer
    +set8im player_move_timer, 0

+   ; Check direction
    lda player_status
    and #PLAYER_STATUS_DIRECTION_MASK
    bne +

    ; Player wants to move to the right
    ; Check the collision map to see if there's something in the way
    clc
    lda player_collision
    and #%00000010
    bne ++

    ; Nothing in the way, move to the right
    +move_sprite_right 0, 1
    jmp ++


+   ; We end up here if the player was moving sideways but not to the right

    ; Check the collision map to see if there's something in the way
    lda player_collision
    and #%00001000
    bne ++

    ; Nothing in the way, move to the left
    +move_sprite_left 0, 1

++  ; Check if player is jumping/falling by
    ; checking the char directly under the sprite
    lda player_collision
    and #%00000100
    beq +

    ;; We must also check if the velocity of the player is negative (going up)
    ;; This would indicate that the player is in fact jumping but semi-stuck
    ;; In an background character. In this case, we proceed with the jump.
    clc
    lda player_gravity_index
    cmp #16
    bmi +

    ;; Player is standing on (or just hit) a character, reset player_gravity_index to 17
    lda #17
    sta player_gravity_index

    ;; Since the sum of the jump/fall not always adds up to exactly y mod 8 = 0,
    ;; we adjust the y-coord of the sprite to the top of next character down
    clc
    lda $D001
    and #%00000111
    beq +++

    lda $D001
    and #%11111000
    adc #%00000101
    sta $D001

    ;; Player is standing on the ground, check if he wants to jump.
+++ lda player_status
    and #PLAYER_STATUS_JUMP_MASK
    beq ++

    ;; Player wants to jump, set gravity index to 0 (gives him velocity upwards)
    lda #0
    sta player_gravity_index

+   ;; Nothing under the player, start or continue the fall/jump

    ;; If player_gravity_index is below 17 (going up) and a collision
    ;; is detected above, set player_gravity_index to 17 (stop going up and start fall)
    clc
    lda player_collision
    and #%00000001
    beq +

    lda player_gravity_index
    cmp #17
    bpl +

    lda #17
    sta player_gravity_index

    ;; Add the current value from gravity_velocity_vector depending on the player_gravity_index
+   clc
    ldx player_gravity_index
    lda $D001
    adc gravity_velocity_vector,X
    sta $D001

    ;; Increase player_gravity_index by but only if it's below 34 (max index)
    lda player_gravity_index
    cmp #34
    beq ++

    inc player_gravity_index

    ;; TODO: Step faster if player is headbutting and on the way down
    ; clc
    ; lda player_status
    ; and #PLAYER_STATUS_HEADBUTT_MASK
    ; beq ++

    ; inc player_jump_timer
    ; inc player_jump_timer

++  ;; We end up here either after a jump finished or no jump is in progress.
    ;; If headbutt is active, start the animation to shoot the mucus,
    ;; but only if mucus isn't already present
    lda player_status
    and #PLAYER_STATUS_HEADBUTT_MASK
    beq +++

    lda player_headbutt_timer
    cmp #0
    bne +++

    lda #30
    sta player_headbutt_timer
    +activate_sprite 1, 1
    +activate_sprite 2, 1

    lda $D000
    sta $D002
    sta $D004

    lda $D001
    sta $D003
    sta $D005

+++ rts
