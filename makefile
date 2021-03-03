
a.bin: lab5.s #a.bin for easier testing of program
	nasm $^ -o a.bin -l a.lst

lab5.bin: lab5.s
	nasm lab5.s -o lab5.bin -l lab5.lst
lab5.s: clib.s my_isr.s my_isrh.s yakc.s yaks.s lab5_app.s
	cat $^ > $@
lab5_app.s: lab5_app.c
	cpp $^ lab5_app.i
	c86 lab5_app.i $@


lab4d.bin: lab4d.s
	nasm lab4d.s -o lab4d.bin -l lab4d.lst
lab4d.s: clib.s my_isr.s my_isrh.s yakc.s yaks.s lab4d_app.s
	cat $^ > $@
lab4d_app.s: lab4d_app.c
	cpp $^ lab4d_app.i
	c86 lab4d_app.i $@
lab4c.bin: lab4c.s
	nasm lab4c.s -o lab4c.bin -l lab4c.lst

lab4c.s: clib.s my_isr.s my_isrh.s yakc.s yaks.s lab4c_app.s
	cat $^ > $@

lab4c_app.s: lab4c_app.c
	cpp $^ lab4c_app.i
	c86 lab4c_app.i $@

lab4b.bin: lab4b.s
	nasm lab4b.s -o lab4b.bin -l lab4b.lst

lab4b.s: clib.s my_isr.s my_isrh.s yakc.s yaks.s lab4b_app.s
	cat $^ > $@

lab4b_app.s: lab4b_app.c
	cpp $^ lab4b_app.i
	c86 lab4b_app.i $@

my_isrh.s: my_isrh.c
	cpp $^ my_isrh.i
	c86 my_isrh.i $@

yakc.s: yakc.c
	cpp $^ yakc.i
	c86 yakc.i $@

all: lab4b.bin lab4c.bin lab4d.bin lab5.bin a.bin


.PHONY: clean

BIN := $(wildcard *.bin)
CFiles := $(wildcard *.c)
DeleteI := $(patsubst %.c, %.i,$(CFiles))
DeleteS := $(patsubst %.c, %.s,$(CFiles))
DeleteFinalS := $(patsubst %.bin, %.s, $(BIN))

clean:
	rm -f $(DeleteI) $(DeleteS) $(DeleteFinalS) *.bin *.lst
#	rm -f my_isrh.i my_isrh.s yakc.i yakc.s lab4b_app.i lab4b_app.s final.s final.bin final.lst
