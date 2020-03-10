!cpu 6510

!source "addr.asm"
!source "basic-boot.asm"
!source "constants.asm"
!source "defs.asm"

!source "macros/basic-macros.asm"
!source "macros/macros.asm"
!source "macros/sprites.asm"

*= sprites_address

!source "data/sprites/lumpman.asm"

+start_at $4000

init
        jsr screen_clear    
        jsr screen_init                 ; clear and initialize screen
                                        ; Initialize level 1
        +load_level l2_map, l2_colors, l2_charset, $08, $09

        jsr irq_setup                   ; initialize our IRQ
        
        jsr setup_player

mainloop:
        clc

        ;; Waits for the raster to be in sync with rendering
        ;; I guess this should be replaced by rasterline interrupts eventually.
        +frame_sync

        jsr update_player_status
        jsr update_player_position
        jsr character_collision_detection
        jsr update_player_sprite
        jsr update_weapon_sprites
        jmp mainloop

!source "screen.asm"
!source "level.asm"
!source "irq.asm"

!source "player/collision_detection.asm"
!source "player/player.asm"
!source "player/position.asm"
!source "player/update_sprite.asm"
!source "player/joystick.asm"
!source "player/weapons.asm"

!source "data/physics.asm"
!source "data/tables.asm"
!source "data/level1-charset.asm"
!source "data/level1-colors.asm"
!source "data/level1-map.asm"
!source "data/level2-charset.asm"
!source "data/level2-colors.asm"
!source "data/level2-map.asm"