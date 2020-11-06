#include <stdio.h>
#include <string.h>
#include "symbolTable.h"
#include "y.tab.h"

extern char code[];
extern FILE *yyin;

int main(int argc, char* argv[]) {
  int i;
  initializeSymbolTable();
	for(i=1;i<argc;i++)
	{
	  yyin = fopen(argv[i], "r");
	  while(yyparse() != 0)
		;
	}
	//printf("%s",code);
	//check while merging the codes
	char code1[99999];
	strcpy(code1,"b\tmain\n");
	strcat(code1,code);
	strcat(code1,"jr\t$ra");
	strcat(code1,"\n\n\t.data\nMSG:\t.asciiz \"\\n OUTPUT = \"");
	FILE* fp1 = fopen("code1.asm","w");
	fprintf(fp1,"%s",code1);
	return 0;
}

