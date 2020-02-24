%{
#include <stdio.h>
#include <stdlib.h>
int valid=1;
int yylex();
int yyerror(const char *s);
extern int SymTable[100];
extern int t_scope;
extern int count;
extern void displaySymTable();
	
%}

%define parse.error verbose
%start S
%token PREP RET MAIN FOR WHILE IF ELSE DO INT_TYPE FLT_TYPE C_TYPE S_TYPE B_TYPE L_MODIF SI_MODIF U_MODIF S_MODIF OB OBR CB CBR IDEN NUM FLT LT GE LE GT NE EQ PLUS MINUS MUL DIV MOD INC DEC AND OR NOT ASGN COL STRC
%left LT GT LE GE EQ NE 
%right ASGN


%%
S:
    PREP type MAIN OB args CB OBR body CBR
    | PREP type MAIN OB args CB OBR body CBR {printf("done!"); return 0;}
    | error
;
args: "int argc" 
	| "int argc, char **argv" 
	| "int argc, char* argv[]"
    |
;
type: d dType 
	
;
d:  L_MODIF 
	| S_MODIF 
    | SI_MODIF
    | U_MODIF
	|	
;
dType: INT_TYPE
        |FLT_TYPE
		| C_TYPE 
		| B_TYPE
;
body: expression body 
		| OBR body CBR body
		| selectionSt 
		| iterationSt 
		| RET expression
		|
;
selectionSt:IF OB condition CB body elseBlock 
			|IF OB condition CB body
			|
;
elseBlock: ELSE body
;
iterationSt: WHILE OB condition CB body 
			| DO OBR body CBR WHILE OB expression CB COL body
			| FOR OB init COL condition COL expressionfor CB body
			| 
;

init: dType var ASGN value
	| dType var
	|
;
condition: var relOp value 
			|expression
;
var: id
;
id: '_' idN | idN
;
idN: NUM
	| IDEN 
	| 
;
Assignment: d dType var ASGN value Assign 
;
Assign: ',' var ASGN value Assign 
		|
;
relOp: LE 
		| LT 
		| GT
		| GE
		| EQ 
		| NE
;
binOp: PLUS 
		| MINUS 
		| MUL 
		| DIV 
		| MOD
;
unaryOp: INC 
		| DEC
;
expressionfor: condition 
			| init
			| dType id ASGN value 
			| Assignment
			| value
			| NUM
;
expression: condition COL 
			| init COL
			| dType id ASGN value COL 
			| Assignment COL
			| value COL
			| NUM
;
value: val relOp value 
		| val binOp value 
		| val unaryOp 
		| unaryOp val 
		| val
;
val: literal 
	| var
; 
literal: NUM 
		| FLT
		| letter
;
letter: IDEN
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
