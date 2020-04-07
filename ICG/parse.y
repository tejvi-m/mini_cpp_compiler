
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct node{
    int scope;
    int value;
    char name[100];
    char dtype[50];
    int line_num;
    int valid;
}node;

typedef struct table{
    node* head;
}table;

typedef struct astnode{
  int isID;
  int scope;
  int entry;
  char *name;
  int numChildren;
  struct astnode** children;
}astnode;

#define YYSTYPE struct astnode*
extern YYSTYPE yylval;

int valid = 1;

astnode* addToTree(char *op, astnode *left,astnode *right, astnode** siblings, int lenSiblings);
void setScopeAndPtr(astnode* node, int scope, int ptr);

void printTree(astnode *tree);
void push();
int yyerror(const char *s);
extern int yylineno;

extern node symTable[100];
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
        displaySymTable();
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
        astnode* masternode = addToTree("main", $3, NULL, NULL, 0);
        printTree(masternode);
        // showSt();
      }
      ;

BODY
      : OBR C CBR{
        $$ = $2;
      }
      ;

// extensively responsible for printing the nodes, and also adding the nodes, loop and statement, of similar scope together, in a binary tree fashion.
C
      : C statement TERMINATOR {
        $$ = addToTree("", $1, $2, NULL, 0);
        // printTree($2);
        printf("\n");
        printf("----------------------------------------------------------------\n");
      }
      | C LOOPS{
        $$ = addToTree("", $1, $2, NULL, 0);
        // printTree($2);
        printf("\n");
        printf("----------------------------------------------------------------\n");
      }
      | statement TERMINATOR {
        $$ = addToTree("", $1, NULL, NULL, 0);
        // printTree($1);
        printf("\n");
        printf("----------------------------------------------------------------\n");
      }
      | LOOPS{
        $$ = addToTree("", $1, NULL, NULL, 0);
        // printTree($1);
        printf("\n");
        printf("----------------------------------------------------------------\n");
      }
      | C OBR C CBR{
        // printTree($3);
        printf("\n");
        printf("----------------------------------------------------------------\n");
      }
      | OBR CBR
      | error TERMINATOR
      ;

LOOPS
      : WHILE{codegen_while1();} OB COND CB {codegen_while2();} LOOPBODY {
        $$ = addToTree("while", $4, $7, NULL, 0);
        codegen_while3();
      }
      | FOR OB ASSIGN_EXPR TERMINATOR COND TERMINATOR statement CB LOOPBODY
      | IF OB COND CB LOOPBODY {
         $$ = addToTree("if", $3, $5, NULL, 0);
      }
      | IF OB COND CB LOOPBODY ELSE LOOPBODY{

            astnode* elsePart = addToTree("else", $7, NULL, NULL, 0);
            astnode* ifPart = addToTree("if", $5, NULL, NULL, 0);

            astnode** siblings = (astnode**) malloc(sizeof(astnode*) * 1);
            siblings[0] = elsePart;

            $$ = addToTree("condition", $3, ifPart, siblings, 1);
          }
      | IF OB COND CB LOOPBODY ELSE LOOPS {

              astnode* elsePart = addToTree("else", $7, NULL, NULL, 0);
              astnode* ifPart = addToTree("if", $5, NULL, NULL, 0);

              astnode** siblings = (astnode**) malloc(sizeof(astnode*) * 1);
              siblings[0] = elsePart;

              $$ = addToTree("condition", $3, ifPart, siblings, 1);
        }
      ;


LOOPBODY
	  : OBR C CBR {
      // printTree($2);
      $$ = $2;
    }
	  | TERMINATOR
	  | statement TERMINATOR {
      // printTree($1);
      $$ = $1;
    }
    | OBR CBR {
      $$ = (astnode *) malloc(sizeof(astnode));
    }
	  ;

statement
      : ASSIGN_EXPR {$$ = $1;}
      | ARITH_EXPR
      | TERNARY_EXPR
      | PRINT
      | RETURN ASSIGN_EXPR
      | RETURN ARITH_EXPR
      ;

//must add the ast logic for other conditional expressions;
COND
      : LIT RELOP LIT {
        codegen_bool();
        $$=addToTree((char *)$2,$1,$3, NULL, 0);
      }
      | LIT {
        $$=$1;
      }
      | LIT RELOP LIT bin_boolop LIT RELOP LIT
      | un_boolop OB LIT RELOP LIT{codegen_bool();} CB{codgen_un();}
      | un_boolop LIT RELOP LIT
      | LIT bin_boolop LIT {codegen_bool();}
      | un_boolop OB LIT CB{codgen_un();}
      | un_boolop LIT{codgen_un();}
      ;


ASSIGN_EXPR
      : ID T_eq ARITH_EXPR
      {
        int id = find(t_scope, $1);
        if (id == -1) {
          yyerror("variable not declared");
        }
        update($1, atoi($3 -> name), t_scope);

        astnode* newnode =addToTree((char*) $1, NULL, NULL, NULL, 0);
        setScopeAndPtr(newnode, -1, id);
        $$=addToTree("=", newnode, $3, NULL, 0);
      }
      | TYPE ID T_eq ARITH_EXPR
      {
        int id = insert(&count, t_scope, $1, $2, yylineno);
        if(id == -1)
              yyerror("Variable redeclared");

        update((char *) $2, atoi($4 -> name), t_scope);

        astnode* newnode =addToTree((char*) $2, NULL, NULL, NULL, 0);
        setScopeAndPtr(newnode, t_scope, id);
        $$ = addToTree("=", newnode , $4, NULL, 0);
      }

    |
      TYPE ID {
          int id = insert(&count, t_scope, $1, $2, yylineno);

          if(id == -1)
                yyerror("Variable redeclared");

          astnode* newnode =addToTree((char*) $2, NULL, NULL, NULL, 0);
          setScopeAndPtr(newnode, t_scope, id);
          $$= addToTree("init", newnode, NULL, NULL, 0);
      }

      | TYPE ID COMMA X {
          strcpy(tdType, $1);
          dflag = 1;

          int id = insert(&count, t_scope, $1, $2, yylineno);
          if(id == -1)
                yyerror("Variable redeclared");


          astnode* newnode =addToTree((char*) $2, NULL, NULL, NULL, 0);
          setScopeAndPtr(newnode, t_scope, id);
          $$= addToTree("init", newnode, NULL, NULL, 0);
        }
      |
      TYPE ID T_eq ARITH_EXPR COMMA X {
        strcpy(tdType, $1);
        dflag = 1;
        int id = insert(&count, t_scope, $1, $2, yylineno);
        if(id == -1)
              yyerror("Variable redeclared");
        update($2, atoi($4 -> name), t_scope);

        astnode* newnode =addToTree((char*) $2, NULL, NULL, NULL, 0);
        setScopeAndPtr(newnode, t_scope, id);
        $$= addToTree("=", newnode, NULL, NULL, 0);
      }
      ;

X : ID COMMA X {
    int id = insert(&count, t_scope, tdType, $1, yylineno);
    if(id == -1){
      printf("redeclared: %s\n", $1);
      yyerror("Variable redeclared");
    }

    astnode* newnode =addToTree((char*) $1, NULL, NULL, NULL, 0);
    setScopeAndPtr(newnode, t_scope, id);
    $$= addToTree("init", newnode, NULL, NULL, 0);
}
  |
  ID {
      int id =  insert(&count, t_scope, tdType, $1, yylineno);
      if(id == -1){
        printf("redeclared: %s\n", $1);
        yyerror("Variable redeclared");
      }

      astnode* newnode =addToTree((char*) $1, NULL, NULL, NULL, 0);
      setScopeAndPtr(newnode, t_scope, id);
      $$= addToTree("init", newnode, NULL, NULL, 0);
  }
  | ID T_eq ARITH_EXPR COMMA X {
    int id = insert(&count, t_scope, tdType, $1, yylineno);
    if(id == -1){
      printf("redeclared: %s\n", $1);
      yyerror("Variable redeclared");
    }
    update($1, atoi($3 -> name), t_scope);

    astnode* newnode =addToTree((char*) $1, NULL, NULL, NULL, 0);
    setScopeAndPtr(newnode, t_scope, id);
    $$= addToTree("=", newnode, $2, NULL, 0);
  }
  | ID T_eq ARITH_EXPR {
    int id = insert(&count, t_scope, tdType, $1, yylineno);
    if(id == -1){
      printf("redeclared: %s\n", $1);
      yyerror("Variable redeclared");
    }
    update($1, atoi($3 -> name), t_scope);

    astnode* newnode =addToTree((char*) $1, NULL, NULL, NULL, 0);
    setScopeAndPtr(newnode, t_scope, id);
    $$= addToTree("=", newnode, $2, NULL, 0);
  }
/* 


ARITH_EXP
	  : ADDSUB {$$=$1;}
	  | EXP T_lt ADDSUB {$$=buildTree("<",$1,$3);}
	  | EXP T_gt ADDSUB {$$=buildTree(">",$1,$3);}
	  ;
	  
ADDSUB
      : TERM {$$=$1;}
      | EXP T_pl TERM {$$=buildTree("+",$1,$3);}
      | EXP T_min TERM {$$=buildTree("-",$1,$3);}
      ;

TERM
	  : FACTOR {$$=$1;}
      | TERM T_mul FACTOR {$$=buildTree("*",$1,$3);}
      | TERM T_div FACTOR {$$=buildTree("/",$1,$3);}
      ;
      
FACTOR
	  : LIT {$$=$1;}
	  | '(' EXP ')' {$$ = $2;}
  	  ;


 */
ARITH_EXPR
      : LIT
      | ADDSUB {$$=$1;}
      /* | LIT bin_arop ARITH_EXPR{
        $$=addToTree((char *) $2, $1, $3, NULL, 0);
        codegen_bool();
      } */
      | LIT bin_boolop ARITH_EXPR {
        $$=addToTree((char *) $2, $1, $3, NULL, 0);
        codegen_bool();
      }
      | LIT un_arop {
         codgen_un();
        $$= addToTree((char *) $2, $1, NULL, NULL, 0);
      }
      | un_arop ARITH_EXPR{
         codgen_un();
        $$= addToTree((char *) $1, $2, NULL, NULL, 0);
      }
      | un_boolop ARITH_EXPR{
         codgen_un();
        $$= addToTree((char *) $1, $2, NULL, NULL, 0);
      }
      ;

ADDSUB
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
  	  ;


TERNARY_EXPR
      : OB COND CB '?' statement ':' statement
      ;


PRINT
      : COUT T_lt T_lt STRING {
        astnode* x = addToTree((char *) $4, NULL, NULL, NULL, 0);
        $$ = addToTree((char *) $1, x, NULL, NULL, 0);
      }
      | COUT T_lt T_lt STRING T_lt T_lt ENDL {
        {
          astnode* x = addToTree((char *) $4, NULL, NULL, NULL, 0);
          $$ = addToTree((char *) $1, x, NULL, NULL, 0);
        }
      }
      | COUT T_lt T_lt ENDL{
        astnode* x = addToTree("", NULL, NULL, NULL, 0);
        $$ = addToTree((char *) $1, x, NULL, NULL, 0);
      }

      ;
LIT
      : ID {
            push((char*)$1);
            int id = find(t_scope, $1);
            if (find == -1) {
                yyerror("variable not declared");
            }
            astnode* newNode = addToTree((char*) $1, NULL, NULL, NULL, 0);
            setScopeAndPtr(newNode, -1, id);
            $$ = newNode;
        }
      | NUM {
        push((char*)$1);
        $$=addToTree((char*) $1, NULL, NULL, NULL, 0);
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

// siblings = list of the n sibling nodes, other than the left and right child, to be added to the parent node.
// will useful in the future i guess
astnode* addToTree(char *op,astnode *left,astnode *right, astnode** siblings, int lenSiblings)
{
  astnode* new = (astnode*) malloc(sizeof(astnode));
  char *newstr = (char *) malloc(strlen(op)+1);
  strcpy(newstr,op);
  new->name=newstr;
  new->children = (astnode**) malloc(sizeof(astnode*) * (lenSiblings + 2));
  new->children[0] = left;
  new->children[1] = right;
  new->numChildren = lenSiblings + 2;
  if(siblings){
        for(int i = 0; i < lenSiblings; i++){
              new->children[i + 2] = siblings[i];
        }
  }
  return (new);
}


// printing the nodes, need to add bfs logic here.
void printTree(astnode *tree)
{
  if(tree){

    if(tree->children[0] || tree->children[1])
    printf("(");
    printf(" %s ",tree->name);
    int i = 0;

    while(i < tree->numChildren){
          printTree(tree->children[i]);
          i++;
    }
    if(tree->children[0] || tree->children[1])
    printf(")");
  }
}

void setScopeAndPtr(astnode* node, int scope, int ptr){
  node -> entry = ptr;
  if(scope >= 0) node -> scope = symTable[ptr].scope;
  node -> isID = 1;

  printf("added id: %s with scope %d and ptr %d\n", node -> name, node -> scope, node -> entry);
}

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
	displaySymTable();
	return 0;
}
