%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define YYSTYPE struct astnode*
    extern YYSTYPE yylval;

    #include "y.tab.h"

    typedef struct astnode{
      char name[100];
      struct astnode** children;
    }astnode;

%}



alphabet [a-zA-z_]
digit [0-9]

%%

\/\/(.*) {};
\/\*(.*\n)*.*\*\/  {};

\n {yylineno++;}

int {printf("%d\t%s\tTYPE\n", yylineno, yytext); yylval = strdup(yytext); return INT;}
float {printf("%d\t%s\tTYPE\n", yylineno, yytext);  yylval = strdup(yytext); return FLOAT;}
char {printf("%d\t%s\tTYPE\n", yylineno, yytext);  yylval = strdup(yytext); return CHAR;}
"main()" {printf("%d\t%s\tKEYW\n", yylineno, yytext); return MAINTOK;}
for {printf("%d\t%s\tKEYW\n", yylineno, yytext); return FOR;}
while {printf("%d\t%s\tKEYW\n", yylineno, yytext); return WHILE;}

return {printf("%d\t%s\tKEYW\n", yylineno, yytext); return RETURN;}
if {printf("%d\t%s\tKEYW\n", yylineno, yytext); return IF;}
else {printf("%d\t%s\tKEYW\n", yylineno, yytext); return ELSE;}


cout {printf("%d\t%s\tKEYW\n", yylineno, yytext);yylval = strdup(yytext); return COUT;}
endl {printf("%d\t%s\tKEYW\n", yylineno, yytext); return ENDL;}
break {printf("%d\t%s\tKEYW\n", yylineno, yytext); return BREAK;}
continue {printf("%d\t%s\tKEYW\n", yylineno, yytext); return CONTINUE;}

{alphabet}({alphabet}|{digit})* {

                                printf("%d\t%s\tID\n", yylineno, yytext);
                                yylval = strdup(yytext);
                                return ID;}

"#include"  {printf("%d\t%s\tKEYW\n", yylineno, yytext); return INCLUDE;}

{alphabet}({alphabet}|{digit})*"\.h"?  {printf("%d\t%s\tPREPROCESSOR\n", yylineno, yytext); return H;}





\( {printf("%d\t%s\tOPEN BRACKETS\n", yylineno,yytext); return OB;}
\) {printf("%d\t%s\tCLOSE BRACKETS\n", yylineno, yytext); return CB;}



\{ { printf("%d\t%s\tOPEN BRACES\n", yylineno, yytext); return OBR;}
\} { printf("%d\t%s\tCLOSE BRACES\n", yylineno, yytext); return CBR;}


{digit}+ {printf("%d\t%s\tINTEGER\n", yylineno, yytext); yylval = strdup(yytext); return NUM;}
{digit}+\.{digit}+(E(\+|\-)?{digit}+)? {printf("%d\t%s\tFLOATING POINT NUMBER\n", yylineno, yytext); return FLT;}

\".*\" {printf("%d\t%s\tSTRING CONSTANT\n", yylineno, yytext);  yylval = strdup(yytext); return STRING;}
"==" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); yylval = strdup(yytext); return T_eqeq;}
"!=" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); yylval = strdup(yytext);  return T_neq;}
">=" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext);  yylval = strdup(yytext); return T_gteq;}
"<=" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); yylval = strdup(yytext);  return T_lteq;}
"<" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); yylval = strdup(yytext);  return T_lt;}
">" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext);  yylval = strdup(yytext); return T_gt;}
\+\+ {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); yylval = strdup(yytext);  return T_incr;}
-- {printf("%d\t%s\tUNARY OPERATORS\n", yylineno, yytext); yylval = strdup(yytext);  return T_decr;}

\+ {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); yylval = strdup(yytext); return T_pl;}
\- {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); yylval = strdup(yytext);  return T_min;}
\/ {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); yylval = strdup(yytext);  return T_div;}
\* {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); yylval = strdup(yytext); return T_mul;}
&& {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); yylval = strdup(yytext); return T_and;}
\|\| {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); yylval = strdup(yytext); return T_or;}
! {printf("%d\t%s\tLOGICAL OPERATORS\n", yylineno, yytext); yylval = strdup(yytext);  return T_neq;}

= {printf("%d\t%s\tASSIGNMENT\n", yylineno, yytext); yylval = strdup(yytext);  return T_eq;}
";" {printf("%d\t%s\tTERMINATOR\n", yylineno, yytext); yylval = strdup(yytext); return TERMINATOR;}
"," {printf("%d\t%s\tCOMMA\n", yylineno, yytext);  yylval = strdup(yytext); return COMMA;}
\t ;

" " ;

\"(\\.|[^"\\])*\" {printf("%d\t%s\tSTRING CONSTANT\n", yylineno, yytext); yylval = strdup(yytext); return STRING;}


. {printf("%d\t%s\ERROR\n", yylineno, yytext);}


%%

int yywrap(){
    return 1;
}
