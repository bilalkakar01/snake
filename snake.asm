;    set game state memory location
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

; button state
.equ    BUTTON_NONE,    0
.equ    BUTTON_LEFT,    1
.equ    BUTTON_UP,      2
.equ    BUTTON_DOWN,    3
.equ    BUTTON_RIGHT,   4
.equ    BUTTON_CHECKPOINT,    5

; array state
.equ    DIR_LEFT,       1       ; leftward direction
.equ    DIR_UP,         2       ; upward direction
.equ    DIR_DOWN,       3       ; downward direction
.equ    DIR_RIGHT,      4       ; rightward direction
.equ    FOOD,           5       ; food

; constants
.equ    NB_ROWS,        8       ; number of rows
.equ    NB_COLS,        12      ; number of columns
.equ    NB_CELLS,       96      ; number of cells in GSA
.equ    RET_ATE_FOOD,   1       ; return value for hit_test when food was eaten
.equ    RET_COLLISION,  2       ; return value for hit_test when a collision was detected
.equ    ARG_HUNGRY,     0       ; a0 argument for move_snake when food wasn't eaten
.equ    ARG_FED,        1       ; a0 argument for move_snake when food was eaten


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
addi a0, zero, 0x09
addi a1, zero, 0x07
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
	ldw t0, (BUTTONS + 0x0004)(zero) ; store edgecapture in t0
	stw zero, (BUTTONS + 0x0004)(zero) ; clear edgecapture
	addi t1, zero, 0x01 ; create a mask (0x01) in t1
	and t2, t0, t1 ; store bit 0 (left button) of edgecapture in t2
	srli t0, t0, 0x01 ; shiftright edgecapture by 1
	and t3, t0, t1 ; store bit 1 (up button) of edgecapture in t3
	srli t0, t0, 0x01 ; shiftright edgecapture by 1
	and t4, t0, t1 ; store bit 2 (down button) of edgecapture in t4
	srli t0, t0, 0x01 ; shiftright edgecapture by 1
	and t5, t0, t1 ; store bit 3 (right button) of edgecapture in t5
	srli t0, t0, 0x01 ; shiftright edgecapture by 1
	and t6, t0, t1 ; store bit 4 (checkpoint button) of edgecapture in t6
	beq t6, t1, checkpoint_pressed ; first check if checkpoint was pressed (highest priority)
	ldw t0, (HEAD_X)(zero) ; store HEAD_X in t0
	ldw t7, (HEAD_Y)(zero) ; store HEAD_Y in t7
	slli t0, t0, 0X03 ; multiply t0 by 8
	add t7, t7, HEAD_Y ; add t7 to it
	slli t0, t7, 0x02 ; mutliply it by 4 to get the address in memory and store it in t0
	ldw t7, (GSA)(t0) ; store the value of snake's head in t7
	beq t2, t1, left_pressed ; check the other buttons (order doesn't matter)
	beq t3, t1, up_pressed
	beq t4, t1, down_pressed
	beq t5, t1, right_pressed
	addi v0, zero, 0x00 ; no button pressed so set v0 to 0
	ret
checkpoint_pressed:
	addi v0, zero, 0x05 ; set v0 to 5
	ret
left_pressed:
	addi v0, zero, 0x01 ; set v0 to 1
	addi t1, zero, 0x04 ; set t1 to 4 (right)
	bne t7, t1, snake_head_left
	ret
snake_head_left:
	stw 0x01, (GSA)(t0)
	ret 
up_pressed:
	addi v0, zero, 0x02 ; set v0 to 2
	addi t1, zero, 0x03 ; set t1 to 3 (down)
	bne t7, t1, snake_head_up
	ret
snake_head_up:
	stw 0x02, (GSA)(t0)
	ret
down_pressed:
	addi v0, zero, 0x03 ; set v0 to 3
	addi t1, zero, 0x02 ; set t1 to 2 (up)
	bne t7, t1, snake_head_down
	ret
snake_head_down:
	stw 0x03, (GSA)(t0)
	ret
right_pressed:
	addi v0, zero, 0x04 ; set v0 to 4
	addi t1, zero, 0x01 ; set t1 to 1 (up)
	bne t7, t1, snake_head_right
	ret
snake_head_right:
	stw 0x04, (GSA)(t0)
	ret

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
