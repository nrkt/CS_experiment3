#include <stdbool.h>

extern FILE *fp;
extern void displayLlvmcodes( LLVMcode *code );
extern void displayLlvmfundecl( Fundecl *decl );
extern void displayFactor( Factor factor);
extern void displayGlobal(void);
extern void displayIO(void);
extern void declare(void);

extern void displayLlvmcodes( LLVMcode *code ){
	if (code == NULL ) return;
	fprintf(fp, "  ");
	switch( code->command){
		case Alloca:
			displayFactor((code->args).alloca.retval);
			fprintf(fp, " = alloca i32, align 4\n");
			break;
		case Alloca_Array:
			displayFactor((code->args).alloca_array.retval);
			fprintf(fp, " = alloca [%d x i32], align 16\n",(code->args).alloca_array.arg1.val-(code->args).alloca_array.arg2.val+1);
			break;
		case Store:
			fprintf(fp, "store i32 ");
			displayFactor((code->args).store.arg1);
			fprintf(fp, ", i32* ");
			displayFactor((code->args).store.arg2);
			fprintf(fp, ", align 4\n");
			break;
		case Load:
			displayFactor((code->args).load.retval);
			fprintf(fp, " = load i32, i32* ");
			displayFactor((code->args).load.arg1);
			fprintf(fp, ", align 4\n");
			break;
		case BrUncond:
			fprintf(fp, "br label %%%d\n\n",(code->args).bruncond.arg1);
			break;
		case BrCond:
			fprintf(fp, "br i1 ");
			displayFactor((code->args).brcond.arg1);
			fprintf(fp, ", label %%%d, label %%%d\n\n",(code->args).brcond.arg2,(code->args).brcond.arg3);
			break;
		case Label:
			fprintf(fp, "; <label>:%d:\n",(code->args).label.l);
			break;
		case Add:
			displayFactor((code->args).add.retval);
			fprintf(fp, " = add nsw i32 ");
			displayFactor((code->args).add.arg1);
			fprintf(fp, ", ");
			displayFactor((code->args).add.arg2);
			fprintf(fp, "\n");
			break;
		case Sub:
			displayFactor((code->args).sub.retval);
			fprintf(fp, " = sub nsw i32 ");
			displayFactor((code->args).sub.arg1);
			fprintf(fp, ", ");
			displayFactor((code->args).sub.arg2);
			fprintf(fp, "\n");
			break;
		case Mult:
			displayFactor((code->args).mult.retval);
			fprintf(fp, " = mul nsw i32 ");
			displayFactor((code->args).mult.arg1);
			fprintf(fp, ", ");
			displayFactor((code->args).mult.arg2);
			fprintf(fp, "\n");
			break;
		case Div:
			displayFactor((code->args).div.retval);
			fprintf(fp, " = sdiv i32 ");
			displayFactor((code->args).div.arg1);
			fprintf(fp, ", ");
			displayFactor((code->args).div.arg2);
			fprintf(fp, "\n");
			break;
		case Icmp:
			displayFactor((code->args).icmp.retval);
			fprintf(fp, " = icmp");
			switch((code->args).icmp.type){
				case EQUAL:
					fprintf(fp, " eq");
					break;
				case NE:
					fprintf(fp, " ne");
					break;
				case SGT:
					fprintf(fp, " sgt");
					break;
				case SGE:
					fprintf(fp, " sge");
					break;
				case SLT:
					fprintf(fp, " slt");
					break;
				case SLE:
					fprintf(fp, " sle");
					break;
			};
			fprintf(fp, " i32 ");
			displayFactor((code->args).icmp.arg2);
			fprintf(fp, ", ");
			displayFactor((code->args).icmp.arg1);
			fprintf(fp, "\n");
			break;
		case Ret:
			if(strcmp((code->args).ret.arg1.vname,"void") == 0 ) {
				fprintf(fp, "ret void ");
			}
			else {
				fprintf(fp, "ret i32 ");
				displayFactor((code->args).ret.arg1);
			}
			fprintf(fp, "\n");
			break;
		case Call:
			if ((code->args).call.arg1.type == PROC_NAME){
				fprintf(fp, "call void @%s%d(",(code->args).call.arg1.vname,(code->args).call.arity_num);
				int i;
				for (i=(code->args).call.arity_num-1;i>=0;i--){
					fprintf(fp, "i32 ");
					displayFactor((code->args).call.arity[i]);
					if (i!=0) fprintf(fp, ",");
				}
				fprintf(fp, ")\n");
			}
			else if ((code->args).call.arg1.type == FUNC_NAME){
				displayFactor((code->args).call.arg2);
				fprintf(fp, " = call i32 @%s%d(",(code->args).call.arg1.vname,(code->args).call.arity_num);
				int i;
				for (i=(code->args).call.arity_num-1;i>=0;i--){
					fprintf(fp, "i32 ");
					displayFactor((code->args).call.arity[i]);
					if(i!=0) fprintf(fp, ",");
				}
				fprintf(fp, ")\n");	
			}
			break;
		case Read:
			displayFactor((code->args).read.retval);
			fprintf(fp, " = call i32 (i8*, ...) @scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.1, i64 0, i64 0), i32* ");
			displayFactor((code->args).read.arg1);
			fprintf(fp, ")\n");
			break;
		case Write:
			displayFactor((code->args).write.retval);
			fprintf(fp, " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 ");
			displayFactor((code->args).write.arg1);
			fprintf(fp, ")\n");
			break;
		case Sext:
			displayFactor((code->args).sext.retval);
			fprintf(fp, " = sext i32 ");
			displayFactor((code->args).sext.arg1);
			fprintf(fp, " to i64\n");
			break;
		case Gep:
			displayFactor((code->args).gep.retval);
			fprintf(fp, " = getelementptr inbounds [%d x i32], [%d x i32]* ",(code->args).gep.arg2.val,(code->args).gep.arg2.val);
			displayFactor((code->args).gep.arg2);
			fprintf(fp, ", i64 0,i64 ");
			displayFactor((code->args).gep.arg1);
			fprintf(fp, "\n");
			break;
		case Shl:
			displayFactor((code->args).shl.retval);
			fprintf(fp, " = shl i32 ");
			displayFactor((code->args).shl.arg1);
			fprintf(fp, ", ");
			displayFactor((code->args).shl.arg2);
			fprintf(fp, "\n");
			break;
		case Ashr:
			displayFactor((code->args).ashr.retval);
			fprintf(fp, " = ashr i32 ");
			displayFactor((code->args).ashr.arg1);
			fprintf(fp, ", ");
			displayFactor((code->args).ashr.arg2);
			fprintf(fp, "\n");
			break;
		default:
			break;
	}
	displayLlvmcodes( code->next);
}

extern void displayLlvmfundecl( Fundecl *decl ){
	if ( decl == NULL ) return;
	if (strcmp(decl->fname,"main") == 0){
			fprintf(fp, "define i32 @%s() {\n", decl->fname );
		}
	else {
		if (decl->arity > 0){
			if (decl->flag == false) {
			int i;
			fprintf(fp, "define void @%s%d(",decl->fname,decl->arity);
			for (i = 1;i < (decl->arity);i++){
				fprintf(fp, "i32,");
				}
			}
			else {
				int i;
				fprintf(fp, "define i32 @%s%d(",decl->fname,decl->arity);
				for (i = 1;i < (decl->arity);i++){
					fprintf(fp, "i32, ");
				}
			}
			fprintf(fp, "i32){ \n");
		}
		else{
			if(decl->flag == false){
				fprintf(fp, "define void @%s0() {\n",decl->fname);
			}
			else{
				fprintf(fp, "define i32 @%s0() {\n",decl->fname);
			}
		}
	}
	displayLlvmcodes( decl->codes );
	fprintf(fp, "}\n\n");
	displayLlvmfundecl( decl->next );
	return;
}

extern void displayFactor( Factor factor){
	switch(factor.type){
		case GLOBAL_VAR:
			fprintf(fp, "@%s",factor.vname);
			break;
		case LOCAL_VAR:
			fprintf(fp, "%%%d", factor.val);
			break;
		case CONSTANT:
			fprintf(fp, "%d",factor.val);
			break;
		case FUNC_NAME:
			fprintf(fp, "%%%d", factor.val);
			break;
		case GLOBAL_ARRAY:
			fprintf(fp, "@%s",factor.vname);
			break;
		case LOCAL_ARRAY:
			fprintf(fp, "%%%d",factor.val);
			break;
		default:
			break;
	}
	return;
}

extern void displayGlobal(void){
	Symtable *tmp;
	tmp = start;
	while (tmp != NULL){
		if(tmp->scope == GLOBAL_VAR){
			fprintf(fp, "@%s = common global i32 0, align 4\n",tmp->var_name);
		}
		else if(tmp->scope == GLOBAL_ARRAY){
			fprintf(fp, "@%s = common dso_local global [%d x i32] zeroinitializer, align 16\n",tmp->var_name,tmp->array_back-tmp->array_front+1);
		}
		tmp = tmp->next;
	}
	fprintf(fp, "\n");
}

extern void displayIO(void){
	if (printfflag == true){
		fprintf(fp, "@.str = private unnamed_addr constant [4 x i8] c\"%%d\\0A\\00\", align 1\n");
	}
	if(scanfflag == true){
		fprintf(fp, "@.str.1 = private unnamed_addr constant [3 x i8] c\"%%d\\00\", align 1\n");
	}
	fprintf(fp, "\n");
}

extern void declare(void){
	if (scanfflag == true){
		fprintf(fp, "declare i32 @scanf(i8*, ...)\n");
	}
	if (printfflag == true){
		fprintf(fp, "declare i32 @printf(i8*, ...)\n");
	}
}