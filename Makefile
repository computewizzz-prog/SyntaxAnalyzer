# Compiler and tools
CC = gcc
CXX = g++
FLEX = flex
BISON = bison
CFLAGS = -std=c99 -Wall -g
CXXFLAGS = -std=c++11 -Wall -g

# Executable name
TARGET = syntax_analyzer

# Source files
FLEX_FILE = src/lexer.l
BISON_FILE = src/parser.y
MAIN_FILE = src/main.cpp

# Generated files
FLEX_OUTPUT = src/lexer.c
BISON_OUTPUT = src/parser.tab.c
BISON_HEADER = src/parser.tab.h

# Object files
OBJECTS = src/lexer.o src/parser.tab.o

# Default target
all: $(TARGET)

# Rule to build the final executable
$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJECTS) -lfl

# Rule to generate and compile lexer
src/lexer.o: $(FLEX_OUTPUT) $(BISON_HEADER)
	$(CC) $(CFLAGS) -c $(FLEX_OUTPUT) -o src/lexer.o

# Rule to generate lexer from flex file
$(FLEX_OUTPUT): $(FLEX_FILE) $(BISON_HEADER)
	$(FLEX) -o $(FLEX_OUTPUT) $(FLEX_FILE)

# Rule to generate and compile parser
src/parser.tab.o: $(BISON_OUTPUT)
	$(CC) $(CFLAGS) -c $(BISON_OUTPUT) -o src/parser.tab.o

# Rule to generate parser from bison file
$(BISON_OUTPUT) $(BISON_HEADER): $(BISON_FILE)
	$(BISON) -d -o $(BISON_OUTPUT) $(BISON_FILE)

# Create src directory if it doesn't exist
src:
	mkdir -p src

# Setup: copy files to src directory
setup: src
	cp lexer.l src/
	cp parser.y src/
	cp tokens.h src/

# Clean up generated files
clean:
	rm -f $(OBJECTS) $(TARGET) $(FLEX_OUTPUT) $(BISON_OUTPUT) $(BISON_HEADER)
	rm -f src/lexer.c src/parser.tab.c src/parser.tab.h
	rm -f test_results.txt

# Clean everything including src directory
distclean: clean
	rm -rf src/

# Run tests
test: $(TARGET)
	@echo "Running syntax analyzer tests..."
	@mkdir -p test_results
	@for testfile in test/*.c; do \
		echo "Testing $$testfile:"; \
		./$(TARGET) "$$testfile" > "test_results/$$(basename $$testfile .c)_result.txt" 2>&1 || true; \
		echo ""; \
	done
	@echo "Test results saved in test_results/ directory"

.PHONY: all clean distclean setup test