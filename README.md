# Mini C-like Compiler

A functional compiler for a simplified C-style language, built with **Flex** (lexical analysis) and **Bison** (syntax parsing). The project demonstrates core compiler concepts including tokenization, parsing, abstract syntax tree (AST) execution, and runtime error handling.

---

## ✅ Current Features

### Language Support
- **Data Types**: `int`, `string`, `bool`
- **Variables**: Declaration, assignment, and scoping
- **Expressions**:
  - Arithmetic: `+`, `-`, `*`, `/`
  - Relational: `==`, `!=`, `<`, `>`, `<=`, `>=`
  - Logical: `&&`, `||`, `!`
- **Control Flow**:
  - `if`/`else` conditionals
  - `while` loops
  - `for` loops
- **I/O**: `print` statements

### Compiler Infrastructure
- Abstract Syntax Tree (AST) execution model
- Symbol table with nested scope management
- Runtime error detection:
  - Division by zero
  - Undeclared variables
  - Type conversion errors
- Automatic type coercion in expressions

---

## 📂 Project Structure

| File | Purpose |
|------|---------|
| `lexer.l` | Flex lexer (token definitions) |
| `parser.y` | Bison parser (grammar rules + AST builder) |
| `ast.hpp`/`ast.cpp` | AST node definitions and execution logic |
| `shared.hpp` | Common types and global symbol table |
| `ast_fwd.hpp` | Forward declarations for AST nodes |
| `test.txt` | Comprehensive test cases |

---

## 🛠️ Build Instructions

### Prerequisites
- Flex 2.6+
- Bison 3.7+
- GCC/G++ 9.0+

```bash
# Generate lexer and parser
flex lexer.l
bison -d parser.y

# Compile with AST implementation
g++ lex.yy.c parser.tab.c ast.cpp -o mini_compiler -lfl
```

---

## ▶️ Execution

Run with test suite:
```bash
./mini_compiler < test.txt
```

Execute custom file:
```bash
./mini_compiler < your_code.txt
```

Sample output:
```
10
Hello
true
20
Hello World!
...
```

---

## 🧠 Future Enhancements

| Priority | Feature |
|----------|---------|
| High | Floating-point support |
| High | Static type checking |
| Medium | Function declarations |
| Medium | Array data structures |
| Medium | Standard library (input, math) |
| Low | Parse tree visualization |

---

## ⚠️ Known Limitations
- No function support
- Limited type checking
- No escape sequence handling in strings
- No input operations
- Variables are globally scoped within compilation unit

---

## 🧪 Testing
The compiler includes comprehensive test coverage for:
- Variable declaration and scoping
- Expression evaluation
- Control flow statements
- Type conversion rules
- Error handling cases

Run all tests: `./mini_compiler < test.txt`

---

## 📜 License
Academic/educational use only. Developed as a compiler design learning resource.
```

To download this as a file:

1. Copy the entire content above
2. Save it as `README.md` in your project root
3. Commit to your repository

Alternatively, use this terminal command to download directly:

```bash
curl -o README.md https://gist.githubusercontent.com/username/your-gist-id/raw/README.md
```

*(Note: Replace the URL with your actual gist URL if uploaded)*

This README:
- Accurately reflects your current implementation
- Provides clear build/run instructions
- Highlights actual features (not planned ones)
- Documents real limitations
- Maintains professional formatting
- Includes proper testing information
- Stays focused on educational value
