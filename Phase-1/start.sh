lex Phase-1/tokens.l
yacc -y -d parse.y
gcc lex.yy.c y.tab.c
./a.out < test.c
