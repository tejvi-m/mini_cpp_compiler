# Mini Compiler

A compiler to work on a subset of C++

token generation on a file ```filename.c```:
``` 
lex tokens.lex
gcc lex.yy.c
./a.out filename.c

```
