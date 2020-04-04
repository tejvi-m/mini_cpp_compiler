
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct astnode{
  char *name;
  struct astnode* left;
  struct astnode* right;
}astnode;
#define YYSTYPE struct astnode*
extern YYSTYPE yylval;
/* #define YYSTYPE struct astnode* */

astnode* addToTree(char *op,astnode *left,astnode *right);
void printTree(astnode *tree);

extern int yylineno;
int valid=1;
int yylex();
int yyerror(const char *s);
/* extern int SymTable[100]; */
extern char tdType[50];
extern int t_scope;
extern int dflag;
extern int count;
extern void displaySymTable();
extern int find(int  t_scope, char *yytext);
extern void update(char* name, int value, int scope);
extern int insert(int* idx, int scope, char* dtype, char* val, int line_num);
extern void decrScope();


%}

%define parse.error verbose
%token ID NUM T_lt T_gt COMMA STRC TERMINATOR RETURN FLT T_lteq T_gteq T_neq T_eqeq T_pl T_min T_mul T_div T_and T_or T_incr T_decr T_not T_eq WHILE INT CHAR FLOAT VOID H MAINTOK INCLUDE BREAK CONTINUE IF ELSE COUT STRING FOR OB CB OBR CBR ENDL


%%
S
      : START {exit(0);}
    |error { yyerrok; yyclearin;}
      ;

START
    : INCLUDE T_lt H T_gt MAIN
    | INCLUDE '\"' H '\"' MAIN
    ;



MAIN
      : VOID MAINTOK BODY
      | INT MAINTOK BODY
      ;

BODY
      : OBR C CBR
      ;


C
      : C statement TERMINATOR {printTree($2);printf("\n");printf("----------------------------------------------------------------\n");}
      | C LOOPS
      | statement TERMINATOR {printTree($1);printf("\n");printf("----------------------------------------------------------------\n");}
      | LOOPS
      | C OBR C CBR
      | OBR CBR
      | error TERMINATOR
      ;

LOOPS
      : WHILE OB COND CB LOOPBODY
      | FOR OB ASSIGN_EXPR TERMINATOR COND TERMINATOR statement CB LOOPBODY
      | IF OB COND CB LOOPBODY
      | IF OB COND CB LOOPBODY ELSE LOOPBODY
      ;


LOOPBODY
	  : OBR C CBR
	  | TERMINATOR
	  | statement TERMINATOR
    | OBR CBR
	  ;

statement
      : ASSIGN_EXPR {$$ = $1;}
      | ARITH_EXPR
      | TERNARY_EXPR
      | PRINT
      | RETURN ASSIGN_EXPR
      | RETURN ARITH_EXPR
      ;


COND
      : LIT RELOP LIT {$$=addToTree((char *)$2,$1,$3);}
      | LIT {$$=$1;}
      | LIT RELOP LIT bin_boolop LIT RELOP LIT
      | un_boolop OB LIT RELOP LIT CB
      | un_boolop LIT RELOP LIT
      | LIT bin_boolop LIT
      | un_boolop OB LIT CB
      | un_boolop LIT
      ;


ASSIGN_EXPR
      : ID T_eq ARITH_EXPR
      /* { */

        /* if (!find(t_scope, $1)) {
          yyerror("variable not declared");
        }
      update($1, atoi($3), t_scope); */
      {
        /* printf("try\n %s\n", $1 -> name); */
        astnode* newnode =addToTree((char*) $1, NULL, NULL);
        $$=addToTree("=", newnode, $3);}


      | TYPE ID T_eq ARITH_EXPR
      /* {
        if(!insert(&count, t_scope, $1, $2, yylineno))
              yyerror("Variable redeclared");

        update($2, atoi($4), t_scope);
      } */
      {$$ = addToTree("=",$2 , $4);}

    |
      TYPE ID {

        /* if(!insert(&count, t_scope, $1, $2, yylineno))
              yyerror("Variable redeclared"); */
      }

      | TYPE ID COMMA X {
        /* strcpy(tdType, $1);
        dflag = 1;

        if(!insert(&count, t_scope, $1, $2, yylineno))
              yyerror("Variable redeclared"); */
            }
      |
      TYPE ID T_eq ARITH_EXPR COMMA X {
        /* strcpy(tdType, $1);
        dflag = 1;
        if(!insert(&count, t_scope, $1, $2, yylineno))
              yyerror("Variable redeclared");
        update($2, atoi($4), t_scope); */
      }
      ;

X : ID COMMA X {
  /* if(!insert(&count, t_scope, tdType, $1, yylineno)){
    printf("redeclared: %s\n", $1);
    yyerror("Variable redeclared");
  } */
}
  |
  ID {
    /* if(!insert(&count, t_scope, tdType, $1, yylineno)){
      printf("redeclared: %s\n", $1);
      yyerror("Variable redeclared");
    } */
  }
  | ID T_eq ARITH_EXPR COMMA X {
    /* if(!insert(&count, t_scope, tdType, $1, yylineno)){
      printf("redeclared: %s\n", $1);
      yyerror("Variable redeclared");
    }
    update($1, atoi($3), t_scope); */
  }
  | ID T_eq ARITH_EXPR {
    /* if(!insert(&count, t_scope, tdType, $1, yylineno)){
      printf("redeclared: %s\n", $1);
      yyerror("Variable redeclared");
    }
    update($1, atoi($3), t_scope); */
  }

ARITH_EXPR
      : LIT
      | LIT bin_arop ARITH_EXPR {$$=addToTree((char *) $2, $1, $3);}
      | LIT bin_boolop ARITH_EXPR
      | LIT un_arop
      | un_arop ARITH_EXPR
      | un_boolop ARITH_EXPR
      ;


TERNARY_EXPR
      : OB COND CB '?' statement ':' statement
      ;


PRINT
      : COUT T_lt T_lt STRING
      | COUT T_lt T_lt STRING T_lt T_lt ENDL
      | COUT T_lt T_lt ENDL

      ;
LIT
      : ID {
        /* if (!find(t_scope, $1)) {
            yyerror("variable not declared");
        } */
      $$=addToTree("i", NULL, NULL);
      }
      | NUM {$$=addToTree((char*) $1, NULL, NULL);}
      ;
TYPE
      : INT
      | CHAR
      | FLOAT
      ;
RELOP
      : T_lt
      | T_gt
      | T_lteq
      | T_gteq
      | T_neq
      | T_eqeq
      ;


bin_arop
      : T_pl {$$=addToTree((char*) $1, NULL, NULL);}
      | T_min
      | T_mul
      | T_div
      ;

bin_boolop
      : T_and
      | T_or
      ;

un_arop
      : T_incr
      | T_decr
      ;

un_boolop
      : T_not
      ;
%%


#include <ctype.h>

astnode* addToTree(char *op,astnode *left,astnode *right)
{
  astnode *new = (astnode*) malloc(sizeof(astnode));
  printf("adding \nop: %s.\n", op);
	char *newstr = (char *) malloc(strlen(op)+1);
  strcpy(newstr,op);
  new->left=left;
  new->right=right;
  new->name=newstr;
  return (new);
}

void printTree(astnode *tree)
{
  /* printf("i have something to print? \n"); */
  /* printf("i have something t_\n"); */
	if(tree->left || tree->right)
		printf("(");
	printf(" %s \n",tree->name);
	if(tree->left)
		printTree(tree->left);
	if(tree->right)
		printTree(tree->right);
	if(tree->left || tree->right)
		printf(")");

}

int yyerror(const char *s)
{
  	extern int yylineno;
  	valid =0;
  	printf("\n\nERROR: line number: %d - error: %s\n\n",yylineno,s);

}

int main()
{
	t_scope=1;
	count=0;
	yyparse();
	if(valid)
  		printf("Parsing successful\n\n\n");
	else
	{
  		printf("Parsing unsuccessful\n\n\n");
	}
	/* displaySymTable(); */
	return 0;
}
