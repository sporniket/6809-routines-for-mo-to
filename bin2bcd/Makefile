
.PHONY: clean

clean:
	rm zz_*

zz_test__bcd_shift.s: bcd_shift__tests.s bcd_shift.s
	spasm_pp $^ > $@

