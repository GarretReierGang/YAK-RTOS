# 1 "my_isrh.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "my_isrh.c"
# 1 "clib.h" 1




void print(char *string, int length);
void printNewLine(void);
void printChar(char c);
void printString(char *string);


void printInt(int val);
void printLong(long val);
void printUInt(unsigned val);
void printULong(unsigned long val);


void printByte(char val);
void printWord(int val);
void printDWord(long val);


void exit(unsigned char code);


void signalEOI(void);
# 2 "my_isrh.c" 2

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
 printNewLine();
 printString("KEYPRESS (");
 printChar(KeyBuffer);
 printString(") IGNORED");
 printNewLine();
}
