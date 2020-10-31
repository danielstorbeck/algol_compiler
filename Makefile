LEX = lex
YACC = yacc
CC = gcc

algol: y.tab.o lex.yy.o 
	$(CC) y.tab.o lex.yy.o
y.tab.c y.tab.h: parser.y
	$(YACC) -v -d parser.y
y.tab.o: y.tab.c
	$(CC) -c y.tab.c
lex.yy.o: y.tab.h lex.yy.c
	$(CC) -c lex.yy.c
lex.yy.c: lexer.l
	$(LEX) -i lexer.l
clean:
	rm *.o a.out
	rm y.output y.tab.c y.tab.h
	rm lex.yy.c
check:
	bash run-tests.sh
