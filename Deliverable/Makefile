parser: y.tab.c lex.yy.c data-structures.h display.h generate-code.h
	cc y.tab.c lex.yy.c -ll -o parser 
y.tab.c: parser.y
	yacc -d parser.y
lex.yy.c: scanner.l
	lex scanner.l

