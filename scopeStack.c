#include <stdio.h>
#include "scopeStack.h"

int scopeStack[100];
int scopeStackTop = 0;

void push(int num, int currentScope) {
	if (scopeStackTop<100) {
		scopeStack[scopeStackTop] = num;
		scopeStackTop++;
	        setParent(num, currentScope);
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
