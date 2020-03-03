
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define YYSTYPE char *

int valid=1;
int yylex();
int yyerror(const char *s);
extern int SymTable[100];
extern int t_scope;
extern int count;
extern void displaySymTable();
extern void update(char* name, int value, int scope);

%}

%define parse.error verbose
%token ID NUM T_lt T_gt STRC TERMINATOR RETURN FLT T_lteq T_gteq T_neq T_eqeq T_pl T_min T_mul T_div T_and T_or T_incr T_decr T_not T_eq WHILE INT CHAR FLOAT VOID H MAINTOK INCLUDE BREAK CONTINUE IF ELSE COUT STRING FOR OB CB OBR CBR ENDL


%%
S
      : START {printf("Successful parsing.\n");displaySymTable();exit(0);}
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
      : C statement TERMINATOR
      | C LOOPS
      | statement TERMINATOR
      | LOOPS
      | C OBR C CBR
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
	  ;

statement
      : ASSIGN_EXPR
      | ARITH_EXPR
      | TERNARY_EXPR
      | PRINT
      | RETURN ASSIGN_EXPR
      | RETURN ARITH_EXPR
      ;


COND
      : LIT RELOP LIT
      | LIT
      | LIT RELOP LIT bin_boolop LIT RELOP LIT
      | un_boolop OB LIT RELOP LIT CB
      | un_boolop LIT RELOP LIT
      | LIT bin_boolop LIT
      | un_boolop OB LIT CB
      | un_boolop LIT
      ;


ASSIGN_EXPR
      : ID T_eq ARITH_EXPR {} { update($1, atoi($3), t_scope);}
      | TYPE ID T_eq ARITH_EXPR { update($2, atoi($4), t_scope);}
      ;


ARITH_EXPR
      : LIT
      | LIT bin_arop ARITH_EXPR
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
      : ID
      | NUM
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
      : T_pl
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
int yyerror(const char *s)
{
  	extern int yylineno;
  	valid =0;
  	printf("Line no: %d \n The error is: %s\n",yylineno,s);

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
	displaySymTable();
	return 0;
}
