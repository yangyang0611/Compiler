/* Definition section */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define YY_NO_UNPUT
    #define YY_NO_INPUT

    int line_num = 0;
    int comment_num = 0;
	int mul_command_flag=0;
    int i=0;
    int count = 0;
%}

/* Define regular expression label */
letter [a-zA-Z_]
digit [0-9]
id {letter}+({letter}|{digit})*
inumber {digit}+
fnumber ({digit}*\.{digit}+)
str \"(\$\{.*\}|\\.|[^\"\\])*\"
blank (" "|\t)
/* Rules section */
%%

{blank}+	{if(mul_command_flag>0){
				printf("%-8s",yytext);}
			}
"var"       { printf("%-8s \t %s\n", yytext, "VAR"); }
"string"    { printf("%-8s \t %s\n", yytext, "STRING");}
"bool"      { printf("%-8s \t %s\n", yytext, "BOOL");}
"false"     { printf("%-8s \t %s\n", yytext, "FALSE");}
"true"      { printf("%-8s \t %s\n", yytext, "TRUE");}
{inumber}	{ printf("%-8s \t %s\n", yytext, "INT_LIT");}
{fnumber}	{ printf("%-8s \t %s\n", yytext, "FLOAT_LIT");}
{str}		{
                printf("%-8s \t %s\n","\"", "QUOTA");
                
                char sub[yyleng-1];
                memcpy(sub, &yytext[1], yyleng-2);
                sub[yyleng-2] = '\0';
                printf("%-8s \t %s\n",sub, "STRING_LIT");

                printf("%-8s \t %s\n","\"", "QUOTA");
            }
            
"if"	    { printf("%-8s \t %s\n", yytext, "IF");}
"else"	    { printf("%-8s \t %s\n", yytext, "ELSE");}
"for"	    { printf("%-8s \t %s\n", yytext, "FOR");}
"print"	    { printf("%-8s \t %s\n", yytext, "PRINT");}
"println"	{ printf("%-8s \t %s\n", yytext, "PRINTLN");}
"break"     { printf("%-8s \t %s\n", yytext, "BREAK");}
"while"     { printf("%-8s \t %s\n", yytext, "WHILE");}
"return"    { printf("%-8s \t %s\n", yytext, "RETURN");}
"void"      { printf("%-8s \t %s\n", yytext, "VOID");}
"continue"  { printf("%-8s \t %s\n", yytext, "CONTINUE");}

"int"		{ printf("%-8s \t %s\n", yytext, "INT");}
"float"	    { printf("%-8s \t %s\n", yytext, "FLOAT");}

"="         { printf("%-8s \t %s\n", yytext, "ASSIGN"); }
"+"         { printf("%-8s \t %s\n", yytext, "ADD"); }
"-"         { printf("%-8s \t %s\n", yytext, "SUB"); }
"*"			{if(mul_command_flag!=0){
				/*In a comment*/
				yymore();}
			 else {printf("%-8s \t %s\n", yytext, "MUL");}}
"%"			{ printf("%-8s \t %s\n", yytext, "REM");}
"/"			{ printf("%-8s \t %s\n", yytext, "QUO");}
"++"		{ printf("%-8s \t %s\n", yytext, "INC");}
"--"		{ printf("%-8s \t %s\n", yytext, "DEC");}
"("			{ printf("%-8s \t %s\n", yytext, "LPAREN");}
")"			{ printf("%-8s \t %s\n", yytext, "RPAREN");}
"+="		{ printf("%-8s \t %s\n", yytext, "ADD_ASSIGN");}
"-="		{ printf("%-8s \t %s\n", yytext, "SUB_ASSIGN");}
"*="		{ printf("%-8s \t %s\n", yytext, "MUL_ASSIGN");}
"/="		{ printf("%-8s \t %s\n", yytext, "QUO_ASSIGN");}
"%="		{ printf("%-8s \t %s\n", yytext, "REM_ASSIGN");}
"{"			{ printf("%-8s \t %s\n", yytext, "LBRACE");}
"}"			{ printf("%-8s \t %s\n", yytext, "RBRACE");}
";"			{ printf("%-8s \t %s\n", yytext, "SEMICOLON");}

">"			{ printf("%-8s \t %s\n", yytext, "GTR");}
","			{ printf("%-8s \t %s\n", yytext, "COMMA");}
"!"			{ printf("%-8s \t %s\n", yytext, "NOT");}
"<"			{ printf("%-8s \t %s\n", yytext, "LSS");}
">="		{ printf("%-8s \t %s\n", yytext, "GEQ");}
"<="		{ printf("%-8s \t %s\n", yytext, "LEQ");}
"=="		{ printf("%-8s \t %s\n", yytext, "EQL");}
"!="		{ printf("%-8s \t %s\n", yytext, "NEQ");}
"&&"		{ printf("%-8s \t %s\n", yytext, "AND");}
"||"		{ printf("%-8s \t %s\n", yytext, "OR");}
 
{id}        {	printf("%-8s \t %s\n", yytext, "IDENT"); }
			
           
("//")[^\n\r]* {
                    comment_num++;
                    printf("%s \t %s\n", yytext, "C++ Comment");
}

"/*"([^*]|\*+[^*/])*\*+"/" { 
                int i=0;
                while(i <= yyleng - 1){
                    if(yytext[i]!='\n')
                        printf("%c", yytext[i]);
                    if(yytext[i] == '\n'){
                        comment_num++;
                        printf(" \t %s\n", "C Comment");
                        count++;
                    }
                    i++;
                }
                printf(" \t %s\n", "C Comment");
                comment_num++;
                line_num++;
                if(count > 2)
                    line_num--;
}

"\n"        {line_num++;}

<<EOF>>     {line_num++; yyterminate(); }
.           {;}

%%

/*  C Code section */
int yywrap(void)
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    yylex();
    printf("\nFinish scanning,\n");
    printf("total line: %d\n", line_num);
    printf("comment line: %d\n", comment_num);
    fclose(yyin);
    return 0;
}
