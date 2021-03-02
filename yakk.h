#ifndef YAKK_H
#define YAKK_H

extern int YKCtxSwCount;
extern int YKIdleCount;
extern int YKTickNum;

typedef struct taskblock *TCBptr;
typedef struct taskblock
{				/* the TCB struct definition */
    void *stackptr;		/* pointer to top of tasks operating Stack */
    int state;          /* What the task is doing */
    unsigned flags;     /* Event Flags this task is currently waiting for*/
    int priority;		/* current priority */
    int delay;			/* #ticks yet to wait */
    TCBptr next;		/* ptr to next Task in queue */
    TCBptr prev;		/* ptr to previous task in the stack */
}  TCB;




void YKInitialize(void);
// YAK uses a priority rank system (lower goes before higher)
// Default priority for idle task is 100.
void YKNewTask(void (* task)(void),
                void *taskStack,
                unsigned char priority);
void YKRun(void);
void YKDelayTask(unsigned count);
void YKEnterMutex(void);
void YKExitMutex(void);
void YKEnterISR(void);
void YKExitISR(void);
void YKScheduler(void);
void YKDispatcher(int saveContext);
void YKTickHandler(void);
void YKIdleTask(void);
void YKSaveContext(void);

//=======================================================
//              Semaphore Flag
//    Semaphores should always be claimed and released in
//    the same order to prevent deadlock.
//    (Claim A, than B. Never claim B than A)
//-------------------------------------------------------
typedef struct sem YKSem {
  int value;
  TCBptr blockedOn;
};
YKSem* YKSemCreate (int initialValue);
void YKSemPend(YKSem *semaphore); // Claim flag
void YKSemPost(YKSem *semaphore); // Release flag
//-------------------------------------------------------
//=======================================================

//=======================================================
//          Message Queue
// Slower and more complicated than semaphore,
// Allows more complicated messages to be exchanged.
//-------------------------------------------------------
typedef struct ykq
{
  void ** messages;
  unsigned size;
  unsigned head;
  unsigned tail;
  TCBptr blockedOn;
  int numOfMsgs;
} YKQ;
// Preallocated storage; number of messages;
YKQ* YKQCreate(void **start, unsigned size);
// Remove oldest message from queue, or wait for message;
void* YKQPend(YKQ *queue);
//
int YKQPost(YKQ *queue, void *msg);
//--------------------------------------------------------
//========================================================

//=======================================================================
//  Events, slower and more complicated to process than a semaphore
//
//-----------------------------------------------------------------------
typedef struct eventGroup {
  unsigned flags;
  TCBptr waitingOn;
} YKEvent;

YKEvent* YKEventCreate(unsigned init);
unsigned YKEventPend(YKEvenet *event, unsigned eventMask, int waitMode);
void YKEventSet(YKEvent *event, unsigned eventMask);
void YKEventReset(YKEvent *event, unsigned eventMask);
//------------------------------------------------------------------------
//========================================================================



#endif
