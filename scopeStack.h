#ifndef SCOPESTACK_H
#define SCOPESTACK_H

#include "symbolTable.h"

void push(int, int);
int pop();
int getCurrentScope();

#endif /* SCOPESTACK_H */
