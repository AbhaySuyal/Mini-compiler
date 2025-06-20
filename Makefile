CC = g++
CFLAGS = -std=c++17 -Wall -Wextra -Werror

all: mycompiler

mycompiler: parser.tab.o lex.yy.o ast.o
	$(CC) $(CFLAGS) -o $@ $^ -lfl

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

parser.tab.o: parser.tab.c
	$(CC) $(CFLAGS) -c $<

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -Wno-unused-function -c $<

ast.o: ast.cpp ast.hpp
	$(CC) $(CFLAGS) -c ast.cpp

clean:
	rm -f *.o parser.tab.c parser.tab.h lex.yy.c mycompiler

run: mycompiler
	./mycompiler < test.txt
