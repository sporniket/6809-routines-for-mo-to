** @brief Copy bytes from bottom to top, size <= 256 (1 byte)
**
** A general purpose copy. No stack blasting.

** ## Synopsys

** void memcpy__fwd_short(from, &to, &length)

** ## Parameters

** * @reg y  from    pointer to the bottom of the source area
** * @reg x  to      pointer to the bottom of the destination area
** * @reg a  length  number of bytes to copy, **0 MEANS 256 BYTES**

** ## Side effects

** * @reg x  pointer to just after the last byte moved
** * @reg a  number of bytes left uncopied ; 0 means a full copy.

** ## Noteworthy

** **If @reg x reach 0, the copy stops.**

memcpy__fwd_short__y_x_a
 pshs b,y,u ; no side effects on those
 tfr x,y ; backup of x to perform comparisons
 tfr a,b ; backup of a for multiple uses
 tsta
 beq _check_full_range ; 0 means 256 here
 abx ; Use abx because it is unsigned
 cmpx y ; Requires (x + a) > y
 bvc _no_limit
 bra _find_range
_check_full_range
 leax 256,x
 cmpx y ; Requires (x + a) > y
 bvs _find_range
_no_limit ; we can perform the whole transfert as requested
 tfr b,a ; restore disturbed values
 tfr y,x
 puls b,y,u ; restore now because of next hidden return
 bra UNCHECKED_memcpy__fwd_short__y_x_a ; hidden return, save one RTS by jumping
_find_range ; we need to stop the tranfert after copying to $ffff
 ; at this point, 0 <= x <= 255 and is the number of bytes that WILL NOT be copied 
 tfr x,a
 pshs a ; backup for the return
 subb a ; b = effective number of bytes to copy
 tfr b,a ; a is ready
 tfr y,x ; restore x, x is ready
 bsr UNCHECKED_memcpy__fwd_short__y_x_a
 ; at this point, the stack contains (a) followed by (b,y,u)
 ; seems we can restore all of that with one go + return
 puls a,b,y,u,pc ; return

** @brief Copy bytes from bottom to top, size <= 256 (1 byte)
**
** A general purpose copy. No stack blasting.
** **NO BOUNDARY CHECKS, NO OVERLAP CHECKS.**
** **SWEAR THAT YOU DID THOSE CHECKS YOURSELF**

** ## Synopsys

** void memcpy__fwd_short(from, &to, &length)

** ## Parameters

** * @reg y  from    pointer to the bottom of the source area
** * @reg x  to      pointer to the bottom of the destination area
** * @reg a  length  number of bytes to copy, **0 MEANS 256 BYTES**

** ## Side effects

** * @reg x  pointer to just after the last byte moved
** * @reg a  number of bytes left uncopied ; 0 means a full copy.
UNCHECKED_memcpy__fwd_short__y_x_a ; SWEAR that you did appropriate checks yourself
 pshs y,u ; no side effects on y, u ; b untouched
 tsta
 beq _full_pipeline_full_range
 cmpa #16
 blt _partial_pipeline
 bra _full_pipeline
_full_pipeline_full_range ; the first iterattion of 8 unrolled transfers of 2 bytes.
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ; We do not need to test `a` (zero) to continue
 ; Instead we set up `a` to the correct value (256 - 16 = 240)
 lda #240 
_full_pipeline ; 8 unrolled transfers of 2 bytes.
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 ldu ,y++
 stu ,x++
 ;
 suba #16
 beq _done_copying
 cmpa #16
 bhs _full_pipeline
_partial_pipeline ; at most 7 transferts of 2 bytes and 1 transfert of a single byte
 ldu ,y++
 stu ,x++
 ;
 suba #2
 beq _done_copying
 cmpa #2
 bhs _partial_pipeline
 ; last byte to copy
 lda ,y+
 sta ,x+
 lda #0
_done_copying
 puls y,u,pc ; return
