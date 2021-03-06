/*
File: lab6inth.c
Revision date: 4 November 2009
Description: Sample interrupt handler code for EE 425 lab 6 (Message queues)
*/

#include "lab7defs.h"
#include "yakk.h"
#include "clib.h"
extern int KeyBuffer;


void tickHandler(void)
{
    YKTickHandler();
}

void keyboardHandler(void)
{
    char c;
    c = KeyBuffer;

    if(c == 'a') YKEventSet(charEvent, EVENT_A_KEY);
    else if(c == 'b')
        YKEventSet(charEvent, EVENT_B_KEY);
    else if(c == 'c')
        YKEventSet(charEvent, EVENT_C_KEY);
    else if(c == 'd')
        YKEventSet(charEvent, EVENT_A_KEY | EVENT_B_KEY | EVENT_C_KEY);
    else if(c == '1') YKEventSet(numEvent, EVENT_1_KEY);
    else if(c == '2')
        YKEventSet(numEvent, EVENT_2_KEY);
    else if(c == '3')
        YKEventSet(numEvent, EVENT_3_KEY);
    else {
        print("\nKEYPRESS (", 11);
        printChar(c);
        print(") IGNORED\n", 10);
    }
}
