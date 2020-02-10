#include <stdio.h>
#include <stdbool.h>

extern int cntr;
extern int flag;
extern bool func_flag;
extern bool return_flag;
extern bool backpatch_flag;
extern Symtable *symbol;
extern Fundecl *Funtemp;
LLVMcode *tmp;
extern Fundecl *decltl;

Symtable *pointer = NULL;
Symtable *start = NULL;
Factor arg1,arg2,retval;

int cntr = 1;
int flag = GLOBAL_VAR;
bool func_flag = false;
bool return_flag = false;
bool backpatch_flag = false;
Symtable *symbol = NULL;
Fundecl *Funtemp = NULL;

extern void output(void);
extern void insert(char *s,int flag);
extern Symtable *lookup(char *s,int arity_num);
extern void delete();
extern void addnode(LLVMcode *tmp);
extern void llvmoperator(int operator);
extern void generate_fundecl(char *s);
extern void generate_llvmcode(int command);
extern void generate_icmpcode(int operator);
extern void backpatch(void);
int optimisation_check(int x);

extern void output(void){
	printf("----------------\n");
	Symtable *tmp;
	tmp = start;
	while(tmp != NULL){
		switch (tmp->scope){
			case GLOBAL_VAR:
				printf("%7s GLOBAL\n",tmp->var_name);
				break;
			case LOCAL_VAR:
				printf("%7s LOCAL\n",tmp->var_name);
				break;
			case PROC_NAME:
				printf("%7s PROC\n",tmp->var_name);
				break;
			case GLOBAL_ARRAY:
				printf("%7s GLOBAL_ARRAY\n",tmp->var_name);
				break;
			case LOCAL_ARRAY:
				printf("%7s LOCAL_ARRAY\n",tmp->var_name);
				break;
			case FUNC_NAME:
				printf("%7s FUNC\n",tmp->var_name);
				break;
			case CONSTANT:
				printf("%7s CONST\n",tmp->var_name);
				break;
		}
		tmp = tmp->next;
	}
	printf("----------------\n");
}

extern void insert(char *s,int flag){
	printf("insert: %s\n",s);
	Symtable *tmp;
	tmp = (Symtable *)malloc(sizeof(Symtable));
	if (start == NULL){
		start = tmp;
		start->next = NULL;
		start->prev = NULL;
		start->scope = flag;
		start->arity_num = 0;
		strcpy(start->var_name,s);
		pointer = start;
	}
	else{
		tmp->scope = flag;
		strcpy(tmp->var_name,s);
		tmp->reg = cntr;
		tmp->next = NULL;
		tmp->prev = pointer;
		tmp->arity_num = 0;
		pointer->next = tmp;
		pointer = tmp;
	}
	output();
}

extern Symtable *lookup(char *s,int arity_num){
	printf("lookup : %s\n",s);
	printf("-----------------\n");
	Symtable *tmp;
	tmp = pointer;
	while(tmp != NULL){
		if (strcmp(tmp->var_name,s) == 0 && tmp->arity_num == arity_num){
			switch (tmp->scope){
				case GLOBAL_VAR:
					printf("%7s GLOBAL\n",tmp->var_name);
					break;
				case LOCAL_VAR:
					printf("%7s LOCAL\n",tmp->var_name);
					break;
				case PROC_NAME:
					printf("%7s PROC\n",tmp->var_name);
					break;
				case FUNC_NAME:
					printf("%7s FUNC\n",tmp->var_name);
					break;
				case GLOBAL_ARRAY:
					printf("%7s GLOBAL_ARRAY\n",tmp->var_name);
					break;
				case LOCAL_ARRAY:
					printf("%7s LOCAL_ARRAY\n",tmp->var_name);
					break;				
				case CONSTANT:
					printf("%7s CONST\n",tmp->var_name);
					break;
			
		}
		printf("-----------------\n");
			return tmp;
		}
		tmp = tmp->prev;
	}
	printf("not found\n");
	return NULL;
	printf("-----------------\n");
}

extern void delete(){
	printf("delete\n");
	Symtable *tmp,*del;
	tmp = pointer;
	while (tmp != NULL){
		if(tmp->scope == PROC_NAME || tmp->scope == FUNC_NAME){
			pointer = tmp;
			output();
			return;
		}
		else{
			del = tmp->prev;
			del->next = NULL;
			free(tmp);
			tmp = del;
		}
	}
}

extern void addnode(LLVMcode *tmp){
	if( codetl == NULL ){
        if( decltl == NULL ){
            fprintf(stderr,"unexpected error\n");
        }
        decltl->codes = tmp; 
        codehd = codetl = tmp;
    } else {
        codetl->next = tmp;
        codetl = tmp;
    }
}

extern void llvmoperator(int operator){
	arg2 = factorpop();
	arg1 = factorpop();
	if (arg1.type == CONSTANT && arg2.type == CONSTANT){
		switch(operator){
			case Add:
				retval.val = arg1.val + arg2.val;
				retval.type = CONSTANT;
				factorpush(retval);
				break;
			case Sub:
				retval.val = arg1.val - arg2.val;
				retval.type = CONSTANT;
				factorpush(retval);
				break;
			case Mult:
				retval.val = arg1.val * arg2.val;
				retval.type = CONSTANT;
				factorpush(retval);
				break;
			case Div:
				retval.val = arg1.val / arg2.val;
				retval.type = CONSTANT;
				factorpush(retval);
				break;
		}
	}
	else{
		tmp = (LLVMcode *)malloc(sizeof(LLVMcode));
		tmp->next = NULL;
		tmp->command = operator;
		if(operator == Mult && arg2.type == CONSTANT){
			int f = optimisation_check(arg2.val);
			if (f != 0){
				operator = Shl;
				tmp->command = Shl;
				arg2.val = f;
			}
		}
		else if(operator == Div && arg2.type == CONSTANT){
			int f = optimisation_check(arg2.val);
			if (f != 0){
				operator = Ashr;
				tmp->command = Ashr;
				arg2.val = f;
			}
		}
		retval.type = LOCAL_VAR;
		retval.val = cntr;
		cntr++;
		switch(operator){
			case Add:
				(tmp->args).add.arg1 = arg1;
				(tmp->args).add.arg2 = arg2;
				(tmp->args).add.retval = retval;
				break;
			case Sub:
				(tmp->args).sub.arg1 = arg1;
				(tmp->args).sub.arg2 = arg2;
				(tmp->args).sub.retval = retval;
				break;
			case Mult:
				(tmp->args).mult.arg1 = arg1;
				(tmp->args).mult.arg2 = arg2;
				(tmp->args).mult.retval = retval;
				break;
			case Div:
				(tmp->args).div.arg1 = arg1;
				(tmp->args).div.arg2 = arg2;
				(tmp->args).div.retval = retval;
				break;
			case Shl:
				(tmp->args).shl.arg1 = arg1;
				(tmp->args).shl.arg2 = arg2;
				(tmp->args).shl.retval = retval;
				break;
			case Ashr:
				(tmp->args).ashr.arg1 = arg1;
				(tmp->args).ashr.arg2 = arg2;
				(tmp->args).ashr.retval = retval;
				break;
		}
		addnode(tmp);
		factorpush(retval);
	}
}

extern void generate_fundecl(char *s){
	if(declhd == NULL){
		declhd = (Fundecl *)malloc(sizeof(Fundecl));
		declhd->next = NULL;
		declhd->arity = 0;
		strcpy(declhd->fname,s);
		decltl = declhd;
	}
	else{
		Fundecl *fundecl;
		fundecl = (Fundecl *)malloc(sizeof(Fundecl));
		strcpy(fundecl->fname,s);
		fundecl->arity = 0;
		decltl->next = fundecl;
		decltl = fundecl;
		decltl->next = NULL;
		codetl = NULL;
	}
}

extern void generate_llvmcode(int command){
	tmp = (LLVMcode *)malloc(sizeof(LLVMcode));
	tmp->next = NULL;
	tmp->command = command;
	switch(command){
		case Alloca:
			(tmp->args).alloca.retval = factorpop();
			factorpush((tmp->args).alloca.retval);
			break;
		case Alloca_Array:
			(tmp->args).alloca_array.arg1 = factorpop();
			(tmp->args).alloca_array.arg2 = factorpop();
			(tmp->args).alloca_array.retval = factorpop();
			factorpush((tmp->args).alloca_array.retval);
			break;
		case Store:
			(tmp->args).store.arg2 = factorpop();
			(tmp->args).store.arg1 = factorpop();
			factorpush((tmp->args).store.arg2);
			break;
		case Load:
			(tmp->args).load.retval.type = LOCAL_VAR;
			(tmp->args).load.retval.val = cntr;
			(tmp->args).load.arg1 = factorpop();
			factorpush((tmp->args).load.retval);
			break;
		case BrUncond:
			if(return_flag == true){(tmp->args).bruncond.arg1 = lstackpop();return_flag = false;}
			else if(backpatch_flag == true){(tmp->args).bruncond.arg1 = cntr;stackpush(tmp);backpatch_flag = false;}
			else {(tmp->args).bruncond.arg1 = cntr;}
			break;
		case Label:
			(tmp->args).label.l = cntr;
			break;
		case Ret:
			(tmp->args).ret.arg1 = factorpop();
			break;
		case Call:
			(tmp->args).call.arity_num = symbol->arity_num;
			int i;
			for (i=0;i<(tmp->args).call.arity_num;i++){
				(tmp->args).call.arity[i] = factorpop();
			}
			arg1.type = symbol->scope;
			strcpy(arg1.vname,symbol->var_name);
			(tmp->args).call.arg1 = arg1;
			if(arg1.type == FUNC_NAME){
				arg2.type = LOCAL_VAR;
				arg2.val = cntr;
				(tmp->args).call.arg2 = arg2;
				factorpush(arg2);
			}
			break;
		case Read:
			(tmp->args).read.retval.type = LOCAL_VAR;
			(tmp->args).read.retval.val = cntr;
			(tmp->args).read.arg1 = factorpop();
			cntr++;
			scanfflag = true;
			break;
		case Write:
			(tmp->args).write.retval.type = LOCAL_VAR;
			(tmp->args).write.retval.val = cntr;
			(tmp->args).write.arg1 = factorpop();
			cntr++;
			printfflag = true;
			break;
		case Sext:
			(tmp->args).sext.retval.type = LOCAL_VAR;
			(tmp->args).sext.retval.val = cntr;
			(tmp->args).sext.arg1 = factorpop();
			factorpush((tmp->args).sext.retval);
			cntr++;
			break;
		case Gep:
			(tmp->args).gep.arg2 = factorpop();
			(tmp->args).gep.arg1 = factorpop();
			(tmp->args).gep.retval.type = LOCAL_VAR;
			(tmp->args).gep.retval.val = cntr;
			factorpush((tmp->args).gep.retval);
			cntr++;
			break;
	}
	addnode(tmp);
}

extern void generate_icmpcode(int operator){
	tmp = (LLVMcode *)malloc(sizeof(LLVMcode));
	tmp->next = NULL;
	tmp->command = Icmp;
	retval.type = LOCAL_VAR;
	retval.val = cntr;
	(tmp->args).icmp.type = operator;
    (tmp->args).icmp.arg1 = factorpop();
    (tmp->args).icmp.arg2 = factorpop();
    (tmp->args).icmp.retval = retval;
	addnode(tmp);
	cntr++;
	tmp = (LLVMcode *)malloc(sizeof(LLVMcode));
	tmp->next = NULL;
	tmp->command = BrCond;
	(tmp->args).brcond.arg1 = retval;
	(tmp->args).brcond.arg2 = cntr;
	stackpush(tmp);
	addnode(tmp);
}

extern void backpatch(void){
	if (stack.top != 0){
		tmp = stackpop();
		if((tmp->command) == BrCond) (tmp->args).brcond.arg3 = cntr;
		else if ((tmp->command) == BrUncond) (tmp->args).bruncond.arg1 = cntr;
	}
}

int optimisation_check(int x){
	int i = 0;
	bool f = true;
	while (x > 1){
		if (x % 2 == 0){ 
			x = x/2;
			i++;
		}
		else {
			f = false;
			break;
		}
	}
	if (f == true) return i;
	else return 0;
}