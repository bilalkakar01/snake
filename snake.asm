;	set game state memory location
.equ    HEAD_X,         0x1000  ; Snake head's position on x
.equ    HEAD_Y,         0x1004  ; Snake head's position on y
.equ    TAIL_X,         0x1008  ; Snake tail's position on x
.equ    TAIL_Y,         0x100C  ; Snake tail's position on Y
.equ    SCORE,          0x1010  ; Score address
.equ    GSA,            0x1014  ; Game state array address

.equ    CP_VALID,       0x1200  ; Whether the checkpoint is valid.
.equ    CP_HEAD_X,      0x1204  ; Snake head's X coordinate. (Checkpoint)
.equ    CP_HEAD_Y,      0x1208  ; Snake head's Y coordinate. (Checkpoint)
.equ    CP_TAIL_X,      0x120C  ; Snake tail's X coordinate. (Checkpoint)
.equ    CP_TAIL_Y,      0x1210  ; Snake tail's Y coordinate. (Checkpoint)
.equ    CP_SCORE,       0x1214  ; Score. (Checkpoint)
.equ    CP_GSA,         0x1218  ; GSA. (Checkpoint)

.equ    LEDS,           0x2000  ; LED address
.equ    SEVEN_SEGS,     0x1198  ; 7-segment display addresses
.equ    RANDOM_NUM,     0x2010  ; Random number generator address
.equ    BUTTONS,        0x2030  ; Buttons addresses

; initialize stack pointer
addi    sp, zero, LEDS

; main
; arguments
;     none
;
; return values
;     This procedure should never return.
main:
call clear_leds
addi a0, a0,0x09
addi a1,a1,0x07
call set_pixel
    ; TODO: Finish this procedure.

    ret


; BEGIN: clear_leds
clear_leds:

stw zero, LEDS(t0)
stw zero, (LEDS+4)(t0)
stw zero, (LEDS+8)(t0)
ret

; END: clear_leds


; BEGIN: set_pixel
set_pixel:
	andi t1, a0, 0x03
	slli t1, t1, 0x03
	add t1, t1, a1 
	addi t2, zero, 0x01
	sll t2, t2, t1
	addi t0, zero, 0x08
	bge a0, t0, set_pixel_2
	addi t0, zero, 0x04
	bge a0, t0, set_pixel_1
	jmpi set_pixel_0
	ret
set_pixel_2:
	ldw t3, (LEDS+0x0008)(zero)
	or t3, t3, t2
	stw t3, (LEDS+0x0008)(zero)
	ret
set_pixel_1:
	ldw t3, (LEDS+0x0004)(zero)
	or t3, t3, t2
	stw t3, (LEDS+0x0004)(zero)
	ret
set_pixel_0:
	ldw t3, (LEDS)(zero)
	or t3, t3, t2
	stw t3, (LEDS)(zero)
	ret
	ret
; END: set_pixel


; BEGIN: display_score
display_score:

; END: display_score


; BEGIN: init_game
init_game:

; END: init_game


; BEGIN: create_food
create_food:

; END: create_food


; BEGIN: hit_test
hit_test:

; END: hit_test


; BEGIN: get_input
get_input:

; END: get_input


; BEGIN: draw_array
draw_array:

; END: draw_array


; BEGIN: move_snake
move_snake:

; END: move_snake


; BEGIN: save_checkpoint
save_checkpoint:

; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:

; END: restore_checkpoint


; BEGIN: blink_score
blink_score:

; END: blink_score
