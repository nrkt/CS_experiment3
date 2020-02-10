#include <stdlib.h>
#include <stdbool.h>

extern bool printfflag;
extern bool scanfflag;
bool printfflag = false;
bool scanfflag = false;

typedef enum { 
  GLOBAL_VAR,
  LOCAL_VAR,
  PROC_NAME,
  FUNC_NAME,
  GLOBAL_ARRAY,
  LOCAL_ARRAY,
  CONSTANT
} Scope;

typedef enum { 
  Alloca,
  Alloca_Array,
  Store,
  Load,
  BrUncond,
  BrCond,
  Label,
  Add,
  Sub,
  Mult,
  Div,
  Icmp,
  Ret, 
  Call,  
  Read,    
  Write,
  Sext,
  Gep,
  Shl,
  Ashr
} LLVMcommand;

typedef enum { 
  EQUAL,
  NE,
  SGT,
  SGE,
  SLT,
  SLE
} Cmptype;


typedef struct {
  Scope type;     
  char vname[256]; 
  int val;
  int arity;
} Factor;

typedef struct symtable {
	char var_name[256];
	int reg;
	Scope scope;
  int arity_num;
	Factor arity[10];
	int array_front;
	int array_back;
	struct symtable *next;
	struct symtable *prev;
} Symtable;

typedef struct llvmcode {
  LLVMcommand command;
  union {
    struct {
      Factor retval;
    } alloca;
    struct {
      Factor retval; Factor arg1; Factor arg2;
    } alloca_array;
    struct {
      Factor arg1;  Factor arg2;
    } store;
    struct {
      Factor arg1;  Factor retval;
    } load;
    struct {
      int arg1;
    } bruncond;
    struct {
      Factor arg1;  int arg2;  int arg3;
    } brcond;
    struct {
      int l;
    } label;
    struct {
      Factor arg1;  Factor arg2;  Factor retval;
    } add;
    struct {
      Factor arg1;  Factor arg2;  Factor retval;
    } sub;
    struct {
      Factor arg1;  Factor arg2;  Factor retval;
    } mult;
    struct {
      Factor arg1;  Factor arg2;  Factor retval;
    } div;
    struct {
      Cmptype type;  Factor arg1;  Factor arg2;  Factor retval;
    } icmp;
    struct {
      Factor arg1;
    } ret;
    struct {
      Factor arg1; Factor arg2; Factor arity[10]; int arity_num;
    } call;
    struct {
      Factor retval; Factor arg1;
    } read;
    struct {
      Factor retval; Factor arg1;
    } write;
    struct {
      Factor arg1; Factor retval;
    } sext;
    struct {
      Factor arg1; Factor arg2; Factor retval;
    } gep;
    struct {
        Factor arg1; Factor arg2; Factor retval;
    } shl;
    struct {
        Factor arg1; Factor arg2; Factor retval;
    } ashr;
  } args;
  struct llvmcode *next;
} LLVMcode;

LLVMcode *codehd = NULL;
LLVMcode *codetl = NULL;

typedef struct {
  Factor element[100];
  unsigned int top;
} Factorstack;

Factorstack fstack;

void init_fstack(){
  fstack.top = 0;
  return;
}

Factor factorpop() {
  Factor tmp;
  tmp = fstack.element[fstack.top];
  fstack.top --;
  return tmp;
}

void factorpush(Factor x) {
  fstack.top ++;
  fstack.element[fstack.top] = x;
  return;
}

typedef struct fundecl {
  char fname[256];
  unsigned int arity;
  Factor args[10];
  LLVMcode *codes;
  bool flag;
  struct fundecl *next;
} Fundecl;
 
Fundecl *declhd = NULL;
Fundecl *decltl = NULL;

typedef struct {
  LLVMcode *element[100];
  unsigned int top;
} Stack;

typedef struct {
  int element[100];
  unsigned int top;
} label_stack;

Stack stack;
label_stack lstack;

extern void init_stack(){
  stack.top = 0;
  return;
}

extern void init_lstack(){
  lstack.top = 0;
  return;
}

extern LLVMcode *stackpop() {
  LLVMcode *tmp;
  tmp = stack.element[stack.top];
  stack.top --;
  return tmp;
}

extern void stackpush(LLVMcode *x) {
  stack.top ++;
  stack.element[stack.top] = x;
  return;
}

extern int lstackpop(){
  int tmp;
  tmp = lstack.element[lstack.top];
  lstack.top --;
  return tmp;
}

extern void lstackpush(int x){
  lstack.top ++;
  lstack.element[lstack.top] = x;
  return;
}

int arity_list[10];
