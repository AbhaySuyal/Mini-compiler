%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <map>
#include <string>
#include <stack>

using namespace std;

extern int yylex(void);
void yyerror(const char *s);

struct SymbolTable {
    map<string, int> variables;
    map<string, bool> declared;
};

stack<SymbolTable> scopeStack;

void enterScope() {
    scopeStack.push(SymbolTable());
}

void exitScope() {
    scopeStack.pop();
}

bool isDeclared(const string& name) {
    stack<SymbolTable> temp = scopeStack;
    while (!temp.empty()) {
        if (temp.top().declared.count(name)) return true;
        temp.pop();
    }
    return false;
}

int getValue(const string& name) {
    stack<SymbolTable> temp = scopeStack;
    while (!temp.empty()) {
        if (temp.top().declared.count(name)) return temp.top().variables[name];
        temp.pop();
    }
    return 0;
}

void setValue(const string& name, int val) {
    stack<SymbolTable> temp;
    bool updated = false;
    while (!scopeStack.empty()) {
        SymbolTable top = scopeStack.top();
        scopeStack.pop();
        if (!updated && top.declared.count(name)) {
            top.variables[name] = val;
            updated = true;
        }
        temp.push(top);
    }
    while (!temp.empty()) {
        scopeStack.push(temp.top());
        temp.pop();
    }
}

%}

%union {
    int ival;
    char *sval;
}

%token <ival> NUMBER
%token <sval> IDENTIFIER
%token IF ELSE WHILE FOR INT PRINT
%token ASSIGN SEMICOLON
%token LPAREN RPAREN LBRACE RBRACE
%token PLUS MINUS MUL DIV
%token GT LT EQ NEQ GE LE
%token AND OR BITWISE_AND BITWISE_OR BITWISE_XOR BITWISE_SHIFT_LEFT BITWISE_SHIFT_RIGHT
%token COMMA
%token STRING_LITERAL

/* Declare precedence to fix dangling else */
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%left OR
%left AND
%left BITWISE_OR
%left BITWISE_XOR
%left BITWISE_AND
%nonassoc EQ NEQ
%nonassoc GT LT GE LE
%left BITWISE_SHIFT_LEFT BITWISE_SHIFT_RIGHT
%left PLUS MINUS
%left MUL DIV
%right UMINUS

%type <ival> expression
%type <ival> argument_list

%%

program:
    { enterScope(); }
    statement_list
    { exitScope(); }
    ;

statement_list:
      /* allow zero or more statements */
    | statement_list statement
    ;

statement:
      INT IDENTIFIER ASSIGN expression SEMICOLON {
        if (isDeclared(string($2))) {
            yyerror(("Variable already declared: " + string($2)).c_str());
            YYABORT;
        }
        scopeStack.top().declared[string($2)] = true;
        scopeStack.top().variables[string($2)] = $4;
        printf("Declare and assign %s = %d\n", $2, $4);
        free($2);
    }
    | IDENTIFIER ASSIGN expression SEMICOLON {
        if (!isDeclared(string($1))) {
            yyerror(("Undeclared variable: " + string($1)).c_str());
            YYABORT;
        }
        setValue(string($1), $3);
        printf("Assign %s = %d\n", $1, $3);
        free($1);
    }
    | PRINT LPAREN expression RPAREN SEMICOLON {
        printf("Output: %d\n", $3);
    }
    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
        printf("If statement (condition: %d)\n", $3);
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        printf("If-Else statement (condition: %d)\n", $3);
    }
    | WHILE LPAREN expression RPAREN statement {
        printf("While loop (condition: %d)\n", $3);
    }
    | FOR LPAREN simple_statement SEMICOLON expression SEMICOLON simple_statement RPAREN statement {
        printf("For loop (init; condition: %d; increment)\n", $5);
    }
    | LBRACE { enterScope(); } statement_list RBRACE {
        exitScope();
        printf("Block statement\n");
    }
    | IDENTIFIER LPAREN argument_list RPAREN SEMICOLON {
        if (!isDeclared(string($1))) {
            yyerror(("Undeclared function: " + string($1)).c_str());
            YYABORT;
        }
        printf("Calling function %s\n", $1);
        free($1);
    }
    | INT IDENTIFIER LPAREN RPAREN LBRACE { enterScope(); } statement_list RBRACE {
        scopeStack.top().declared[string($2)] = true;
        printf("Function %s defined\n", $2);
        exitScope();
        free($2);
    }
    ;

simple_statement:
      IDENTIFIER ASSIGN expression {
        if (!isDeclared(string($1))) {
            yyerror(("Undeclared variable: " + string($1)).c_str());
            YYABORT;
        }
        setValue(string($1), $3);
        printf("Assign %s = %d\n", $1, $3);
        free($1);
    }
    | INT IDENTIFIER ASSIGN expression {
        if (isDeclared(string($2))) {
            yyerror(("Variable already declared: " + string($2)).c_str());
            YYABORT;
        }
        scopeStack.top().declared[string($2)] = true;
        scopeStack.top().variables[string($2)] = $4;
        printf("Declare and assign %s = %d\n", $2, $4);
        free($2);
    }
    ;

argument_list:
      expression {
        $$ = $1;
    }
    | argument_list COMMA expression {
        $$ = $1;
    }
    | /* empty */ {
        $$ = 0;
    }
    ;

expression:
      NUMBER {
        $$ = $1;
    }
    | IDENTIFIER {
        if (!isDeclared(string($1))) {
            yyerror(("Undeclared variable: " + string($1)).c_str());
            YYABORT;
        }
        $$ = getValue(string($1));
        printf("Use variable %s = %d\n", $1, $$);
        free($1);
    }
    | expression PLUS expression { $$ = $1 + $3; }
    | expression MINUS expression { $$ = $1 - $3; }
    | expression MUL expression { $$ = $1 * $3; }
    | expression DIV expression {
        if ($3 == 0) {
            yyerror("Division by zero");
            YYABORT;
        }
        $$ = $1 / $3;
    }
    | expression GT expression { $$ = $1 > $3; }
    | expression LT expression { $$ = $1 < $3; }
    | expression EQ expression { $$ = $1 == $3; }
    | expression NEQ expression { $$ = $1 != $3; }
    | expression GE expression { $$ = $1 >= $3; }
    | expression LE expression { $$ = $1 <= $3; }
    | expression AND expression { $$ = $1 && $3; }
    | expression OR expression { $$ = $1 || $3; }
    | expression BITWISE_AND expression { $$ = $1 & $3; }
    | expression BITWISE_OR expression { $$ = $1 | $3; }
    | expression BITWISE_XOR expression { $$ = $1 ^ $3; }
    | expression BITWISE_SHIFT_LEFT expression { $$ = $1 << $3; }
    | expression BITWISE_SHIFT_RIGHT expression { $$ = $1 >> $3; }
    | MINUS expression %prec UMINUS { $$ = -$2; }
    | LPAREN expression RPAREN { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    enterScope();
    yyparse();
    return 0;
}
