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

#include\ *<{alphabet}+(\.{alphabet}*)?> {printf("%d\t%s\tPREPROCESSOR\n", yylineno, yytext); return PREP;}

return {printf("%d\t%s\tKEYW\n", yylineno, yytext); return RET;}
main {printf("%d\t%s\tKEYW\n", yylineno, yytext); dflag = 0; return MAIN;}
for {printf("%d\t%s\tKEYW\n", yylineno, yytext); flag = 1; t_scope++; return FOR;}
while {printf("%d\t%s\tKEYW\n", yylineno, yytext); flag = 1; t_scope++; return WHILE;}

if {printf("%d\t%s\tKEYW\n", yylineno, yytext); return IF;}
else {printf("%d\t%s\tKEYW\n", yylineno, yytext); return ELSE;}
do {printf("%d\t%s\tKEYW\n", yylineno, yytext); return DO;}

int {printf("%d\t%s\tTYPE\n", yylineno, yytext);  dflag = 1; strcpy(tdType, yytext); return INT_TYPE;}
float {printf("%d\t%s\tTYPE\n", yylineno, yytext); dflag = 1; strcpy(tdType, yytext); return FLT_TYPE;}
bool {printf("%d\t%s\tTYPE\n", yylineno, yytext);  dflag = 1; strcpy(tdType, yytext);return B_TYPE;}
char {printf("%d\t%s\tTYPE\n", yylineno, yytext); dflag = 1; strcpy(tdType, yytext); return C_TYPE;}
struct {printf("%d\t%s\tTYPE\n", yylineno, yytext); dflag = 1; strcpy(tdType, yytext); return S_TYPE;}

"long" {printf("%d\t%s\tTYPE\n", yylineno, yytext); return L_MODIF;}
"short" {printf("%d\t%s\tTYPE\n", yylineno, yytext); return S_MODIF;}
"unsigned" {printf("%d\t%s\tTYPE\n", yylineno, yytext); return U_MODIF;}
"signed" {printf("%d\t%s\tDATATYPE MODIFIERS\n", yylineno, yytext); return SI_MODIF;}

\( {printf("%d\t%s\tOPEN BRACKETS\n", yylineno,yytext); return OB;}
\) {printf("%d\t%s\tCLOSE BRACKETS\n", yylineno, yytext); return CB;}

\{ {if(!flag){
		t_scope++;
	}
	printf("%d\t%s\tOPEN BRACES\n", yylineno, yytext); return OBR;}
\} {t_scope--;printf("%d\t%s\tCLOSE BRACES\n", yylineno, yytext); return CBR;}

{alphabet}({alphabet}|{digit})* {
                                if(dflag)
                                    insert(symTable, &count, t_scope, tdType, yytext);printf("%d\t%s\tIDENTIFIER\n", yylineno, yytext);
                                dflag = 0;    
                                return IDEN;}

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


    // node* newEntry = (node*) malloc(sizeof(node));
    // newEntry->scope = scope;
    // strcpy(newEntry->value, val);
    // newEntry->next = NULL;
    // if(!head){
    //     head = newEntry;
    // }
    // else{
    //     newEntry->next = head;
    //     head = newEntry;
    // }
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
