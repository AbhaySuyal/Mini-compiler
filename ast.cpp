#include "ast.hpp"
#include <iostream>
#include <stdexcept>
#include <cmath>
#include <cstdlib>
#include <cstring>

// Use the global symbol table declared in shared.hpp
extern std::map<std::string, Value> variables;

// Helper functions
int toInt(const Value& v) {
    if (v.type == VT_INT) return v.ival;
    if (v.type == VT_BOOL) return v.bval ? 1 : 0;
    if (v.type == VT_STRING) {
        try { return std::stoi(v.sval); }
        catch (...) { return 0; }
    }
    return 0;
}

bool toBool(const Value& v) {
    if (v.type == VT_BOOL) return v.bval;
    if (v.type == VT_INT) return v.ival != 0;
    if (v.type == VT_STRING) return !v.sval.empty();
    return false;
}

std::string toString(const Value& v) {
    if (v.type == VT_STRING) return v.sval;
    if (v.type == VT_INT) return std::to_string(v.ival);
    if (v.type == VT_BOOL) return v.bval ? "true" : "false";
    return "";
}

// Destructors
ProgramNode::~ProgramNode() {
    for (auto stmt : statements) {
        if (stmt) delete stmt;
    }
}

BlockNode::~BlockNode() {
    if (block) delete block;
}

DeclarationNode::~DeclarationNode() {
    if (expression) delete expression;
}

AssignmentNode::~AssignmentNode() {
    if (expression) delete expression;
}

PrintNode::~PrintNode() {
    if (expression) delete expression;
}

IfNode::~IfNode() {
    if (condition) delete condition;
    if (thenBranch) delete thenBranch;
    if (elseBranch) delete elseBranch;
}

WhileNode::~WhileNode() {
    if (condition) delete condition;
    if (body) delete body;
}

ForNode::~ForNode() {
    if (initialization) delete initialization;
    if (condition) delete condition;
    if (increment) delete increment;
    if (body) delete body;
}

BinaryOpNode::~BinaryOpNode() {
    if (left) delete left;
    if (right) delete right;
}

UnaryOpNode::~UnaryOpNode() {
    if (operand) delete operand;
}

// Execute methods
Value ProgramNode::execute() {
    for (auto stmt : statements) {
        stmt->execute();
    }
    return Value();
}

Value BlockNode::execute() {
    return block->execute();
}

Value DeclarationNode::execute() {
    Value value = expression->execute();
    variables[name] = value;
    return value;
}

Value AssignmentNode::execute() {
    if (variables.find(name) == variables.end()) {
        throw std::runtime_error("Undeclared variable: " + name);
    }
    Value value = expression->execute();
    variables[name] = value;
    return value;
}

Value PrintNode::execute() {
    Value value = expression->execute();
    if (value.type == VT_INT) std::cout << value.ival;
    else if (value.type == VT_STRING) std::cout << value.sval;
    else std::cout << (value.bval ? "true" : "false");
    std::cout << std::endl;
    return Value();
}

Value IfNode::execute() {
    if (toBool(condition->execute())) {
        return thenBranch->execute();
    } else if (elseBranch) {
        return elseBranch->execute();
    }
    return Value();
}

Value WhileNode::execute() {
    while (toBool(condition->execute())) {
        body->execute();
    }
    return Value();
}

Value ForNode::execute() {
    initialization->execute();
    while (toBool(condition->execute())) {
        body->execute();
        increment->execute();
    }
    return Value();
}

Value BinaryOpNode::execute() {
    Value leftVal = left->execute();
    Value rightVal = right->execute();
    
    switch (op) {
        case TOKEN_PLUS:
            if (leftVal.type == VT_STRING || rightVal.type == VT_STRING) {
                return Value(toString(leftVal) + toString(rightVal));
            }
            return Value(toInt(leftVal) + toInt(rightVal));
            
        case TOKEN_MINUS:
            return Value(toInt(leftVal) - toInt(rightVal));
            
        case TOKEN_MUL:
            return Value(toInt(leftVal) * toInt(rightVal));
            
        case TOKEN_DIV:
            if (toInt(rightVal) == 0) throw std::runtime_error("Division by zero");
            return Value(toInt(leftVal) / toInt(rightVal));
            
        case TOKEN_EQ:
            return Value(toString(leftVal) == toString(rightVal));
            
        case TOKEN_NEQ:
            return Value(toString(leftVal) != toString(rightVal));
            
        case TOKEN_LT:
            return Value(toInt(leftVal) < toInt(rightVal));
            
        case TOKEN_GT:
            return Value(toInt(leftVal) > toInt(rightVal));
            
        case TOKEN_LE:
            return Value(toInt(leftVal) <= toInt(rightVal));
            
        case TOKEN_GE:
            return Value(toInt(leftVal) >= toInt(rightVal));
            
        case TOKEN_AND:
            return Value(toBool(leftVal) && toBool(rightVal));
            
        case TOKEN_OR:
            return Value(toBool(leftVal) || toBool(rightVal));
            
        default:
            throw std::runtime_error("Unknown binary operator");
    }
}

Value UnaryOpNode::execute() {
    Value val = operand->execute();
    
    switch (op) {
        case TOKEN_MINUS:
            return Value(-toInt(val));
            
        case TOKEN_NOT:
            return Value(!toBool(val));
            
        default:
            throw std::runtime_error("Unknown unary operator");
    }
}

Value IdentifierNode::execute() {
    if (variables.find(name) == variables.end()) {
        throw std::runtime_error("Undeclared variable: " + name);
    }
    return variables[name];
}

Value LiteralNode::execute() {
    return value;
}
