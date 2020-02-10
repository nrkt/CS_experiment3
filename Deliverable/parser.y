%{
/*
 * parser; Parser for PL-4*
 */

#define MAXLENGTH 16
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "data-structures.h"
#include "generate-code.h"
#include "display.h"

extern int yylineno;
extern char *yytext;
FILE *fp;

Factor for_var;
Factor arg1,arg2,retval;

bool cntr_flag = false;
int arity_cntr = 0;
int i;

%}

%union {
    int num;
    char ident[MAXLENGTH+1];
}

%token SBEGIN DO ELSE SEND
%token FOR FORWARD FUNCTION IF PROCEDURE
%token PROGRAM READ THEN TO VAR
%token WHILE WRITE

%left PLUS MINUS
%left MULT DIV

%token EQ NEQ LE LT GE GT
%token LPAREN RPAREN LBRACKET RBRACKET
%token COMMA SEMICOLON COLON INTERVAL
%token PERIOD ASSIGN
%token <num> NUMBER
%token <ident> IDENT
%type <ident> proc_call_name
%type <ident> proc_name
%type <ident> func_name
%type <ident> var_name
%%

program
    : PROGRAM
	IDENT SEMICOLON outblock PERIOD
	{
		fp = fopen("result.ll","w");
		displayGlobal(); 
		displayIO();
		displayLlvmfundecl(declhd);
		declare();
		fclose(fp);
	}
    ;

outblock
    : var_decl_part forward_decl_part subprog_decl_part statement 
	{
		generate_llvmcode(Load);
		generate_llvmcode(Ret);
	}
    ;

var_decl_part
    : /* empty */
    | var_decl_list SEMICOLON
    ;

forward_decl_part
    : /* empty */
    | FORWARD forward_decl_list SEMICOLON forward_decl_part
    ;

forward_decl_list
    : PROCEDURE IDENT {insert($2,PROC_NAME);}
    | FUNCTION IDENT {insert($2,FUNC_NAME);}
	| PROCEDURE IDENT LPAREN {cntr_flag = true;} arg_list RPAREN
	{
		insert($2,PROC_NAME);
		symbol = lookup($2,0);
		symbol->arity_num = arity_cntr;
		arity_cntr = 0;
		cntr_flag = false;
	} 
	| FUNCTION IDENT LPAREN {cntr_flag = true;} arg_list RPAREN
	{
		insert($2,FUNC_NAME);
		symbol = lookup($2,0);
		symbol->arity_num = arity_cntr;
		cntr_flag = false;
		arity_cntr = 0;
	} 
    ;

var_decl_list
	: var_decl_list SEMICOLON var_decl
	| var_decl
	;

var_decl
	: VAR id_list
	;

subprog_decl_part
	: subprog_decl_list SEMICOLON
	{
		strcpy(arg2.vname,"main");
		arg1.type = CONSTANT; arg1.val = 0; factorpush(arg1);
		arg2.type = LOCAL_VAR; arg2.val = cntr; factorpush(arg2);
		generate_fundecl("main");
		generate_llvmcode(Alloca);
		generate_llvmcode(Store);
		factorpush(arg2);
		cntr++;
	}
	| /*empty*/
	{
		strcpy(arg2.vname,"main");
		arg1.type = CONSTANT;
		arg1.val = 0;
		arg2.type = LOCAL_VAR;
		arg2.val = cntr;
		factorpush(arg1);
		factorpush(arg2);
		generate_fundecl("main");
		generate_llvmcode(Alloca);
		generate_llvmcode(Store);
		factorpush(arg2);
		cntr++;
	}
	;

subprog_decl_list
	: subprog_decl_list SEMICOLON subprog_decl
	| subprog_decl
	;

subprog_decl
	: proc_decl
	;

proc_decl
	: FUNCTION func_name SEMICOLON
	{
		func_flag = true;
		cntr = 1;
		symbol = lookup($2,0);
		symbol->reg = cntr;
		strcpy(arg1.vname,symbol->var_name);
		arg1.val = symbol->reg;
		arg1.type = LOCAL_VAR;
		factorpush(arg1);
		generate_llvmcode(Alloca);
		cntr++;
	}
	inblock
	{
		symbol = lookup($2,0);
		arg1.val = symbol->reg;
		arg1.type = FUNC_NAME;
		strcpy(arg1.vname,$2);
		factorpush(arg1);
		generate_llvmcode(Load);
		cntr++;

		flag = GLOBAL_VAR;
		delete();
		Funtemp = NULL;
		cntr = 1;

		generate_llvmcode(Ret);
		func_flag = false;
	}
	| PROCEDURE proc_name SEMICOLON {cntr = 1; flag = LOCAL_VAR;} inblock
	{
		flag = GLOBAL_VAR;
		delete();
		cntr = 1;

		strcpy(arg1.vname,"void");
		factorpush(arg1);
		generate_llvmcode(Ret);
	}
	| FUNCTION func_name {func_flag = true; cntr_flag = true;} LPAREN id_list RPAREN 
	{
		symbol = lookup($2,0);
		symbol->arity_num = Funtemp->arity;
		cntr = Funtemp->arity + 1;
		arg1.val = cntr;
		arg1.type = LOCAL_VAR;
		factorpush(arg1);
		generate_llvmcode(Alloca);
		symbol->reg = cntr;
		for (i = 0;i < Funtemp->arity;i++){
			cntr++;
			arity_list[i] = cntr;
			arg1.val = cntr;
			arg1.type = LOCAL_VAR;
			factorpush(arg1);
			generate_llvmcode(Alloca);
			factorpop();
		}
		cntr++;

		for (i = 0;i < Funtemp->arity;i++){
			LLVMcode *tmp;
			tmp = (LLVMcode *)malloc(sizeof(LLVMcode));
			tmp->command = Store;
			arg1 = Funtemp->args[i];
			symbol = lookup(Funtemp->args[i].vname,0);
			symbol->reg = arity_list[i];
			arg2.type = LOCAL_VAR;
			arg2.val = arity_list[i];
			(tmp->args).store.arg1 = arg1;
			(tmp->args).store.arg2 = arg2;
			addnode(tmp);
			factorpush(arg1);
		}
		cntr_flag = false;
	}
	SEMICOLON inblock
	{
		generate_llvmcode(Load);
		cntr++;
		generate_llvmcode(Ret);
		
		flag = GLOBAL_VAR;
		delete();
		Funtemp = NULL;
		cntr = 1;
		func_flag = false;
	}
	| PROCEDURE proc_name {cntr_flag = true;} LPAREN id_list RPAREN 
	{
		cntr_flag = false;
		symbol = lookup($2,0);
		symbol->arity_num = Funtemp->arity;
		for (i = 0;i < Funtemp->arity;i++){
			cntr++;
			arity_list[i] = cntr;
			arg1.val = cntr;
			arg1.type = LOCAL_VAR;
			factorpush(arg1);
			generate_llvmcode(Alloca);
			factorpop();
		}
		cntr++;

		for (i = 0;i < Funtemp->arity;i++){
			LLVMcode *tmp;
			tmp = (LLVMcode *)malloc(sizeof(LLVMcode));
			tmp->command = Store;
			arg1 = Funtemp->args[i];
			symbol = lookup(Funtemp->args[i].vname,0);
			symbol->reg = arity_list[i];
			arg2.type = LOCAL_VAR;
			arg2.val = arity_list[i];
			(tmp->args).store.arg1 = arg1;
			(tmp->args).store.arg2 = arg2;
			addnode(tmp);
			factorpush(arg1);
		}
	} 
	SEMICOLON inblock 
	{
		delete();
		flag = GLOBAL_VAR;
		Funtemp = NULL;
		cntr = 1;

		arg1.type = CONSTANT;
		arg1.val = 0;
		strcpy(arg1.vname,"void");
		factorpush(arg1);
		generate_llvmcode(Ret);
	} 
	;

func_name
	: IDENT
	{
		if(lookup($1,0) == NULL) insert($1,FUNC_NAME);
		generate_fundecl($1);
		decltl->flag = true;
        Funtemp = decltl;
        cntr = 0;
        flag = LOCAL_VAR;
	}
	;

proc_name
	: IDENT
	{
		if(lookup($1,0) == NULL) insert($1,PROC_NAME);
		generate_fundecl($1);
		decltl->flag = false;
        Funtemp = decltl;
        cntr = 0;
        flag = LOCAL_VAR;
	}
	;

inblock
	: var_decl_part statement
	;

statement_list
	: statement_list SEMICOLON statement
	| statement
	;

statement
	: assignment_statement
	| if_statement
	| while_statement
	| for_statement
	| proc_call_statement
	| null_statement
	| block_statement
	| read_statement
	| write_statement
	;

assignment_statement
	: IDENT ASSIGN expression
	{
		if(func_flag == true && strcmp($1,Funtemp->fname) == 0){symbol = lookup($1,Funtemp->arity);arg2.type = LOCAL_VAR;}
		else{symbol = lookup($1,0);arg2.type = symbol->scope;}
		arg2.val = symbol->reg;
		strcpy(arg2.vname,$1);
		factorpush(arg2);
		generate_llvmcode(Store);
	} 
	| IDENT LBRACKET expression RBRACKET
	{
		symbol = lookup($1,0);
		arg2.val = symbol->array_front;
		arg2.type = CONSTANT;
		factorpush(arg2);
		llvmoperator(Sub);
		generate_llvmcode(Sext);
		arg2.type = symbol->scope;
		strcpy(arg2.vname,symbol->var_name);
		arg2.val = symbol->array_back - symbol->array_front + 1;
		factorpush(arg2);
		generate_llvmcode(Gep);
	} 
	ASSIGN expression 
	{
		arg1 = factorpop();
		arg2 = factorpop();
		factorpush(arg1);
		factorpush(arg2);
		generate_llvmcode(Store);
	}
	;

if_statement
	: IF condition THEN {generate_llvmcode(Label);cntr++;} statement
    {
        backpatch();
		backpatch_flag = true;
		generate_llvmcode(BrUncond);
		generate_llvmcode(Label);
    	cntr++;
    }
	else_statement
	;

else_statement
	: ELSE statement
	{
		backpatch();
	  	generate_llvmcode(BrUncond);
	  	generate_llvmcode(Label);
	  	cntr++;
	}
	| /*empty*/ {stackpop();}
	;

while_statement
	: WHILE 
	{
		generate_llvmcode(BrUncond);
		generate_llvmcode(Label);
		lstackpush(cntr);
		cntr++;
	} 
	condition {generate_llvmcode(Label); cntr++;} DO statement
	{
		return_flag = true;
		generate_llvmcode(BrUncond);
		return_flag = false;
		generate_llvmcode(Label);
		backpatch();
		cntr++;
	} 
	;

for_statement
	: FOR IDENT ASSIGN expression
	{
        symbol = lookup($2,0);
		arg1 = factorpop();
        arg2.type = symbol->scope;
		arg2.val = symbol->reg;
        strcpy(arg2.vname,symbol->var_name);
		factorpush(arg1);
		factorpush(arg2);
	  	for_var = arg2;
		generate_llvmcode(Store);
		generate_llvmcode(BrUncond);
		generate_llvmcode(Label);
	  	lstackpush(cntr);
        cntr++;
		generate_llvmcode(Load);
		cntr++;
	}
	TO expression
	{
        generate_icmpcode(SLE);
		generate_llvmcode(Label); cntr++;
    }
	DO statement
    {
		generate_llvmcode(BrUncond);
		generate_llvmcode(Label);
        cntr++;

	  	strcpy(arg1.vname,for_var.vname);
	  	arg1.val = for_var.val;
	  	arg1.type = for_var.type;
		factorpush(arg1);
		generate_llvmcode(Load);
		cntr++;

	  	arg2.val = 1;
	  	arg2.type = CONSTANT;
		factorpush(arg2);   
		llvmoperator(Add);
		
        arg2.type = for_var.type;
        strcpy(arg2.vname,for_var.vname);
		arg2.val = for_var.val;
        arg1 = factorpop();
		factorpush(arg1);
		factorpush(arg2);
		generate_llvmcode(Store);
		for_var = arg1;
		return_flag = true;
		generate_llvmcode(BrUncond);
		generate_llvmcode(Label);

		backpatch();
        cntr++;
    }
	;

proc_call_statement
	: proc_call_name {symbol = lookup($1,0); generate_llvmcode(Call);}
	| proc_call_name LPAREN {cntr_flag = true;} arg_list RPAREN 
	{
		symbol = lookup($1,arity_cntr);
		generate_llvmcode(Call);
		cntr_flag = false;
		arity_cntr = 0;
	}
	;

func_call_statement
	: proc_call_name LPAREN RPAREN
	{
		symbol = lookup($1,0);
		generate_llvmcode(Call);
		cntr++;
	}
	| proc_call_name LPAREN {cntr_flag = true;} arg_list RPAREN
	{
		symbol = lookup($1,arity_cntr);
		generate_llvmcode(Call);
		cntr++;
		cntr_flag = false;
		arity_cntr = 0;
	}
	;

proc_call_name
	: IDENT
	;

block_statement
	: SBEGIN statement_list SEND
	;

read_statement
	: READ LPAREN IDENT RPAREN
	{
		symbol = lookup($3,0);
		arg2.type = symbol->scope;
		strcpy(arg2.vname,symbol->var_name);
		arg2.val = symbol->reg;
		factorpush(arg2);
		generate_llvmcode(Read);
	}
	| READ LPAREN IDENT LBRACKET expression RBRACKET RPAREN
	{
		symbol = lookup($3,0);
		arg2.val = symbol->array_front;
		arg2.type = CONSTANT;
		factorpush(arg2);
		llvmoperator(Sub);
		generate_llvmcode(Sext);
		arg2.type = symbol->scope;
		strcpy(arg2.vname,symbol->var_name);
		arg2.val = symbol->array_back - symbol->array_front + 1;
		factorpush(arg2);
		generate_llvmcode(Gep);
		generate_llvmcode(Read);
	}
	;

write_statement
	: WRITE LPAREN expression RPAREN {generate_llvmcode(Write);} 
	;

null_statement
	: /*empty*/
	;

condition
	: expression EQ expression {generate_icmpcode(EQUAL);}
	| expression NEQ expression {generate_icmpcode(NE);}
	| expression LT expression {generate_icmpcode(SLT);}
	| expression LE expression {generate_icmpcode(SLE);}
	| expression GT expression {generate_icmpcode(SGT);}
	| expression GE expression {generate_icmpcode(SGE);}
	;

expression
	: term
	| PLUS term
	| MINUS term 
	{
		arg1.val = -1;
		arg1.type = CONSTANT;
		factorpush(arg1); 
		llvmoperator(Mult);
	}
	| expression PLUS term {llvmoperator(Add);}
	| expression MINUS term {llvmoperator(Sub);}
	;

term	
	: factor
	| term MULT factor {llvmoperator(Mult);}
	| term DIV factor 	{llvmoperator(Div);}
	;

factor
	: var_name
	| NUMBER 
	{
		arg1.type = CONSTANT;
		arg1.val = $1;
		factorpush(arg1);
	}
	| LPAREN expression RPAREN
	| func_call_statement
	;

var_name 
	: IDENT
	{
		symbol = lookup($1,0);
		arg1.type = symbol->scope;
		arg1.val = symbol->reg;
		strcpy(arg1.vname,symbol->var_name);
		factorpush(arg1);
		generate_llvmcode(Load);
		cntr++;
	}
	| IDENT LBRACKET expression RBRACKET
	{
		symbol = lookup($1,0);
		arg2.val = symbol->array_front;
		arg2.type = CONSTANT;
		factorpush(arg2);
		llvmoperator(Sub);
		generate_llvmcode(Sext);
		arg2.type = symbol->scope;
		strcpy(arg2.vname,symbol->var_name);
		arg2.val = symbol->array_back - symbol->array_front + 1;
		factorpush(arg2);
		generate_llvmcode(Gep);
		generate_llvmcode(Load);
		cntr++;
	}
	;

arg_list
	: expression {if(cntr_flag == true) arity_cntr++;}
	| arg_list COMMA expression {if(cntr_flag == true) arity_cntr++;}
	;

id_list
	: id
	| id_list COMMA id
	;

id 	
	: IDENT 
	{
		insert($1,flag);
		if(cntr_flag == true){
			strcpy(Funtemp->args[Funtemp->arity].vname, $1);
			Funtemp->args[Funtemp->arity].val = cntr;
			Funtemp->args[Funtemp->arity].type = flag;
			cntr++;
			Funtemp->arity++;			
		}
		else if(flag == LOCAL_VAR){
			strcpy(retval.vname,$1);
			retval.type = flag;
			retval.val = cntr;
			factorpush(retval);
			generate_llvmcode(Alloca);
			cntr++;
		}
	}
	| IDENT LBRACKET NUMBER INTERVAL NUMBER RBRACKET
	{
		if (flag == GLOBAL_VAR){insert($1,GLOBAL_ARRAY);}
		else{
				insert($1,LOCAL_ARRAY);
				strcpy(retval.vname,$1);
				retval.type = flag;
				retval.val = cntr;
				cntr++;
				arg1.val = $5;
				arg2.val = $3;
				factorpush(retval);
				factorpush(arg2);
				factorpush(arg1);
				generate_llvmcode(Alloca_Array);
			}
		symbol = lookup($1,0);
		symbol->array_front = $3;
		symbol->array_back = $5;
	}
	;

%%
yyerror(char *s)
{
  fprintf(stderr, "%s \n %d %s\n", s,yylineno,yytext);
}
