%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "y.tab.h"
    typedef struct node{
        int scope;
        char value[100];
        char dtype[50];

    }node;

    typedef struct table{
        node* head;
    }table;
    int count = 0;
    node symTable[1000];
    int t_scope = 1;
    int flag = 0;
    int dflag = 0;
    char tdType[50];
    void insert(node* head, int* idx, int scope, char* dtype, char* val);
    void displaySymTable();
%}


alphabet [a-zA-z_]
digit [0-9]

%%

\/\/(.*) {};
\/\*(.*\n)*.*\*\/  {};

\n {yylineno++;}

int {printf("%d\t%s\tTYPE\n", yylineno, yytext);  dflag = 1; strcpy(tdType, yytext); return INT;}
float {printf("%d\t%s\tTYPE\n", yylineno, yytext); dflag = 1; strcpy(tdType, yytext); return FLOAT;}
char {printf("%d\t%s\tTYPE\n", yylineno, yytext); dflag = 1; strcpy(tdType, yytext); return CHAR;}
"main()" {printf("%d\t%s\tKEYW\n", yylineno, yytext); dflag = 0; return MAINTOK;}
for {printf("%d\t%s\tKEYW\n", yylineno, yytext); flag = 1; t_scope++; return FOR;}
while {printf("%d\t%s\tKEYW\n", yylineno, yytext); flag = 1; t_scope++; return WHILE;}

if {printf("%d\t%s\tKEYW\n", yylineno, yytext); return IF;}
else {printf("%d\t%s\tKEYW\n", yylineno, yytext); return ELSE;}


cout {printf("%d\t%s\tKEYW\n", yylineno, yytext); return COUT;}
endl {printf("%d\t%s\tKEYW\n", yylineno, yytext); return ENDL;}
break {printf("%d\t%s\tKEYW\n", yylineno, yytext); return BREAK;}
continue {printf("%d\t%s\tKEYW\n", yylineno, yytext); return CONTINUE;}

{alphabet}({alphabet}|{digit})* {
                                if(dflag)
                                    insert(symTable, &count, t_scope, tdType, yytext);printf("%d\t%s\tIDENTIFIER\n", yylineno, yytext);
                                dflag = 0;
                                return ID;}

"#include"  {printf("%d\t%s\tKEYW\n", yylineno, yytext); dflag = 0; return INCLUDE;}

{alphabet}({alphabet}|{digit})*"\.h"?  {printf("%d\t%s\tPREPROCESSOR\n", yylineno, yytext); return H;}





\( {printf("%d\t%s\tOPEN BRACKETS\n", yylineno,yytext); return OB;}
\) {printf("%d\t%s\tCLOSE BRACKETS\n", yylineno, yytext); return CB;}



\{ {if(!flag){
		t_scope++;
	}
	printf("%d\t%s\tOPEN BRACES\n", yylineno, yytext); return OBR;}
\} {t_scope--;printf("%d\t%s\tCLOSE BRACES\n", yylineno, yytext); return CBR;}


{digit}+ {printf("%d\t%s\tINTEGER\n", yylineno, yytext); return NUM;}
{digit}+\.{digit}+(E(\+|\-)?{digit}+)? {printf("%d\t%s\tFLOATING POINT NUMBER\n", yylineno, yytext); return FLT;}

\".*\" {printf("%d\t%s\tSTRING CONSTANT\n", yylineno, yytext); return STRING;}
"==" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_eqeq;}
"!=" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_neq;}
">=" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_gteq;}
"<=" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_lteq;}
"<" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_lt;}
">" {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_gt;}
\+\+ {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_incr;}
-- {printf("%d\t%s\tUNARY OPERATORS\n", yylineno, yytext); return T_decr;}

\+ {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_pl;}
\- {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_min;}
\/ {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_div;}
\* {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_mul;}
&& {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_and;}
\|\| {printf("%d\t%s\tRELATIONAL OPERATORS\n", yylineno, yytext); return T_or;}
! {printf("%d\t%s\tLOGICAL OPERATORS\n", yylineno, yytext); return T_neq;}

= {printf("%d\t%s\tASSIGNMENT\n", yylineno, yytext); return T_eq;}
";ROR" {printf("%d\t%s\tTERMINATOR\n", yylineno, yytext); return TERMINATOR;}

\t ;

" " ;

\"(\\.|[^"\\])*\" {printf("%d\t%s\tSTRING CONSTANT\n", yylineno, yytext); return STRING;}


. {printf("%d\t%s\ERROR\n", yylineno, yytext);}


%%

void insert(node* head, int* idx, int scope, char* dtype, char* val){
    int present = 0;
    for(int i = 0; i < *idx; i++){
            if(!strcmp(head[i].value, val) && head[i].scope == scope){
                present = 1;
                break;
            }
    }

    if(!present){
        head[*idx].scope = scope;
        strcpy(head[*idx].value, val);
        strcpy(head[*idx].dtype, dtype);
        *idx = *idx + 1;

    }


    /* // node* newEntry = (node*) malloc(sizeof(node));
    // newEntry->scope = scope;
    // strcpy(newEntry->value, val);
    // newEntry->next = NULL;
    // if(!head){
    //     head = newEntry;
    // }
    // else{
    //     newEntry->next = head;
    //     head = newEntry;
    // } */
}

void displaySymTable()
{
        for(int i = 0; i < count; i++)
        {
                printf("Scope %d\t",symTable[i].scope);
                printf("Token is %s\t", symTable[i].value);
                printf("data type is %s\n", symTable[i].dtype);
        }
}

int yywrap(){
    return 1;
}

// int main(int argc, char * argv[]){
//     //table* symTable = (table*) malloc(sizeof(table));
//     // symTable->head = NULL;

//     yyin=fopen(argv[1],"r");
//     printf("LINE\tLEXME\tTOKEN\n");
//     yylex();

//     displaySymTable();
//     fclose(yyin);
//     return 0;
// }
