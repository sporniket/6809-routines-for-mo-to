** @brief Left shift the string of bcd

** ## Synopsys

** void bcd__shift(nb_bcd_digit, &ptr_bcd_digit_top, &bit_in)

** ## Parameters

** * @reg b 	nb_bcd_digit 		SIGNED, max number of bcd digit
** * @reg y 	ptr_bcd_digit_top 	pointer to the top bcd digit string
** * @reg a 	bit_in 			MUST be 0 or 1 ; bit to be injected at the right

** ## Side effects

** * @reg y  	pointer to the first used digit of the bcd string
** * @reg a	carry bit of the operation

** ## Noteworthy

** **If the bcd digit being processed is at address 0, the routine stop there and returns.**

bcd__shift__b_y_a
                ; (note)
                ; seems I cannot verify that y >= b
                ; only a an b are checked beforehand
                ; y MUST be checked in the body of the routine

                anda    #1      ; sanity -- only keep the first bit of a
                tstb            ; **avoid buffer underflow** caused by b <= 0
                bgt     UNSANITIZED__bcd__shift_b_y_a
                rts             ; **UNSANE** early return
UNSANITIZED__bcd__shift_b_y_a   ; you MUST swear that you have sanitized @reg a and @reg b yourself

                pshs    b       ; backup b for rts
                pshs    b       ; store local count of remaining bcd digit
                ldb     ,y      ; b = first bcd digit

                bpl     _begin_shifting ; first digit already in use

                sta     ,y      ; a blank bcd string will just receive @reg a
                lda     #0      ; obviously, carry bit is zero
		leas    1,s     ; drop counter
                puls    b,pc    ; early return
                                ; ---
_begin_shifting
                ldx     #BCD__LUT__BCD_TO_SHIFTED_BCD_AND_CARRY ; I want x=lut[b]
                lslb            ; index of item b = 2*b
                abx             ; x=lut[b]

                ora     ,x+     ; a = shifted bcd digit
                sta     ,y      ; update digit
                lda     ,x      ; a = next carry bit
                cmpy    #0      ; I don't see how to do better
                bne     _not_buffer_underflow
		leas    1,s     ; drop counter
                puls    b,pc    ; early return, don't even try to go further, even if it would be the last digit

_not_buffer_underflow puls b    ; recall local count of remaining bcd digit
                decb
                beq     _done
                pshs    b       ; store local count of remaining bcd digit
                leay    -1,y    ; next bcd digit
                ldb     ,y      ; b = next bcd digit
                bpl     _begin_shifting ; not the last bcd digit
                tsta            ; do we need a new digit ?
                bne     _begin_shifting ; yes
                                ; done
                leay    1,y     ; fix y value to point first used bcd digit.
		leas    1,s     ; drop counter
_done
                puls    b,pc    ; final return


** # LUT : bcd -> LSL bcd, carry bit
BCD__LUT__BCD_TO_SHIFTED_BCD_AND_CARRY
                fcb     0,0
                fcb     2,0
                fcb     4,0
                fcb     6,0
                fcb     8,0
                fcb     0,1
                fcb     2,1
                fcb     4,1
                fcb     6,1
                fcb     8,1

