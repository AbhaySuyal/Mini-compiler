%{
#include "ast.hpp"
#include <vector>
#include <iostream>
#include <cstdlib>
#include <cstring>
#include <map>
#include <string>

using namespace std;

// Define global symbol table
std::map<std::string, Value> variables;

// AST root
ProgramNode* programRoot = nullptr;

// Helper functions
TokenType getTokenType(int token);
ExpressionNode* createLiteralNode(Value value);
ExpressionNode* createIdentifierNode(const char* name);

void yyerror(const char *s) { cerr << "Error: " << s << endl; }
int yylex();
%}

%code requires {
    #include "ast_fwd.hpp"
}

%union {
    int ival;
    bool bval;
    char* sval;
    char* id;
    ExpressionNode* expr;
    StatementNode* stmt;
    ProgramNode* program;
    BlockNode* block;
    DeclarationNode* decl;
    AssignmentNode* assign;
}

%token <id> ID
%token <ival> NUMBER
%token <sval> STR_LITERAL
%token <bval> BOOL_LITERAL
%token PRINT IF ELSE WHILE FOR
%token TYPE_INT TYPE_STRING TYPE_BOOL
%token ASSIGN SEMICOLON COMMA LP RP LBRACE RBRACE
%token PLUS MINUS MUL DIV
%token EQ NEQ LT GT LE GE
%token AND OR NOT

%type <program> program
%type <block> block
%type <stmt> statement
%type <stmt> if_stmt
%type <decl> declaration
%type <assign> assignment
%type <expr> expr
%type <stmt> for_loop

%left OR
%left AND
%left EQ NEQ
%left LT LE GT GE
%left PLUS MINUS
%left MUL DIV
%right NOT UMINUS

%start program

%%

program:
    /* empty */ { 
        $$ = new ProgramNode();
        programRoot = $$;  // Set program root
    }
    | program statement { 
        $1->statements.push_back($2); 
        $$ = $1; 
        programRoot = $1;  // Update program root
    }
    ;

block:
    LBRACE program RBRACE { 
        auto blockNode = new BlockNode();
        blockNode->block = $2;
        $$ = blockNode;
    }
    ;

statement:
    declaration SEMICOLON { $$ = static_cast<StatementNode*>($1); }
    | assignment SEMICOLON { $$ = static_cast<StatementNode*>($1); }
    | PRINT expr SEMICOLON {
        auto printNode = new PrintNode();
        printNode->expression = $2;
        $$ = static_cast<StatementNode*>(printNode);
    }
    | if_stmt
    | WHILE LP expr RP statement {
        auto whileNode = new WhileNode();
        whileNode->condition = $3;
        whileNode->body = $5;
        $$ = static_cast<StatementNode*>(whileNode);
    }
    | for_loop
    | block { $$ = static_cast<StatementNode*>($1); }
    ;

declaration:
    TYPE_INT ID ASSIGN expr {
        auto declNode = new DeclarationNode();
        declNode->type = VT_INT;
        declNode->name = $2;
        declNode->expression = $4;
        free($2);
        $$ = declNode;
    }
    | TYPE_STRING ID ASSIGN expr {
        auto declNode = new DeclarationNode();
        declNode->type = VT_STRING;
        declNode->name = $2;
        declNode->expression = $4;
        free($2);
        $$ = declNode;
    }
    | TYPE_BOOL ID ASSIGN expr {
        auto declNode = new DeclarationNode();
        declNode->type = VT_BOOL;
        declNode->name = $2;
        declNode->expression = $4;
        free($2);
        $$ = declNode;
    }
    ;

assignment:
    ID ASSIGN expr {
        auto assignNode = new AssignmentNode();
        assignNode->name = $1;
        assignNode->expression = $3;
        free($1);
        $$ = assignNode;
    }
    ;

if_stmt:
    IF LP expr RP statement {
        auto ifNode = new IfNode();
        ifNode->condition = $3;
        ifNode->thenBranch = $5;
        $$ = static_cast<StatementNode*>(ifNode);
    }
    | IF LP expr RP statement ELSE statement {
        auto ifNode = new IfNode();
        ifNode->condition = $3;
        ifNode->thenBranch = $5;
        ifNode->elseBranch = $7;
        $$ = static_cast<StatementNode*>(ifNode);
    }
    ;

for_loop:
    FOR LP declaration SEMICOLON expr SEMICOLON assignment RP statement {
        auto forNode = new ForNode();
        forNode->initialization = $3;
        forNode->condition = $5;
        forNode->increment = $7;
        forNode->body = $9;
        $$ = static_cast<StatementNode*>(forNode);
    }
    ;

expr:
    NUMBER { 
        Value val; 
        val.type = VT_INT; 
        val.ival = $1; 
        $$ = createLiteralNode(val); 
    }
    | STR_LITERAL { 
        Value val; 
        val.type = VT_STRING; 
        val.sval = $1; 
        $$ = createLiteralNode(val); 
        free($1);
    }
    | BOOL_LITERAL { 
        Value val; 
        val.type = VT_BOOL; 
        val.bval = $1; 
        $$ = createLiteralNode(val); 
    }
    | ID { $$ = createIdentifierNode($1); free($1); }
    | expr PLUS expr { 
        auto binOp = new BinaryOpNode();
        binOp->op = getTokenType(PLUS);
        binOp->left = $1;
        binOp->right = $3;
        $$ = binOp;
    }
    | expr MINUS expr { 
        auto binOp = new BinaryOpNode();
        binOp->op = getTokenType(MINUS);
        binOp->left = $1;
        binOp->right = $3;
        $$ = binOp;
    }
    | expr MUL expr { 
        auto binOp = new BinaryOpNode();
        binOp->op = getTokenType(MUL);
        binOp->left = $1;
        binOp->right = $3;
        $$ = binOp;
    }
    | expr DIV expr { 
        auto binOp = new BinaryOpNode();
        binOp->op = getTokenType(DIV);
        binOp->left = $1;
        binOp->right = $3;
        $$ = binOp;
    }
    | expr EQ expr { 
        auto binOp = new BinaryOpNode();
        binOp->op = getTokenType(EQ);
        binOp->left = $1;
        binOp->right = $3;
        $$ = binOp;
    }
    | expr NEQ expr { 
        auto binOp = new BinaryOpNode();
        binOp->op = getTokenType(NEQ);
        binOp->left = $1;
        binOp->right = $3;
        $$ = binOp;
    }
    | expr LT expr { 
        auto binOp = new BinaryOpNode();
        binOp->op = getTokenType(LT);
        binOp->left = $1;
        binOp->right = $3;
        $$ = binOp;
    }
    | expr GT expr { 
        auto binOp = new BinaryOpNode();
        binOp->op = getTokenType(GT);
        binOp->left = $1;
        binOp->right = $3;
        $$ = binOp;
    }
    | expr LE expr { 
        auto binOp = new BinaryOpNode();
        binOp->op = getTokenType(LE);
        binOp->left = $1;
        binOp->right = $3;
        $$ = binOp;
    }
    | expr GE expr { 
        auto binOp = new BinaryOpNode();
        binOp->op = getTokenType(GE);
        binOp->left = $1;
        binOp->right = $3;
        $$ = binOp;
    }
    | expr AND expr { 
        auto binOp = new BinaryOpNode();
        binOp->op = getTokenType(AND);
        binOp->left = $1;
        binOp->right = $3;
        $$ = binOp;
    }
    | expr OR expr { 
        auto binOp = new BinaryOpNode();
        binOp->op = getTokenType(OR);
        binOp->left = $1;
        binOp->right = $3;
        $$ = binOp;
    }
    | NOT expr { 
        auto unOp = new UnaryOpNode();
        unOp->op = getTokenType(NOT);
        unOp->operand = $2;
        $$ = unOp;
    }
    | MINUS expr %prec UMINUS { 
        auto unOp = new UnaryOpNode();
        unOp->op = getTokenType(MINUS);
        unOp->operand = $2;
        $$ = unOp;
    }
    | LP expr RP { $$ = $2; }
    ;

%%

TokenType getTokenType(int token) {
    switch (token) {
        case PLUS: return TOKEN_PLUS;
        case MINUS: return TOKEN_MINUS;
        case MUL: return TOKEN_MUL;
        case DIV: return TOKEN_DIV;
        case EQ: return TOKEN_EQ;
        case NEQ: return TOKEN_NEQ;
        case LT: return TOKEN_LT;
        case GT: return TOKEN_GT;
        case LE: return TOKEN_LE;
        case GE: return TOKEN_GE;
        case AND: return TOKEN_AND;
        case OR: return TOKEN_OR;
        case NOT: return TOKEN_NOT;
        default: return TOKEN_EOF;
    }
}

ExpressionNode* createLiteralNode(Value value) {
    auto literal = new LiteralNode();
    literal->value = value;
    return literal;
}

ExpressionNode* createIdentifierNode(const char* name) {
    auto idNode = new IdentifierNode();
    idNode->name = name;
    return idNode;
}

int main() {
    cout << "Mini C-like Compiler Ready" << endl;
    if (yyparse() == 0 && programRoot) {
        try {
            programRoot->execute();
        } catch (const exception& e) {
            cerr << "Runtime error: " << e.what() << endl;
            delete programRoot;
            return 1;
        }
        delete programRoot;
    }
    return 0;
}
