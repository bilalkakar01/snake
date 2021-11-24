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
; TODO: Finish this procedure.
stw zero, HEAD_X(zero)
stw zero, HEAD_Y(zero)
stw zero, TAIL_X(zero)
stw zero, TAIL_Y(zero)
addi t0, zero, 4
stw t0, GSA(zero)
addi t0, zero, 48
stw t0, SCORE(zero)
main:
call display_score
break
call clear_leds
call create_food
call draw_array
jmpi main



; BEGIN: clear_leds
clear_leds:

stw zero, LEDS(zero)
stw zero, (LEDS+4)(zero)
stw zero, (LEDS+8)(zero)
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
; END: set_pixel


; BEGIN: display_score
display_score:
	ldw t0, digit_map(zero) ; load number 0 LED representation in t0
	stw t0, SEVEN_SEGS(zero) ; store 0 LED representation in first seven seg display
	stw t0, (SEVEN_SEGS + 4)(zero) ; store 0 LED representation in second seven seg display
	ldw t1, SCORE(zero) ; load score in t1
	add t2, t1, zero ; store score in t2
	addi t4, zero, 0x0A ; t4 contains value 10
	mod10_loop: ; compute the unit digit (score mod 10) and store it in t2
	bge t4, t2, end_mod10_loop ; check if t2 is smaller than 10
	sub t2, t2, t4 ; subtract 10 to t2
	jmpi mod10_loop ; go to the top of the loop
	end_mod10_loop:
	sub t1, t1, t2 ; subtract the unit digit to the score
	addi t3, zero, 0 ; initialize t3 to 0 (t3 will be the tens digit)
	addi t5, zero, 1 ; initialize t5 to be 1
	divBy10_loop: ; divide t3 by 10 to get tens digit
	beq zero, t1, end_divBy10_loop ; loop ends when score is 0
	sub t1, t1, t4 ; subtract 10 to the score
	add t3, t3, t5 ; add 1 to the tens number
	jmpi divBy10_loop ; go to the top of the loop
	end_divBy10_loop:
	slli t3, t3, 0x02 ; multiply t3 by 4
	ldw t3, (digit_map)(t3) ; load tens number LED representation in t3
	stw t3, (SEVEN_SEGS + 8)(zero) ; store tens number LED representation in third seven seg display
	slli t2, t2, 0x02 ; multiply t2 by 4
	ldw t2, (digit_map)(t2) ; load unit number LED representation in t2
	stw t2, (SEVEN_SEGS + 12)(zero) ; store unit number LED representation in fourth seven seg display
	ret
; END: display_score


; BEGIN: init_game
init_game:

; END: init_game


; BEGIN: create_food
create_food:
addi t1, zero,NB_CELLS ; 	t1: contains the value 96 which is the limit of the NB_CELLS

verify_limits: 			; verifies if the random position is in range b/w 0 and 96
ldw t0, RANDOM_NUM(t5)
andi t0,t0,0xFF			;	t1: contains a "condidate" position of food
bge t0,t1,verify_limits
blt t0,t1, verify_availability 


verify_availability:    ; verifies if the cell is available to create "Food"
slli t7, t0, 0x02
add t7,t7,t0
ldw t3, GSA(t7)  		; 	t3: contains the value of in GSA(t0)
beq t3, zero, end
jmpi verify_limits

end:
addi t4, zero, FOOD
stw t4,GSA(t7)
; END: create_food


; BEGIN: hit_test
hit_test:
stw t0, HEAD_X(zero)
stw t1, HEAD_Y(zero)
stw t2, TAIL_X(zero)
stw t3, TAIL_Y(zero)

slli t5, t0, 0x03
add t5, t5, t1
slli t5,t5, 0x02
ldw t5, GSA(t5)  ; t5: direction of the snake's head

addi t4, zero , 0x01
beq t5, t4, left
addi t4, zero, 0x02
beq t5,t4, up
addi t4, zero, 0x03
beq t5, t4, down

addi t0, t0, 0x01
addi t2, t2, 0x01
jmpi collision_test

left: 
sub t0, t0,t4
sub t2, t2,t4
jmpi collision_test
;end left
up:
addi t1,t1, 0x01
addi t3,t3, 0x01
jmpi collision_test
;end up
down:
addi t4, zero, 0x01
sub t1,t1,t4
sub t3,t3,t4
jmpi collision_test

collision_test:




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
	slli t0, t0, 0x03 ; multiply t0 by 8
	add t7, t0, t7 ; add t7 to it
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
	bne t7, t1, snake_head_left ; check that snake is not currently heading right
	ret
snake_head_left:
	addi t6, zero, 0x01
	stw t6, (GSA)(t0) ; sets snake's head direction to left
	ret 
up_pressed:
	addi v0, zero, 0x02 ; set v0 to 2
	addi t1, zero, 0x03 ; set t1 to 3 (down)
	bne t7, t1, snake_head_up ; check that snake is not currently heading down
	ret
snake_head_up:
	addi t6, zero, 0x02
	stw t6, (GSA)(t0) ; sets snake's head direction to up
	ret
down_pressed:
	addi v0, zero, 0x03 ; set v0 to 3
	addi t1, zero, 0x02 ; set t1 to 2 (up)
	bne t7, t1, snake_head_down ; check that snake is not currently heading up
	ret
snake_head_down:
	addi t6, zero, 0x03
	stw t6, (GSA)(t0) ; sets snake's head direction to down
	ret
right_pressed:
	addi v0, zero, 0x04 ; set v0 to 4
	addi t1, zero, 0x01 ; set t1 to 1 (up)
	bne t7, t1, snake_head_right ; check that snake is not currently heading left
	ret
snake_head_right:
	addi t6, zero, 0x04
	stw t6, (GSA)(t0) ; sets snake's head direction to right
	ret
; END: get_input


; BEGIN: draw_array
draw_array:
	addi t4, zero, 0 ; initialize a counter
	addi t5, zero, 384 ; end value of the for loop
	loop_draw_array: ; start of the for loop
	beq t4, t5, end_loop_draw_array ; end condition of the for loop
	ldw t6, (GSA)(t4) ; load value of GSA in t6
	bne t6, zero, call_set_pixel ; if the element is not zero, set pixel
	addi t4, t4, 4 ; add 4 to the counter
	jmpi loop_draw_array ; go at the top of the loop
	end_loop_draw_array:
	ret ; return to where the procedure was called
	call_set_pixel:
	add t6, zero, t4 ; store counter's value in t6
	srli t6, t6, 2 ; divide GSA index by 4
	andi a1, t6, 7 ; compute t6 mod 8 to get y and store it in a1
	sub t6, t6, a1 ; subtract y to t6
	srli a0, t6, 3 ; divide by 8 to get x and store it in a0
	add t7, zero, ra ; store ra in t7 before calling set_pixel procedure
	call set_pixel ; call the set_pixel procedure
	add ra, zero, t7 ; store back ra's old value
	addi t4, t4, 4 ; add 4 to the counter
	jmpi loop_draw_array ; go to the top of the loop
; END: draw_array


; BEGIN: move_snake
move_snake:
ldw t0, HEAD_X(zero) ; store the Head_x in t0
ldw t2, HEAD_Y(zero) ; store the head_y in t2
ldw t6, TAIL_X(zero); t6: tail_x
ldw t7, TAIL_Y(zero); t7: tail_y
; get tail's position in GSA
slli t1, t6, 0x03
add t1, t1, t7
slli t1, t1, 0x02
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
jmpi rightwards

update:
; update the new head pos in GSA
slli t5, t0, 0x03 ; t0: head_x
add t5, t5, t2 ; t5: new position of snake's head, t2: head_y
slli t5, t5, 0x02
stw t3, GSA(t5)
stw t0, HEAD_X(zero)
stw t2, HEAD_Y(zero) 
; update the new tail pos in GSA
stw zero, GSA(t1)
stw t6, TAIL_X(zero)
stw t7, TAIL_Y(zero)
ret

leftwards:
addi t4, zero, 0x01
sub t0, t0,t4   ; t0 : head_x of the snake
sub t6, t6, t4 ; t6: tail_x
jmpi update
 

upwards:
addi t4, zero, 0x01
sub t2, t2, t4 ; t2: head_y of the snake
sub t7, t7, t4 ; t7: tail_y
jmpi update


downwards:
addi t2, t2, 0x01
addi t7, t7, 0x01
jmpi update

rightwards:
addi t0, t0, 0x01 ; t0 : head_x
addi t6, t6, 0x01  ; t6: tail_x
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

digit_map:
.word 0xFC ; 0
.word 0x60 ; 1
.word 0xDA ; 2
.word 0xF2 ; 3
.word 0x66 ; 4
.word 0xB6 ; 5
.word 0xBE ; 6
.word 0xE0 ; 7
.word 0xFE ; 8
.word 0xF6 ; 9
