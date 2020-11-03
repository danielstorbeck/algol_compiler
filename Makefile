LEX = lex
YACC = yacc
CC = gcc

algol: y.tab.o lex.yy.o scopeStack.o symbolTable.o tree.o
	$(CC) y.tab.o lex.yy.o scopeStack.o symbolTable.o tree.o

scopeStack.o: scopeStack.c scopeStack.h symbolTable.h
	$(CC) -c scopeStack.c scopeStack.h

symbolTable.o: symbolTable.c symbolTable.h tree.h
	$(CC) -c symbolTable.c symbolTable.h

tree.o: tree.c tree.h
	$(CC) -c tree.c tree.h

y.tab.o: y.tab.c y.tab.h
	$(CC) -c y.tab.c

y.tab.c y.tab.h: parser.y scopeStack.h symbolTable.h tree.h
	$(YACC) -v -d parser.y

lex.yy.o: y.tab.h lex.yy.c
	$(CC) -c lex.yy.c

lex.yy.c: lexer.l
	$(LEX) -i lexer.l

clean:
	rm *.o *.gch a.out y.output y.tab.c y.tab.h lex.yy.c

check:
	bash run-tests.sh
