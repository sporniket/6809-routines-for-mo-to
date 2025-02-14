** Test suite for bcd__shift__b_y_a
start
** Prepare
                ; fill the test bcd string with value "15"
                ldy     #UTST_BUF__bcd_string_1
                lda     #$80     ; just put unused digits to negative (just set the sign bit, i.e. 0x80)
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
                tsta    ; there is no carry 
                bne     utst_end__bcd__shift_should_shift
                lda     #1 ; force value of a that will serve to write true for any passing test
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
