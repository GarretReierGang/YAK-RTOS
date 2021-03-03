#include "clib.h"
#include "yakk.h"

extern int KeyBuffer;

void reset_handler() {
	exit(0);
}

void tick_handler() {
	static int tick_num = 0;
	tick_num++;
	printNewLine();
	printString("TICK ");
	printInt(tick_num);
	printNewLine();
    YKTickHandler();
}

void keyboard_handler() {
	int asdfasdf = 0;
	if(KeyBuffer == 100) {
		printNewLine();
		printString("DELAY KEY PRESSED");
		printNewLine();
		while(asdfasdf < 5000)
			asdfasdf++;

		printNewLine();
		printString("DELAY COMPLETE");
		printNewLine();
		return;
	}
}
