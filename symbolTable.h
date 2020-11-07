#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <stdbool.h>
#include <string.h>

typedef struct Symbol {
	char *lexeme;
	int token;
	int value;
	float realValue;
	int type;
	bool boolean;
	int offset;
	int dim;
	int procNumParam;
	int lowerBound[20];
	int upperBound[20]; 
	struct Symbol *next;
} Symbol;
	
typedef struct SymbolTable {
	Symbol *head;
	Symbol *currentSymbol;
	Symbol *tail;
	int parent;
	int arrayOffset;
	int currentOffset;
	int newTempOffset;
} SymbolTable;

void initializeSymbolTable();
int getNewLabel();
Symbol* lookUp(char *lexm,int scope);
Symbol* lookUpInCurrentScope(char *lexm, int scope);
Symbol* addEntry(char *lexm, int scope);

void symbolTableDisplay(int scope);

int getNewTempOffset();
int getArrayOffset();
void setArrayOffset(int idx, int offset);
int getCurrentOffset(int idx);
void setCurrentOffset(int idx, int offset);

void pushScope();
int popScope();
int getCurrentScope();
int getGlobalLevel();
void increaseGlobalLevel();
void printSymbolTable();

#endif /* SYMBOLTABLE_H */
