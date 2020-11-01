LEX = lex
YACC = yacc
CC = gcc

algol: y.tab.o lex.yy.o tree.o
	$(CC) y.tab.o lex.yy.o tree.o
tree.o: tree.c tree.h
	$(CC) -c tree.c tree.h
y.tab.c y.tab.h: parser.y tree.h
	$(YACC) -v -d parser.y
y.tab.o: y.tab.c tree.h
	$(CC) -c y.tab.c
lex.yy.o: y.tab.h lex.yy.c
	$(CC) -c lex.yy.c
lex.yy.c: lexer.l
	$(LEX) -i lexer.l
clean:
	rm *.o *.gch a.out y.output y.tab.c y.tab.h lex.yy.c
check:
	bash run-tests.sh
