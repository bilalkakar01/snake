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

; END: get_input


; BEGIN: draw_array
draw_array:

; END: draw_array


; BEGIN: move_snake
move_snake:
stw t0, HEAD_X(zero) ; store the Head_x in t0
stw t2, HEAD_Y(zero) ; store the head_y in t2
stw t6, TAIL_X(zero); t6: tail_x
stw t7, TAIL_Y(zero); t7: tail_y
	;get the head direction vector from GSA 
slli t3,t0, 0x03
add t3,t3,t2
slli t3, t3, 0x02
ldw t3, GSA(t3) ; t3: direction of snake's head
	;compare if the direction is leftward,upward,downward or rightward
addi t4, zero, 0x01
beq t3,t4, leftwards
addi t4, zero, 0x02
beq t3,t4, upwards
addi t4, zero, 0x03
beq t3, t4, downwards
	;if rightward
addi t0, t0, 0x01
addi t6, t6,0x01  ; t6: tail_x

addi t4, zero, 0x01
jmpi update

update:

; update the new head pos in GSA
slli t5, t0, 0x03 ; t0: head_x
add t5, t5, t2 ; t5: new position of snake's head, t2: head_y
slli t5, t5, 0x02
stw t3, GSA(t5)
; update the new tail pos in GSA
slli t5, t6, 0x03 ; t5: new pos of snake tail, t6: tail_x
add t5, t5,t7  ;  t7: tail_y
slli t5,t5,0x02
stw t3, GSA(t5)

leftwards:
sub t0, t0,t4   ; t0 : head_x of the snake
sub t6, t6, t4 ; t6: tail_x
jmpi update
 

upwards:
addi t2, t2, 0x02 ; t2: head_y of the snake
addi t7, t7, 0x01 ; t7: tail_y
jmpi update


downwards:
sub t2, t2,t4
sub t7, t7, t4
jmpi update


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
