;; This subroutine sets the current status of the player
;; based on the previous state and the current joystick input.
update_player_status:
    clc
    lda player_status
    ; Store previous state
    sta player_prev_status

    ; Reset player_status but keep direction
    ; in case the joystick isn't moving in any direction, otherwise it would flip
    ; Lumpman back to facing right every time we stop moving him.
    and #PLAYER_STATUS_DIRECTION_MASK
    sta player_status

    ; Set moving bit (if joystick right)
    lda joystick_2
    eor #$8
    and #$8
    lsr
    lsr
    ora player_status
    sta player_status

    ; Set moving bit (if joystick left)
    lda joystick_2
    eor #$4
    and #$4
    lsr
    ora player_status
    sta player_status

    ; Facing right          Yes             No
    lda joystick_2      ; 10110111      ; 10111111
    eor #$8             ; 01001000      ; 01000000
    and #$8             ; 00001000      ; 00000000
    lsr                 ; 00000100      ; 00000000
    eor #$FF            ; 11111011      ; 11111111
    and player_status   ; XXXXX0XX      ; XXXXXXXX
    sta player_status
    
    ; Facing left
    lda joystick_2
    eor #$4
    and #$4
    ora player_status
    sta player_status

    ; Up/jump
    lda player_collision            ; Only allowed to jump if not already jumping
    and #PLAYER_COLLISION_MASK_DOWN
    beq +
    lda joystick_2
    eor #$01
    and #$01
    ora player_status
    sta player_status
+
    ; Down/headbutt
    lda joystick_2
    eor #$02
    and #$02
    asl
    asl
    asl
    ora player_status
    sta player_status

    rts