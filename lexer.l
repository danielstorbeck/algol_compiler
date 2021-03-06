%{

#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <string.h>
#include <stdbool.h>
#include "y.tab.h"
#include "symbolTable.h"

int lineNo = 1;

void errorMessage() {
        fprintf(stderr,"scanning error on line %d: invalid input character ->%s<-\n", lineNo, yytext);
}

%}

letter			[a-zA-Z]
digit	 		[0-9]
logical_value		"true"|"false"

arithmetic_operator	"+"|"-"|"*"|"/"|"**"
relational_operator	"<"|"<="|"="|">"|">="|"<>"
logical_operator	"|"|"&"|"!"
sequential_operator	"goto"|"if"|"then"|"else"|"for"|"do"
operator		{logical_operator}|{arithmetic_operator}|{relational_operator}|{sequential_operator}

separator		","|"."|"\'10\'"|":"|";"|":="|" "|"step"|"until"|"while"|"comment"
bracket			"("|")"|"["|"]"|"`"|"'"|"begin"|"end"
declarator		"own"|"Boolean"|"integer"|"real"|"array"|"switch"|"procedure"
specificator		"string"|"label"|"value"

delimiter		{operator}|{separator}|{bracket}|{declarator}|{specificator}

basic_symbol		{letter}|{digit}|{logical_value}|{delimiter}

identifier		{letter}({letter}|{digit})*

unsigned_integer	{digit}+
integer			{unsigned_integer}
decimal_fraction	"."{unsigned_integer}
exponential_part	"\'10\'"{integer}
decimal_number		{unsigned_integer}|{decimal_fraction}|{unsigned_integer}{decimal_fraction}
unsigned_number		{decimal_number}|{exponential_part}|{decimal_number}{exponential_part}
real_number		{unsigned_number}

white			" "|"\t"
newline			"\n"
library			"sin"|"cos"|"tan"|"abs"|"sign"|"sqrt"|"ln"|"exp"|"arctan"|"arcsin"|"arccos"

%%

{newline}		{lineNo++;}
			
COMMENT[^.;]*;		{
			 char *tempString = (char *)yytext;
			 int i = 0;
			 while(tempString != NULL) {
				if (tempString[0]=='\n') {lineNo++;}
				tempString++;
			 }
			}
			
"begin"			{
			 increaseGlobalLevel();
			 pushScope();
			 return TOKEN_BEGIN ;
			}
			
"end"			{
			 popScope();
			 return TOKEN_END;
			}

{white}*		{}

{logical_value}		{return TOKEN_LOGICAL_VALUE;}

"+"			{return TOKEN_PLUS ;}
"-"			{return TOKEN_MINUS;}
"/"			{return TOKEN_DIVIDE;}
"*"			{return TOKEN_MULTIPLY;}
"**"			{return TOKEN_POWER;}

{relational_operator}	{return TOKEN_REL_OP;}

","			{return TOKEN_COMMA ;}
";"			{return TOKEN_SEMICOLON ;}
":="			{return TOKEN_ASSIGN ;}
":"			{return TOKEN_COLON ;}
"_"			{return TOKEN_UNDERSCORE ;}

"!"			{return TOKEN_NOT_OP ;}
"|"			{return TOKEN_OR_OP ;}
"&"			{return TOKEN_AND_OP ;}
"=>"			{return TOKEN_IMPLY ;}
"==" 			{return TOKEN_EQUIV;}

"goto"			{return TOKEN_GOTO ;}
"if"			{return TOKEN_IF ;}
"then"			{return TOKEN_THEN ;}
"else"			{return TOKEN_ELSE ;}
"for"			{return TOKEN_FOR ;}
"do"			{return TOKEN_DO ;}
"return"		{return TOKEN_RETURN ;}

"step"			{return TOKEN_STEP ;}
"until"			{return TOKEN_UNTIL;}
"while"			{return TOKEN_WHILE;}

"("			{return TOKEN_OPEN_BRACKET;}
")"			{return TOKEN_CLOSE_BRACKET;}
"{"                     {return TOKEN_OPEN_CURLY_BRACKET;}
"}"			{return TOKEN_CLOSE_CURLY_BRACKET;}
"["			{return TOKEN_OPEN_SQUARE_BRACKET;}
"]"			{return TOKEN_CLOSE_SQUARE_BRACKET;}
{bracket}		{return TOKEN_BRACKET;}

"own"			{return TOKEN_TYPE_OWN;}
"boolean"		{return TOKEN_TYPE_BOOLEAN;}
"integer"		{return TOKEN_TYPE_INTEGER;}
"real"			{return TOKEN_TYPE_REAL;}
"array"			{return TOKEN_ARRAY;}
"switch"		{return TOKEN_SWITCH;}
"procedure"		{return TOKEN_PROCEDURE;}
"print"			{return TOKEN_PRINT;}
"label"			{return TOKEN_TYPE_LABEL;}
"value"			{return TOKEN_VALUE;}

{specificator}		{return TOKEN_SPECIFIER;}

{library}		{return TOKEN_LIBRARY;}

{identifier}		{return TOKEN_IDENTIFIER;}

{integer}		{return TOKEN_INTEGER;}

{real_number}		{return TOKEN_REAL_NUM;}

.			{errorMessage();
			 return 0;
			}

<<EOF>>			{return 0;}

%%
