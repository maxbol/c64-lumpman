;; JS Jumping parabola generator
;; var steps = 40, height = 40, list = []; steps--; for(var i = 0; i < steps; i++) {list.push(Math.round((Math.pow(steps/2, 2) - Math.pow(steps/2-i, 2))/(Math.pow(steps/2, 2)/height)));}; list.push(0);
jump_parabola
!byte 0, 4, 8, 11, 15, 18, 20, 23, 25, 28, 29, 31, 32, 34, 35, 35, 36, 36, 36, 36, 35, 35, 34, 32, 31, 29, 28, 25, 23, 20, 18, 15, 11, 8, 4, 0

;; Center value is 0-index 17 (max 0-index is 34)
gravity_velocity_vector
!byte  -4, -4, -3, -3, -3, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1, -1, -1, 0, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 4, 4

;; Player gravity index
;; Normally at 17
;; During the positioning of the player, a check is made to see if 
;; there is a character directly under (y-coord) the player sprite. If not, the index
;; is increased and the value in the gravity_velocity_vector is added to the players y-coord.
;; When jumping it is set to 0 and updated every player position check
;; When it has reached 34 it stays there until the player lands (a character appears under the sprite)
;; After landing the gravity index is reset to 17.
player_gravity_index 
!byte 17