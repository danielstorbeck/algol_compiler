#include "tree.h"

Node* createNode() {
	Node *newNode = (Node*)malloc(sizeof(Node));
	newNode->parent = NULL;
	newNode->pt0 = NULL;
	newNode->pt1 = NULL;
	newNode->pt2 = NULL;
	newNode->pt3 = NULL; 
	newNode->identLex = (char*)malloc(15*sizeof(char));
	newNode->dim = -1;
	newNode->isArray = 0;
	return newNode;	
}

void displayNode(Node *node) {
	printf("PRINTING Node:\n");
	printf("LEXEME: %s",node->identLex);
	printf("SEMTYPEDEF: %d",node->semTypeDef);
	printf("INTEGER VALUE: %d",node->intValue);
	if(!(node->realValue)){
		printf("REAL VALUE: %f",node->realValue);}
	if(node->boolValue){
		printf("BOOLVALUE: TRUE");}
	printf("TYPE: %d",node->type);
	printf("Track: %d",node->dim);
}
