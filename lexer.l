%{
#include "shared.hpp"
#include "ast_fwd.hpp"
#include "parser.tab.h"
#include <string>
#include <cstring>
using namespace std;
%}

%option noyywrap

%%
"int"           { return TYPE_INT; }
"string"        { return TYPE_STRING; }
"bool"          { return TYPE_BOOL; }
"true"          { yylval.bval = true; return BOOL_LITERAL; }
"false"         { yylval.bval = false; return BOOL_LITERAL; }
"print"         { return PRINT; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }

"=="            { return EQ; }
"!="            { return NEQ; }
"<="            { return LE; }
">="            { return GE; }
"<"             { return LT; }
">"             { return GT; }

"&&"            { return AND; }
"||"            { return OR; }
"!"             { return NOT; }

"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MUL; }
"/"             { return DIV; }
"="             { return ASSIGN; }
";"             { return SEMICOLON; }
","             { return COMMA; }
"("             { return LP; }
")"             { return RP; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }

[0-9]+          { yylval.ival = atoi(yytext); return NUMBER; }

\"([^\\\"]|\\.)*\" {
    string s = yytext;
    s = s.substr(1, s.length() - 2);
    yylval.sval = strdup(s.c_str());
    return STR_LITERAL;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.id = strdup(yytext);
    return ID;
}

[ \t\r\n]+      { /* skip whitespace */ }
"//"[^\n]*      { /* skip single-line comments */ }
.               { /* ignore unknown */ }
%%
