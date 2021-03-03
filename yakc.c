#include "yaku.h"
#include "yakk.h"
#include "clib.h"

#define DONT_SAVE_CONTEXT 0
#define SAVE_CONTEXT 1
#define NUM_REGISTERS 18


int Running;

TCBptr TaskToSave; // Used by x86 dispatcher to save the current stackptr. See yaks.s YKSaveContext for details.
TCBptr RunningTask;
TCBptr YKRdyList;		/* a list of TCBs of all ready tasks

				   in order of decreasing priority */
TCBptr YKSuspList;		/* tasks delayed or suspended */
TCBptr YKAvailTCBList;		/* a list of available TCBs */
TCB    YKTCBArray[MAX_TASKS+1];	/* array to allocate all needed TCBs
				   (extra one is for the idle task) */

int IdleStk[IDLE_STACK_SIZE];

unsigned int YKCtxSwCount;
unsigned int YKIdleCount;
unsigned int YKTickNum;

unsigned int NestingLevel;


#ifdef SEMAPHORE
unsigned int YKSemAvailCount = MAX_SEMAPHORES;
#endif
#ifdef MESSAGING
unsigned int YKQAvailCount = MAX_MESSAGE_QUEUES;
#endif
#ifdef YKEvent
unsigned int YKEventAvailCount = MAX_EVENTS;
#endif


#define BIGGER_FIRST >
#define COMPARE_PRIORITY(x,y) (x BIGGER_FIRST y)
//=========================================================================
// Priority Queue Implementation
// using a linked list
//? Say we have nodes A B D and insert node C
void queue_insertNode(TCBptr* queue, TCBptr node) {
    TCBptr head;
    if ( (*queue) == NULL)
    {
      (*queue) = node;
      // node->prev = NULL;
      node->next = NULL;
      return;
    }
    //special case, the new node has a higher Priority
    // exit early replace the queue's head with the new node
    if (node->priority < (*queue)->priority)
    {
        // node->prev = NULL;    //soon to be new head's Prev = NULL
        //(*queue)->prev = node; //Old Head's Prev = new Head

        node->next = (*queue); //new Head's->next = Old Head
        (*queue) = node;       //Head = new Head
        return;                //node inserted, finish early
    }

    // Highest priority task has been checked.
    // moving on to the next task in the line
    head = (*queue);
    while (head->next != NULL && !(node->priority < head->next->priority ))
    {
        head = head->next;
    }
    // head's next node is either NULL, or has a lower priority
    // (head->next)->prev = node;  // D->prev = C
    node->next = head->next;    // C->next = D
    // node->prev = head;          // C->prev = B
    head->next = node;          // B->next = C
}

TCBptr queue_pop(TCBptr* queue) {
    TCBptr tmp = (*queue);     // A
    (*queue) = (*queue)->next; // Head = B
    // queue->prev = NULL;     // B->prev = NULL;
    return tmp;                // return A
}
//=========================================================================

//=========================================================================
// DEBUG CODE
// Iterates through a queue starting at the highest Priority item
void printQueue(TCBptr queue) {
    while (queue != NULL)
    {
        printString("Task: ");
        printInt(queue->taskNumber);
        printChar(' ');
        printInt(queue->priority);
        printNewLine();
        queue = queue->next;
    }
}
//===========================================================================

//===========================================================================
//                           YAK specific code
//---------------------------------------------------------------------------


// Starts the next task
void YKScheduler(void) {
    // If the currently running task has the highest priority;
    // Do not need to save contex or anything like that.
    YKEnterMutex();
    if (YKRdyList == RunningTask)
    {
        YKExitMutex();
        return;
    }
    TaskToSave = RunningTask;
    RunningTask = YKRdyList;

    YKCtxSwCount++;
    YKDispatcher(SAVE_CONTEXT);   // setup runtime environment for new task
}


// Used to calculate the amount of time the kernal is idle.
void YKIdleTask(void) {
    while(1){
        YKEnterMutex();
        YKIdleCount++;
        YKExitMutex();
    }
}

void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority) {
    // Temp vars to insert new task
    TCBptr temp;
    int i;
    int* tmpStackPointer;
    static int TaskNumber = 0;

    // Disable interupts;
    YKEnterMutex();

    // Get an available TCB
    tmpStackPointer = (int*)taskStack-1;
    //Don't know what flags should be initalised at
    --tmpStackPointer;  //Space for flags
    (*tmpStackPointer) = 0; //CS register initialised to zero
    --tmpStackPointer;
    (*tmpStackPointer) = (int)task; // IP
    --tmpStackPointer;
    (*tmpStackPointer) = (int)taskStack-1; // BP
    for (i=0; i < 8; i++)
    {
      --tmpStackPointer;
      (*tmpStackPointer) = 0;
    }

    temp = YKAvailTCBList;
    YKAvailTCBList = YKAvailTCBList->next;
    // Init variables
    temp->stackptr = (void*) (tmpStackPointer);
    temp->priority = priority;
    temp->state = 0;
    temp->delay = 0;
    #ifdef DEBUG_MODE
    printString("Creating Task: ");
    printInt(TaskNumber);
    printNewLine();
    temp->taskNumber = TaskNumber++;
    #endif
    // Put task address at stack
    queue_insertNode(&YKRdyList, temp);
    #if (defined DEBUG_MODE) && (defined VERBOSE)
    printQueue(YKRdyList);
    #endif
    if(Running) {
        YKScheduler();
    }

    YKExitMutex();
    //interupts reenabled.
}

void YKInitialize(void) {
    int i;
    // construct available TCB list
    Running = 0;
    // init variables
    YKIdleCount = 0;
    YKCtxSwCount = 0;
    YKTickNum = 0;
    NestingLevel = 0;
    YKSuspList = NULL;

    YKAvailTCBList = &(YKTCBArray[0]);
    for (i = 0; i < MAX_TASKS; i++)
	    YKTCBArray[i].next = &(YKTCBArray[i+1]);
    YKTCBArray[MAX_TASKS].next = NULL;
    // create idle task
    YKNewTask(YKIdleTask, (void *)&IdleStk[IDLE_STACK_SIZE], 100);
    RunningTask = YKRdyList;
}

void YKRun(void) {
    Running = 1;
    YKCtxSwCount++;
    RunningTask = YKRdyList;
    YKDispatcher(DONT_SAVE_CONTEXT);
}

void YKDelayTask(unsigned count) {
    TCBptr temp;
    YKEnterMutex();
    #if (defined DEBUG_MODE) && (defined VERBOSE)
    printString("Delaying Task: ");
    printInt(YKRdyList->taskNumber);
    printNewLine();
    #endif
    temp = queue_pop(&YKRdyList); // Remove it from the ready list
    temp->delay = count;

    // Delay task uses a doubly linked stack
    temp->prev = NULL;
    if (YKSuspList != NULL)
        YKSuspList->prev = temp;
    temp->next = YKSuspList;
    YKSuspList = temp;
    YKScheduler();
    YKExitMutex();
}

//Called by an interupt to clock
// YKScheduler will be called by YKExitISR.
void YKTickHandler() {
    TCBptr temp, next;
    YKEnterMutex();
    YKTickNum++;
    temp = YKSuspList;
    while (temp != NULL)
    {
        temp->delay--;
        if (temp->delay == 0)
        {
            #ifdef VERBOSE
            printString("Task Ready! ");
            printInt(temp->taskNumber);
            printChar(' ');
            printInt(temp->prev);
            printChar(' ');
            printInt(temp->next);
            printNewLine();
            #endif
            next = temp->next;
            next->prev = temp->prev;
            temp->prev->next = next;
            queue_insertNode(&YKRdyList, temp);
            if (temp == YKSuspList)
                YKSuspList = next;
            temp = next;
        }
        else
        {
            temp = temp->next;
        }
    }
    YKExitMutex();
}

void YKEnterISR() {
    NestingLevel++;
}

void YKExitISR() {
    NestingLevel--;
    // Should only call YKScheduler once all interupts have been handled.
    if (NestingLevel == 0 && Running) {
        YKScheduler();
    }
}

//-----------------------------------------------------------------------------
//============================================================================

//=======================================================
//              Semaphore Flag
//    Semaphores should always be claimed and released in
//    the same order to prevent deadlock.
//    (Claim A, than B. Never claim B than A)
//-------------------------------------------------------
#ifdef SEMAPHORE
YKSEM YKSemaphores[MAX_SEMAPHORES];

YKSEM* YKSemCreate (int initialValue) {
    YKSEM* semaphore;
    YKEnterMutex();
    if (YKSemAvailCount <= 0)
    {
        YKExitMutex();
        printString("Not enough semaphores");
        exit(0xff);
    } //ELSE
    YKSemAvailCount--;
    semaphore = &YKSemaphores[YKSemAvailCount];
    semaphore->value = initialValue;
    semaphore->blockedOn = NULL;
    YKExitMutex();
    return semaphore;
}
void YKSemPend(YKSEM *semaphore) {
    TCBptr temp;
    YKEnterMutex();
    if (semaphore->value-- > 0){
    // Semaphore claimable.
        YKExitMutex();
        return;
    }
    // Semaphore busy:
    temp = queue_pop(&YKRdyList);
    queue_insertNode(&semaphore->blockedOn, temp);
    YKScheduler();
    YKExitMutex();
}

// Can be called by an interupt, potentially.
void YKSemPost(YKSEM *semaphore) {
    TCBptr temp;
    YKEnterMutex();
    if (semaphore->value++ >= 0)
    {
        // Nothing is waiting on the semaphore.
        YKExitMutex();
        return;
    }
    // Remove top of blocked tasks.
    if (semaphore->blockedOn != NULL)
    {
        temp = queue_pop(&semaphore->blockedOn);
        semaphore->blockedOn = temp->next;
        // Insert removed task to ready list;
        queue_insertNode(&YKRdyList, temp);
        if (NestingLevel == 0)
        {
            YKScheduler();
        }
    }
    YKExitMutex();
}
#endif
//-------------------------------------------------------
//=======================================================



//=======================================================
//          Message Queue
// Implemented here using a ring buffer to store messages;

//-------------------------------------------------------
#ifdef MESSAGING
YKQ YKQueues[MAX_MESSAGE_QUEUES];

YKQ* YKQCreate(void **start, unsigned size) {
    YKQ* newlyCreated;
    YKEnterMutex();
    if (YKQAvailCount <= 0)
    {
        YKExitMutex();
        printString("Too many message queues created. Allocate more space\n");
        exit(0xff);
    }
    YKQAvailCount--;
    newlyCreated = &YKQueues[YKQAvailCount];
    newlyCreated->messages = start;
    newlyCreated->size = size;
    newlyCreated->head = 0;
    newlyCreated->tail = 0;
    newlyCreated->blockedOn = NULL;
    newlyCreated->numOfMsgs = 0;
    YKExitMutex();
    return newlyCreated;
}

// Remove oldest message from queue, or wait for message;
void* YKQPend(YKQ* messageQueue) {
    void* msg;
    TCBptr temp;
    YKEnterMutex();
    if (messageQueue->numOfMsgs <= 0)
    {
        // Wait for message;
        #if (defined VERBOSE) && (defined DEBUG_YKQ)
        printInt(RunningTask->taskNumber);
        printString(" Waiting On Message\n");
        #endif
        temp = queue_pop(&YKRdyList);
        queue_insertNode(&messageQueue->blockedOn, temp);
        YKScheduler();
    }
    // Will reach here if this is the highest Priority & there is a message to read, YKDispatch will restore mutex when this is called again.
    msg = messageQueue->messages[messageQueue->tail++];

    if (messageQueue->tail >= messageQueue->size)
        messageQueue->tail = 0;
    messageQueue->numOfMsgs--;

    YKExitMutex();
    return msg;
}
//
int YKQPost(YKQ *messageQueue, void *msg) {
    TCBptr temp;
    YKEnterMutex();
    #if (defined VERBOSE) && (defined DEBUG_YKQ)
    printInt(RunningTask->taskNumber);
    printString(" Posted Message\n");
    #endif
    if (messageQueue->numOfMsgs >= messageQueue->size)
    {
        YKExitMutex();
        return POST_MSG_FAIL;
    }
    messageQueue->numOfMsgs++;
    messageQueue->messages[messageQueue->head++] = msg;

    if (messageQueue->head >= messageQueue->size)
        messageQueue->head = 0;

    if (messageQueue->blockedOn != NULL)
    {
        temp = queue_pop(&messageQueue->blockedOn);
        queue_insertNode(&YKRdyList, temp);
        if (NestingLevel == 0)
            YKScheduler();
    }

    YKExitMutex();
    return POST_MSG_SUCCESS;
}
#endif
//--------------------------------------------------------
//========================================================

//========================================================
//                      Events
// -------------------------------------------------------
#ifdef YKEvent

YKEvent YKEvents[MAX_EVENTS];

YKEvent* YKEventCreate(unsigned init) {
    YKEvent* newEvent;
    YKEnterMutex();
    if (YKEventAvailCount <= 0)
    {
        YKExitMutex();
        printString("Not enough Event types allocated\n");
        exit (0xff);
    }
    YKEventAvailCount--;
    newEvent = &YKEvents[YKEventAvailCount];
    newEvent->flags = init;
    newEvent->blockedOn = NULL;
    YKExitMutex();
    return newEvent;
}

inline bool eventCheck(unsigned currentFlags, unsigned conditions, unsigned type)
{
    if (type == EVENT_WAIT_ANY)
    {
        return (bool) currentFlags & conditions;
    }
    return (currentFlags & conditions) == conditions;
}

unsigned YKEventPend(YKEvenet *event, unsigned eventMask, int waitMode) {
    TCBptr temp;

    YKEnterMutex();
    if (!eventCheck(event->flags, eventMask, waitMode))
    {
        temp = queue_pop(&YKRdyList);
        temp->prev = NULL;
        if (event->blockedOn != NULL)
            event->blockedOn->prev = temp;
        temp->next = event->blockedOn;
        event->blockedOn = temp;
        YKScheduler();
    }

    YKExitMutex();
    return event->flags;
}

// Can only set flags. Cannot lower them.
void YKEventSet(YKEvent *event, unsigned eventMask) {
    TCBptr temp, next;
    YKEnterMutex();
    // Check if new events cause flags to change.
    // No change == no need to check.
    if (event->flags | eventMask == event->flags)
    {
        YKExitMutex();
        return;
    } // ELSE:
    event->flags |= eventMask;
    temp = event->blockedOn;
    while (temp != NULL)
    {
        if (eventCheck(event->flags, temp->flags, temp->state ))
        {
            next = temp->next;
            next->prev = temp->prev;
            temp->prev->next = next;
            queue_insertNode(&YKRdyList, temp);
            if (temp == event->blockedOn)
                event->blockedOn = next;
            temp = next;
        }
    }
    YKScheduler();
    YKExitMutex();
}

// Can only lower flags cannot raise them.
// YAK Kernal, tasks only unblock when a flag raises.
// Therefore this does nothing save lower flags.
// It cannot cause new events to occur.
// Inverting the event masks to reset,
// Has no effect on current flags that are not in the event mask.
void YKEventReset(YKEvent *event, unsigned eventMask) {
    YKEnterMutex();
    eventMask = ~eventMask;
    event->flags &= eventMask;
    YKExitMutex();
}
#endif
//--------------------------------------------------------
//========================================================
