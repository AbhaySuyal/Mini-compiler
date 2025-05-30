%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>

extern int yylex(void);
%}

digit       [0-9]
letter      [a-zA-Z_]
identifier  {letter}({letter}|{digit})*
number      {digit}+

%%

\"([^\\\"]|\\.)*\" {
    // Copy string without quotes (if you want to handle string literals)
    int len = yyleng - 2; // exclude quotes
    char *str = (char *)malloc(len + 1);
    strncpy(str, yytext + 1, len);
    str[len] = '\0';
    yylval.sval = str;
    return STRING_LITERAL;
}

"int"           { return INT; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }
"print"         { return PRINT; }

"=="            { return EQ; }
"!="            { return NEQ; }
">="            { return GE; }
"<="            { return LE; }
">"             { return GT; }
"<"             { return LT; }

"&&"            { return AND; }
"||"            { return OR; }

"&"             { return BITWISE_AND; }
"|"             { return BITWISE_OR; }
"^"             { return BITWISE_XOR; }
"<<"            { return BITWISE_SHIFT_LEFT; }
">>"            { return BITWISE_SHIFT_RIGHT; }

"="             { return ASSIGN; }
";"             { return SEMICOLON; }
","             { return COMMA; }

"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }

"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MUL; }
"/"             { return DIV; }

{number}        { yylval.ival = atoi(yytext); return NUMBER; }
{identifier}    { yylval.sval = strdup(yytext); return IDENTIFIER; }

[ \t\r\n]+      { /* ignore whitespace */ }

.               { printf("Unknown character: %s\n", yytext); }

%%

int yywrap(void) {
    return 1;
}
