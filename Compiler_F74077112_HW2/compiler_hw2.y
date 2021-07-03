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
    char op_type;
    char *printtype = "X";
    char *recenttype = "X";
    int redeclare = 0;
    int addr = 0;
    int recentScope = 0;

    /* Symbol table function - you can add new function if needed. */
    static void create_symbol();
    static void insert_symbol();
    static int lookup_symbol();
    static void dump_symbol();
    
    static char type_process(char);
    static void assign_op_process(char, int, char);
    static int unary_op_process(int, char);
    static int binary_op_process(int);
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
    :Type ID
     {
        insert_symbol();
    	if(redeclare == 0)
    		printf("> Insert {%s} into symbol table (scope level: %d)\n", $<s_val>2, recentScope);
     }
    | Type ID{insert_symbol(); } '=' Expression
     {
        if(redeclare == 0)
        	{printf("> Insert {%s} into symbol table (scope level: %d)\n", $<s_val>2, recentScope);}
     }
    | Type ID {insert_symbol();} ArrayType
      {
         if(redeclare ==0)
            printf("> Insert {%s} into symbol table (scope level: %d)\n", $<s_val>2, recentScope);
        symbolTable[yylineno].type = arr;
	    if(a[yylineno] == 'i')
            symbolTable[yylineno].element = "int";
        if(a[yylineno] == 'f')
            symbolTable[yylineno].element = "float";
        if(a[yylineno] == 's')
            symbolTable[yylineno].element = "string";
        if(a[yylineno] == 'b')
            symbolTable[yylineno].element = "bool";    
      }
;

AssignmentStmt
    :Expression assign_op Expression {assign_op_process($<c_val>1, $<i_val>2, $<c_val>3);} ';'
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

ArrayType : '[' Expression ']' {$<c_val>$ = 'a'; }
;

Expression
	: Expression OR{printtype= "bool";} entryA{
    	if(($<c_val>1=='i'||$<c_val>1=='I')||($<c_val>3=='i'||$<c_val>3 =='I'))
            printf("error:%d: invalid operation: (operator OR not defined on int)\n",yylineno+1);
	    else{$<c_val>$ = 'b';}        
            printf("OR\n");
    	} 
    | entryA
;
    	
entryA:
    | entryA AND{printtype = "bool";} entryB{
        if(($<c_val>1=='i'||$<c_val>1=='I')||($<c_val>3=='i'||$<c_val>3=='I'))
    	    printf("error:%d: invalid operation: (operator AND not defined on int)\n",yylineno+1);
        else{$<c_val>$ = 'b';}
            printf("AND\n");
    	}	 
    | entryB 
;
    
entryB 
    : entryB cmp_op entryC{
        $<c_val>$ = 'b';
        binary_op_process($<i_val>2);
    } 
    | entryC
;

entryC 
    : entryC add_op entryD{
        if((($<c_val>1=='f')||($<c_val>1=='F'))&&(($<c_val>3=='i')||($<c_val>3=='I'))){        
            if($<i_val>2 == 1)
                printf("error:%d: invalid operation: ADD (mismatched types float and int)\n",yylineno+1);
            if($<i_val>2 == 2)
                printf("error:%d: invalid operation: SUB (mismatched types float and int)\n",yylineno+1);
        }
        if((($<c_val>1 == 'i') || ($<c_val>1 == 'I')) && (($<c_val>3 == 'f')||($<c_val>3 == 'F'))){
            if($<i_val>2 == 1)
                printf("error:%d: invalid operation: ADD (mismatched types int and float)\n",yylineno+1);
            if($<i_val>2 == 2)
                printf("error:%d: invalid operation: SUB (mismatched types int and float)\n",yylineno+1);
        } 
       binary_op_process($<i_val>2);
    } 
    | entryD
;
    
entryD 
    : entryD mul_op UnaryExpr{
      if(binary_op_process($<i_val>2) == 5){
            if((($<c_val>1=='f')||($<c_val>1=='F'))&&(($<c_val>3=='i')||($<c_val>3=='I')))
                printf("error:%d: invalid operation: (operator REM not defined on float)\n",yylineno+1);
            if((($<c_val>1=='i')||($<c_val>1=='I'))&&(($<c_val>3=='f')||($<c_val>3=='F')))
                printf("error:%d: invalid operation: (operator REM not defined on float)\n",yylineno+1);
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
        else
            printf("error:%d: undefined: %s\n",yylineno+1,yylval.s_val);
        for(int i=0;i<100;i++){
            if(symbolTable[i].addr==lookup_symbol(yylval.s_val)){
        	    if(strcmp(symbolTable[i].element, &_[0]) != 0){
        	      if(strcmp(symbolTable[i].element, "int") == 0)
                        printtype = "int";
                     if(strcmp(symbolTable[i].element, "float") == 0)
                        printtype= "float";
                     if(strcmp(symbolTable[i].element, "bool") == 0)
                        printtype = "bool";
                     if(strcmp(symbolTable[i].element, "string") == 0)
                        printtype = "string";
                 }
            else{
	           if(printArray[symbolTable[i].addr] == "int"){
	                $<c_val>$ = 'i';
			        printtype = "int";
                }
                  if(printArray[symbolTable[i].addr] == "float"){
	                $<c_val>$ = 'f';
                    printtype = "float";
                }
                  if(printArray[symbolTable[i].addr]== "bool"){
	                $<c_val>$ = 'b';
	                printtype = "bool";
		        }  
                  if(printArray[symbolTable[i].addr]== "string"){
                        $<c_val>$ = 's';
                        printtype = "string";
		        }
                op_type = $<c_val>$;             
            }
            break;
        }
            else
                $<c_val>$ = 'u';
        }
        recenttype = "Val";
    }
    |'(' Expression ')'
;

Literal 
    : INT_LIT{
        $<c_val>$ = 'I';
        recenttype = "Int";
        printf("INT_LIT %d\n",yylval.i_val);
    }   
    | FLOAT_LIT{
        $<c_val>$ = 'F';
        recenttype = "Float";
        printtype = "float";
        printf("FLOAT_LIT %.6f\n",yylval.f_val);
    }   
    |'"' STRING_LIT '"'{
        $<c_val>$ = 'S';
        printtype = "string";
        printf("STRING_LIT %s\n",yylval.s_val);
    }
    | BOOL_LIT{
        $<c_val>$ = 'B';
        if(yylval.b_val)
            printf("TRUE\n");
        else
            printf("FALSE\n");
    } 
;  

IndexExpr
    : PrimaryExpr '[' Expression ']'
;

ConversionExpr
    : '(' Type ')' Expression{
        char sType = 'X', tType = 'X';         
        for(int i = 0; i < 100; i++){
            if(strcmp(recenttype, "Val") == 0){
                if(symbolTable[i].addr==lookup_symbol(yylval.s_val)){
                    if(a[yylineno] == 'i')
                         tType = 'I';
                    if(a[yylineno] == 'f')
                         tType = 'F';
                    if(a[yylineno] == 'b')
                         tType = 'B';
                    if(a[yylineno] == 's')
                         tType = 'S';
                    
                    if(strcmp(symbolTable[i].type, "int") == 0)
                        printf("I to %c\n",tType);
                    if(strcmp(symbolTable[i].type, "float") == 0)
                         printf("F to %c\n",tType);
                    if(strcmp(symbolTable[i].type, "bool") == 0)
                        printf("B to %c\n",tType);
                    if(strcmp(symbolTable[i].type, "string") == 0)
                        printf("S to %c\n",tType);
                    break;
                }              
            }
            else{
                    if(strcmp(recenttype, "Float") == 0)
                        sType = 'F';
                    if(strcmp(recenttype, "Int") == 0)
                        sType = 'I';
                    if(a[yylineno] == 'i')
                         printf("%c to I\n",sType);
                    if(a[yylineno] == 'f')
                         printf("%c to F\n",sType);
                    if(a[yylineno] == 'b')
                         printf("%c to B\n",sType);
                    if(a[yylineno] == 's')
                         printf("%c to S\n",sType);
		
                    break;
            }
       }
} 
;

IncDecStmt
	: ID inc_dec_op{
        if(lookup_symbol(yylval.s_val)>=0)
            printf("IDENT (name=%s, address=%d)\n",yylval.s_val,lookup_symbol(yylval.s_val));
        else
            printf("error:%d: undefined: %s\n",yylineno+1,yylval.s_val);
        binary_op_process($<i_val>2);
 }
;

inc_dec_op
	: INC {$<i_val>$ = 12;}
	| DEC {$<i_val>$ = 13;}
;

Block 
    : '{'{recentScope+=1;} NEWLINE StatementList '}'{dump_symbol();recentScope-=1;}
;


IfStmt
    :IF '(' Condition ')' Block IfExtend
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

Condition
    :Expression{
	if($<c_val>1 =='i'|| $<c_val>1 == 'I')
         printf("error:%d: non-bool (type int) used as for condition\n",yylineno+2);
    if($<c_val>1 =='f'|| $<c_val>1 == 'F')
         printf("error:%d: non-bool (type float) used as for condition\n",yylineno+2);
}
;

LoopStmt
    : FOR '(' ForClause ')' Block
	| WHILE '(' Condition ')' Block
	| WHILE '(' Condition ')' Block NEWLINE
	| WHILE '(' Condition ')' NEWLINE Block
;
	
ForClause
    :SimpleStmt Condition ';' SimpleStmt
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
        if(strcmp(printtype, "int") == 0)
            printf("PRINT %s\n", printtype);
        if(strcmp(printtype, "float") == 0)
            printf("PRINT %s\n", printtype);
        if(strcmp(printtype, "bool") == 0)
            printf("PRINT %s\n", printtype);
        if(strcmp(printtype, "string") == 0)
            printf("PRINT %s\n", printtype);
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
    create_symbol();
    yylineno = 0;
    yyparse();
    dump_symbol();
    printf("Total lines: %d\n", yylineno+1);
    fclose(yyin);
    return 0;
}

static void create_symbol() {
    int i = 0;
    while(i != 100){
        symbolTable[i].index = -1; symbolTable[i].name = NULL; symbolTable[i].type = NULL; symbolTable[i].addr = -1; symbolTable[i].lineno = -1; symbolTable[i].element = _; symbolTable[i].scope = -1; a[i] = 'X';
	i++;
    }
}

static void insert_symbol() {
    int i = 0, j = 0;
    while(i != 100){
        if(symbolTable[i].scope == recentScope){
            if(strcmp(symbolTable[i].name,yylval.s_val) == 0){
                printf("error:%d: %s redeclared in this block. previous declaration at line %d\n",yylineno+1,yylval.s_val,symbolTable[i].lineno+1);
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
			    return 'i';
			
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
   if(input1 =='I')printf("error:%d: cannot assign to int\n",yylineno+1);
    if((input1 =='i')&&((input2 =='f')||(input2 =='F'))){
            if(op == 1)
                printf("error:%d: invalid operation: ASSIGN (mismatched types int and float)\n",yylineno+1);
    }
    switch(op){
        case 1:
            printf("ASSIGN\n");
            break;
        case 2:
            printf("ADD_ASSIGN\n");
  	        break;
        case 3:
            printf("SUB_ASSIGN\n");
            break;
        case 4:
            printf("MUL_ASSIGN\n");
            break;
        case 5:
            printf("QUO_ASSIGN\n");
            break;
        case 6:
            printf("REM_ASSIGN\n");
            break;
        default:
            printf("Error printing assign op%d\n", op);
            break;
        }
}

static int unary_op_process(int op, char input){
	switch(op){
		case 1:
			printf("POS\n");
			return input;
		case 2:
			printf("NEG\n");
			return input;
		case 3:
			printf("NOT\n");
			return input;
	}
}

static int binary_op_process(int op){
	switch(op){
		case 1:
			printf("ADD\n");
			return 0;
		case 2:
			printf("SUB\n");
			return 0;
		case 3:
			printf("MUL\n");
			return 0;
		case 4:
			printf("QUO\n");
			return 0;
		case 5:
			return op;
		case 6:
			printf("EQL\n");
			return 0;
		case 7:
			printf("NEQ\n");
			return 0;
		case 8:
			printf("LSS\n");
			return 0;
		case 9:
			printf("LEQ\n");
			return 0;
		case 10:
			printf("GTR\n");
			return 0;
		case 11:
			printf("GEQ\n");
			return 0;
		case 12:
			printf("INC\n");
			return 0;
		case 13:
			printf("DEC\n");
			return 0;
	}
}
