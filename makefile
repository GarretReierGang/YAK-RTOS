final.bin: final.s
	nasm final.s -o final.bin -l final.lst

final.s: clib.s my_isr.s my_isrh.s yakc.s yaks.s lab4b_app.s
	cat $^ > $@


my_isrh.s: my_isrh.c
	cpp $^ my_isrh.i
	c86 my_isrh.i $@

yakc.s: yakc.c
	cpp $^ yakc.i
	c86 yakc.i $@

lab4b_app.s: lab4b_app.c
	cpp $^ lab4b_app.i
	c86 lab4b_app.i $@

.PHONY: clean

clean:
	rm -f my_isrh.i my_isrh.s yakc.i yakc.s lab4b_app.i lab4b_app.s final.s final.bin final.lst
