%option yylineno
%{

    	#include "y.tab.h"
	#include <stdio.h>
    	int st[100];
	int top;
	int count;
	int flag = 0;
	void insertIntoSym(char *text,int nm,int scp);
	void display();
	

	
%}


alphabet [a-zA-z_]
digit [0-9]

%%


\/\/(.*) {};
\/\*(.*\n)*.*\*\/  {};

\n {yylineno++;}

#include\ *<{alphabet}+(\.{alphabet}*)?> {printf("%d\t%s\tPREPROCESSOR\n", yylineno, yytext); return PREP;}

return {printf("%d\t%s\tKEYW\n", yylineno, yytext); return RET;}
main {printf("%d\t%s\tKEYW\n", yylineno, yytext); return MAIN;}
for {printf("%d\t%s\tKEYW\n", yylineno, yytext); flag = 1; count=count+1; top = top + 1; st[top]=count; return FOR;}
while {printf("%d\t%s\tKEYW\n", yylineno, yytext); return WHILE;}

if {printf("%d\t%s\tKEYW\n", yylineno, yytext); return IF;}
else {printf("%d\t%s\tKEYW\n", yylineno, yytext); return ELSE;}
do {printf("%d\t%s\tKEYW\n", yylineno, yytext); return DO;}

int {printf("%d\t%s\tTYPE\n", yylineno, yytext); return INT_TYPE;}
float {printf("%d\t%s\tTYPE\n", yylineno, yytext); return FLT_TYPE;}
bool {printf("%d\t%s\tTYPE\n", yylineno, yytext); return B_TYPE;}
char {printf("%d\t%s\tTYPE\n", yylineno, yytext); return C_TYPE;}
struct {printf("%d\t%s\tTYPE\n", yylineno, yytext); return S_TYPE;}

"long" {printf("%d\t%s\tTYPE\n", yylineno, yytext); return L_MODIF;}
"short" {printf("%d\t%s\tTYPE\n", yylineno, yytext); return S_MODIF;}
"unsigned" {printf("%d\t%s\tTYPE\n", yylineno, yytext); return U_MODIF;}
"signed" {printf("%d\t%s\tDATATYPE MODIFIERS\n", yylineno, yytext); return SI_MODIF;}

\( {printf("%d\t%s\tOPEN BRACKETS\n", yylineno,yytext); return OB;}
\) {printf("%d\t%s\tCLOSE BRACKETS\n", yylineno, yytext); return CB;}

\{ {if(!flag){
		count=count+1;top=top+1;st[top]=count;
	}
	printf("%d\t%s\tOPEN BRACES\n", yylineno, yytext); return OBR;}
\} {top=top-1;printf("%d\t%s\tCLOSE BRACES\n", yylineno, yytext); return CBR;}

{alphabet}({alphabet}|{digit})* {insertIntoSym(yytext,yylineno,st[top]);printf("%d\t%s\tIDENTIFIER\n", yylineno, yytext); return IDEN;}

{digit}+ {printf("%d\t%s\tINTEGER\n", yylineno, yytext); return NUM;}
{digit}+\.{digit}+(E(\+|\-)?{digit}+)? {printf("%d\t%s\tFLOATING POINT NUMBER\n", yylineno, yytext); return FLT;}

"==" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return EQ;}
"!=" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return NE;}
">=" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return GE;}
"<=" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return LE;}
"<" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return LT;}
">" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return GT;}
\+\+ {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return INC;}
-- {printf("%d\t%s\tUNARY OPERATORS\n", yylineno, yytext); return DEC;}

\+ {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return PLUS;}
\- {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return MINUS;}
\/ {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return DIV;}
\* {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return MUL;}
% {printf("%d\t%s\t BINARY OPERATORS\n", yylineno, yytext); return MOD;}
&& {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return AND;}
\|\| {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return OR;}
! {printf("%d\t%s\tLOGICAL OPERATORS\n", yylineno, yytext); return NOT;}

= {printf("%d\t%s\tASSIGNMENT\n", yylineno, yytext); return ASGN;}

; {printf("%d\t%s\tTERMINATOR\n", yylineno, yytext); return COL;}

\t ;

" " ;

\"(\\.|[^"\\])*\" {printf("%d\t%s\tSTRING CONSTANT\n", yylineno, yytext); return STRC;}


. {return yytext[0];}
%%

struct scope
{
	char arr[20][20];
	int up;
};

struct scope symtab[100];


void insertIntoSym(char *text,int nm,int scp)
{
	int present=0;
	for(int i=0;i<=symtab[scp].up;i++)
	{
		if(strcmp(symtab[scp].arr[i],text)==0)
		{
			present=1;
			break;
		}
	}
	if(present==0)
	{
		symtab[scp].up++;
		int p=symtab[scp].up;
		strcpy(symtab[scp].arr[p],text);
	}
}

void display()
{
	for(int i=0;i<=count;i++)
	{
		printf("Scope %d \n",i);
		printf("----------\n");
		int h=symtab[i].up;
		for (int j=1;j<=h;j++)
		{
			printf("Symbol:%s \n",symtab[i].arr[j]);
		}
		printf("\n\n");
	}	
}

int yywrap()
{
return 1;
}
