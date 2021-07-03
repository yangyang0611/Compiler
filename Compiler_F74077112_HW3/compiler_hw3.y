/*	Definition section */
%{
    #include "common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;
    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }
    struct symbolTable symbolTable[100];
    char a[100];
    char *printArray[100];
    char *intNum = "int";
    char *floatNum = "float";
    char *boolean = "bool";
    char *string = "string";
    char *_ = "-";
    char *arr = "array";
    //char op_type;
    char *printtype ="X";
    int recenttype = 0;
    int redeclare = 0;
    int addr = 0;
    int recentScope = 0;
    bool handleArray = false;

    FILE *file;
    int has_error = 0;
    int cmpt = 0; 
    int cmpf = 1;
    int gtr_num = 0;
    int leq_num = 0;
    int eql_num = 0;
    int neq_num = 0;
    int lss_num = 0;
    int geq_num = 0;
    int printbool_num = 0;
    int currentaddr = 0;
    int tmp = 0;
    int fc = 0;
    int ifc = 0;
    int whileStack[100];
    int while_num = 0;
    int while_top = -1;
    int forStack[100];
    int for_num = 0;
    int for_top = -1;
    int string_assign = 0;
    int bool_assign = 0;
    int test = 0;
    int assign_num = 0;
    char recordType = 'x';

    /* Symbol table function - you can add new function if needed. */
    static void create_symbol();
    static void insert_symbol();
    static int lookup_symbol();
    static void dump_symbol();
    
    static char type_process(char);
    static void assign_op_process(char, int, char);
    static int unary_op_process(int, char);
    static char binary_op_process(char, int, char);
    //static char binary_op_process1(int, char, char, bool);
%}

%error-verbose

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */
 
%union {
    int i_val;
    float f_val;
    char *s_val;
    char c_val;
    bool b_val;
}

/* Token without return */
%token ID True False
%token <i_val> INT FLOAT BOOL STRING
%token INC DEC
%token NEWLINE PRINT IF ELSE FOR WHILE

/* Token with return, which need to sepcify type */
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%token <s_val> STRING_LIT
%token <b_val> BOOL_LIT

/* Nonterminal with return, which need to sepcify type */
//%type <c_val> add_op mul_op

/* Yacc will start at this nonterminal */
%start Program

/* Precedence and associative*/
%left '[' ']'
%left '<' '>' GEQ LEQ EQL NEQ
%left '+' '-' '*' '/' '%'
%right '=' '!' 
%right ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN 
%right AND OR

/* Grammar section */
%%

Program
    : StatementList
;

StatementList
    : StatementList Statement 
    | Statement 
;

Statement 
    :DeclarationStmt ';' 
    |AssignmentStmt 
    |Expression ';' 
    |IncDecStmt ';' 
    |IfStmt 
    |LoopStmt
    |Block 
    |PrintStmt 
    |NEWLINE
;    

DeclarationStmt
    :/*Type ID DeclareExtend
    { insert_symbol();
        $<i_val>$ = lookup_symbol(yylval.s_val);
        if(redeclare == 0)
           printf("> Insert {%s} into symbol table (scope level: %d)\n", $<s_val>2, recentScope);
            fprintf(file, "%d\n",$<i_val>3);
            recordType = $<c_val>1;
           }*/
    
    Type ID{
        insert_symbol();
        $<i_val>$ = lookup_symbol(yylval.s_val);
        if(redeclare == 0)
    		printf("> Insert {%s} into symbol table (scope level: %d)\n", $<s_val>2, recentScope);
        
        if($<c_val>1 == 'i') {fprintf(file, "ldc 0\nistore ");}
        if($<c_val>1 == 'f') {fprintf(file, "ldc 0.0\nfstore ");}
        if($<c_val>1 == 'a') {fprintf(file, "astore ");}
        if($<c_val>1 == 'z') {fprintf(file, "astore ");}
        if($<c_val>1 == 'x') {fprintf(file, "astore ");}
        if($<c_val>1 == 's') {fprintf(file, "ldc \"\"\nastore ");}
        //fprintf(file, "%d\n",$<i_val>2);
     } DeclareExtend1{fprintf(file, "%d\n",$<i_val>3);}
    |Type ID{
        insert_symbol();
        $<i_val>$ = lookup_symbol(yylval.s_val);
     } '=' Expression{
        if(redeclare == 0)
    		printf("> Insert {%s} into symbol table (scope level: %d)\n", $<s_val>2, recentScope);
        //fprintf(file, "%d\n",$<i_val>3);
     	if($<c_val>1 == 'i') {fprintf(file, "istore ");}
        if($<c_val>1 == 'f') {fprintf(file, "fstore ");}
        if($<c_val>1 == 's' || $<c_val>1 == 'S') {fprintf(file, "astore ");}
        if($<c_val>1 == 'b') {fprintf(file, "istore ");}
        if($<c_val>1 == 'a') {fprintf(file, "astore ");}
        if($<c_val>1 == 'z') {fprintf(file, "astore ");}
        if($<c_val>1 == 'x') {fprintf(file, "astore ");}
        fprintf(file, "%d\n",$<i_val>3);
     }
    
    
    
    | Type ID {insert_symbol();} ArrayType
      {
         if(redeclare ==0)
            printf("> Insert {%s} into symbol table (scope level: %d)\n", $<s_val>2, recentScope);
        symbolTable[yylineno].type = arr;
	    
       // for(int i = 0; i < 100; i++){
         //   if(symbolTable[i].lineno == yylineno){
                //symbolTable[yylineno].type = arr;
                if(a[yylineno] == 'i'){
                    symbolTable[yylineno].element = "int";
                    fprintf(file, "newarray int\n");
                }
                if(a[yylineno] == 'f'){
                    symbolTable[yylineno].element = "float";
                    fprintf(file, "newarray float\n");
                }
                if(a[yylineno] == 's')
                    symbolTable[yylineno].element = "string";
                if(a[yylineno] == 'b')
                    symbolTable[yylineno].element = "bool";    
          $<c_val>$ = 'a';
        }
;

DeclareExtend1:
	;

DeclareExtend
    : '=' Expression{
    if(recordType == 'i') {fprintf(file, "istore ");}
        if(recordType == 'f') {fprintf(file, "fstore ");}
        if(recordType == 's') {fprintf(file, "astore ");}
        if(recordType == 'b') {fprintf(file, "istore ");}
        if(recordType == 'a') {fprintf(file, "astore ");}
        if(recordType == 'z') {fprintf(file, "astore ");}
        if(recordType == 'x') {fprintf(file, "astore ");}
        }
    |{if(recordType == 'i') {fprintf(file, "ldc 0\nistore ");}
        if(recordType == 'f') {fprintf(file, "ldc 0.0\nfstore ");}
        if(recordType == 'a') {fprintf(file, "astore ");}
        if(recordType == 'z') {fprintf(file, "astore ");}
        if(recordType == 'x') {fprintf(file, "astore ");}
        if(recordType == 's') {fprintf(file, "ldc \"\"\nastore ");}
        }
;

/*AssignmentStmt
    :Expression {$<i_val>$ = tmp;} assign_op Expression {
        assign_op_process($<c_val>1, $<i_val>2, $<c_val>3);
       // if($<c_val>1 == 'b' && $<c_val>3 == 'B')
            //fprintf(file, "istore 0");
    } 

    ';'
;*/

AssignmentStmt:Expression{$<i_val>$ = tmp;} assign_op Expression{
    if($<c_val>1=='z')
	{fprintf(file,"iastore\n");}
    else if($<c_val>1=='x')
	{fprintf(file,"fastore\n");}
    if($<c_val>1=='I')
	{printf("error:%d: cannot assign to int\n",yylineno);has_error = 1;}
    if(($<c_val>1=='i')&&(($<c_val>4=='f')||($<c_val>4=='F'))){
        if($<c_val>3=='=')
	{printf("error:%d: invalid operation: ASSIGN (mismatched types int and float)\n",yylineno);has_error = 1;}
}
    if((($<c_val>1=='i')||($<c_val>1=='I'))&&(($<c_val>4=='i')||($<c_val>4=='I'))){
    	if($<i_val>3==1){printf("ASSIGN\n");fprintf(file,"istore %d\n",$<i_val>2);}
    	else if($<i_val>3==2){printf("ADD_ASSIGN\n");fprintf(file,"iadd\n");fprintf(file,"istore %d\n",$<i_val>2);}
    	else if($<i_val>3==3){printf("SUB_ASSIGN\n");fprintf(file,"isub\n");fprintf(file,"istore %d\n",$<i_val>2);}
    	else if($<i_val>3==4){printf("MUL_ASSIGN\n");fprintf(file,"imul\n");fprintf(file,"istore %d\n",$<i_val>2);}
    	else if($<i_val>3==5){printf("QUO_ASSIGN\n");fprintf(file,"idiv\n");fprintf(file,"istore %d\n",$<i_val>2);}
    	else if($<i_val>3==6){printf("REM_ASSIGN\n");fprintf(file,"irem\n");fprintf(file,"istore %d\n",$<i_val>2);}
        
    }
    if((($<c_val>1=='f')||($<c_val>1=='F'))&&(($<c_val>4=='f')||($<c_val>4=='F'))){
    	if($<i_val>3== 1){printf("ASSIGN\n");fprintf(file,"fstore %d\n",$<i_val>2);}
    	else if($<i_val>3==2){printf("ADD_ASSIGN\n");fprintf(file,"fadd\n");fprintf(file,"fstore %d\n",$<i_val>2);}
    	else if($<i_val>3==3){printf("SUB_ASSIGN\n");fprintf(file,"fsub\n");fprintf(file,"fstore %d\n",$<i_val>2);}
    	else if($<i_val>3==4){printf("MUL_ASSIGN\n");fprintf(file,"fmul\n");fprintf(file,"fstore %d\n",$<i_val>2);}
    	else if($<i_val>3==5){printf("QUO_ASSIGN\n");fprintf(file,"fdiv\n");fprintf(file,"fstore %d\n",$<i_val>2);}
    	else if($<i_val>3==6){printf("REM_ASSIGN\n");fprintf(file,"frem\n");fprintf(file,"fstore %d\n",$<i_val>2);}
        
    }
    if(($<c_val>1=='s')&&($<c_val>4=='S')){fprintf(file,"astore %d\n",$<i_val>2);}
    if(($<c_val>1=='b')&&($<c_val>4=='B')){fprintf(file,"istore %d\n",$<i_val>2);}
} ';'
;
assign_op 
    : '='{$<i_val>$ = 1;} 
    | ADD_ASSIGN{$<i_val>$ = 2;} 
    | SUB_ASSIGN{$<i_val>$ = 3;} 
    | MUL_ASSIGN{$<i_val>$ = 4;} 
    | QUO_ASSIGN{$<i_val>$ = 5;} 
    | REM_ASSIGN{$<i_val>$ = 6;}
;

Type 
	: TypeName {$<c_val>$ = type_process($<c_val>1);} 
	| ArrayType;

TypeName 
	: INT {$<c_val>$ = 'i'; }
    | FLOAT {$<c_val>$ = 'f'; }
    | STRING {$<c_val>$ = 's'; }
    | BOOL {$<c_val>$ = 'b'; }
;

ArrayType : '[' Expression ']' {handleArray = true; $<c_val>$ = 'a'; }

;

Expression
     /*Expression AND{printtype = "bool";} Expression
      {$<c_val>$ = 'b';
      binary_op_process1(14, $<c_val>1, $<c_val>3, true); }
    | Expression OR{printtype == "bool";} Expression
      {$<c_val>$ = 'b';
      binary_op_process1(15, $<c_val>1, $<c_val>3, true); }
	*/
      : Expression OR{printtype= "bool";} Expression{
    	if(($<c_val>1=='i' || $<c_val>1=='I') || ($<c_val>4=='i'|| $<c_val>4 =='I')){
            printf("error:%d: invalid operation: (operator OR not defined on int)\n",yylineno+1);
            has_error = 1;
        }
        else{
            $<c_val>$ = 'b';       
            printf("OR\n");
            fprintf(file, "ior\n");
        }
      } 
    | Expression AND{printtype = "bool";} Expression{
        if(($<c_val>1=='i'||$<c_val>1=='I')||($<c_val>4=='i'||$<c_val>4=='I')){
    	    printf("error:%d: invalid operation: (operator AND not defined on int)\n",yylineno+1);
            has_error = 1;
        }
        else{
            $<c_val>$ = 'b';
            printf("AND\n");
    	    fprintf(file, "iand\n");
        }
        }
    | entryB 
;
    
entryB 
    : entryB cmp_op entryC{
        //$<c_val>$ = 'b';
        $<c_val>$ = binary_op_process($<c_val>1, $<i_val>2, $<c_val>3);
        $<c_val>$ = 'b';
    } 
    | entryC
;

entryC 
    : /*entryC add_op entryD{
        if($<c_val>1 == 'z')
            fprintf(file, "iaload\n");
        else if($<c_val>1 == 'x')
            //fprintf(file, "faload\n");
        if((($<c_val>1=='f')||($<c_val>1=='F'))&&(($<c_val>3=='i')||($<c_val>3=='I'))){        
            if($<i_val>2 == 1){
                printf("error:%d: invalid operation: ADD (mismatched types float and int)\n",yylineno+1);
                has_error = 1;
            }
            if($<i_val>2 == 2){
                printf("error:%d: invalid operation: SUB (mismatched types float and int)\n",yylineno+1);
                has_error = 1;
            }
        }
        if((($<c_val>1 == 'i') || ($<c_val>1 == 'I')) && (($<c_val>3 == 'f')||($<c_val>3 == 'F'))){
            if($<i_val>2 == 1){
                printf("error:%d: invalid operation: ADD (mismatched types int and float)\n",yylineno+1);
                has_error = 1;
            }
            if($<i_val>2 == 2){
                printf("error:%d: invalid operation: SUB (mismatched types int and float)\n",yylineno+1);
                has_error = 1;
            }
        } 
       $<c_val>$ = 
       binary_op_process($<c_val>1, $<i_val>2, $<c_val>3);
    } */
entryC add_op entryD{
	{if($<c_val>1=='z'){fprintf(file,"iaload\n");}else if($<c_val>1=='x'){fprintf(file,"faload\n");}}
        if((($<c_val>1=='f')||($<c_val>1=='F'))&&(($<c_val>3=='i')||($<c_val>3=='I'))){
            if($<i_val>3==1){printf("error:%d: invalid operation: ADD (mismatched types float32 and int32)\n",yylineno);has_error = 1;}
            if($<i_val>3==2){printf("error:%d: invalid operation: SUB (mismatched types float32 and int32)\n",yylineno);has_error = 1;}
}
        if((($<c_val>1=='i')||($<c_val>1=='I'))&&(($<c_val>3=='f')||($<c_val>3=='F'))){
            if($<i_val>3==1){printf("error:%d: invalid operation: ADD (mismatched types int32 and float32)\n",yylineno);has_error = 1;}
            if($<i_val>3==2){printf("error:%d: invalid operation: SUB (mismatched types int32 and float32)\n",yylineno);has_error = 1;}
} 
        if((($<c_val>1=='i')||($<c_val>1=='I')||($<c_val>1=='z'))&&(($<c_val>3=='i')||($<c_val>3=='I')||($<c_val>1=='z'))){
            if($<i_val>3==1){fprintf(file,"iadd\n");}
            if($<i_val>3==2){fprintf(file,"isub\n");}
            $<c_val>$ = 'i';
}
        if((($<c_val>1=='f')||($<c_val>1=='F')||($<c_val>1=='x'))&&(($<c_val>3=='f')||($<c_val>3=='F')||($<c_val>1=='x'))){
            if($<i_val>3==1){fprintf(file,"fadd\n");}
            if($<i_val>3==2){fprintf(file,"fsub\n");}
            $<c_val>$ = 'f';
}
        if($<i_val>3==1){
            $<c_val>$ = $<c_val>1;
            printf("ADD\n");
        }
        else if($<i_val>3==2){
            printf("SUB\n");
        }
    } | entryD{$<c_val>$ = $<c_val>1;};    
    
    
    | entryD
;
    
entryD 
    : entryD
        /*if($<c_val>1 == 'z')
            fprintf(file, "iaload\n");
        else
            fprintf(file, "faload\n");*/
     mul_op UnaryExpr{
     if($<c_val>1 == 'z')
            fprintf(file, "iaload\n");
        else
            //fprintf(file, "faload\n");
      $<c_val>$ = 
      binary_op_process($<c_val>1, $<i_val>2, $<c_val>3);
        if($<i_val>2 == 5){
            if((($<c_val>1=='f')||($<c_val>1=='F'))&&(($<c_val>3=='i')||($<c_val>3=='I'))){
                printf("error:%d: invalid operation: (operator REM not defined on float)\n",yylineno+1);
                has_error = 1;
            }
            if((($<c_val>1=='i')||($<c_val>1=='I'))&&(($<c_val>3=='f')||($<c_val>3=='F'))){
                printf("error:%d: invalid operation: (operator REM not defined on float)\n",yylineno+1);
                has_error = 1;
            }
            printf("REM\n");
      }
    } 
    | UnaryExpr
;
    
UnaryExpr 
	: PrimaryExpr
	| unary_op UnaryExpr{unary_op_process($<i_val>1, $<c_val>2);}
;
    
add_op 
    : '+'{$<i_val>$ = 1;}
    | '-'{$<i_val>$ = 2;}
;

mul_op
    : '*'{$<i_val>$ = 3;}
    | '/'{$<i_val>$ = 4;} 
    | '%'{$<i_val>$ = 5;}
;

cmp_op 
	: EQL{$<i_val>$ = 6;} 
	| NEQ{$<i_val>$ = 7;} 
	| '<'{$<i_val>$ = 8;} 
	| LEQ{$<i_val>$ = 9;} 
	| '>'{$<i_val>$ = 10;} 
	| GEQ{$<i_val>$ = 11;}
;

unary_op 
	: '+'{$<i_val>$ = 1;}
	| '-'{$<i_val>$ = 2;}
	| '!'{$<i_val>$ = 3;}
;

PrimaryExpr 
	: Operand
	| IndexExpr 
	| ConversionExpr; 

Operand 
    : Literal 
    | ID{
        if(lookup_symbol(yylval.s_val)>=0)
            printf("IDENT (name=%s, address=%d)\n",yylval.s_val,lookup_symbol(yylval.s_val));
        else{
            printf("error:%d: undefined: %s\n",yylineno+1,yylval.s_val);
            has_error = 1;
        }
        for(int i=0;i<100;i++){
            if(symbolTable[i].addr == lookup_symbol(yylval.s_val)){
            tmp = lookup_symbol(yylval.s_val);
        	    if(strcmp(symbolTable[i].element, &_[0]) != 0){
        	        if(strcmp(symbolTable[i].element, "int") == 0){
                        printtype = "int";
                        $<c_val>$ = 'z';
                     }
                     if(strcmp(symbolTable[i].element, "float") == 0){
                        printtype= "float";
                        $<c_val>$ = 'x';
                     }
                     if(strcmp(symbolTable[i].element, "bool") == 0)
                        printtype = "bool";
                     if(strcmp(symbolTable[i].element, "string") == 0)
                        printtype = "string";
                     fprintf(file, "aload %d\n", lookup_symbol(yylval.s_val));    
                 }
                else{
                    if(printArray[symbolTable[i].addr] == "int"){
	                    $<c_val>$ = 'i';
			            printtype = "int";
                        fprintf(file, "iload %d\n", lookup_symbol(yylval.s_val));
                    }
                    if(printArray[symbolTable[i].addr] == "float"){
	                    $<c_val>$ = 'f';
                        printtype = "float";
                        fprintf(file, "fload %d\n", lookup_symbol(yylval.s_val));
                    
                    }
                    if(printArray[symbolTable[i].addr] == "bool"){
	                    $<c_val>$ = 'b';
	                    printtype = "bool";
                        fprintf(file, "iload %d\n", lookup_symbol(yylval.s_val));
		            }  
                    if(printArray[symbolTable[i].addr] == "string"){
                        $<c_val>$ = 's';
                        printtype = "string";
                        fprintf(file, "aload %d\n", lookup_symbol(yylval.s_val));   
		            }
                //op_type = $<c_val>$;             
            }
            break;
        }
            else
                $<c_val>$ = 'u';
        }
        currentaddr = lookup_symbol(yylval.s_val);
        recenttype = 2;
    }
    |'(' Expression ')'
;

Literal 
    : INT_LIT{
        $<c_val>$ = 'I';
        recenttype = 0;
        printf("INT_LIT %d\n",yylval.i_val);
        fprintf(file, "ldc %d\n",yylval.i_val);
    }   
    | FLOAT_LIT{
        $<c_val>$ = 'F';
        recenttype = 1;
        printtype = "float";
        printf("FLOAT_LIT %.6f\n",yylval.f_val);
        fprintf(file, "ldc %f\n",yylval.f_val);
    }   
    |'"' STRING_LIT '"'{
        $<c_val>$ = 'S';
        //recenttype = "String";
        printtype = "string";
        printf("STRING_LIT %s\n", yylval.s_val);
        fprintf(file, "ldc \"%s\"\n",yylval.s_val);
    }
    | BOOL_LIT{
        $<c_val>$ = 'B';
        //recenttype = "Bool";
        if(yylval.b_val){
            printf("TRUE\n");
            fprintf(file, "iconst_1\n");
        }
        else{
            printf("FALSE\n");
            fprintf(file, "iconst_0\n");
        }
    } 
;  

IndexExpr
    : PrimaryExpr '[' Expression ']'{
        recenttype = 3;
    }
;

ConversionExpr
    : '(' Type ')' Expression{
        char s = 'X', t = 'X';         
        //char sType = 'X', tType = 'X';         
        for(int i = 0; i < 100; i++){
           /*// if(strcmp(recenttype, "Val") == 0){
              if(currenttype = 2){  
                if(symbolTable[i].addr==lookup_symbol(yylval.s_val)){
                    if(a[yylineno] == 'i')
                         tType = 'I';
                    if(a[yylineno] == 'f'){
                         tType = 'F';
                         //fprintf(file, "faload\n");
                    }
                    if(a[yylineno] == 'b')
                         tType = 'B';
                    if(a[yylineno] == 's')
                         tType = 'S';
                    
                    if(strcmp(symbolTable[i].type, "int") == 0){
                        printf("I to %c\n",tType);
                        fprintf(file ,"i2f\n");
                        $<c_val>$ = 'f';
                    }
                    if(strcmp(symbolTable[i].type, "float") == 0){
                        printf("F to %c\n",tType);
                        fprintf(file, "f2i\n");
                        $<c_val>$ = 'i';
                        printtype = "int";
                    }
                    if(strcmp(symbolTable[i].type, "bool") == 0)
                        printf("B to %c\n",tType);
                    if(strcmp(symbolTable[i].type, "string") == 0)
                        printf("S to %c\n",tType);
                    break;
                }              
            }
            //the else if there need more change
            else if(currenttype = 2){
              //else{
              if(strcmp(recenttype, "Float") == 0)
                        sType = 'F';
                    if(strcmp(recenttype, "Int") == 0)
                        sType = 'I';
                    if(a[yylineno] == 'i'){
                         printf("%c to I\n",sType);
                         fprintf(file, "f2i\n");
                         $<c_val>$ = 'i';
                         printtype = "int";
                    }
                    if(a[yylineno] == 'f'){
                         printf("%c to F\n",sType);
                         fprintf(file, "i2f\n");
                         $<c_val>$ = 'f';
                         //printftype = "float";
                    }
                    if(a[yylineno] == 'b')
                         printf("%c to B\n",sType);
                    if(a[yylineno] == 's')
                         printf("%c to S\n",sType);
		
                    break;
            }*/
            if(recenttype == 2){
                //printf("1 lv\n");
                //printf("%d\n",lookup_symbol(yylval.s_val));
                if(symbolTable[i].addr==lookup_symbol(yylval.s_val)){
                    //printf("2 lv\n");
                    if(symbolTable[i].type=="int"){s = 'I';}
                    else if(symbolTable[i].type=="float"){ s = 'F';}
                    else if(symbolTable[i].type=="bool"){ s = 'B';}
                    else if(symbolTable[i].type=="string"){ s = 'S';}
                    
                    if($<c_val>2=='i'){ /*st[i].type = int32;*/t = 'I';}
                    else if($<c_val>2=='f'){ /*st[i].type = float32;*/t = 'F';}
                    else if($<c_val>2=='b'){ /*st[i].type = boo;*/t = 'B';}
                    else if($<c_val>2=='s'){ /*st[i].type = string;*/t = 'S';}
		    if((s=='I')&&(t=='F')){fprintf(file,"i2f\n");$<c_val>$ = 'f';}
		    else if((s=='F')&&(t=='I')){fprintf(file,"f2i\n");$<c_val>$ = 'i';printtype = "int";}
                    printf("%c to %c\n",s,t);
                    break;
                }
                
            }
            else if(recenttype == 3){
		    if(symbolTable[i].addr==currentaddr){
		     if(symbolTable[i].element== "int"){s = 'I';}
                     else if(symbolTable[i].element== "float32"){s = 'F';fprintf(file,"faload\n");}
                     else if(symbolTable[i].element== "bool"){s = 'B';}
                     else if(symbolTable[i].element== "string"){s = 'I';}

		     if($<c_val>2=='i'){ /*st[i].type = int32;*/t = 'I';}
                     else if($<c_val>2=='f'){ /*st[i].type = float32;*/t = 'F';}
                     else if($<c_val>2=='b'){ /*st[i].type = boo;*/t = 'B';}
                     else if($<c_val>2=='s'){ /*st[i].type = string;*/t = 'S';}
		     if((s=='I')&&(t=='F')){fprintf(file,"i2f\n");$<c_val>$ = 'f';}
		     else if((s=='F')&&(t=='I')){fprintf(file,"f2i\n");$<c_val>$ = 'i';printtype = "int";}
                     printf("%c to %c\n",s,t);
                     break;
		}
	    }
            else{
                if(recenttype == 1) {s = 'F';}
                else if(recenttype == 0) {s = 'I';}
                if(a[yylineno] == 'i') {t = 'I';}
                else if(a[yylineno] == 'f') {t = 'F';}
                else if(a[yylineno] == 'b') {t = 'B';}
                else if(a[yylineno] == 's') {t = 'S';}
                if((s == 'I') && (t == 'F')) {fprintf(file, "i2f\n"); $<c_val>$ = 'f';}
                else if((s == 'F') && (t == 'I')) {fprintf(file, "f2i\n"); $<c_val>$ = 'i';}
                printf("%c to %c\n", s, t);
                break;
            }
       }
}
;

IncDecStmt
    :ID{
       for(int i=0;i<100;i++){
             if(symbolTable[i].addr==lookup_symbol(yylval.s_val)){
                 if(strcmp(symbolTable[i].element,  &_[0]) != 0){
                     if(strcmp(symbolTable[i].element, "int") == 0) {}
                     else if(strcmp(symbolTable[i].element, "float") == 0) {}
                 }
                 else{
                     //if(symbolTable[i].type== "int")
                    if(printArray[symbolTable[i].addr] == "int")
                    {fprintf(file,"iload %d\nldc 1\n",lookup_symbol(yylval.s_val));}
                     //else if(symbolTable[i].type== "float")
                    else if(printArray[symbolTable[i].addr] == "float")
                    {fprintf(file,"fload %d\nldc 1.0\n",lookup_symbol(yylval.s_val));}                    
                 }
                 break;
             }
             else{$<c_val>$ = 'u';}
        }
        $<s_val>$ =yylval.s_val;
        if(lookup_symbol(yylval.s_val)>=0){
            printf("IDENT (name=%s, address=%d)\n",yylval.s_val,lookup_symbol(yylval.s_val));
        }
        else{
            printf("error:%d: undefined: %s\n",yylineno+1,yylval.s_val);has_error = 1;
        }
    }
    INC{
        for(int i=0;i<100;i++){
             if(symbolTable[i].addr==lookup_symbol($<s_val>2)){
                 //if(symbolTable[i].element!= &_[0]){
                  //   if(symbolTable[i].element== "int"){}
                  //   else if(symbolTable[i].element== "float"){}
                  if(strcmp(symbolTable[i].element,  &_[0]) != 0){
                     if(strcmp(symbolTable[i].element, "int") == 0) {}
                     else if(strcmp(symbolTable[i].element, "float") == 0) {}
                 }
                 else{
                     //if(symbolTable[i].type== "int")
                     if(printArray[symbolTable[i].addr] == "int")
                     {fprintf(file,"iadd\nistore %d\n",lookup_symbol($<s_val>2));}
                     //else if(symbolTable[i].type== "float")
                     else if(printArray[symbolTable[i].addr] == "float")
                     {fprintf(file,"fadd\nfstore %d\n",lookup_symbol($<s_val>2));}                    
                 }
                 break;
             }
             else{$<c_val>$ = 'u';}
        }
        printf("INC\n");
    }
    | ID{
       for(int i=0;i<100;i++){
             if(symbolTable[i].addr==lookup_symbol(yylval.s_val)){
                 if(strcmp(symbolTable[i].element,  &_[0]) != 0){
                     if(strcmp(symbolTable[i].element, "int") == 0) {}
                     else if(strcmp(symbolTable[i].element, "float") == 0) {}
                 }
                 else{
                     //if(symbolTable[i].type== "int")
                    if(printArray[symbolTable[i].addr] == "int")
                    {fprintf(file,"iload %d\nldc 1\n",lookup_symbol(yylval.s_val));}
                     //else if(symbolTable[i].type== "float")
                    else if(printArray[symbolTable[i].addr] == "float")
                    {fprintf(file,"fload %d\nldc 1.0\n",lookup_symbol(yylval.s_val));}                    
                 }
                 break;
             }
             else{$<c_val>$ = 'u';}
        }
        $<s_val>$ =yylval.s_val;
        if(lookup_symbol(yylval.s_val)>=0){
            printf("IDENT (name=%s, address=%d)\n",yylval.s_val,lookup_symbol(yylval.s_val));
        }
        else{
            printf("error:%d: undefined: %s\n",yylineno+1,yylval.s_val);has_error = 1;
        }
    }
    DEC{
       for(int i=0;i<100;i++){
             if(symbolTable[i].addr==lookup_symbol($<s_val>2)){
                 //if(symbolTable[i].element!= &_[0]){
                   //  if(symbolTable[i].element== "int"){}
                   //  else if(symbolTable[i].element== "float"){}
                     if(strcmp(symbolTable[i].element,  &_[0]) != 0){
                     if(strcmp(symbolTable[i].element, "int") == 0) {}
                     else if(strcmp(symbolTable[i].element, "float") == 0) {}
                 }
                 else{
                    // if(symbolTable[i].type== "int")
                     if(printArray[symbolTable[i].addr] == "int")
                     {fprintf(file,"isub\nistore %d\n",lookup_symbol($<s_val>2));}
                     //else if(symbolTable[i].type== "float")
                     else if(printArray[symbolTable[i].addr] == "float")
                     {fprintf(file,"fsub\nfstore %d\n",lookup_symbol($<s_val>2));}                    
                 }
                 break;
             }
             else{$<c_val>$ = 'u';}
        }
        printf("DEC\n");
    }
;
/*
IncDecStmt
	: ID inc_dec_op{
        /*for(int i = 0; i < 100; i++){
            if(symbolTable[i].addr == lookup_symbol(yylval.s_val)){
                if(symbolTable[i].element != &_[0]){
                    if(symbolTable[i].element == "int") {}
                    else if(symbolTable[i].element == "float") {}
                }
                else{
                    if(symbolTable[i].type == "int")
                        fprintf(file, "iload %d\nldc 1\n", lookup_symbol(yylval.s_val));
                    else if(symbolTable[i].type == "float")
                        fprintf(file, "fload %d\nldc 1.0\n", lookup_symbol(yylval.s_val));
                }
            }
            else 
                $<c_val>$ = 'u';
        }
            $<s_val>$ = yylval.s_val;
            if(lookup_symbol(yylval.s_val)>=0)
                printf("IDENT (name=%s, address=%d)\n",yylval.s_val,lookup_symbol(yylval.s_val));
            else{
                printf("error:%d: undefined: %s\n",yylineno+1,yylval.s_val);
                has_error = 1;
            }
       //}
       // inc_dec_op{
            for(int i = 0; i < 100; i++){
                if(symbolTable[i].addr == lookup_symbol($<s_val>2)){
                    if(symbolTable[i].element != &_[0]){
                        if(symbolTable[i].element == "int"){}
                        else if(symbolTable[i].element == "float"){}
                    }
                    else{
                        if(symbolTable[i].type == "int" && $<i_val>2 == 12)
                            fprintf(file, "%cadd\n%cstore %d\n", symbolTable[i].type[0], symbolTable[i].type[0], lookup_symbol($<s_val>2));
                        //else if(symbolTable.type == "float" && $<i_val> == 12)
                          //  fprintf(file, "fadd\nistore %d\n", lookup_symbol($<s_val>2));
                    	 else if(symbolTable[i].type == "float" && $<i_val>2 == 13)
                            fprintf(file, "%csub\n%cstore %d\n", symbolTable[i].type[0], symbolTable[i].type[0], lookup_symbol($<s_val>2));
                    }
                    //break;
                }
            }
                 //else 
                    $<c_val>$ = 'u';
                    binary_op_process('x', $<i_val>2, 'x');
        }
        //binary_op_process($<i_val>2);
;
*/
inc_dec_op
	: INC {$<i_val>$ = 12;}
	| DEC {$<i_val>$ = 13;}
;

Block 
    : '{'{recentScope+=1;} NEWLINE StatementList '}'{dump_symbol();recentScope-=1;}
;

IfStmt:
      IFS 
	{fprintf(file,"else_%d:\n",$<i_val>1);fprintf(file,"if_exit_%d:\n",$<i_val>1);}
     |IFS ElseStmt
	{fprintf(file,"if_exit_%d:\n",$<i_val>1);}
;

IFS :IF{$<i_val>$=ifc;ifc++;} 
	Condition{fprintf(file,"ifeq else_%d\n",$<i_val>2);} 
	Block{fprintf(file,"goto if_exit_%d\n",$<i_val>2);$<i_val>$=$<i_val>2;}

;
ElseStmt:ELSE {fprintf(file,"else_%d:\n",--ifc);
            $<i_val>$=ifc;
            ifc++;} 
        IfStmt
        |ELSE {fprintf(file,"else_%d:\n",--ifc);$<i_val>$=ifc;ifc++;} Block
;

/*
IfStmt
    :IF {
        fprintf(file, "L_if_false_%d:\n",$<i_val>1);
    } '(' Condition 
    ')' 
    Block IfExtend
    |IF '(' Condition ')' NEWLINE Block IfExtend
    |IfExtend  
;

IfExtend
    : ELSE ElseExtend
    |
;

ElseExtend
    : IfStmt
    | Block
;
*/
Condition
    :Expression{
	if($<c_val>1 =='i'|| $<c_val>1 == 'I'){
        printf("error:%d: non-bool (type int) used as for condition\n",yylineno+2);
        has_error = 1;
    }
    if($<c_val>1 =='f'|| $<c_val>1 == 'F'){
        printf("error:%d: non-bool (type float) used as for condition\n",yylineno+2);
        has_error = 1;
    }
}
;

LoopStmt
    : //ForStmt
//;

//ForStmt:
      /* FOR '(' {fprintf(file,"L_for_begin_%d:\n",fc);}  FS 
;

FS:	Condition{
		$<i_val>$=fc;  
		fprintf(file,"ifeq L_for_exit_%d\n",fc);
		fc++;
	}
	 Block{
		fprintf(file,"goto L_for_begin_%d\n",$<i_val>2);
		fprintf(file,"L_for_exit_%d:\n",$<i_val>2);
	} ')'
	|ForClause{
		$<i_val>$=fc;
		fprintf(file,"L_for_cont_%d:\n",fc);fc++;
	} Block{
		fprintf(file,"goto L_for_post_%d\n",$<i_val>2);
		fprintf(file,"L_for_exit_%d:\n",$<i_val>2);
	} ')'
;
ForClause:SimpleStmt{fprintf(file,"L_for_cond_%d:\n",fc);}
//	 ';'
	 Condition{
		fprintf(file,"ifeq L_for_exit_%d\n",fc);
		fprintf(file,"goto L_for_cont_%d\n",fc);}
	 ';'{fprintf(file,"L_for_post_%d:\n",fc);}
	 SimpleStmt{fprintf(file,"goto L_for_cond_%d\n",fc);}

;*/
    /*FOR {fprintf(file, "for_begin_%d:\n", fc);} 
    '('
    ForClause {
        //$<i_val>$ = fc;
        fprintf(file, "forcont%d\n", fc);
        fc++;
    }
    ')' 
    Block{
        fprintf(file, "goto for_begin%d\n", $<i_val>2);
        fprintf(file, "for_exit:%d\n", $<i_val>2);
    }*/
    FOR '(' ForClause AssignFor ')' Block ForEnd
	| WHILE '(' EnterWhile Condition LeaveWhile ')' Block WhileEnd
	| WHILE '(' EnterWhile Condition LeaveWhile ')' Block NEWLINE WhileEnd
	| WHILE '(' EnterWhile Condition LeaveWhile ')' NEWLINE Block WhileEnd

;
	
EnterWhile
    : {
        fprintf(file, "whileLoop%d:\n", while_num);
        whileStack[++while_top] = while_num;    
    }
;

LeaveWhile
    : {
        fprintf(file, "ifeq exit_while%d\n", while_num++);
    }
;

WhileEnd
    : {
        fprintf(file, "goto whileLoop%d\n", whileStack[while_top]);
        fprintf(file, "exit_while%d:\n", whileStack[while_top--]);
      }
;

/*ForClause
    :SimpleStmt {fprintf(file, "forcond%d:\n", fc);} 
    Condition //{
        //$<i_val>$ = fc;
        //fprintf(file, "ifeq for_exit_%d\n",fc);
        //fprintf(file, "goto for_cint%d\n", fc);
   // }
    ';' {fprintf(file, "for_post_%d\n", fc);}
    SimpleStmt /*{fprintf(file, "goto forcond%d\n", fc);}
;
*/

ForClause
    :SimpleStmt {fprintf(file, "for_loop%d:\n", for_num);} Condition LeaveFor ';' SimpleStmt
;

LeaveFor
    : {
        fprintf(file, "ifeq exit_for%d\n", for_num);
        fprintf(file, "goto for_statement%d\n", for_num);
        fprintf(file, "for_index_update%d:\n", for_num);
        //forStack[++for_top] = for_num++;
    }
;

AssignFor
    : {
        fprintf(file, "goto for_loop%d\n", for_num);
        fprintf(file, "for_statement%d:\n", for_num);
        forStack[++for_top] = for_num++;
    }
;

ForEnd
    : {
        fprintf(file, "goto for_index_update%d\n", forStack[for_top]);
        fprintf(file, "exit_for%d:\n", forStack[for_top--]);
    }
;   

SimpleStmt 
	: DeclarationStmt 
	| AssignmentStmt 
	| Expression 
	| IncDecStmt
;

PrintStmt 
	: PRINT{printtype = "int";} '(' Expression ')'
    {
        if($<c_val>3 == 'z')
            fprintf(file, "iaload\n");
        else if($<c_val>3 == 'x')
            fprintf(file, "faload\n");
        if(strcmp(printtype, "int") == 0){
            printf("PRINT %s\n", printtype);
            fprintf(file, "getstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(file, "swap\n");
            fprintf(file, "invokevirtual java/io/PrintStream/print(I)V\n");
            }
        if(strcmp(printtype, "float") == 0){
            printf("PRINT %s\n", printtype);
            fprintf(file, "getstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(file, "swap\n");
            fprintf(file, "invokevirtual java/io/PrintStream/print(F)V\n");
            }
        if(strcmp(printtype, "bool") == 0){
            printf("PRINT %s\n", printtype);
            fprintf(file, "ifeq FALSE_%d\n", printbool_num);
            fprintf(file, "TRUE_%d:\n", printbool_num);
            fprintf(file, "ldc \"true\"\n");
            fprintf(file, "goto exit_printbool%d\n", printbool_num);
            fprintf(file, "FALSE_%d:\n", printbool_num);
            fprintf(file, "ldc \"false\"\n");
            fprintf(file, "exit_printbool%d:\n", printbool_num);
            //cmpt+=2;
            //cmpf+=2;
            fprintf(file, "getstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(file, "swap\n");
            fprintf(file, "invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
            printbool_num++;
            }
        if(strcmp(printtype, "string") == 0){
            printf("PRINT %s\n", printtype);
            fprintf(file, "getstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(file, "swap\n");
            fprintf(file, "invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
        }
	} ';'
;

%%

/* C code section */
int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    
    file = fopen("hw3.j","wb");
    fprintf(file, ".source hw3.j\n");
    fprintf(file, ".class public Main\n");
    fprintf(file, ".super java/lang/Object\n");
    fprintf(file, ".method public static main([Ljava/lang/String;)V\n");
    fprintf(file, ".limit stack 100\n");
    fprintf(file, ".limit locals 100\n");

    create_symbol();
    yylineno = 0;
    yyparse();
    dump_symbol();
    printf("Total lines: %d\n", yylineno+1);
    fclose(yyin);

    fprintf(file, "return\n");
    fprintf(file, ".end method\n");
    if(has_error)
        remove("hw3.j");
    return 0;
}

static void create_symbol() {
    int i = 0;
    while(i != 100){
        symbolTable[i].index = -1; 
        symbolTable[i].name = NULL; 
        symbolTable[i].type = NULL; 
        symbolTable[i].addr = -1; 
        symbolTable[i].lineno = -1; 
        symbolTable[i].element = _; 
        symbolTable[i].scope = -1; 
        a[i] = 'X';
	i++;
    }
}

static void insert_symbol() {
    int i = 0, j = 0;
    while(i != 100){
        if(symbolTable[i].scope == recentScope){
            if(strcmp(symbolTable[i].name,yylval.s_val) == 0){
                printf("error:%d: %s redeclared in this block. previous declaration at line %d\n",yylineno+1,yylval.s_val,symbolTable[i].lineno+1);
                has_error = 1;
                redeclare = 1;
                return;
            }
        }
        i++;
    }
    i = 0;
    while(i != 100){
        if(symbolTable[i].index == -1){
            int largest = -1;
            while(j != 100){
                if(symbolTable[j].scope == recentScope){
                    if(symbolTable[j].index > largest){
                        largest = symbolTable[j].index;
                    }
                }                    
            j++;
            }
            symbolTable[i].index = largest+1; symbolTable[i].name = yylval.s_val; symbolTable[i].addr = addr; addr+=1; symbolTable[i].lineno = yylineno; symbolTable[i].element = _; symbolTable[i].scope = recentScope;;
            return;
        }   
    i++;
    }
}

static int lookup_symbol() {
    for(int findScope = recentScope; findScope >= 0; findScope --){
        for(int i = 0;i < 100; i++){
            if(symbolTable[i].scope==findScope){
                if(strcmp(symbolTable[i].name,yylval.s_val) == 0)
		    return symbolTable[i].addr; 
            }
        }
    }
    return -1;
}

static void dump_symbol() {
    printf("> Dump symbol table (scope level: %d)\n", recentScope);
    printf("%-10s%-10s%-10s%-10s%-10s%s\n",
           "Index", "Name", "Type", "Address", "Lineno", "Element type");
    int i = 0;
    while(i != 100){
        if(symbolTable[i].scope==recentScope){
            printf("%-10d%-10s%-10s%-10d%-10d%s\n", symbolTable[i].index, symbolTable[i].name, symbolTable[symbolTable[i].lineno].type, symbolTable[i].addr, symbolTable[i].lineno+1, symbolTable[symbolTable[i].lineno].element);
            symbolTable[i].index = -1; symbolTable[i].name = NULL; symbolTable[i].type = NULL; symbolTable[i].addr = -1; symbolTable[i].lineno = -1; symbolTable[i].element = NULL; symbolTable[i].scope = -1; a[i] = 'X';
        }
        i++;
    }   
}

static char type_process(char type){
	switch(type){
		case 'i':
		{
			    symbolTable[yylineno].type = "int";
			    printArray[addr] = "int";
                a[yylineno] = 'i';
                return 'i';
            
        }
		case 'f':
       	{
       		symbolTable[yylineno].type = "float";
                a[yylineno] = 'f';
			    printArray[addr] = "float";
			    return 'f';
			    
        }
		case 's':
        {
        	 symbolTable[yylineno].type = "string";
                a[yylineno] = 's';
			    printArray[addr] = "string";
			    return 's';
			
        }
		case 'b':
        {
        	    symbolTable[yylineno].type = "bool";
		        a[yylineno] = 'b';
                printArray[addr] = "bool";
			    return 'b';
		    
        }
        
    }	
}

static void assign_op_process(char input1, int op, char input2){
    if(input1 == 'z')  // int
        fprintf(file, "iastore\n");
    if(input1 == 'x')  // float
        fprintf(file, "fastore\n");
    if(input1 == 's' && input2 == 'S')
        //fprintf(file, "astore %d\n", ++string_assign);
    if(input1 == 'b' && input2 == 'B')
        //fprintf(file, "istore 0\n");
    
    if(input1 =='I'){
        printf("error:%d: cannot assign to int\n",yylineno+1);
        has_error = 1;
    }
    if((input1 =='i') && (input2 =='f')){
        if(op == 1){
            printf("error:%d: invalid operation: ASSIGN (mismatched types int and float)\n",yylineno+1);
            has_error = 1;
        }
    }
    
    char *typeA = "f";
    if(((input1 == 'i') || (input1 == 'I')) && ((input2 == 'i') || (input2 == 'I')))
        typeA = "i";
    if(((input1 == 'f') || (input1 == 'F')) && ((input2 == 'f') || (input2 == 'F')))
        typeA = "f";
    
    switch(op){
        case 1:{
            printf("ASSIGN\n");  
            fprintf(file, "%cstore %d\n",typeA[0], assign_num++  );
            break;
        }
        case 2:{
            printf("ADD_ASSIGN\n");
            fprintf(file, "%cadd\n", typeA[0]);
            break;
        }
        case 3:{
            printf("SUB_ASSIGN\n");
            fprintf(file, "%csub\n", typeA[0] );
            break;
        }
        case 4:{
            printf("MUL_ASSIGN\n");
            fprintf(file, "%cmul\n", typeA[0] );
            break;
        }
        case 5:{
            printf("QUO_ASSIGN\n");
            fprintf(file, "%cdiv\n", typeA[0] );
            break;
        }
        case 6:{
            printf("REM_ASSIGN\n");
            fprintf(file, "%crem\n", typeA[0] );
            break;
        }
    }
}

static int unary_op_process(int op, char input){
	switch(op){
		case 1:
			printf("POS\n");
            return input;
		case 2:
			printf("NEG\n");
            if(input == 'i' || input == 'I')
                fprintf(file, "ineg\n");
            if(input == 'f' ||input == 'F')
                fprintf(file, "fneg\n");
			return input;
		case 3:
			printf("NOT\n");
            fprintf(file, "iconst_1\n");
            fprintf(file, "ixor\n");
            return input;
	}
}

static char  binary_op_process(char input1, int op, char input2){
	char *typeB = "i";
    if(((input1 == 'i') || (input1 == 'I') || (input1 == 'z')) && ((input2 == 'i') || (input2 == 'I') || (input2 == 'z')))
        typeB = "isub";
        //type = "i";
    if(((input1 == 'f') || (input1 == 'F') || (input1 == 'x')) && ((input2 == 'f') || (input2 == 'F') || (input2 == 'x')))
        typeB = "fcmpl";

    switch(op){
		case 1:
        {
			printf("ADD\n");
          //  if(type == "isub")  
              //  fprintf(file, "iadd\n");  // ("%cadd",type[0])
			//else
                fprintf(file, "%cadd\n", typeB[0]);
            //return 0;
            return typeB[0];
		}
        case 2:
        {   
			printf("SUB\n");
			//if(type == "fcmpl");
             //   fprintf(file, "isub\n");
            //else
                fprintf(file, "%csub\n", typeB[0]);
            //return 0;
            return typeB[0];
		}
        case 3:
        {
			printf("MUL\n");
		    fprintf(file, "%cmul\n", typeB[0]);
            //return 0;
            return typeB[0];
		}
        case 4:
        {
			printf("QUO\n");
            fprintf(file, "%cdiv\n", typeB[0]);
            //return 0;
			return typeB[0];
		}
        case 5:
        {
            fprintf(file, "%crem\n", typeB[0]);

			//return op;
            return typeB[0];
        }
		case 6:
        {
			printf("EQL\n");
            fprintf(file, "%s\n", typeB);
            fprintf(file, "ifeq L_eql%d_1\n", eql_num);
            fprintf(file, "L_eql%d_0:\n", eql_num);
            fprintf(file, "iconst_0\n");
            fprintf(file, "goto exit_eql%d_cmp\n",eql_num);
            fprintf(file, "L_eql%d_1:\n", eql_num);
            fprintf(file, "iconst_1\n");
            fprintf(file, "exit_eql%d_cmp:\n",eql_num);
            eql_num++;
            //return 0;
            	return 'b';
		}
        case 7:
		{
            printf("NEQ\n");
		    fprintf(file, "%s\n", typeB);
            fprintf(file, "ifne L_neq%d_1\n", neq_num);
            fprintf(file, "L_neq%d_0:\n", neq_num);
            fprintf(file, "iconst_0\n");
            fprintf(file, "goto exit_neq%d_cmp\n",neq_num);
            fprintf(file, "L_neq%d_1:\n", neq_num);
            fprintf(file, "iconst_1\n");
            fprintf(file, "exit_neq%d_cmp:\n",neq_num);
            neq_num++;
            //return 0;
            return 'b';
        }
		case 8:
		{
            printf("LSS\n");
		    fprintf(file, "%s\n", typeB);
            fprintf(file, "iflt L_lss%d_1\n", lss_num);
            fprintf(file, "L_lss%d_0:\n", lss_num);
            fprintf(file, "iconst_0\n");
            fprintf(file, "goto exit_lss%d_cmp\n",lss_num);
            fprintf(file, "L_lss%d_1:\n", lss_num);
            fprintf(file, "iconst_1\n");
            fprintf(file, "exit_lss%d_cmp:\n",lss_num);
            lss_num++;
            //cmpt+=2;
            //cmpf+=2;
            //return 0;
            return 'b';
		}
        case 9:
        {
			printf("LEQ\n");
            fprintf(file, "%s\n", typeB);
            fprintf(file, "ifle L_leq%d_1\n", leq_num);
            fprintf(file, "L_leq%d_0:\n", leq_num);
            fprintf(file, "iconst_0\n");
            fprintf(file, "goto exit_leq%d_cmp\n",leq_num);
            fprintf(file, "L_leq%d_1:\n", leq_num);
            fprintf(file, "iconst_1\n");
            fprintf(file, "exit_leq%d_cmp:\n",leq_num);
            leq_num++;
            //cmpt+=2;
            //cmpf+=2;
            //return 0;
			return 'b';
		}
        case 10:
        {
			printf("GTR\n");
		    fprintf(file, "%s\n", typeB);
            fprintf(file, "ifgt L_gtr%d_1\n", gtr_num);
            fprintf(file, "L_gtr%d_0:\n", gtr_num);
            fprintf(file, "iconst_0\n");
            fprintf(file, "goto exit_gtr%d_cmp\n", gtr_num);
            fprintf(file, "L_gtr%d_1:\n", gtr_num);
            fprintf(file, "iconst_1\n");
            fprintf(file, "exit_gtr%d_cmp:\n", gtr_num);
            gtr_num++;
            //cmpt+=2;
            //cmpf+=2;
            //return 0;
            return 'b';
		}
        case 11:
        {
            printf("GEQ\n");
			fprintf(file, "%s\n", typeB);
            fprintf(file, "ifge L_geq%d_1\n", geq_num);
            fprintf(file, "L_geq%d_0:\n", geq_num);
            fprintf(file, "iconst_0\n");
            fprintf(file, "goto exit_geq%d_cmp\n", geq_num);
            fprintf(file, "L_geq%d_1:\n", geq_num);
            fprintf(file, "iconst_1\n");
            fprintf(file, "exit_geq%d_cmp:\n", geq_num);
            geq_num++;
            //return 0;
            return 'b';
        }
        case 12:
			printf("INC\n");
			//if()
		//	return 0;
            return 'u';
		case 13:
			printf("DEC\n");
			//if()
		//	return 0;
            return 'u';
        //case 15:
            //printf("OR");
           // return 0;
          // return 'b';
        //case 14:
            //printf("AND");
          //  return 0;
          // return 'b';
	}
}

/*static char binary_op_process1(int input, char op1, char op2, bool type_checking){
    if(type_checking == true){
        switch(input){
            //14 or 15and
            case 14: 
            case 15:
                if((op1 == 'i' || op1 == 'I') || op2 == 'i' || op2 == 'I'){
                    printf("error:%d: invalid operation: (operator ",yylineno+1);
                    //binary_op_process(input);
                    printf(" not defined on int)\n");
                }
                else {
                        if(input == 14)
                            //binary_op_process(15);    

                        if(input == 15)
                            //binary_op_process(14);
		            printf("\n");
                }
        }
        
    }
}*/
