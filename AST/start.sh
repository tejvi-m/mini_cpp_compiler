lex tokens.l 
yacc -y -d parse.y  -Wall
gcc lex.yy.c y.tab.c -g -Wall
./a.out < test.cpp
