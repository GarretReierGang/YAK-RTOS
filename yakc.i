# 1 "yakc.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "yakc.c"
# 1 "yaku.h" 1
# 2 "yakc.c" 2
# 1 "yakk.h" 1



extern int YKCtxSwCount;
extern int YKIdleCount;
extern int YKTickNum;

void YKInitialize(void);
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
# 3 "yakc.c" 2
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
# 4 "yakc.c" 2



typedef struct taskblock *TCBptr;
typedef struct taskblock
{
    void *stackptr;
    int state;
    int priority;
    int delay;
    TCBptr next;
    TCBptr prev;
} TCB;

void* savePointer;
void* restorePointer;
int running;

TCBptr runningTask;
TCBptr YKRdyList;

TCBptr YKSuspList;
TCBptr YKAvailTCBList;
TCB YKTCBArray[5 +1];


int IdleStk[256];

int YKCtxSwCount;
int YKIdleCount;
int YKTickNum;






void queue_insertNode(TCBptr* queue, TCBptr node)
{
  TCBptr head;
  if ( (*queue) == 0)
  {
      (*queue) = node;
      node->prev = 0;
      node->next = 0;
      return;
  }


  if (node->priority < (*queue)->priority)
  {
    node->prev = 0;
    (*queue)->prev = node;

    node->next = (*queue);
    (*queue) = node;
    return;
  }



  head = (*queue)->next;

  while (head->next != 0 && !(node->priority < head->next->priority ))
  {
    head = head->next;
  }

  (head->next)->prev = node;
  node->next = head->next;
  node->prev = head;
  head->next = node;
}

TCBptr queue_pop(TCBptr* queue)
{
  TCBptr tmp = (*queue);
  (*queue) = (*queue)->next;
  (*queue)->prev = 0;
  return tmp;
}



void printQueue(TCBptr queue)
{
  while (queue != 0)
  {
    printInt(queue->priority);
    queue = queue->next;
  }
}



void YKScheduler(void) {


  if (YKRdyList == runningTask)
  {
    return;
  }
  savePointer = runningTask->stackptr;
  runningTask = YKRdyList;
  restorePointer = runningTask->stackptr;
  YKCtxSwCount++;
  YKDispatcher(1);
}


void YKIdleTask(void) {
    while(1){
        YKIdleCount++;
    }
}

void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority) {

    TCBptr temp, temp2;
    int i;
    int* tmpStackPointer;

    tmpStackPointer = (int*)taskStack-1;

    --tmpStackPointer;
    (*tmpStackPointer) = 0;
    --tmpStackPointer;
    (*tmpStackPointer) = (int)task;
    --tmpStackPointer;
    (*tmpStackPointer) = (int)taskStack-1;
    for (i=0; i < 8; i++)
    {
      --tmpStackPointer;
      (*tmpStackPointer) = 0;
    }

    temp = YKAvailTCBList;
    YKAvailTCBList = YKAvailTCBList->next;

    temp->stackptr = (void*) (tmpStackPointer);
    temp->priority = priority;
    temp->state = 0;
    temp->delay = 0;


    queue_insertNode(&YKRdyList, temp);
    if(running) {
        YKScheduler();
    }
}

void YKInitialize(void) {
    int i;

    running = 0;
    YKAvailTCBList = &(YKTCBArray[0]);
    for (i = 0; i < 5; i++)
     YKTCBArray[i].next = &(YKTCBArray[i+1]);
    YKTCBArray[5].next = 0;

    YKNewTask(YKIdleTask, (void *)&IdleStk[256], 100);

    YKIdleCount = 0;
    YKCtxSwCount = 0;
    YKTickNum = 0;
    runningTask = YKRdyList;
}

void YKRun(void) {
    running = 1;
    YKCtxSwCount++;
    runningTask = YKRdyList;
    restorePointer = runningTask->stackptr;
    YKDispatcher(0);
}
