
a.bin: lab7.s #a.bin for easier testing of program
	nasm $^ -o a.bin -l a.lst

lab7.bin: lab7.s
	nasm lab7.s -o lab7.bin -l lab7.lst
lab7.s: clib.s lab6isr.s lab7inth.s yakc.s yaks.s lab7_app.s
	cat $^ > $@
lab7inth.s: lab7inth.c
	cpp $^ lab7inth.i
	c86 lab7inth.i $@
lab7_app.s: lab7_app.c
	cpp $^ lab7_app.i
	c86 lab7_app.i $@

lab6.bin: lab6.s
	nasm lab6.s -o lab6.bin -l lab6.lst
lab6.s: clib.s lab6isr.s lab6inth.s yakc.s yaks.s lab6_app.s
	cat $^ > $@
lab6inth.s: lab6inth.c
	cpp $^ lab6inth.i
	c86 lab6inth.i $@
lab6_app.s: lab6_app.c
	cpp $^ lab6_app.i
	c86 lab6_app.i $@

lab5.bin: lab5.s
	nasm lab5.s -o lab5.bin -l lab5.lst
lab5.s: clib.s my_isr.s lab5inth.s yakc.s yaks.s lab5_app.s
	cat $^ > $@
lab5inth.s: lab5inth.c
	cpp $^ lab5inth.i
	c86 lab5inth.i $@
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

all: lab4b.bin lab4c.bin lab4d.bin lab5.bin lab6.bin a.bin


.PHONY: clean

BIN := $(wildcard *.bin)
CFiles := $(wildcard *.c)
DeleteI := $(patsubst %.c, %.i,$(CFiles))
DeleteS := $(patsubst %.c, %.s,$(CFiles))
DeleteFinalS := $(patsubst %.bin, %.s, $(BIN))

clean:
	rm -f $(DeleteI) $(DeleteS) $(DeleteFinalS) *.bin *.lst
#	rm -f my_isrh.i my_isrh.s yakc.i yakc.s lab4b_app.i lab4b_app.s final.s final.bin final.lst
