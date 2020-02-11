# Mini Compiler

A compiler to work on a subset of C++

token generation on a file ```filename.c```:
``` 
lex tokens.lex
gcc lex.yy.c
./a.out filename.c

```
passing the stream of tokens, as of now from stdout, to the parser for validation:
```
lex genTokens.l
yacc -y -d parse.y
gcc lex.yy.c y.tab.c
./a.out

```
