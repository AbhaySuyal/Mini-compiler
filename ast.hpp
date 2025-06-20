#ifndef AST_HPP
#define AST_HPP

#include "shared.hpp"
#include <vector>
#include <string>
#include <stdexcept>

// Forward declarations
class ASTNode;
class ProgramNode;
class StatementNode;
class ExpressionNode;
class BlockNode;
class DeclarationNode;
class AssignmentNode;
class PrintNode;
class IfNode;
class WhileNode;
class ForNode;
class BinaryOpNode;
class UnaryOpNode;
class IdentifierNode;
class LiteralNode;

// Base AST Node
class ASTNode {
public:
    virtual ~ASTNode() = default;
    virtual Value execute() = 0;
};

// Program Node
class ProgramNode : public ASTNode {
public:
    std::vector<StatementNode*> statements;
    ~ProgramNode();
    Value execute() override;
};

// Base Statement Node
class StatementNode : public ASTNode {};

// Block Node
class BlockNode : public StatementNode {
public:
    ProgramNode* block;
    ~BlockNode();
    Value execute() override;
};

// Declaration Node
class DeclarationNode : public StatementNode {
public:
    ValueType type;
    std::string name;
    ExpressionNode* expression;
    ~DeclarationNode();
    Value execute() override;
};

// Assignment Node
class AssignmentNode : public StatementNode {
public:
    std::string name;
    ExpressionNode* expression;
    ~AssignmentNode();
    Value execute() override;
};

// Print Node
class PrintNode : public StatementNode {
public:
    ExpressionNode* expression;
    ~PrintNode();
    Value execute() override;
};

// If Node
class IfNode : public StatementNode {
public:
    ExpressionNode* condition;
    StatementNode* thenBranch;
    StatementNode* elseBranch;
    ~IfNode();
    Value execute() override;
};

// While Node
class WhileNode : public StatementNode {
public:
    ExpressionNode* condition;
    StatementNode* body;
    ~WhileNode();
    Value execute() override;
};

// For Node
class ForNode : public StatementNode {
public:
    DeclarationNode* initialization;
    ExpressionNode* condition;
    AssignmentNode* increment;
    StatementNode* body;
    ~ForNode();
    Value execute() override;
};

// Base Expression Node
class ExpressionNode : public ASTNode {};

// Binary Operation Node
class BinaryOpNode : public ExpressionNode {
public:
    TokenType op;
    ExpressionNode* left;
    ExpressionNode* right;
    ~BinaryOpNode();
    Value execute() override;
};

// Unary Operation Node
class UnaryOpNode : public ExpressionNode {
public:
    TokenType op;
    ExpressionNode* operand;
    ~UnaryOpNode();
    Value execute() override;
};

// Identifier Node
class IdentifierNode : public ExpressionNode {
public:
    std::string name;
    Value execute() override;
};

// Literal Node
class LiteralNode : public ExpressionNode {
public:
    Value value;
    Value execute() override;
};

#endif
