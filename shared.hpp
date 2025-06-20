#ifndef SHARED_HPP
#define SHARED_HPP

#include <string>
#include <map>

enum ValueType { VT_INT, VT_STRING, VT_BOOL };

struct Value {
    ValueType type;
    int ival = 0;
    bool bval = false;
    std::string sval;

    Value() : type(VT_INT), ival(0), bval(false), sval("") {}
    Value(int v) : type(VT_INT), ival(v), bval(false), sval("") {}
    Value(bool b) : type(VT_BOOL), ival(0), bval(b), sval("") {}
    Value(const std::string &s) : type(VT_STRING), ival(0), bval(false), sval(s) {}
};

enum TokenType {
    TOKEN_EOF,
    // Keywords
    TOKEN_INT, TOKEN_STRING, TOKEN_BOOL,
    TOKEN_PRINT, TOKEN_IF, TOKEN_ELSE, TOKEN_WHILE, TOKEN_FOR,
    TOKEN_TRUE, TOKEN_FALSE,
    // Operators
    TOKEN_PLUS, TOKEN_MINUS, TOKEN_MUL, TOKEN_DIV,
    TOKEN_EQ, TOKEN_NEQ, TOKEN_LT, TOKEN_GT, TOKEN_LE, TOKEN_GE,
    TOKEN_AND, TOKEN_OR, TOKEN_NOT,
    // Punctuation
    TOKEN_ASSIGN, TOKEN_SEMICOLON, TOKEN_COMMA,
    TOKEN_LPAREN, TOKEN_RPAREN, TOKEN_LBRACE, TOKEN_RBRACE,
    // Literals
    TOKEN_ID, TOKEN_NUMBER, TOKEN_STRING_LITERAL
};

// Declare global symbol table
extern std::map<std::string, Value> variables;

#endif
