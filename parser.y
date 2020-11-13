%{

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>
#include "tree.h"
#include "symbolTable.h"

#define YYSTYPE Node *

extern char* yytext;
extern int yylex();
extern int lineNo;
 
int currentGlobalOffset=0;
char code[99999];

void yyerror(const char *str) {
  fprintf(stderr,"parsing error on line %d at token ->%s<-\n", lineNo, yytext);
}

int yywrap() {
        return 1;
}
 
%}

// %define api.value.type {Node *}
%define parse.trace

////////////TOKEN DEFINITIONS/////////////

%token TOKEN_PRINT
%token TOKEN_IDENTIFIER
%token TOKEN_BEGIN 
%token TOKEN_END		
%token TOKEN_LOGICAL_VALUE	
%token TOKEN_OPERATOR 	
%token TOKEN_OR	
%token TOKEN_PROCEDURE  	
%token TOKEN_PLUS		
%token TOKEN_MINUS		
%token TOKEN_DIVIDE		
%token TOKEN_POWER		
%token TOKEN_MULTIPLY		
%token TOKEN_COMMA
%token TOKEN_UNDERSCORE
%token TOKEN_SPECIFIER
%token TOKEN_LIBRARY
%token TOKEN_BRACKET
%token TOKEN_OPEN_BRACKET
%token TOKEN_CLOSE_BRACKET
%token TOKEN_OPEN_SQUARE_BRACKET
%token TOKEN_CLOSE_SQUARE_BRACKET
%token TOKEN_OPEN_CURLY_BRACKET                  //added support for belu curly brackets
%token TOKEN_CLOSE_CURLY_BRACKET		//belup
%token TOKEN_CONTINUE	
%token TOKEN_REAL_NUM		
%token TOKEN_INTEGER	
%token TOKEN_COLON		
%token TOKEN_REL_OP
%token TOKEN_LESS_EQUAL
%token TOKEN_GREATER
%token TOKEN_GREATER_EQUAL
%token TOKEN_EQUAL
%token TOKEN_LESS
%token TOKEN_NOTEQUAL		
%token TOKEN_EQUIV		
%token TOKEN_AND_OP		
%token TOKEN_OR_OP		
%token TOKEN_NOT_OP	
%token TOKEN_GOTO
%token TOKEN_FOR
%token TOKEN_DO
%token TOKEN_WHILE
%token TOKEN_STEP
%token TOKEN_UNTIL
%token TOKEN_IF
%token TOKEN_THEN
%token TOKEN_ELSE
%token TOKEN_SWITCH
%token TOKEN_VALUE
%token TOKEN_BOOLEAN
%token TOKEN_TYPE_OWN
%token TOKEN_TYPE_INTEGER
%token TOKEN_TYPE_REAL
%token TOKEN_TYPE_BOOLEAN
%token TOKEN_TYPE_ARRAY
%token TOKEN_TYPE_SWITCH
%token TOKEN_TYPE_PROCEDURE
%token TOKEN_TYPE_STRING
%token TOKEN_TYPE_LABEL
%token TOKEN_TYPE_VALUE
%token TOKEN_ARRAY
%token TOKEN_IMPLY
%token TOKEN_SEMICOLON
%token TOKEN_LTRSTRING
//%token TOKEN_TINTEGER
//%token TOKEN_TREAL
%token TOKEN_RETURN
%token TOKEN_ASSIGN_IDENTIFIER
%token TOKEN_LABEL_IDENTIFIER
%token TOKEN_BOOL_IDENTIFIER
%right	TOKEN_ASSIGN
%left	TOKEN_EQUIV
%left	TOKEN_EQUAL
%left	TOKEN_IMPLY
%left	TOKEN_OR_OP
%left	TOKEN_AND_OP
%left	TOKEN_NOT_OP
%left	TOKEN_LESS TOKEN_GREATER TOKEN_LESS_EQUAL TOKEN_GREATER_EQUAL TOKEN_NOT_EQUAL
%left	TOKEN_REL_OP
%left	TOKEN_PLUS TOKEN_MINUS
%right	TOKEN_POWER

%start  program

//%union {
//	//float fvalue;
//	int integerVal; 		/* integer value */
//	char* symbolIndex; 		/* symbol table index */
//	Node *pt; 			/* node pointer */
//};

/*
%type <tree> program block unlabelledBlock
%type <tree> unlabelledBasicStatement compoundStatement unlabelledCompound compoundTail
%type <tree> basicStatement unconditionalStatement
%type <tree> statement conditionalStatement forStatement gotoStatement assignmentStatement
%type <tree> ifStatement tlabel procedureStatement procedureBody

%type <sym> declaration typeDeclaration arrayDeclaration switchDeclaration procedureDeclaration listType
%type <sym> procedureHeading formalParameterPart formalParameterList identifierList formalParameter
%type <sym> valuePart specificationPart specificationIdentifierList
%type <sym> arraySegment arrayList

%type <typ> type 

%type <expr> arithmeticExpression simpleArithmeticExpression
%type <expr> subscriptedExpression relation booleanExpression functionDesigntor
%type <expr> designationExpression simpleDesigntionalExpression 
%type <expr> ifClause actualParameterPart actualParameterList actualParameter

%type <bound> boundPair boundPairList 
%type <mindex> subscriptedList
*/

%%

blockHead :
	TOKEN_BEGIN declaration
	{
		Node* newNode = createNode();
		Node* tempNode = $2;
		strcpy(newNode->code,tempNode->code);
		$$=newNode;
	}
	|
	blockHead TOKEN_SEMICOLON declaration
	{
		Node* newNode = createNode();
		Node* tempNode1 = $1;
		Node* tempNode2 = $3;
		sprintf(newNode->code,"%s%s",tempNode1->code,tempNode2->code);
		$$=newNode;
	}
	;

unlabelledBlock :
	blockHead TOKEN_SEMICOLON compoundTail
	{
		Node* newNode = createNode();
		Node* tempNode1 = $1;
		Node* tempNode2 = $3;
		newNode->pt0 = $3;
		sprintf(newNode->code,"%s%s",tempNode1->code,tempNode2->code);
		$$ = newNode;
	}
        ;

block :
	unlabelledBlock 
	{
		Node *newNode = createNode();
		newNode->pt0 = $1;
		Node* tempNode = $1;
		sprintf(newNode->code,tempNode->code);
		$$ = newNode;
	}
	|
	tlabel block
	{
		Node *newNode = createNode();
		newNode->pt0 = $2;
		Node* tempNode2 = $2;
		Node* tempNode1 = $1;
		strcpy(newNode->identLex,tempNode1->identLex);
		//No need to get a new label
		int label = getNewLabel();
		sprintf(newNode->code,"b\tlabel%d\n%s:\n%slabel%d:\n",label, tempNode1->identLex, tempNode2->code,label);
		$$ = newNode;

	};

tlabel :
        label TOKEN_COLON
	{
		Node* newNode = createNode();
		Node* tempNode = $1;
		strcpy(newNode->identLex,tempNode->identLex);
		$$=newNode;
	}
        ;

label :
	identifier
	{
		Node* newNode = createNode();
		Node* tempNode = $1;
		strcpy(newNode->identLex,tempNode->identLex);
		$$=newNode;
	}
	| integer
	{
		Node* newNode = createNode();
		Node* tempNode = $1;
		sprintf(newNode->identLex, "%d", tempNode->intValue);
		$$=newNode;
	}
	;

program :
	compoundStatement
	{
		Node* newNode = createNode();
		Node* tempNode = $1;
		strcpy(newNode->code,tempNode->code);
		strcpy(code,newNode->code);
		printSymbolTable();
		$$=newNode;
	}
	| block
	{
		Node* newNode = createNode();
		Node* tempNode = $1;
		strcpy(newNode->code,tempNode->code);
		strcpy(code,newNode->code);
		printSymbolTable();
		$$=newNode;
	}
	;

unlabelledCompound :
	TOKEN_BEGIN compoundTail
	{
		Node* newNode = createNode();
		Node* tempNode = $2;
		strcpy(newNode->code,tempNode->code);
		$$=newNode;	
	}
	;

compoundStatement :
	unlabelledCompound
	{
		Node* newNode = createNode();
		Node* tempNode = $1;
		strcpy(newNode->code,tempNode->code);
		$$=newNode;	
	}
	|
	tlabel compoundStatement
	{
		Node* newNode = createNode();
		Node* tempNode1 = $1;
		Node* tempNode2 = $2;
		int label = getNewLabel();
		sprintf(newNode->code,"b\tlabel%d\n%s:\n%slabel%d:\n",label,tempNode1->identLex,tempNode2->code,label);
		$$=newNode;	
	}
	;

compoundTail :
	statement TOKEN_END
	{
		Node *newNode = createNode();
		newNode->pt0 = $1;
		Node* tempNode = $1;
		strcpy(newNode->code, tempNode->code);
		$$ = newNode;
	}	
	|
	statement TOKEN_SEMICOLON compoundTail
	{	
		Node *newNode = createNode();
		newNode->pt0 = $1;
		Node* tempNode1=$1;
		Node* tempNode2=$3;
		sprintf(newNode->code,"%s%s",tempNode1->code,tempNode2->code);
		$$ = newNode;
	}
	;

declaration : 
	typeDeclaration
	{
		Node* newNode = createNode();
		strcpy(newNode->code,"");
		$$=newNode;
	}	 
	|
	arrayDeclaration
	{
		Node* newNode = createNode();
		strcpy(newNode->code,"");
		$$=newNode;
	}
	|
	switchDeclaration{
		Node* newNode = createNode();
		strcpy(newNode->code,"");
		$$=newNode;
	}
	|
	procedureDeclaration
	{
		Node* newNode = createNode();
		Node* tempNode = $1;
		strcpy(newNode->code,tempNode->code);
		$$=newNode;
	};

lowerBound:
	arithmeticExpression
	{
		Node *newNode = createNode();
		newNode->type = lowerBound;
		newNode->pt0 = $1;
		Node *tempNode = $1;
		newNode->place = tempNode->place;
		strcpy(newNode->code,tempNode->code);
		if(tempNode->semTypeDef==storeInteger) {
			newNode->semTypeDef = storeInteger;
			newNode->intValue = tempNode->intValue;
		}
		else {
			printf("error in array declaration-> lowerbound should be integer\n");
		}
		$$=newNode;
	};

upperBound:
	arithmeticExpression
	{
		Node *newNode = createNode();
		newNode->type = upperBound;
		newNode->pt0 = $1;
		Node *tempNode = $1;
		newNode->place = tempNode->place;
		strcpy(newNode->code,tempNode->code);
		if(tempNode->semTypeDef==storeInteger) {
			newNode->semTypeDef = storeInteger;
			newNode->intValue = tempNode->intValue;
		}
		else {
			printf("error in array declaration-> upperbound should be integer\n");
		}
		$$=newNode;
	};

boundPair :
	lowerBound TOKEN_COLON upperBound
	{
		Node* newNode = createNode();         	  
		newNode->type = boundPair;
		newNode->pt0 = $1;
		newNode->pt2 = $3;
		Node* tempNodeOne = $1;
		Node* tempNodeTwo = $3;
		if (tempNodeOne->semTypeDef==storeInteger && tempNodeTwo->semTypeDef==storeInteger && tempNodeOne->intValue <= tempNodeTwo->intValue) {
			newNode->semTypeDef=storeBoundPairList;
			sprintf(newNode->code,"%s%s",tempNodeOne->code,tempNodeTwo->code);
			newNode->lowerBound[0] = tempNodeOne->intValue;
			newNode->upperBound[0] = tempNodeTwo->intValue;
		}
		$$ = newNode;
	}
        ;

boundPairList :
	boundPair
	{
		Node* newNode = createNode();
		newNode->type = boundPairList;
		newNode->pt0 = $1;
		Node* tempNode = $1;
		if (tempNode->semTypeDef==storeBoundPairList) {  
			newNode->semTypeDef=tempNode->semTypeDef;
			newNode->dim = 1;
			newNode->lowerBound[newNode->dim-1] = tempNode->lowerBound[0];
			newNode->upperBound[newNode->dim-1] = tempNode->upperBound[0];
		}
		$$ = newNode;
	}
	|
	boundPairList TOKEN_COMMA boundPair
	{
		Node* newNode = createNode();
		newNode->type = boundPairList;
		newNode->pt0 = $1;
		newNode->pt2 = $3;
		Node* tempNodeOne = $1;
		Node* tempNodeTwo = $3;
		int i;
		if (tempNodeOne->semTypeDef==storeBoundPairList && tempNodeTwo->semTypeDef==storeBoundPairList ) {
			newNode->semTypeDef=storeBoundPairList;
			for(i=tempNodeOne->dim-1;i>=0;i--) {
				newNode->lowerBound[i] = tempNodeOne->lowerBound[i];
				newNode->upperBound[i] = tempNodeOne->upperBound[i];
			}
			newNode->dim = tempNodeOne->dim + 1 ;
			newNode->lowerBound[newNode->dim-1] = tempNodeTwo->lowerBound[0];
			newNode->upperBound[newNode->dim-1] = tempNodeTwo->upperBound[0]; 	
		}
		else {
			printf("error in boundpairlist semantic type definition\n");			
		}
		$$ = newNode;
	}
        ;

arrayIdentifier :
	identifier
	{
		Node* newNode = createNode();
		newNode->type = arrayIdentifier;
		newNode->pt0 = $1;
		Node* tempNode = $1;
		strcpy(newNode->identLex, tempNode->identLex);
		$$ = newNode;
	}
	;

arraySegment :
	arrayIdentifier TOKEN_OPEN_SQUARE_BRACKET boundPairList TOKEN_CLOSE_SQUARE_BRACKET
	{
		Node* newNode = createNode();
		newNode->type = arraySegment;
		newNode->pt0 = $1;
		newNode->pt2 = $3;
		Node *tempNodeOne = $1;
		Node *tempNodeTwo = $3;
		Symbol* entry = lookUpInCurrentScope(tempNodeOne->identLex, getCurrentScope());
		if(entry==NULL) {
		  entry = addEntry(tempNodeOne->identLex, getCurrentScope());			
		}
		int size = 1;
		entry->dim = tempNodeTwo->dim;
		newNode->dim = tempNodeTwo->dim;
		int i;
		for(i=tempNodeTwo->dim-1;i>=0;i--) {
			entry->lowerBound[i] = tempNodeTwo->lowerBound[i];
			entry->upperBound[i] = tempNodeTwo->upperBound[i];
			newNode->lowerBound[i] = tempNodeTwo->lowerBound[i];
			newNode->upperBound[i] = tempNodeTwo->upperBound[i];
			size = size*(tempNodeTwo->upperBound[i]-tempNodeTwo->lowerBound[i]+1);
		}
		entry->offset = getArrayOffset();
		setArrayOffset(getCurrentScope(), getArrayOffset() - size * 4);
		newNode->identLex = tempNodeOne->identLex;
		$$ = newNode;
	}
	| arrayIdentifier TOKEN_COMMA arraySegment
	{	
		Node* newNode = createNode();
		newNode->type = arraySegment;
		newNode->pt0 = $1;
		newNode->pt2 = $3;
		Node *tempNodeOne = $1;
		Node *tempNodeTwo = $3;
		Symbol* entry = lookUpInCurrentScope(tempNodeOne->identLex, getCurrentScope());
		if(entry==NULL) {
		  entry = addEntry(tempNodeOne->identLex, getCurrentScope());			
		}
		int size =1;
		entry->dim = tempNodeTwo->dim;
		newNode->dim = tempNodeTwo->dim;
		int i;
		for(i=tempNodeTwo->dim-1;i>=0;i--) {
			entry->lowerBound[i] = tempNodeTwo->lowerBound[i];
			entry->upperBound[i] = tempNodeTwo->upperBound[i];
			newNode->lowerBound[i] = tempNodeTwo->lowerBound[i];
			newNode->upperBound[i] = tempNodeTwo->upperBound[i];
			size = size*(tempNodeTwo->upperBound[i]-tempNodeTwo->lowerBound[i]+1);
		}
		entry->offset = getArrayOffset();
		setArrayOffset(getCurrentScope(), getArrayOffset() - size * 4);
		newNode->identLex=tempNodeTwo->identLex;
		strcat(newNode->identLex,",");		
		strcat(newNode->identLex,tempNodeOne->identLex);
		$$ = newNode;
	}
	;

arrayList :
	arraySegment 
	{
		Node* tempNode0=$-1;
		Node* tempNode1=$1;
		char* pch;
		pch = strtok (tempNode1->identLex,",");
  		while (pch != NULL)
  		{
		  Symbol* symbolEntry=lookUpInCurrentScope(pch, getCurrentScope());
			if (symbolEntry!=NULL) {
				symbolEntry->type=tempNode0->semTypeDef;
			}
			else {
			  symbolEntry = addEntry(pch, getCurrentScope());
				symbolEntry->type=tempNode0->semTypeDef;
				symbolEntry->dim=tempNode1->dim;
			}
  			pch = strtok (NULL, ",");
 		}
		$$=$-1;
	}
	|
	arrayList TOKEN_COMMA arraySegment
	{
		Node* tempNode0=$1;
		Node* tempNode1=$3;
		Symbol* symbolEntry=lookUpInCurrentScope(tempNode1->identLex, getCurrentScope());
		if (symbolEntry!=NULL) {
			symbolEntry->type=tempNode0->semTypeDef;
		}
		else {
		  symbolEntry = addEntry(tempNode1->identLex, getCurrentScope());
			symbolEntry->type=tempNode0->semTypeDef;
			symbolEntry->dim=tempNode1->dim;
		}
		$$=$1;
	}
	;

arrayDeclaration :
	type TOKEN_ARRAY arrayList
	;

expression :
	arithmeticExpression
	{
		Node *newNode = createNode();
		newNode->type = expression;
		newNode->pt0 = $1;
		Node *tempNode = $1;
		newNode->semTypeDef = tempNode->semTypeDef;
		newNode->place = tempNode->place ;
		strcpy(newNode->code,tempNode->code);
		$$ = newNode;
	}
	|
	booleanExpression
	{
		Node *newNode = createNode();
		newNode->type = expression;
		newNode->pt0 = $1;
		Node *tempNode = $1;
		newNode->semTypeDef = tempNode->semTypeDef;
		newNode->place = tempNode->place ;
		strcpy(newNode->code,tempNode->code);
		$$ = newNode;
	}
	|
	designationalExpression////check////
	{
			
	};

arithmeticExpression :
	simpleArithmeticExpression
	{
		Node *newNode = createNode();
		newNode->type = arithmeticExpression;
		newNode->pt0 = $1;
		Node* tempNode = (Node*)$1;
		newNode->realValue = tempNode->realValue;
		newNode->intValue = tempNode->intValue;
		newNode->semTypeDef = tempNode->semTypeDef;
		newNode->place = tempNode->place;
		strcpy(newNode->code,tempNode->code);
		$$ = newNode;
	}
	/*|
	ifClause simpleArithmeticExpression TOKEN_ELSE arithmeticExpression 
	{
		Node *newNode = createNode();
		newNode->type = arithmeticExpression;
		newNode->pt0 = $1;
		newNode->pt1 = $2;
		newNode->pt3 = $4;
		Node* tempNode2 = (Node*)$2;
		Node* tempNode4 = (Node*)$4;
		if(tempNode2->semTypeDef == storeInteger )
		{
			if(tempNode4->semTypeDef == storeInteger)
			{
				newNode->semTypeDef=storeInteger ;  		
			}
		}
		$$ = newNode;
	}*///since it appears in unconditional statement
	;

simpleArithmeticExpression :
	term
	{
		Node *newNode = createNode();
		newNode->type = simpleArithmeticExpression;
		newNode->pt0 = $1;
		Node* tempNode = (Node*)$1;
		newNode->intValue = tempNode->intValue;
		newNode->realValue = tempNode->realValue;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place;
		strcpy(newNode->code,tempNode->code);
		$$ = newNode;
	}
	|
	TOKEN_PLUS term
	{
		Node *newNode = createNode();
		newNode->type = simpleArithmeticExpression;
		newNode->pt0 = $2;
		Node* tempNode = (Node*)$2;
		newNode->intValue = tempNode->intValue;
		newNode->realValue = tempNode->realValue;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place;
		strcpy(newNode->code,tempNode->code);
		$$ = newNode;
	}
	|
	TOKEN_MINUS term
	{
		Node *newNode = createNode();
		newNode->type = simpleArithmeticExpression;
		newNode->pt0 = $2;
		Node* tempNode = (Node*)$2;
		newNode->intValue = 0-tempNode->intValue;
		newNode->realValue = 0.0-tempNode->realValue;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=getNewTempOffset();
		if (tempNode->semTypeDef == storeReal) {
			sprintf(newNode->code,"%s\nli.s\t$f0,0.0\nl.s\t$f1,%d($sp)\nsub\t$f2,$f0,$f1\ns.s\t$f2,%d($sp)\n",tempNode->code,tempNode->place,newNode->place);
		}
		else {
			sprintf(newNode->code,"%s\nli\t$t0,0\nlw\t$t1,%d($sp)\nsub\t$t2,$t0,$t1\nsw\t$t2,%d($sp)\n",tempNode->code,tempNode->place,newNode->place);
		}
		$$ = newNode;
	}
	|
	simpleArithmeticExpression TOKEN_PLUS term
	{
		Node *newNode = createNode();
		newNode->type = term;
		newNode->pt0 = $1;
		newNode->pt1 = $2;
		newNode->pt2 = $3;
		Node* tempNode0 = (Node*)$1;
		Node* tempNode1 = (Node*)$2;
		Node* tempNode2 = (Node*)$3;
		sprintf(newNode->code,"%s%s",tempNode0->code,tempNode2->code);
		if (tempNode0->semTypeDef==storeReal || tempNode2->semTypeDef==storeReal)
		{			
			newNode->semTypeDef = storeReal ;  
			if (tempNode0->semTypeDef==storeInteger) {  
				tempNode0->realValue = 1.00*tempNode0->intValue;  
				tempNode0->semTypeDef==storeReal;
				sprintf(newNode->code,"%slw\t$t0,%d($sp)\nmtc1\t$t0,$f0\ncvt.s.w\t$f0,$f0\ns.s\t$f0,%d($sp)\n",newNode->code,tempNode0->place,tempNode0->place);
			}
			else if (tempNode2->semTypeDef==storeInteger) {  
				tempNode2->realValue = 1.00*tempNode2->intValue;  
				tempNode2->semTypeDef==storeReal;
				sprintf(newNode->code,"%slw\t$t0,%d($sp)\nmtc1\t$t0,$f0\ncvt.s.w\t$f0,$f0\ns.s\t$f0,%d($sp)\n",newNode->code,tempNode2->place,tempNode2->place);
			}
			newNode->realValue=tempNode0->realValue  +  tempNode2->realValue;
			sprintf(newNode->code,"%sl.s\t$f0,%d($sp)\nl.s\t$f1,%d($sp)\nadd.s\t$f2,$f0,$f1\ns.s\t$f2,%d($sp)\n",newNode->code,tempNode0->place,tempNode2->place,tempNode0->place);
			newNode->place = tempNode0->place;	
		}
		else {  			
			newNode->semTypeDef = storeInteger ;  
			newNode->intValue = tempNode0->intValue  +  tempNode2->intValue ;
			sprintf(newNode->code,"%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nadd\t$t2,$t0,$t1\nsw\t$t2,%d($sp)\n",newNode->code,tempNode0->place,tempNode2->place,tempNode0->place);
			newNode->place=tempNode0->place;
		}
		$$ = newNode;
	}
	|
	simpleArithmeticExpression TOKEN_MINUS term
	{	
		Node *newNode = createNode();
		newNode->type = term;
		newNode->pt0 = $1;
		newNode->pt1 = $2;
		newNode->pt2 = $3;
		Node* tempNode0 = (Node*)$1;
		Node* tempNode1 = (Node*)$2;
		Node* tempNode2 = (Node*)$3;
		sprintf(newNode->code,"%s%s",tempNode0->code,tempNode2->code);
		if (tempNode0->semTypeDef==storeReal || tempNode2->semTypeDef==storeReal) {  
			newNode->semTypeDef = storeReal;  
			if (tempNode0->semTypeDef==storeInteger) {  
				tempNode0->realValue = 1.00*tempNode0->intValue;  
				tempNode0->semTypeDef==storeReal;
				sprintf(newNode->code,"%slw\t$t0,%d($sp)\nmtc1\t$t0,$f0\ncvt.s.w\t$f0,$f0\ns.s\t$f0,%d($sp)\n",newNode->code,tempNode0->place,tempNode0->place);
			}
			else if (tempNode2->semTypeDef==storeInteger) {  
				tempNode2->realValue = 1.00*tempNode2->intValue ;  
				tempNode2->semTypeDef==storeReal;
				sprintf(newNode->code,"%slw\t$t0,%d($sp)\nmtc1\t$t0,$f0\ncvt.s.w\t$f0,$f0\ns.s\t$f0,%d($sp)\n",newNode->code,tempNode2->place,tempNode2->place);
			}
			newNode->realValue=tempNode0->realValue  -  tempNode2->realValue ;
			sprintf(newNode->code,"%sl.s\t$f0,%d($sp)\nl.s\t$f1,%d($sp)\nsub.s\t$f2,$f0,$f1\ns.s\t$f2,%d($sp)\n",newNode->code,tempNode0->place,tempNode2->place,tempNode0->place);
			newNode->place = tempNode0->place;
		}
		else {  
			newNode->semTypeDef = storeInteger ;  
			newNode->intValue = tempNode0->intValue - tempNode2->intValue ; 
			sprintf(newNode->code,"%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nsub\t$t2,$t0,$t1\nsw\t$t2,%d($sp)\n",newNode->code,tempNode0->place,tempNode2->place,tempNode0->place);
			newNode->place=tempNode0->place;
		}
		$$ = newNode;
	}
	;

term :	
	factor 	
	{
		Node *newNode = createNode();
		newNode->type = term;
		newNode->pt0 = $1;
		Node* tempNode = (Node*)$1;
		newNode->intValue = tempNode->intValue;
		newNode->realValue = tempNode->realValue;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place;
		strcpy(newNode->code,tempNode->code);
		$$ = newNode;
	}
	|
	term TOKEN_MULTIPLY factor
	{
		Node *newNode = createNode();
		newNode->type = term;
		newNode->pt0 = $1;
		newNode->pt1 = $2;
		newNode->pt2 = $3;
		Node* tempNode0 = (Node*)$1;
		Node* tempNode1 = (Node*)$2;
		Node* tempNode2 = (Node*)$3;
		sprintf(newNode->code,"%s%s",tempNode0->code,tempNode2->code);
		if (tempNode0->semTypeDef==storeReal || tempNode2->semTypeDef==storeReal) {  
			newNode->semTypeDef = storeReal ;  
			if (tempNode0->semTypeDef==storeInteger) {     
				tempNode0->realValue = 1.00*tempNode0->intValue ;  
				tempNode0->semTypeDef==storeReal;
				sprintf(newNode->code,"%slw\t$t0,%d($sp)\nmtc1\t$t0,$f0\ncvt.s.w\t$f0,$f0\ns.s\t$f0,%d($sp)\n",newNode->code,tempNode0->place,tempNode0->place);
			}
			else if (tempNode2->semTypeDef==storeInteger) {  
				tempNode2->realValue = 1.00*tempNode2->intValue ;  
				tempNode2->semTypeDef==storeReal;
				sprintf(newNode->code,"%slw\t$t0,%d($sp)\nmtc1\t$t0,$f0\ncvt.s.w\t$f0,$f0\ns.s\t$f0,%d($sp)\n",newNode->code,tempNode2->place,tempNode2->place);
			}
				newNode->realValue=tempNode0->realValue  *  tempNode2->realValue;
				sprintf(newNode->code,"%sl.s\t$f0,%d($sp)\nl.s\t$f1,%d($sp)\nmul.s\t$f0,$f0,$f1\ns.s\t$f0,%d($sp)\n",newNode->code,tempNode0->place,tempNode2->place,tempNode0->place);
		}
		else {  
			newNode->semTypeDef = storeInteger ;  
			newNode->intValue = tempNode0->intValue*tempNode2->intValue ;
			sprintf(newNode->code,"%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nmult\t$t0,$t1\nmflo\t$t0\nsw\t$t0,%d($sp)\n",newNode->code,tempNode0->place,tempNode2->place,tempNode0->place);
		}
		newNode->place=tempNode0->place;
		$$ = newNode;
	}
	|
	term TOKEN_DIVIDE factor
	{
		Node *newNode = createNode();
		Node* tempNode0 = (Node*)$1;
		Node* tempNode1 = (Node*)$2;
		Node* tempNode2 = (Node*)$3;
		sprintf(newNode->code,"%s%s",tempNode0->code,tempNode2->code);
		if (tempNode0->semTypeDef==storeReal || tempNode2->semTypeDef==storeReal) {  
			newNode->semTypeDef = storeReal ;  
			if (tempNode0->semTypeDef==storeInteger) {
				tempNode0->realValue = 1.00*tempNode0->intValue ;  
				tempNode0->semTypeDef==storeReal;
				sprintf(newNode->code,"%slw\t$t0,%d($sp)\nmtc1\t$t0,$f0\ncvt.s.w\t$f0,$f0\ns.s\t$f0,%d($sp)\n",newNode->code,tempNode0->place,tempNode0->place);
			}
			else if (tempNode2->semTypeDef==storeInteger) {
				tempNode2->realValue = 1.00*tempNode2->intValue;
				tempNode2->semTypeDef==storeReal;
				sprintf(newNode->code,"%slw\t$t0,%d($sp)\nmtc1\t$t0,$f0\ncvt.s.w\t$f0,$f0\ns.s\t$f0,%d($sp)\n",newNode->code,tempNode2->place,tempNode2->place);
			}
			if (tempNode2->realValue==0.00) {
				exit(0);
			}
			else {
				newNode->realValue=tempNode0->realValue/tempNode2->realValue;
				sprintf(newNode->code,"%sl.s\t$f0,%d($sp)\nl.s\t$f1,%d($sp)\ndiv.s\t$f1,$f0,$f1\ns.s\t$f1,%d($sp)\n",newNode->code, tempNode0->place, tempNode2->place, tempNode0->place);
				newNode->place = tempNode0->place;
			}
		}
		else {  
			newNode->semTypeDef = storeInteger;
			if (tempNode2->intValue==0) {
				exit(0);
			}
			else {
				newNode->intValue = tempNode0->intValue/tempNode2->intValue;
				sprintf(newNode->code,"%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\ndiv\t$t0,$t1\nmflo\t$t1\nsw\t$t1,%d($sp)\n",newNode->code, tempNode0->place, tempNode2->place, tempNode0->place);
				newNode->place=tempNode0->place;
			}
		}
		$$ = newNode;
	}
        ;

factor : 
	primary
	{
		Node* newNode = createNode();
		newNode->type = factor;
		newNode->pt0 = $1;
		Node* tempNode = (Node*)$1;
		newNode->intValue = tempNode->intValue;
		newNode->realValue = tempNode->realValue;
		newNode->semTypeDef=tempNode->semTypeDef; 
		newNode->place=tempNode->place;
		strcpy(newNode->code,tempNode->code); 
		$$ = newNode;
	}
	|
	factor TOKEN_POWER primary
	{
		Node *newNode = createNode();
		newNode->type = factor;
		newNode->pt0 = $1;
		newNode->pt2 = $3;
		Node* tempNode0 = (Node*)$1;
		Node* tempNode1 = (Node*)$3;
		$$ = newNode;
	}
	;

primary :
	unsignedNumber
	{
		Node *newNode = createNode();
		newNode->type = primary;
		newNode->pt0 = $1;
		Node *tempNode = (Node*)$1;
		newNode->intValue = tempNode->intValue;
		newNode->realValue = tempNode->realValue;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place;
		strcpy(newNode->code,tempNode->code);
		$$ = newNode;
	}
	|	
	functionDesignator
	{
		Node *newNode = createNode();
		newNode->type = primary;
		newNode->pt0 = $1;
		Node *tempNode = (Node*)$1;
		newNode->intValue = tempNode->intValue;
		newNode->realValue = tempNode->realValue;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place;
		strcpy(newNode->code,tempNode->code);
		$$ = newNode;
	}
	|
	variable
	{
		Node *newNode = createNode();
		newNode->type = primary;
		newNode->pt0 = $1;
		Node *tempNode = (Node*)$1;
		Symbol* foundEntry = lookUp(tempNode->identLex,getCurrentScope());
		if (foundEntry)
		{	
			newNode->intValue =  foundEntry->value;
			newNode->realValue = foundEntry->realValue;		
			newNode->semTypeDef= foundEntry->type ;
			newNode->place=getNewTempOffset();
			int offset;
			if (tempNode->isArray == 1) {
				offset = tempNode->place;
			}
			else {
				offset = foundEntry->offset;
			}
			if (foundEntry->type==storeReal) {
				sprintf(newNode->code,"%sl.s\t$f0,%d($sp)\ns.s\t$f0,%d($sp)\n",tempNode->code,offset,newNode->place);	
			}
			else {
				sprintf(newNode->code,"%slw\t$t0,%d($sp)\nsw\t$t0,%d($sp)\n",tempNode->code,offset,newNode->place);	
			}
		}
		else {
			printf("error: %s not declared\n",tempNode->identLex);
		}
		$$ = newNode;
	}
	|
	TOKEN_OPEN_BRACKET arithmeticExpression TOKEN_CLOSE_BRACKET
	{
		Node *newNode = createNode();
		newNode->type = primary;
		newNode->pt1 = $2;
		Node *tempNode = (Node*)$2;  
		newNode->intValue = tempNode->intValue;
		newNode->realValue=tempNode->realValue;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place;
		strcpy(newNode->code,tempNode->code);
		$$ = newNode;
	}
        ;

unsignedNumber :
	realNumber
	{
		Node *newNode = createNode();
		newNode->type = unsignedNumber;
		newNode->pt0 = $1;
		Node *tempNode = (Node*)$1;
		newNode->intValue = tempNode->intValue;
		newNode->realValue = tempNode->realValue;
		newNode->semTypeDef=storeReal;
		newNode->place=getNewTempOffset();
		sprintf(newNode->code,"li.s\t$f0,%f\ns.s\t$f0,%d($sp)\n",newNode->realValue,newNode->place);
		$$ = newNode;
	}
	|
	integer
	{	
		Node *newNode = createNode();
		newNode->type = unsignedNumber;
		newNode->pt0 = $1;
		Node *tempNode = (Node*)$1;
		newNode->intValue = tempNode->intValue;
		newNode->realValue = tempNode->realValue;
		newNode->semTypeDef=storeInteger;
		newNode->place=getNewTempOffset();
		sprintf(newNode->code,"li\t$t0,%d\nsw\t$t0,%d($sp)\n",newNode->intValue,newNode->place);
		$$ = newNode;
	};

realNumber :  
	TOKEN_REAL_NUM
	{
		Node *newNode = createNode();		
		newNode->type = realNumber;
		newNode->realValue = atof(yytext);
		newNode->semTypeDef=storeReal;
		$$ = newNode;
	};

integer :
	TOKEN_INTEGER
	{
		Node *newNode = createNode();
		newNode->type = integer;
		newNode->intValue = atoi(yytext);
		newNode->semTypeDef=storeInteger;  
		$$ = newNode;
	};

simpleVariable :
	varIdentifier
	{	
		Node *new = createNode();		
		new->type = simpleVariable;
		new->pt0 = $1;
		Node* temp = (Node*)$1;			
		new->realValue=temp->realValue;		
		new->intValue=temp->intValue;
		new->boolValue=temp->boolValue;
		new->semTypeDef=temp->semTypeDef;
		strcpy(new->identLex, temp->identLex);
		new->place=temp->place;
		strcpy(new->code,temp->code);
		$$ = new;
	}
        ;

variable : 
	simpleVariable
	{
		Node* newNode = createNode();
		newNode->type = variable;
		newNode->pt0 = $1;
		Node* tempNode = (Node*)$1;
		newNode->boolValue = tempNode->boolValue;
		newNode->intValue = tempNode->intValue;
		newNode->realValue=tempNode->realValue;
		newNode->semTypeDef=tempNode->semTypeDef;
		strcpy(newNode->identLex,tempNode->identLex);
		newNode->place=tempNode->place;
		strcpy(newNode->code,tempNode->code);
		$$ = newNode;
	}
	|
	subscriptedVariable
	{
		Node *newNode = createNode();
		newNode->isArray = 1;
		newNode->type = variable;
		newNode->pt0 = $1;
		Node* tempNode = (Node*)$1;
		newNode->boolValue = tempNode->boolValue;
		newNode->intValue = tempNode->intValue;
		newNode->realValue=tempNode->realValue;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place = tempNode->place;
		strcpy(newNode->code,tempNode->code);
		strcpy(newNode->identLex, tempNode->identLex);
		$$ = newNode;
	}
        ;	

subscriptedVariable :
	arrayIdentifier TOKEN_OPEN_SQUARE_BRACKET subscriptList TOKEN_CLOSE_SQUARE_BRACKET
	{
		Node* newNode = createNode();
		newNode->type = subscriptedVariable;
		newNode->pt0 = $1;
		newNode->pt2 = $3;
		Node* tempNode0 = $1;
		Node* tempNode1 = $3;
		strcpy(newNode->identLex, tempNode0->identLex);
		Symbol* foundEntry = lookUp(tempNode0->identLex,getCurrentScope());
		if(foundEntry==NULL)
		{
			newNode->semTypeDef = storeError;
		}
		else
		{	
			if (tempNode1->semTypeDef == storeInteger) {		
				newNode->semTypeDef = foundEntry->type;
				int i;
				int offset = foundEntry->offset - (tempNode1->lowerBound[tempNode1->dim-1]-foundEntry->lowerBound[tempNode1->dim-1])*4;
				for (i=foundEntry->dim-1;i>0;i--) {
					if (tempNode1->lowerBound[i-1] <= foundEntry->upperBound[i-1] && tempNode1->lowerBound[i-1] >= foundEntry->lowerBound[i-1]) {
						offset-=(foundEntry->upperBound[i]-foundEntry->lowerBound[i])*4*(tempNode1->lowerBound[i-1]-foundEntry->lowerBound[i-1]);
					}
					else {
						printf("error: array dimension is out of range\n");
					}
				}
				newNode->place = offset;
				strcpy(newNode->code,tempNode1->code);
			}
		}	
		$$ = newNode;
	}
	;

subscriptList :
	subscriptExpression
	{
		Node* newNode = createNode();
		newNode->type = subscriptList;
		Node* tempNode = $1;
		newNode->semTypeDef = tempNode->semTypeDef;
		newNode->pt0 = $1;
		newNode->place = tempNode->place;
		strcpy(newNode->code,tempNode->code);
		if (tempNode->semTypeDef==storeInteger) {
			newNode->semTypeDef = tempNode->semTypeDef;
			newNode->dim = 1;
			newNode->lowerBound[newNode->dim-1] = tempNode->intValue;
		}
		else {
			newNode->semTypeDef = storeError;
		}
		$$ = newNode;
	}
	|
	subscriptList TOKEN_COMMA subscriptExpression
	{
		Node* newNode = createNode();
		newNode->type = subscriptList;
		newNode->pt0 = $1;
		newNode->pt1 = $3;
		Node* tempNode1 = $1;
		Node* tempNode2 = $3;
		newNode->semTypeDef = tempNode2->semTypeDef;
		sprintf(newNode->code,"%s%s",tempNode1->code,tempNode2->code);
		if (tempNode2->semTypeDef == storeInteger) {
			newNode->semTypeDef = tempNode2->semTypeDef;
			int i;
			for (i=tempNode1->dim-1;i>=0;i--) {
				newNode->lowerBound[i] = tempNode1->lowerBound[i];
			}
			newNode->dim = tempNode1->dim+1;
			newNode->lowerBound[newNode->dim-1] = tempNode2->intValue;
		}
		else {
			newNode->semTypeDef = storeError;
		}
		$$ = newNode;
	}
        ;

subscriptExpression :
	arithmeticExpression
	{
		Node* newNode = createNode();
		newNode->type = subscriptExpression;
		newNode->pt0 = $1;
		Node* tempNode = $1;
		newNode->semTypeDef = tempNode->semTypeDef;
		newNode->intValue = tempNode->intValue;
		newNode->place = tempNode->place;
		strcpy(newNode->code,tempNode->code);
		$$ = newNode;
	}
        ;

identifier :
	TOKEN_IDENTIFIER
	{
		Node* newNode = createNode();
		newNode->type = identifier;
		strcpy(newNode->identLex,yytext);
		sprintf(newNode->code,"");
		$$ = newNode;
	}
        ;

booleanExpression :
	simpleBoolean
	{
		Node* newNode = createNode();
		newNode->type = booleanExpression;
		newNode->pt0 = $1;
		Node* tempNode = $1;
		newNode->place = tempNode->place ;
		strcpy(newNode->code,tempNode->code);
		if (tempNode->semTypeDef == storeBoolean) {
			newNode->semTypeDef = tempNode->semTypeDef;
		}
		else {
			newNode->semTypeDef = storeError;
		}
		$$ = newNode;
	}
	/*|
	ifClause simpleBoolean TOKEN_ELSE booleanExpression
	{
		Node* newNode = createNode();
		newNode->type = booleanExpression;
		newNode->pt0 = $1;
		newNode->pt1 = $2;
		newNode->pt2 = $4;
		Node* tempNode1 = $1;
		Node* tempNode2 = $2;
		Node* tempNode3 = $4;
		if(tempNode1->semTypeDef == storeBoolean && tempNode2->semTypeDef == storeBoolean && tempNode3->semTypeDef == storeBoolean){
			newNode->semTypeDef = tempNode3->semTypeDef;
		}
		else{
			newNode->semTypeDef = storeError;
		}
		$$ = newNode;
	}*/
        ;

simpleBoolean:
	implication
	{
		Node* newNode = createNode();
		newNode->type = booleanExpression;
		newNode->pt0 = $1;
		Node* tempNode = $1;
		newNode->boolValue = tempNode->boolValue;
		newNode->semTypeDef = tempNode->semTypeDef;
		newNode->place = tempNode->place ;
		strcpy(newNode->code,tempNode->code);
		$$ = newNode;
	}
	|
	simpleBoolean TOKEN_EQUIV implication
	{
		Node* newNode = createNode();
		newNode->type = booleanExpression;
		newNode->pt0 = $1;
		newNode->pt2 = $3;
		Node* tempNode1 = $1;
		Node* tempNode2 = $3;
		int label1 = getNewLabel();
		int label2 = getNewLabel();
		sprintf(newNode->code,"%s%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nbeq\t$t0,$t1,label%d\nli\t$t2,0\nb\tlabel%d\nlabel%d:\nli\t$t2,1\nlabel%d:\nsw\t$t2,%d($sp)\n",tempNode1->code,tempNode2->code,tempNode1->place,tempNode2->place,label1,label2,label1,label2,tempNode1->place);
		newNode->place = tempNode1->place;
		$$ = newNode;
	}
        ;

implication : 
	booleanTerm
	{
		Node *newNode = createNode();
		newNode->type = implication;
		newNode->pt0 = $1;
		Node* tempNode = $1;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place ;  
		strcpy(newNode->code, tempNode->code);
		$$ = newNode;  
	}
	|
	implication TOKEN_IMPLY booleanTerm
	{
		Node *newNode = createNode();         		
		newNode->type = implication;
		newNode->pt0 = $1;
		newNode->pt2 = $3;
		Node* tempNode1 = $1;
		Node* tempNode2 = $3;
		int label1=getNewLabel();
		int label2=getNewLabel();
		if (tempNode1->semTypeDef==storeBoolean && tempNode2->semTypeDef==storeBoolean) {  
			newNode->semTypeDef=storeBoolean ;
		}
		else {  
			newNode->semTypeDef=storeError;
		}
		$$ = newNode; 
	}
        ;

booleanTerm :
	booleanFactor
	{
		Node *newNode = createNode();
		newNode->type = booleanTerm;
		newNode->pt0 = $1;
		Node* tempNode = (Node*)$1;
		newNode->place=tempNode->place ;  
		strcpy(newNode->code, tempNode->code);
		newNode->semTypeDef=tempNode->semTypeDef;
		$$ = newNode;
	}
	|
	booleanTerm TOKEN_OR_OP booleanFactor
	{
		Node *newNode = createNode();
		newNode->type = booleanFactor;
		newNode->pt0 = $1;
		newNode->pt2 = $3;
		Node* tempNode1 = (Node*)$1;
		Node* tempNode2 = (Node*)$3;
		sprintf(newNode->code,"%s%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nor\t$t2,$t0,$t1\nsw\t$t2,%d($sp)\n",tempNode1->code,tempNode2->code,tempNode1->place,tempNode2->place, tempNode1->place);
		newNode->place = tempNode1->place;
		if (tempNode1->semTypeDef==storeBoolean && tempNode2->semTypeDef==storeBoolean) {  
			newNode->semTypeDef=storeBoolean;	
		}
		else {
			newNode->semTypeDef=storeError ;  
		}
		$$ = newNode;  
	}
        ;

booleanFactor :
	booleanSecondary
	{
		Node *newNode = createNode();
		newNode->type = booleanFactor;
		newNode->pt0 = $1;
		Node* tempNode = (Node*)$1;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place ;  
		strcpy(newNode->code, tempNode->code);
		$$ = newNode;
	}
	|
	booleanFactor TOKEN_AND_OP booleanSecondary
	{
		Node *newNode = createNode();
		newNode->type = booleanFactor;
		newNode->pt0 = $1;
		newNode->pt2 = $3;
		Node* tempNode1 = (Node*)$1;
		Node* tempNode2 = (Node*)$3;
		sprintf(newNode->code,"%s%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nand\t$t2,$t0,$t1\nsw\t$t2,%d($sp)\n",tempNode1->code,tempNode2->code,tempNode1->place,tempNode2->place, tempNode1->place);
		newNode->place = tempNode1->place;
		if (tempNode1->semTypeDef==storeBoolean && tempNode2->semTypeDef==storeBoolean) {  
			newNode->semTypeDef=storeBoolean ;  
		}
		else {  
			newNode->semTypeDef=storeError ;  
		}
		$$ = newNode;  
	};

booleanSecondary :
	booleanPrimary 
	{
		Node *newNode = createNode();
		newNode->type = booleanSecondary;
		newNode->pt0 = $1;
		Node* tempNode = (Node*)$1;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place ;  
		strcpy(newNode->code, tempNode->code);
		$$ = newNode;
	}
	|
	TOKEN_NOT_OP booleanPrimary
	{
		Node *newNode = createNode();
		newNode->type = booleanSecondary;
		newNode->pt1 = $2;
		Node* tempNode = $2;
		newNode->place = getNewTempOffset();
		sprintf(newNode->code,"%sli\t$t0,1\nlw\t$t1,%d($sp)\nsub\t$t2,$t0,$t1\nsw\t$t2,%d($sp)\n",tempNode->code,tempNode->place,newNode->place);
		if (tempNode->semTypeDef==storeBoolean) {  
			newNode->semTypeDef=storeBoolean ;  
		}
		else {  
			newNode->semTypeDef=storeError ;  
		}
		$$ = newNode;
	}
	;

booleanPrimary :
	logicalValue
	{
		Node *newNode = createNode();
		newNode->type = booleanPrimary;
		newNode->pt0 = $1;
		Node* tempNode = $1;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place ;  
		strcpy(newNode->code, tempNode->code);
		$$ = newNode;
	}
	/*|
	variable
	{
		Node *newNode = createNode();
		newNode->type = variable;
		newNode->pt0 = $1;
		Node *tempNode=$1;
		Symbol* entry = lookUp(tempNode->identLex,getCurrentScope());
		tempNode->semTypeDef = entry->type;
		newNode->semTypeDef = tempNode->semTypeDef;
		$$=newNode;
	}*/
	|
	relation
	{
		Node *newNode = createNode();
		newNode->type = booleanPrimary;
		newNode->pt0 = $1;
		Node* tempNode = $1;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place ;  
		strcpy(newNode->code, tempNode->code);
		$$=newNode;
	}
	|
	TOKEN_OPEN_BRACKET booleanExpression TOKEN_CLOSE_BRACKET
	{
		Node *newNode = createNode();
		newNode->type = booleanPrimary;
		newNode->pt0 = $2;
		Node* tempNode = $2;  
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place ;  
		strcpy(newNode->code, tempNode->code);
		$$=newNode;
	}
        ;

logicalValue:
	TOKEN_LOGICAL_VALUE
	{
		Node* newNode = createNode();
		newNode->type = logicalValue;
		newNode->place = getNewTempOffset();
		if (strcmp("true",yytext)==0) {
			newNode->boolValue = true;
			sprintf(newNode->code,"li\t$t0,1\nsw\t$t0,%d($sp)\n",newNode->place);
		}
		else {
			newNode->boolValue = false;
			sprintf(newNode->code,"li\t$t0,0\nsw\t$t0,%d($sp)\n",newNode->place);
		}
		$$ = newNode;
	}
        ;

relation : 
	simpleArithmeticExpression relationalOperator simpleArithmeticExpression
	{
		Node *newNode = createNode();
		newNode->type = relation;
		newNode->pt0 = $1;
		newNode->pt1 = $2;
		newNode->pt2 = $3;
		Node* tempNode0 = $1;
		Node* tempNode1 = $2;
		Node* tempNode2 = $3;
		newNode->place = getNewTempOffset();
		int label1 = getNewLabel();
		int label2 = getNewLabel();
		if (strcmp(tempNode1->identLex,">") == 0) 
		{
			sprintf(newNode->code,"%s%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nbgt\t$t0,$t1,label%d\nli\t$t3,0\nsw\t$t3,%d($sp)\nb\tlabel%d\nlabel%d:\nli\t$t4,1\nsw\t$t4,%d($sp)\nlabel%d:\n",tempNode0->code,tempNode2->code,tempNode0->place,tempNode2->place,label1,newNode->place,label2,label1,newNode->place,label2);
			if( tempNode0->intValue > tempNode2->intValue)
			{
				newNode->boolValue = true;
			}
			else
			{
				newNode->boolValue = false;
			}
		}
		else if (strcmp(tempNode1->identLex,"<") == 0) 
		{
			sprintf(newNode->code,"%s%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nblt\t$t0,$t1,label%d\nli\t$t3,0\nsw\t$t3,%d($sp)\nb\tlabel%d\nlabel%d:\nli\t$t4,1\nsw\t$t4,%d($sp)\nlabel%d:\n",tempNode0->code,tempNode2->code,tempNode0->place,tempNode2->place,label1,newNode->place,label2,label1,newNode->place,label2);
			if(tempNode0->intValue < tempNode2->intValue)
			{
				newNode->boolValue = true;
			}
			else
			{
				newNode->boolValue = false;
			}
		}
		else if (strcmp(tempNode1->identLex,"<=") == 0) 
		{
			sprintf(newNode->code,"%s%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nble\t$t0,$t1,label%d\nli\t$t3,0\nsw\t$t3,%d($sp)\nb\tlabel%d\nlabel%d:\nli\t$t4,1\nsw\t$t4,%d($sp)\nlabel%d:\n",tempNode0->code,tempNode2->code,tempNode0->place,tempNode2->place,label1,newNode->place,label2,label1,newNode->place,label2);
			if(tempNode0->intValue <= tempNode2->intValue)
			{
				newNode->boolValue = true;
			}
			else
			{
				newNode->boolValue = false;
			}
		}
		else if (strcmp(tempNode1->identLex,">=") == 0) 
		{
			sprintf(newNode->code,"%s%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nbge\t$t0,$t1,label%d\nli\t$t3,0\nsw\t$t3,%d($sp)\nb\tlabel%d\nlabel%d:\nli\t$t4,1\nsw\t$t4,%d($sp)\nlabel%d:\n",tempNode0->code,tempNode2->code,tempNode0->place,tempNode2->place,label1,newNode->place,label2,label1,newNode->place,label2);
			if (tempNode0->intValue >= tempNode2->intValue)
			{
				newNode->boolValue = true;
			}
			else
			{
				newNode->boolValue = false;
			}
		}
		else if (strcmp(tempNode1->identLex,"<>") == 0) 
		{
			sprintf(newNode->code,"%s%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nbne\t$t0,$t1,label%d\nli\t$t3,0\nsw\t$t3,%d($sp)\nb\tlabel%d\nlabel%d:\nli\t$t4,1\nsw\t$t4,%d($sp)\nlabel%d:\n",tempNode0->code,tempNode2->code,tempNode0->place,tempNode2->place,label1,newNode->place,label2,label1,newNode->place,label2);
			if (tempNode0->intValue != tempNode2->intValue)
			{
				newNode->boolValue = true;
			}
			else
			{
				newNode->boolValue = false;
			}
		}
		else if (strcmp(tempNode1->identLex,"=") == 0)          	
        	{
			sprintf(newNode->code,"%s%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nbeq\t$t0,$t1,label%d\nli\t$t3,0\nsw\t$t3,%d($sp)\nb\tlabel%d\nlabel%d:\nli\t$t4,1\nsw\t$t4,%d($sp)\nlabel%d:\n",tempNode0->code,tempNode2->code,tempNode0->place,tempNode2->place,label1,newNode->place,label2,label1,newNode->place,label2);
        		if (tempNode0->intValue == tempNode2->intValue)
        		{
        			newNode->boolValue = true;
 			}
 			else
			{
				newNode->boolValue = false;
			}
		}
		newNode->semTypeDef = storeBoolean ;  
		$$=newNode;
	}
        ;
	        
relationalOperator :
	TOKEN_REL_OP
	{	
		Node *newNode = createNode();
		newNode->type = relationalOperator;
		strcpy(newNode->identLex, yytext);
		$$ = newNode;
	}
        ;

listType :
	varIdentifier
	{
		Node *temp2=$0;
		Node *temp1=$1;
		if (lookUpInCurrentScope(temp1->identLex, getCurrentScope())!=NULL) {
			return 0;
		}
		else {
		  Symbol *newEntry=addEntry(temp1->identLex, getCurrentScope());
			newEntry->type=temp2->semTypeDef;
			if (currentGlobalOffset <= getCurrentOffset(getCurrentScope())) {
				newEntry->offset=currentGlobalOffset;
				currentGlobalOffset-=4;
			}
			else {
				newEntry->offset=getCurrentOffset(getCurrentScope());
				setCurrentOffset(getCurrentScope(), getCurrentOffset(getCurrentScope()) - 4);				
			}
			$$=$0;
		}
	}
	|
	listType TOKEN_COMMA varIdentifier
	{
		Node *temp2=$0;
		Node *temp0=$1;
		Node *temp1=$3;
		if (lookUpInCurrentScope(temp1->identLex, getCurrentScope())!=NULL) {
		}
		else {
		  Symbol *newEntry=addEntry(temp1->identLex, getCurrentScope());
			newEntry->type=temp2->semTypeDef;
			if (currentGlobalOffset <= getCurrentOffset(getCurrentScope())) {
				newEntry->offset=currentGlobalOffset;
				currentGlobalOffset-=4;
			}
			else {
				newEntry->offset=getCurrentOffset(getCurrentScope());
				setCurrentOffset(getCurrentScope(), getCurrentOffset(getCurrentScope()) - 4);				
			}
		}
		$$=$0;	
	}
	;

type :
	TOKEN_TYPE_REAL
	{
		Node *new = createNode();         	
        	new->type = type;
        	new->semTypeDef = storeReal;
		$$ = new;
	}
	|
	TOKEN_TYPE_INTEGER
	{
		Node *new = createNode();         	
        	new->type = type;
        	new->semTypeDef=storeInteger;
		$$ = new;	
	}
	|
	TOKEN_TYPE_BOOLEAN
	{
		Node *new = createNode();         	
        	new->type = type;
        	new->semTypeDef=storeBoolean;
		$$ = new;
	}
	;

typeDeclaration :
	type listType
	{
	}
	;

varIdentifier :
	identifier
	{
		Node *new = createNode();		
		new->type = varIdentifier;
		new->pt0 = $1;
		Node* temp = (Node*)$1;			
		new->realValue=temp->realValue;		
		new->intValue=temp->intValue;
		new->boolValue=temp->boolValue;
		new->semTypeDef = temp->semTypeDef;
		strcpy(new->identLex, temp->identLex);
		new->place=temp->place;
		strcpy(new->code,temp->code);
		$$ = new;
	}
	;

unconditionalStatement :
	basicStatement
	{
		Node *new = createNode();         	
        	new->type = unconditionalStatement;
        	new->pt0 = $1;
		Node *temp1 = $1;
		new->semTypeDef=temp1->semTypeDef;
		strcpy(new->code,temp1->code);
		$$ = new;
	}
	|
        compoundStatement
	{
		Node *new = createNode();         	
        	new->type = unconditionalStatement;
        	new->pt0 = $1;
		Node *temp1 = $1;
		new->semTypeDef=temp1->semTypeDef;
		strcpy(new->code,temp1->code);
		$$ = new;
	}
	|
	block
	{
		Node *new = createNode();
        	new->type = unconditionalStatement;
        	new->pt0 = $1;
		Node *temp1 = $1;
		new->semTypeDef=temp1->semTypeDef;
		strcpy(new->code,temp1->code);
		$$ = new;
	}
	;

conditionalStatement :
	ifStatement
	{
		Node *newNode = createNode();         	
        	newNode->type = conditionalStatement;
        	newNode->pt0 = $1;
		Node *tempNode = $1;
		newNode->semTypeDef=tempNode->semTypeDef;
		newNode->place=tempNode->place;
		sprintf(newNode->code,"%slabel%d:\n",tempNode->code,tempNode->intValue);
		$$ = newNode;
	}
	|
        ifStatement TOKEN_ELSE statement
	{
		Node *newNode = createNode();         	
        	newNode->type = conditionalStatement;
        	newNode->pt0 = $1 ;  
		newNode->pt2 = $3 ;  
		Node *tempNode1 = $1 ;  
		Node *tempNode2 = $3 ;
		int label=getNewLabel();
		sprintf(newNode->code,"%sb\tlabel%d\nlabel%d:\n%slabel%d:\n",tempNode1->code,label,tempNode1->intValue,tempNode2->code,label);
		if (tempNode1->semTypeDef==storeVoid && tempNode2->semTypeDef==storeVoid ) {  
			newNode->semTypeDef=storeVoid ;  
		}
		$$ = newNode;
	}
	|
        ifClause forStatement
	{
		Node *newNode = createNode();         	
		newNode->type = conditionalStatement;
		newNode->pt0 = $1;  
		newNode->pt1 = $2;  
		Node *tempNode1=$1;
		Node *tempNode2=$2;
		int label = getNewLabel();
		if (tempNode1->semTypeDef==storeBoolean && tempNode2->semTypeDef==storeVoid ) {  
			newNode->semTypeDef==storeVoid ;  
			sprintf(newNode->code,"%sli\t$t0,0\nlw\t$t1,%d($sp)\nbeq\t$t1,$t0,label%d\n%slabel%d:\n",tempNode1->code,tempNode1->place,label,tempNode2->code,label) ;
		}
		else {
			newNode->semTypeDef==storeError;
		}
		$$=newNode;
	}
	|
	tlabel conditionalStatement
	{
		Node* newNode = createNode();
		Node* tempNode1 = $1;
		Node* tempNode2 = $2;
		int label = getNewLabel();
		sprintf(newNode->code,"b\tlabel%d\n%s:\n%slabel%d:\n",label,tempNode1->identLex,tempNode2->code,label);
		$$=newNode;	
	}		
	;

ifStatement :
	ifClause unconditionalStatement 
	{
		Node *newNode = createNode();         	
        	newNode->type = ifStatement;
        	newNode->pt0 = $1;
		newNode->pt1 = $2;
		Node *tempNode1 = $1;
		Node *tempNode2 = $2;
		int label = getNewLabel();
		newNode->intValue = label;
		sprintf(newNode->code,"%sli\t$t0,0\nlw\t$t1,%d($sp)\nbeq\t$t1,$t0,label%d\n%s",tempNode1->code,tempNode1->place,label,tempNode2->code);  
		newNode->place = tempNode1->place;
		if (tempNode1->semTypeDef==storeBoolean) {  
			newNode->semTypeDef=tempNode2->semTypeDef;
		}
		else {
			newNode->semTypeDef=storeError;
		}
		$$ = newNode;
	}
	;

ifClause :
	TOKEN_IF booleanExpression TOKEN_THEN
	{
		Node *newNode = createNode();
        	newNode->type = ifClause;
        	newNode->pt1 = $2;
                Node* tempNode = (Node*)$2;
		newNode->place = tempNode->place;
		strcpy(newNode->code,tempNode->code);
		if (tempNode->semTypeDef==storeBoolean) {  
			newNode->semTypeDef=storeBoolean ;  
		}
		else {  
			newNode->semTypeDef=storeError ;  
		}
		$$ = newNode;  
	}
	;

basicStatement :
	unlabelledBasicStatement
	{
		Node *new = createNode();         	
        	new->type = basicStatement;
        	new->pt0 = $1 ;  
		Node *temp = $1 ;  
		new->semTypeDef=temp->semTypeDef ;
		strcpy(new->code,temp->code);  
		$$ = new;
	}
	|
        tlabel basicStatement
	{
		Node* newNode = createNode();
		Node* tempNode1 = $1;
		Node* tempNode2 = $2;
		int label = getNewLabel();
		sprintf(newNode->code,"b\tlabel%d\n%s:\n%slabel%d:\n",label,tempNode1->identLex,tempNode2->code,label);
		$$=newNode;	
	}
	;

unlabelledBasicStatement :
	assignmentStatement
	{		
		Node *new = createNode();         	
        	new->type = unlabelledBasicStatement; 
        	new->pt0 = $1 ; 
		Node *temp = $1 ;  
		new->semTypeDef=temp->semTypeDef ;
		strcpy(new->code,temp->code);
		$$ = new;
	}
	|
	dummyStatement
	{
		Node *new = createNode();         	
        	new->type = unlabelledBasicStatement;
        	new->pt0 = $1 ;  
		Node *temp = $1 ;  
		strcpy(new->code,"");
		new->semTypeDef=temp->semTypeDef ;  
		$$ = new;
	}
	|
	procedureStatement
	{
		Node *new = createNode();         	
        	new->type = unlabelledBasicStatement;
        	new->pt0 = $1 ;  
		Node *temp = $1 ;  
		new->semTypeDef=temp->semTypeDef ;  
		strcpy(new->code,temp->code);
		$$ = new;
	}
	|
	returnStatement
	{
		Node* newNode = createNode();
		Node *tempNode = $1;
		strcpy(newNode->code,tempNode->code);
		$$ = $1;
	}
	|
	gotoStatement
	{
		Node* newNode = createNode();
		Node* tempNode = $1;
		strcpy(newNode->code,tempNode->code);
	}
	;

dummyStatement :
	empty
	;
	
returnStatement :
	TOKEN_RETURN expression
	{
		Node *newNode = createNode();
                newNode->type = returnStatement;
		Node *tempNode = $2 ;
		sprintf(newNode->code,"%slw\t$v0,%d($sp)\njr\t$ra\n",tempNode->code,tempNode->place);
		if(tempNode->semTypeDef==storeError)
		{
			newNode->semTypeDef=storeError;
		}
		else
		{
			newNode->semTypeDef = tempNode->semTypeDef;
		}
		$$ = newNode;
	}
        ;

assignmentStatement :
	variable TOKEN_ASSIGN arithmeticExpression  
	{
		Node *new = createNode();         	
        	new->type = assignmentStatement;
        	new->pt0 = $1;
		new->pt2 = $3;
		Symbol *symbol1;	
		Node *tmp1=$1;
		Node *tmp2=$3;
		new->semTypeDef=storeVoid;
  		symbol1=lookUp(tmp1->identLex, getCurrentScope());
		if (symbol1==NULL){
			new->semTypeDef=storeError;
		}
		else{
			if (symbol1->type==storeInteger && tmp2->semTypeDef==storeInteger){								
				// SYMBOL1>TYPE IS INTEGER  
				symbol1->value = tmp2->intValue;
				int offset;
				if(tmp1->isArray==1){
					offset = tmp1->place;
				}
				else{
					offset = symbol1->offset;
				}
				sprintf(new->code,"%s%slw\t$t0,%d($sp)\nsw\t$t0,%d($sp)\n",tmp1->code,tmp2->code,tmp2->place,offset);
			}
			else if (symbol1->type==storeReal && tmp2->semTypeDef==storeReal){								
				// SYMBOL1>TYPE IS Real
		  		symbol1->realValue=tmp2->realValue;
				int offset;
				if(tmp1->isArray==1){
					offset = tmp1->place;
				}
				else{
					offset = symbol1->offset;
				}
				sprintf(new->code,"%s%sl.s\t$f0,%d($sp)\ns.s\t$f0,%d($sp)\n",tmp1->code,tmp2->code,tmp2->place,offset);
						
			}
			else if(symbol1->type==storeReal && tmp2->semTypeDef==storeInteger){
				symbol1->realValue = (tmp2->intValue)*1.0;
				int offset;
				if(tmp1->isArray==1){
					offset = tmp1->place;
				}
				else{
					offset = symbol1->offset;
				}
				sprintf(new->code,"%s%slw\t$t0,%d($sp)\nmtc1\t$t0,$f0\ncvt.s.w\t$f0,$f0\ns.s\t$f0,%d($sp)\n",tmp1->code,tmp2->code,tmp2->place,offset);
				
			}
			else{	
				printf("error: inconsistent Types in assignment\n");
				new->semTypeDef = storeError;
			}
		}
		$$ = new;
	}
	|
	variable TOKEN_ASSIGN booleanExpression
	{
		Node *new = createNode();         	
        	new->type = assignmentStatement;
        	new->pt0 = $1;
		new->pt2 = $3;
		
	
		Node *temp1=$1;
		Node *temp2=$3;
		Symbol *symbol2=lookUp(temp1->identLex,getCurrentScope());
		new->semTypeDef=storeVoid ;  
		


		if (symbol2==NULL){
			new->semTypeDef=storeError;  
		
		}
		else{
			if (symbol2->type==storeBoolean==storeBoolean && temp2->semTypeDef==storeBoolean) {  
				symbol2->boolean=temp2->boolValue;
				int offset;
				if(temp1->isArray==1){
					offset = temp1->place;
				}
				else{
					offset = symbol2->offset;
				}
				sprintf(new->code,"%s%slw\t$t0,%d($sp)\nsw\t$t0,%d($sp)\n",temp1->code,temp2->code,temp2->place,offset);
			}
		}
		$$ = new;
	}
	;

forStatement :
	TOKEN_FOR variable TOKEN_ASSIGN arithmeticExpression TOKEN_STEP arithmeticExpression TOKEN_UNTIL arithmeticExpression TOKEN_DO statement
	{  
		Node *new = createNode();
		Node *temp = $2;
		Node *temp2 = $4;
		Node *temp3 = $6;
		Node *temp4 = $8;
		Node *temp5 = $10;
		Symbol *symbol=lookUp(temp->identLex,getCurrentScope());
		if (symbol == NULL) {  
			temp->semTypeDef=storeError;
		}
		else {
			if (!(symbol->type==storeInteger || symbol->type==storeReal)) {
				temp->semTypeDef=storeError;
			}
		}
		if (temp->semTypeDef==storeError) {  
			new->semTypeDef=storeError;
			$$ = new;
		}
		else {
			int label1 = getNewLabel();
			int label2 = getNewLabel();
			int offset = symbol->offset;
			sprintf(new->code,"%slw\t$t0,%d($sp)\nsw\t$t0,%d($sp)\nlabel%d:\n%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nbge\t$t0,$t1,label%d\n%s%slw\t$t0,%d($sp)\nlw\t$t1,%d($sp)\nadd\t$t2,$t0,$t1\nsw\t$t2,%d($sp)\nb\tlabel%d\nlabel%d:\n",temp2->code,temp2->place,offset,label1,temp4->code,temp->place,temp4->place,label2,temp5->code,temp3->code,offset,temp3->place,offset,label1,label2);
			$$=new;
		}
	}
	;

empty :	
	{	
		Node *new = createNode();         	            	  
		new->type =empty;
		$$ = new;
	}
	;

procedureStatement :
	procedureIdentifier actualParameterPart {
		Node *new = createNode();
		Node *temp1 = $1;
		Node *temp2 = $2;
		Symbol *symbol= lookUp(temp1->identLex,getCurrentScope());
		if(symbol == NULL)
		{
			new->semTypeDef = storeError;
		}
		else
		{
			new->semTypeDef = symbol->type;
			new->place = getNewTempOffset();
			sprintf(new->code, "sw\t$t0,-996($sp)\nsw\t$t1,-992($sp)\nsw\t$t2,-988($sp)\nsw\t$t3,-984($sp)\nsw\t$t4,-980($sp)\nsw\t$t5,-976($sp)\nsw\t$t6,-972($sp)\nsw\t$t7,-968($sp)\nsw\t$ra,-964($sp)\n%sli\t$t0,100\nsub\t$sp,$sp,$t0\njal\t%s\nli\t$t0,100\nadd\t$sp,$sp,$t0\nlw\t$t0,-996($sp)\nlw\t$t1,-992($sp)\nlw\t$t2,-988($sp)\nlw\t$t3,-984($sp)\nlw\t$t4,-980($sp)\nlw\t$t5,-976($sp)\nlw\t$t6,-972($sp)\nlw\t$t7,-968($sp)\nlw\t$ra,-964($sp)\nsw\t$v0,%d($sp)\n",temp2->code,temp1->identLex,new->place);
		}
		$$ = new; 
	}
	;

procedureIdentifier :
	identifier
	{
		Node *new = createNode(); 
		new->type = procedureIdentifier;
		new->pt0 = $1;
		Node *temp=$1;
		strcpy(new->identLex,temp->identLex);
		$$ = new;
	}
	;

actualParameterPart :
	TOKEN_OPEN_BRACKET TOKEN_CLOSE_BRACKET
	|
	TOKEN_OPEN_BRACKET actualParameterList TOKEN_CLOSE_BRACKET
	{
		Node *temp = $2;
		if(temp->semTypeDef != storeError)
		{		
			temp->semTypeDef == storeVoid;
		}
		$$=$2;
	}
	;

actualParameterList :
	actualParameter
	{
		Node *temp = $-1;
		Node *temp1 = $1;
		Symbol* symbol= lookUp(temp1->identLex,getCurrentScope());
		Node *new = createNode();
		new->dim = 0;
		sprintf(new->code,"%slw\t$t0,%d($sp)\nsw\t$t0,%d($sp)\n",temp1->code,temp1->place,-100-4* new->dim);
		new->semTypeDef = storeVoid;
		$$ = new;
	}
	|
        actualParameterList parameterDelimiter actualParameter  
	{
		Node *temp = $-1;
		Node *temp3 = $1;
		Node *temp1 = $3;
		Symbol* symbol= lookUp(temp->identLex,getCurrentScope());
		Node *new = createNode();
		new->dim = 1 + temp3->dim;
		if (temp3->semTypeDef == storeError)
			new->semTypeDef = storeError;
		else {
			new->semTypeDef = storeVoid;
			sprintf(new->code,"%s%slw\t$t0,%d($sp)\nsw\t$t0,%d($sp)\n",temp3->code,temp1->code,temp1->place,-100-4* new->dim);			
		}	
		$$ = new;
	}
	;

actualParameter :
	expression
	{
		Node *newNode = createNode(); 
		Node *tempNode = $1; 
		newNode->type = actualParameter;
		newNode->semTypeDef = tempNode->semTypeDef;
		newNode->pt0 = $1;
		newNode->place = tempNode->place;
		strcpy(newNode->code, tempNode->code);
		$$ = newNode;
	}
	;

parameterDelimiter :
        TOKEN_COMMA
	| TOKEN_CLOSE_BRACKET identifier TOKEN_COLON TOKEN_OPEN_BRACKET
	;

functionDesignator :
	procedureIdentifier actualParameterPart
	{
		Node *new = createNode();
		Node *temp1 = $1;
		Node *temp2 = $2;
		Symbol *symbol= lookUp(temp1->identLex,getCurrentScope());
		if(symbol == NULL)
		{
			new->semTypeDef = storeError;
		}
		else
		{
			new->semTypeDef = symbol->type;
			new->place = getNewTempOffset();
			sprintf(new->code, "sw\t$t0,-996($sp)\nsw\t$t1,-992($sp)\nsw\t$t2,-988($sp)\nsw\t$t3,-984($sp)\nsw\t$t4,-980($sp)\nsw\t$t5,-976($sp)\nsw\t$t6,-972($sp)\nsw\t$t7,-968($sp)\nsw\t$ra,-964($sp)\n%sli\t$t0,100\nsub\t$sp,$sp,$t0\njal\t%s\nli\t$t0,100\nadd\t$sp,$sp,$t0\nlw\t$t0,-996($sp)\nlw\t$t1,-992($sp)\nlw\t$t2,-988($sp)\nlw\t$t3,-984($sp)\nlw\t$t4,-980($sp)\nlw\t$t5,-976($sp)\nlw\t$t6,-972($sp)\nlw\t$t7,-968($sp)\nlw\t$ra,-964($sp)\nsw\t$v0,%d($sp)\n",temp2->code,temp1->identLex,new->place);
		}
		$$ = new; 
	}
	;

statement :
	unconditionalStatement
	{
		Node* newNode=createNode();
		Node *tempNode=$1;
		newNode->semTypeDef = tempNode->semTypeDef;
		strcpy(newNode->code,tempNode->code);
		$$=newNode;
	}
	|
        conditionalStatement
	{
		Node* newNode=createNode();
		Node *tempNode=$1;
		newNode->semTypeDef = tempNode->semTypeDef;
		strcpy(newNode->code,tempNode->code);
		$$=newNode;

	}
	|
	forStatement
	{	Node* newNode=createNode();
		Node *tempNode=$1;
		newNode->semTypeDef = tempNode->semTypeDef;
		strcpy(newNode->code,tempNode->code);
		$$=newNode;
	}
	|
	TOKEN_PRINT expression
	{
		Node* newNode=createNode();
		Node* tempNode=$2;
		newNode->semTypeDef = tempNode->semTypeDef;
		if(newNode->semTypeDef==storeReal){
			sprintf(newNode->code,"%sli\t$v0,4\nla\t$a0, MSG\nsyscall\nl.s\t$f10,%d($sp)\nmov.s\t$f12,$f10\nli\t$v0,2\nsyscall\n",tempNode->code,tempNode->place);
		}
		else{
			sprintf(newNode->code,"%sli\t$v0,4\nla\t$a0, MSG\nsyscall\nlw\t$t0,%d($sp)\nli\t$v0,1\nmove\t$a0,$t0\nsyscall\n",tempNode->code,tempNode->place);
		}
		$$=newNode;
	}
	;

formalParameter :
	identifier
	{
		$0=$-1;
		Node *node0 = $0;
		Node *node1 = $1;

		int globalLevelPlusOne = getGlobalLevel() + 1;
		if (lookUpInCurrentScope(node1->identLex, globalLevelPlusOne) == NULL){
		  Symbol * entry = addEntry(node1->identLex, globalLevelPlusOne);
			entry->offset = getCurrentOffset(globalLevelPlusOne);
			setCurrentOffset(globalLevelPlusOne, getCurrentOffset(globalLevelPlusOne) - 4);
		}
		else{
			printf("warning: paramaters,%s already defined\n",node1->identLex);
		}

		if (lookUpInCurrentScope(node0->identLex, getCurrentScope()) == NULL){
		  Symbol * entry = addEntry(node1->identLex, getCurrentScope());
			entry->procNumParam++;
		}
		$$ = $0;
	};
	
formalParameterList :
	formalParameter
	| formalParameterList parameterDelimiter formalParameter
	{
		$1=$0;
		$2=$0;
	}
	;

formalParameterPart :
	empty
	{
		$$ = $0;
	}
	| TOKEN_OPEN_BRACKET
	{
		$1 = $0;
	}
        formalParameterList TOKEN_CLOSE_BRACKET
	;

identifierList :
	identifier
	{
		Node *node1 = $0;
		Node *node2 = $1;
		Symbol *symbol1=lookUp(node2->identLex,getGlobalLevel() + 1);
		if (symbol1 != NULL) {
			symbol1->type=node1->semTypeDef;		
		}
		else {
			printf("error: %s is absent from formal paramater",node2->identLex);
		}
		$$ = node1;
	}
	| identifierList TOKEN_COMMA identifier
	{
		Node *node1 = $1;
		Node *node2 = $3;
		Symbol *symbol1=lookUp(node2->identLex,getGlobalLevel() + 1);
		if (symbol1 != NULL) {
			symbol1->type=node1->semTypeDef;		
		}
		else {
			printf("error: %s is absent from formal paramater",node2->identLex);
		}
		$$ = node1;
	}
        ;

valuePart :  TOKEN_VALUE identifierList TOKEN_SEMICOLON
        {
		$3 = $0;
	}
	| empty;

specifier :
	type
	| type TOKEN_ARRAY
	| TOKEN_TYPE_LABEL 
	| TOKEN_SWITCH 
	| type TOKEN_PROCEDURE;

specificationPart :
        empty
	| specificationIdentifierList;

specificationIdentifierList :
        specifier identifierList TOKEN_SEMICOLON
	{
		Node *node1 = $1;
	}
	| specificationIdentifierList specifier identifierList TOKEN_SEMICOLON
	;

procedureHeading :
	procedureIdentifier
	{
		Node *node = createNode();
		node->type = procedureHeading;
		node->pt0 = $1;
		Node *node1 = $1;
		node1->parent = node;
		strcpy(node->identLex, node1->identLex);
		if (lookUpInCurrentScope(node1->identLex, getCurrentScope()) == NULL) {
		  Symbol * entry = addEntry(node1->identLex, getCurrentScope());
			entry->procNumParam = 0;
		}
		$$ = node;
	}
        formalParameterPart TOKEN_SEMICOLON
	{
		$3 = $1;
	}
        valuePart specificationPart
	;

procedureBody :
	statement
	{
		Node *new = createNode();
		new->type = procedureBody;
		Node *temp = $1;
		new->semTypeDef = temp->semTypeDef;
		strcpy(new->code,temp->code);
		$$ = new;
	}
        ;

procedureDeclaration : 
	TOKEN_PROCEDURE procedureHeading procedureBody
	{
		Node *node1 = $2;
		Node *node2 = $3;
		Symbol* symbol = lookUp(node1->identLex, getCurrentScope());
		symbol->type = storeVoid;
		Node *node = createNode();
		node->type = procedureDeclaration;
		if (node1->semTypeDef == storeVoid && node2->semTypeDef == storeVoid) {
			node->semTypeDef = storeVoid;
		}
		else {
			node->semTypeDef = storeError;
		}
		int label = getNewLabel();
		sprintf(node->code,"b\tlabel%d\n%s:\n%s\njr $ra\nlabel%d:\n",label,node1->identLex,node2->code,label);		
		$$ = node;
	}
	| type TOKEN_PROCEDURE procedureHeading procedureBody
	{
		Node *node1 = $3;
		Node *node2 = $4;
		Node *node3 = $1;
		Symbol* symbol = lookUpInCurrentScope(node1->identLex, getCurrentScope());
		symbol->type = node3->semTypeDef;
		Node *node = createNode();
		node->type = procedureDeclaration;
		if (node1->semTypeDef == storeVoid && node2->semTypeDef == storeVoid) {
			node->semTypeDef = node3->semTypeDef;
		}
		else {
			node->semTypeDef = storeError;
		}
		int label = getNewLabel();
		sprintf(node->code,"b\tlabel%d\n%s:\n%s\njr $ra\nlabel%d:\n",label,node1->identLex,node2->code,label);		
		$$ = node;
	}
        ;

gotoStatement :
	TOKEN_GOTO designationalExpression
	{
		Node* newNode=createNode();
		Node* tempNode = $2;
		sprintf(newNode->code,"b\t%s\n",tempNode->identLex);
		$$=newNode;
	};

switchDeclaration :
	TOKEN_SWITCH switchIdentifier TOKEN_ASSIGN switchList;

switchList :
	designationalExpression
	|
	switchList TOKEN_COMMA designationalExpression
	;

switchIdentifier :
	identifier
	{
		Node *newNode = createNode();
		newNode->type= switchIdentifier;
		newNode->pt0=$1;
		Node* tempNode = $1;
		strcpy(newNode->identLex,tempNode->identLex);
		$$=newNode;
	}
	;

designationalExpression :
	simpleDesignationalExpression
	{
		Node* newNode=createNode();
		Node* tempNode = $1;
		strcpy(newNode->identLex,tempNode->identLex);
		$$=newNode;
	}
	|
	ifClause simpleDesignationalExpression TOKEN_ELSE designationalExpression
	;

simpleDesignationalExpression : 
	tlabel
	{
		Node* newNode=createNode();
		Node* tempNode = $1;
		strcpy(newNode->identLex,tempNode->identLex);
		$$=newNode;
	}
	|
	switchDesignator
	|
	TOKEN_OPEN_BRACKET designationalExpression TOKEN_CLOSE_BRACKET
	;

switchDesignator :
	switchIdentifier TOKEN_OPEN_CURLY_BRACKET subscriptExpression TOKEN_CLOSE_CURLY_BRACKET
	;

%%
