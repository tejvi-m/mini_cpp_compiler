/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    PREP = 258,
    RET = 259,
    MAIN = 260,
    FOR = 261,
    WHILE = 262,
    IF = 263,
    ELSE = 264,
    DO = 265,
    INT_TYPE = 266,
    FLT_TYPE = 267,
    C_TYPE = 268,
    S_TYPE = 269,
    B_TYPE = 270,
    L_MODIF = 271,
    SI_MODIF = 272,
    U_MODIF = 273,
    S_MODIF = 274,
    OB = 275,
    OBR = 276,
    CB = 277,
    CBR = 278,
    IDEN = 279,
    NUM = 280,
    FLT = 281,
    LT = 282,
    GE = 283,
    LE = 284,
    GT = 285,
    NE = 286,
    EQ = 287,
    PLUS = 288,
    MINUS = 289,
    MUL = 290,
    DIV = 291,
    MOD = 292,
    INC = 293,
    DEC = 294,
    AND = 295,
    OR = 296,
    NOT = 297,
    ASGN = 298,
    COL = 299,
    STRC = 300
  };
#endif
/* Tokens.  */
#define PREP 258
#define RET 259
#define MAIN 260
#define FOR 261
#define WHILE 262
#define IF 263
#define ELSE 264
#define DO 265
#define INT_TYPE 266
#define FLT_TYPE 267
#define C_TYPE 268
#define S_TYPE 269
#define B_TYPE 270
#define L_MODIF 271
#define SI_MODIF 272
#define U_MODIF 273
#define S_MODIF 274
#define OB 275
#define OBR 276
#define CB 277
#define CBR 278
#define IDEN 279
#define NUM 280
#define FLT 281
#define LT 282
#define GE 283
#define LE 284
#define GT 285
#define NE 286
#define EQ 287
#define PLUS 288
#define MINUS 289
#define MUL 290
#define DIV 291
#define MOD 292
#define INC 293
#define DEC 294
#define AND 295
#define OR 296
#define NOT 297
#define ASGN 298
#define COL 299
#define STRC 300

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
