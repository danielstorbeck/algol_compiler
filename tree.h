#ifndef TREE_H
#define TREE_H

# include <stdio.h>
# include <stdbool.h>
# include <stdlib.h>

enum tag {TOKEN_ID,//TOKEN_SEPARATOR,
	lowerBound,
	upperBound,
	boundPair,
	semTypeDef,
	storeInteger,
	storeBoundPairList,
	storeReal,
	storeBoolean,
	storeVoid,
	storeError,
	boundPairList,
	arrayIdentifier,
	expression,
	arithmeticExpression,
	simpleExpression,
	booleanExpression,
	term,
	subscriptExpression,
	label,
	addingOperator,
	multiplyingOperator,
	factor,
	primary,
	unsignedNumber,
	realNumber,
	integer,
	variable,
	simpleVariable,
	subscriptedVariable,
	simpleArithmeticExpression,
	subscriptList,
	identifier,
	implication,
	booleanTerm,
	booleanFactor,
	booleanSecondary,
	booleanPrimary,
	logicalValue,
	relation,
	arraySegment,
	relationalOperator,
	varIdentifier,
	unconditionalStatement,
	conditionalStatement,
	type,
	returnStatement,
	ifStatement,
	ifClause,
	basicStatement,
	unlabelledBasicStatement,
	assignmentStatement,
	empty,
	boolVariable,
	boolSimpleVariable,
	procedureIdentifier,
	procedureBody,
	procedureDeclaration,
	actualParameter,
	procedureHeading,
	switchIdentifier
};

typedef struct Node {
	enum tag type;
	struct Node* parent;
	int intValue;
	float realValue;
	bool boolValue;
	char *identLex;
	int semTypeDef;
	int dim;
	int isArray;	
	int lowerBound[20];
	int upperBound[20];
	char code[99999];
	int place;
	struct Node* pt0;
	struct Node* pt1;
	struct Node* pt2;
	struct Node* pt3;
} Node;

extern Node* createNode();

#endif /* TREE_H */
