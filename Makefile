LEX = lex
YACC = yacc
CC = gcc

algol: driver.o y.tab.o lex.yy.o symbolTable.o tree.o
	$(CC) driver.o y.tab.o lex.yy.o symbolTable.o tree.o

driver.o: driver.c y.tab.h y.tab.c
	$(CC) -c driver.c

symbolTable.o: symbolTable.c symbolTable.h tree.h
	$(CC) -c symbolTable.c symbolTable.h

tree.o: tree.c tree.h
	$(CC) -c tree.c tree.h

y.tab.o: y.tab.c y.tab.h
	$(CC) -c y.tab.c

y.tab.c y.tab.h: parser.y  symbolTable.h tree.h
	$(YACC) -v -d parser.y

lex.yy.o: y.tab.h lex.yy.c
	$(CC) -c lex.yy.c

lex.yy.c: lexer.l
	$(LEX) -i lexer.l

clean:
	rm *.o *.gch a.out y.output y.tab.c y.tab.h lex.yy.c

check:
	bash run-tests.sh
