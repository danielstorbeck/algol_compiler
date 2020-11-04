#include <stddef.h>
#include "symbolTable.h"
#include "tree.h"

SymbolTable symbolTable[1000];
int scopeStack[100];
int scopeStackTop = 0;
int globalLevel = 0;

Symbol* lookUp(char *lexm,int scope){
  Symbol *symbolEntry = symbolTable[scope].head;
  while (symbolEntry!=NULL) {
    if (strcmp(lexm, symbolEntry->lexeme) == 0) {
      return symbolEntry;
    }
    else {
      symbolEntry = symbolEntry->next;
    }
  }
  if(scope==0){
    //printf("error:%s not found in scope %d, \n", scope,lexm);
    return NULL;
  }
  else{
    return lookUp(lexm,symbolTable[scope].parent);
  }
}

Symbol* lookUpInCurrentScope(char *lexm, int scope){
  Symbol* symbolEntry = symbolTable[scope].head;
  while(symbolEntry != NULL){
    if(strcmp(lexm,symbolEntry->lexeme)==0){
      return symbolEntry;
    }
    else 
      symbolEntry = symbolEntry->next; 
  }
  return NULL;
}

Symbol* addEntry(char *lexm, int scope){
  //symbolTableDisplay(scope);
  Symbol *symbolEntry = symbolTable[scope].head;
  if(symbolEntry == NULL){
    Symbol *newNodeEntry = (Symbol*)malloc(sizeof(Symbol));
    newNodeEntry->lexeme = malloc(strlen(lexm)+1);
    strcpy(newNodeEntry->lexeme, lexm);
    newNodeEntry->token = TOKEN_ID;
    symbolTable[scope].head = newNodeEntry;
    symbolTable[scope].head->next = symbolTable[scope].tail;
    symbolTable[scope].currentSymbol = symbolTable[scope].head;
    return newNodeEntry;
  }
  Symbol *newNodeEntry = (Symbol*)malloc(sizeof(Symbol));
  newNodeEntry->lexeme = malloc(strlen(lexm)+1);
  strcpy(newNodeEntry->lexeme, lexm);
  newNodeEntry->token = TOKEN_ID;
  symbolTable[scope].tail = newNodeEntry;
  symbolTable[scope].tail = symbolTable[scope].tail->next;
  symbolTable[scope].currentSymbol->next = newNodeEntry;
  symbolTable[scope].currentSymbol = newNodeEntry;
  //symbolTableDisplay(scope);
  return newNodeEntry;
}

void symbolTableDisplay(int scope){
  Symbol *entry = symbolTable[scope].head;
  int i;
  printf("Symbol Table Scope %d\n",scope);
  while (entry !=NULL){
    if (entry->lexeme != NULL)
      printf("lexeme: %s\n",entry->lexeme);
    if (&(entry->token) != NULL)
      printf("token :%d\n",entry->token);
    if (entry->value || entry->value==0)
      printf("intValue: %d\n",entry->value);
    if (entry->realValue || entry->realValue==0.0)
      {
        printf("realValue: %f \n",entry->realValue);
      }
    if (&(entry->boolean) != NULL)
      printf("boolean: %d\n",entry->boolean); 
    if (&(entry->dim) != NULL)
      printf("dim: %d\n",entry->dim);
    for(i=0;i<entry->dim;i++){
      printf("lower: %d, upper: %d\n",entry->lowerBound[i],entry->upperBound[i]);
    }
    if (entry->type || entry->type==0)
      printf("type: %d\n",entry->type);
    if (entry->offset || entry->offset==0)
      printf("offset: %d\n",entry->offset);
    entry = entry->next;
  }
}

int getNewTemp(){
  int currentScope = getCurrentScope();
  symbolTable[currentScope].newTempOffset-=4;
  return symbolTable[currentScope].newTempOffset+4;
}

int getArrayOffset(int idx) {
  return symbolTable[idx].arrayOffset;
}

void setArrayOffset(int idx, int offset) {
  symbolTable[idx].arrayOffset = offset;
}

int getCurrentOffset(int idx) {
  return symbolTable[idx].currentOffset;
}

void setCurrentOffset(int idx, int offset) {
  symbolTable[idx].currentOffset = offset;
}

int getNewTempOffset(int idx) {
  return symbolTable[idx].newTempOffset;
}

void setNewTempOffset(int idx, int offset) {
  symbolTable[idx].newTempOffset = offset;
}

void setParent(int idx, int scope) {
  symbolTable[idx].parent = scope;
}

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
