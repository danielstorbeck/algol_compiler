#include <stdio.h>
#include "scopeStack.h"

int scopeStack[100];
int scopeStackTop = 0;
int globalLevel = 0;

void push() {
  int currentScope = getCurrentScope();
	if (scopeStackTop<100) {
		scopeStack[scopeStackTop] = globalLevel;
		scopeStackTop++;
	        setParent(globalLevel, currentScope);
	}
	else {
		printf("error: Scope stack overflow\n");
	}
}

int pop() {
	if (scopeStackTop) {
		scopeStackTop--;
		return scopeStack[scopeStackTop];
	}
	else {
		return -1;
	}
}

int getCurrentScope() {
  return scopeStack[scopeStackTop - 1];
}

int getGlobalLevel() {
  return globalLevel;
}

void increaseGlobalLevel() {
  globalLevel++;
}

void printSymbolTable() {
  int i;
  for(i=0; i <= globalLevel; i++){
    symbolTableDisplay(i);
  }
}  
