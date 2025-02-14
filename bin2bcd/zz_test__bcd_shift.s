** Test suite for bcd__shift__b_y_a
start
** Prepare
                ; fill the test bcd string with value "15"
                ldy     #UTST_BUF__bcd_string_1
                lda     #$80    ; just put unused digits to negative (just set the sign bit, i.e. 0x80)
                sta     ,y+
                sta     ,y+
                sta     ,y+
                sta     ,y+
                sta     ,y+
                sta     ,y+
                lda     #1
                sta     ,y+
                lda     #5
                sta     ,y+
                lda     #0
                sta     ,y+
                sta     ,y+
                sta     ,y+
                sta     ,y+
                ; dump initial state
                ldy     #$400
                jsr     dump_buffer

** verify
verify
                ldb     #6
                ldy     #UTST_BUF__bcd_string_1
                leay    7,y
                lda     #1
                jsr     bcd__shift__b_y_a
                ; Perform each verification
                ; fail fast : as soon as a test fails, skip to the end
                ; -- verify a first
                tsta            ; there is no carry
                bne     utst_end__bcd__shift_should_shift
                lda     #1      ; force value of a that will serve to write true for any passing test
                ldx     #UTST_FLAG__result_bcd__shift_should_set_a_to_0
                sta     ,x
                ; -- verify b
                cmpb    #6
                bne     utst_end__bcd__shift_should_shift
                ldx     #UTST_FLAG__result_bcd__shift_should_not_change_b
                sta     ,x
                ; -- verify y
                leay    -6,y
                cmpy    #UTST_BUF__bcd_string_1
                bne     utst_end__bcd__shift_should_shift
                ldx     #UTST_FLAG__result_bcd__shift_should_point_to_first_used_bcd_digit
                sta     ,x
                ; -- verify content
                leay    6,y
                ldd     ,y
                cmpd    #$0301
                bne     utst_end__bcd__shift_should_shift
                lda     #1
                ldx     #UTST_FLAG__result_bcd__shift_should_shift
                sta     ,x

utst_end__bcd__shift_should_shift
                ; dump final state
                ldy     #$420
                jsr     dump_buffer
                ; done
thats_my_buffer
                rts


** # Buffer for the routine
UTST_BUF__bcd_string_1 rmb 8    ; up to 24-bits integers
UTST_FLAG__result_bcd__shift_should_set_a_to_0 fcb 0
UTST_FLAG__result_bcd__shift_should_not_change_b fcb 0
UTST_FLAG__result_bcd__shift_should_point_to_first_used_bcd_digit fcb 0
UTST_FLAG__result_bcd__shift_should_shift fcb 0

** dump buffer in the ascii memory
** @reg y MUST be initialized to the target memory
dump_buffer
                ldx     #UTST_BUF__bcd_string_1
                ; copy bcd string
                lda     ,x+
                adda    #$30
                sta     ,y+
                lda     ,x+
                adda    #$30
                sta     ,y+
                lda     ,x+
                adda    #$30
                sta     ,y+
                lda     ,x+
                adda    #$30
                sta     ,y+
                lda     ,x+
                adda    #$30
                sta     ,y+
                lda     ,x+
                adda    #$30
                sta     ,y+
                lda     ,x+
                adda    #$30
                sta     ,y+
                lda     ,x+
                adda    #$30
                sta     ,y+
                ; copy flags and add spaces
                lda     #$20
                sta     ,y+
                lda     ,x+
                adda    #$30
                sta     ,y+
                lda     #$20
                sta     ,y+
                lda     ,x+
                adda    #$30
                sta     ,y+
                lda     #$20
                sta     ,y+
                lda     ,x+
                adda    #$30
                sta     ,y+
                lda     #$20
                sta     ,y+
                lda     ,x+
                adda    #$30
                sta     ,y+
                lda     #$20
                sta     ,y+
                ; done
                rts

** _brief Left shift the string of bcd

** ## Synopsys

** void bcd__shift(nb_bcd_digit, &ptr_bcd_digit_top, &bit_in)

** ## Parameters

** * _reg b 	nb_bcd_digit 		SIGNED, max number of bcd digit
** * _reg y 	ptr_bcd_digit_top 	pointer to the top bcd digit string
** * _reg a 	bit_in 			MUST be 0 or 1 ; bit to be injected at the right

** ## Side effects

** * _reg y  	pointer to the first used digit of the bcd string
** * _reg a	carry bit of the operation

** ## Noteworthy

** **If the processing reach address 0, the last processed bcd digit will be at address 1.**

bcd__shift__b_y_a
                ; (note)
                ; seems I cannot verify that y >= b
                ; only a an b are checked beforehand
                ; y MUST be checked in the body of the routine

                anda    #1      ; sanity -- only keep the first bit of a
                tstb            ; **avoid buffer underflow** caused by b <= 0
                bgt     UNSANITIZED__bcd__shift_b_y_a
                rts             ; **UNSANE** early return
UNSANITIZED__bcd__shift_b_y_a   ; you MUST swear that you have sanitized _reg a and _reg b yourself

                pshs    b       ; backup b for rts
                pshs    b       ; store local count of remaining bcd digit
                ldb     ,y      ; b = first bcd digit

                bpl     _begin_shifting ; first digit already in use

                sta     ,y      ; a blank bcd string will just receive _reg a
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


