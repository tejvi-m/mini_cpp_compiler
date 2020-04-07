
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define YYSTYPE char *
extern YYSTYPE yylval;

int valid = 1;

void push();
int yyerror(const char *s);
extern int yylineno;

%}

%define parse.error verbose
%token ID NUM T_lt T_gt COMMA STRC TERMINATOR RETURN FLT T_lteq T_gteq T_neq T_eqeq T_pl T_min T_mul T_div T_and T_or T_incr T_decr T_not T_eq WHILE INT CHAR FLOAT VOID H MAINTOK INCLUDE BREAK CONTINUE IF ELSE COUT STRING FOR OB CB OBR CBR ENDL
%right T_eq
%left T_or
%left T_and
%left T_neq T_eqeq
%left T_lteq T_gteq T_lt T_gt

%left T_pl T_min
%left T_div T_mul
%right T_incr T_decr
%right T_not







%%
S: START {
        printf("Successful parsing.\n");
        exit(0);
      }
      | error {
         yyerrok;
         yyclearin;
       }
      ;

START
    : INCLUDE T_lt H T_gt MAIN
    | INCLUDE '\"' H '\"' MAIN
    ;



MAIN
      : VOID MAINTOK BODY
      | INT MAINTOK BODY{
        // showSt();
      }
      ;

BODY
      : OBR C CBR{
      }
      ;

// extensively responsible for printing the nodes, and also adding the nodes, loop and statement, of similar scope together, in a binary tree fashion.
C
      : C statement TERMINATOR
      | C LOOPS
      | statement TERMINATOR
      | LOOPS
      | C OBR C CBR
      | OBR CBR
      | error TERMINATOR
      ;

LOOPS
      : WHILE{codegen_while1();} OB COND CB {codegen_while2();} LOOPBODY {
        codegen_while3();
      }
      | FOR OB ASSIGN_EXPR TERMINATOR COND TERMINATOR statement CB LOOPBODY
      | IF OB COND CB LOOPBODY
      | IF OB COND CB LOOPBODY ELSE LOOPBODY
      | IF OB COND CB LOOPBODY ELSE LOOPS
      ;


LOOPBODY
	  : OBR C CBR {
    }
	  | TERMINATOR
	  | statement TERMINATOR {
    }
    | OBR CBR {
    }
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
      : LIT RELOP LIT {
        codegen_bool();
        }
      | LIT {
      }
      | LIT RELOP LIT bin_boolop LIT RELOP LIT
      | un_boolop OB LIT RELOP LIT {codegen_bool();} CB{codgen_un();}
      | un_boolop LIT RELOP LIT
      | LIT bin_boolop LIT {codegen_bool();}
      | un_boolop OB LIT CB{codgen_un();}
      | un_boolop LIT{codgen_un();}
      ;


ASSIGN_EXPR
      : ID T_eq ARITH_EXPR
      | TYPE ID T_eq ARITH_EXPR
      | TYPE ID
      | TYPE ID COMMA X
      | TYPE ID T_eq ARITH_EXPR COMMA X
      ;

X : ID COMMA X
  | ID
  | ID T_eq ARITH_EXPR COMMA X
  | ID T_eq ARITH_EXPR
  ;

ARITH_EXPR
      : LIT
      // | ADDSUB {$$=$1;}
      | LIT bin_arop ARITH_EXPR{
        codegen_bool();
      }
      | LIT bin_boolop ARITH_EXPR {
        codegen_bool();
      }
      | LIT un_arop {
         codgen_un();
      }
      | un_arop ARITH_EXPR{
         codgen_un();
      }
      | un_boolop ARITH_EXPR{
         codgen_un();
      }
      ;

/* ADDSUB
      : TERM {$$=$1;}
      | ARITH_EXPR T_pl TERM { push((char*)$2); $$= addToTree((char *) $2, $1, $3, NULL, 0); codegen();}
      | ARITH_EXPR T_min TERM {push((char*)$2); $$= addToTree((char *) $2, $1, $3, NULL, 0); codegen();}
      ;

TERM
	  : FACTOR {$$=$1;}
      | TERM T_mul FACTOR { push((char*)$2); $$= addToTree((char *) $2, $1, $3, NULL, 0); codegen();}
      | TERM T_div FACTOR { push((char*)$2); $$= addToTree((char *) $2, $1, $3, NULL, 0); codegen();}
      ;

FACTOR
	  : LIT {$$=$1;}
	  | '(' ARITH_EXPR ')' {$$ = $2;}
  	  ; */


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
            push((char*)$1);
        }
      | NUM {
        push((char*)$1);
      }
      ;
TYPE
      : INT
      | CHAR
      | FLOAT
      ;
RELOP
      : T_lt {push((char*)$1);}
      | T_gt {push((char*)$1);}
      | T_lteq {push((char*)$1);}
      | T_gteq {push((char*)$1);}
      | T_neq {push((char*)$1);}
      | T_eqeq {push((char*)$1);}
      ;


bin_arop
      : T_pl {push((char*)$1);}
      | T_min {push((char*)$1);}
      | T_mul {push((char*)$1);}
      | T_div {push((char*)$1);}
      ;

bin_boolop
      : T_and {push((char*)$1);}
      | T_or {push((char*)$1);}
      ;

un_arop
      : T_incr {push((char*)$1);}
      | T_decr {push((char*)$1);}
      ;

un_boolop
      : T_not {push((char*)$1);}
      ;
%%


#include <ctype.h>


int yyerror(const char *s)
{
  	extern int yylineno;
    valid = 0;
  	printf("\n\nERROR: line number: %d - error: %s\n\n",yylineno,s);
}

char st[100][20];
int top = 0;
int lnum = 0;
int ltop = 0;
int label[25];
char i_[3]="00";
char temp[2]="t";

void push(char* val){
  strcpy(st[top++], val);
}

void showSt(){
  printf("\nprinting the stack contents\n");
  while(top != -1){
    printf("%s ", st[top]);
    top--;
  }
  printf("\nstack over\n");
}

void codegen_bool()
{
	strcpy(temp,"t");
	strcat(temp,i_);
	printf("%s = %s %s %s\n",temp,st[top-3],st[top-2],st[top-1]);
	top-=2;
	strcpy(st[top-1],temp);
	if(i_[1]!='9')
		i_[1]++;
	else
	{
		i_[1] = '0';
		i_[0]++;
	}
}

void codegen()
{
	strcpy(temp,"t");
	strcat(temp,i_);
	printf("%s = %s %s %s\n",temp,st[top-3],st[top-1],st[top-2]);
	top-=2;
	strcpy(st[top-1],temp);
	if(i_[1]!='9')
		i_[1]++;
	else
	{
		i_[1] = '0';
		i_[0]++;
	}
}

void codgen_un()
{
	strcpy(temp,"t");
	strcat(temp,i_);
  if(strlen(st[top - 2]) == 2){
    printf(" %s = %s %c %d\n", temp, st[top-1], st[top-2][0], 1);

    printf("%s = %s\n", st[top - 1], temp);

  }
  else
    printf(" %s = %s%s\n", temp, st[top-2], st[top-1]);
  top = top - 1;
  strcpy(st[top - 1], temp);
  if(i_[1]!='9')
		i_[1]++;
	else
	{
		i_[1] = '0';
		i_[0]++;
	}
}

void codegen_while1(){
  label[ltop++] = lnum;
  printf("L%d :", lnum++);
}

void codegen_while2(){
  strcpy(temp,"t");
	strcat(temp,i_);

	printf("%s = not %s\n",temp,st[top - 1]);
	printf("if %s goto L%d\n",temp,lnum);
	if(i_[1]!='9')
		i_[1]++;
	else
	{
		i_[1] = '0';
		i_[0]++;
	}
}
void codegen_while3(){
  strcpy(temp,"t");
	strcat(temp,i_);

	printf("goto L%d\n",label[ltop - 1]);
	printf("L%d\n",lnum++);
  ltop = ltop - 1;
	if(i_[1]!='9')
		i_[1]++;
	else
	{
		i_[1] = '0';
		i_[0]++;
	}
}
int main()
{
	yyparse();
	if(valid)
  		printf("Parsing successful\n\n\n");
	else
	{
  		printf("Parsing unsuccessful\n\n\n");
	}

	return 0;
}
