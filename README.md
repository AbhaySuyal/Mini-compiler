# Mini-Compiler

A simplified C-like mini compiler built using **Flex** and **Bison**. This project implements a functional subset of a compiler supporting lexical analysis, parsing, expression evaluation, variable declarations, conditional statements, block scoping, and parse tree generation.

---

## 🔧 Current Features

✅ Implemented using Flex (for lexical analysis) and Bison (for syntax parsing)  
✅ Supports:
- Integer and string variable declarations
- Assignment and arithmetic expressions
- `if` and `if-else` conditional statements
- Print statements
- Block scoping using `{}` for variables
- Symbol table with proper scope handling
- Parse tree printing after tokenization

---

## 📁 Project Structure

| File | Description |
|------|-------------|
| `lexer.l` | Flex file defining tokens and regular expressions |
| `parser.y` | Bison file defining grammar, rules, and semantic actions |
| `parser.tab.c` / `parser.tab.h` | Auto-generated Bison files after parsing |
| `lex.yy.c` | Auto-generated Flex output |
| `mini_compiler` | Final executable |
| `test.code` | Sample input program to test the compiler |

---

## 🚀 How to Build

Ensure `flex`, `bison`, and `g++` are installed:

```bash
flex lexer.l
bison -d parser.y
g++ lex.yy.c parser.tab.c -o mini_compiler -lfl
```

---

## ▶️ How to Run

Run the compiler with:

```bash
./mini_compiler < test.code
```

Example `test.code` content:

```c
int a = 5;
int b = 10;
if (a < b) {
    print(a);
} else {
    print(b);
}
```

---

## 🧠 Future Work

🛠️ Planned features for future versions:

- Support for `while` and `for` loops  
- Floating-point (`float`), `char`, and `bool` data types  
- String operations and comparisons  
- Enhanced parse tree visualization  
- User-defined functions and function calls  
- Type-checking and conversion  
- Error handling and recovery  
- Intermediate code generation (TAC or IR)  
- Symbol table visualization and logging

---

## 🛡️ License

This project is developed as an academic exercise. Free to use and extend for educational purposes.

---

Built by **Abhay Suyal** for exploring the core phases of a compiler.
