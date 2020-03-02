lex tokens.l
yacc -y -d parse.y
gcc lex.yy.c y.tab.c
./a.out < test1.c
