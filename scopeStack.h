#ifndef SCOPESTACK_H
#define SCOPESTACK_H

#include "symbolTable.h"

void push();
int pop();
int getCurrentScope();
int getGlobalLevel();
void increaseGlobalLevel();
void printSymbolTable();

#endif /* SCOPESTACK_H */
