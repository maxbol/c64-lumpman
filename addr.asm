!ifdef FILE_Addr !eof
FILE_Addr = 1

;; Setting up some temporary zeropage addresses to store variables 
zp = $02
zp1 = zp + 1
zp2 = zp + 2
zp3 = zp + 3
zp4 = zp + 4
zp5 = zp + 5
zp6 = zp + 6
zp7 = zp + 7

screen_characters = $0400

;; Start of BASIC program
basic = $0801

screen_back_buffer = $C00

;; Player parameters
;; Bits:
;; 0: is jumping
;; 1: is walking
;; 2: direction:
;;      0xx: right
;;      1xx: left
;; 3: is firing
;; 4: headbutt in action!
player_status = $11F0
player_prev_status = player_status + 1
player_jump_timer = player_status + 2
player_jump_start_y = player_status + 3
player_move_timer = player_status + 4
player_current_base_sprite = player_status + 5
player_headbutt_timer = player_status + 6


;; Bits 0-3 indicates collision in four directions:
;; 0 - up
;; 1 - right
;; 2 - down
;; 3 - left
player_collision = player_status + 7


sprites_address = $2000

charset_mem = $3000

;; Start of main program
main_address = $3FC0

;; Setting already existing addresses to easier names

sprites_highbit = $D010

;; Most significant bit for current raster line
msb_raster_line = $d011

raster_line = $d012

enable_sprites = $D015

;; Border color
bocol = $d020

;; Background color
bgcol = $d021

joystick_2 = $dc00