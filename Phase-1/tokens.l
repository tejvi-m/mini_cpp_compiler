%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    typedef struct node{
        int scope;
        char value[100];
   
    }node;

    typedef struct table{
        node* head;
    }table;
    int count = 0;
    node symTable[1000];
    int t_scope = 1;
    int flag = 0;
    void insert(node* head, int* idx, int scope, char* val);
    void displaySymTable();
%}


alphabet [a-zA-z_]
digit [0-9]

%%


\/\/(.*) {};
\/\*(.*\n)*.*\*\/  {};

\n yylineno++;

#include\ *<{alphabet}+(\.{alphabet}*)?> printf("%d\t%s\tPREPROCESSOR\n", yylineno, yytext);

return|main printf("%d\t%s\tKEYWORD\n", yylineno, yytext);
for|while|case|switch|if|else|do|class {printf("%d\t%s\tKEYWORD\n", yylineno, yytext);t_scope++; flag = 1;}

int|float|char|struct printf("%d\t%s\tDATATYPE\n", yylineno, yytext);
long|short|unsigned|signed printf("%d\t%s\tDATATYPE MODIFIERS\n", yylineno, yytext);

\( printf("%d\t%s\tOPEN BRACKETS\n", yylineno,yytext);
\) printf("%d\t%s\tCLOSE BRACKETS\n", yylineno, yytext);

\{ {printf("%d\t%s\tOPEN BRACES\n", yylineno, yytext);
    if(!flag){
        t_scope++;
    }
    flag = 0;}
\} {printf("%d\t%s\tCLOSE BRACES\n", yylineno, yytext);t_scope--;}

{alphabet}({alphabet}|{digit})* {printf("%d\t%s\tIDENTIFIER\n", yylineno, yytext);insert(symTable, &count, t_scope, yytext);}

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

. printf("%d\t\%s\tERROR\n", yylineno, yytext);


%%

void insert(node* head, int* idx, int scope, char* val){
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
                printf("Token is %s\n", symTable[i].value);
        }       
}

int yywrap(){
    return 1;
}

int main(int argc, char * argv[]){
    //table* symTable = (table*) malloc(sizeof(table));
    // symTable->head = NULL;

    yyin=fopen(argv[1],"r");
    printf("LINE\tLEXME\tTOKEN\n");
    yylex();

    displaySymTable();
    fclose(yyin);
    return 0;
}
