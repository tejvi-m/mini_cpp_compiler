%{
%}


alphabet [a-zA-z_]
digit [0-9]

%%


\/\/(.*) {};
\/\*(.*\n)*.*\*\/  {};

\n yylineno++;

#include\ *<{alphabet}+(\.{alphabet}*)?> printf("%d\t%s\tPREPROCESSOR\n", yylineno, yytext);

return|main|for|while|case|switch|if|else|do|class printf("%d\t%s\tKEYWORD\n", yylineno, yytext);

int|float|char|struct printf("%d\t%s\tDATATYPE\n", yylineno, yytext);
long|short|unsigned|signed printf("%d\t%s\tDATATYPE MODIFIERS\n", yylineno, yytext);

\( printf("%d\t%s\tOPEN BRACKETS\n", yylineno,yytext);
\) printf("%d\t%s\tCLOSE BRACKETS\n", yylineno, yytext);

\{ printf("%d\t%s\tOPEN BRACES\n", yylineno, yytext);
\} printf("%d\t%s\tCLOSE BRACES\n", yylineno, yytext);

{alphabet}({alphabet}|{digit})* printf("%d\t%s\tIDENTIFIER\n", yylineno, yytext);

{digit}+ printf("%d\t%s\tINTEGER\n", yylineno, yytext);
{digit}+\.{digit}+(E(\+|\-)?{digit}+)? printf("%d\t%s\tFLOATING POINT NUMBER\n", yylineno, yytext);

==|!=|>=|<=|<|> printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext);
\+\+|-- printf("%d\t%s\tUNARY OPERATORS\n", yylineno, yytext);
\+|\-|\/|\*|% printf("%d\t%s\t BINARY OPERATORS\n", yylineno, yytext);
&&|\|\||! printf("%d\t%s\tLOGICAL OPERATORS\n", yylineno, yytext);

= printf("%d\t%s\tASSIGNMENT\n", yylineno, yytext);

; printf("%d\t%s\tTERMINATOR\n", yylineno, yytext);

\t ;

" " ;

\"(\\.|[^"\\])*\" printf("%d\t%s\tSTRING CONSTANT\n", yylineno, yytext);




%%


int yywrap(){
    return 1;
}

int main(int argc, char * argv[]){
    yyin=fopen(argv[1],"r");
    printf("LINE\tLEXME\tTOKEN\n");
    yylex();
    fclose(yyin);
    return 0;
}
