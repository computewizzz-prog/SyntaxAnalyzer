# Syntax Analyzer Implementation

This project implements a complete syntax analyzer using Flex and Bison for a C-like programming language.

## Prerequisites

Make sure you have the following installed:
- gcc/g++ compiler
- flex (Fast Lexical Analyzer Generator)
- bison (GNU Parser Generator)
- make

### On Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install build-essential flex bison
```

### On CentOS/RHEL:
```bash
sudo yum install gcc gcc-c++ flex bison make
```

### On macOS:
```bash
brew install flex bison
```

## Project Structure

```
.
├── src/
│   ├── lexer.l          # Flex lexical analyzer specification
│   ├── parser.y         # Bison parser specification
│   └── tokens.h         # Token definitions header
├── test/
│   ├── test1_valid.c    # Test case 1: Basic valid program
│   ├── test2_control.c  # Test case 2: Control structures
│   ├── test3_struct.c   # Test case 3: Structures and arrays
│   ├── test4_pointers.c # Test case 4: Pointers and functions
│   ├── test5_error.c    # Test case 5: Syntax errors
│   ├── test6_advanced.c # Test case 6: Advanced features
│   └── test7_complex.c  # Test case 7: Complex expressions
├── Makefile             # Build configuration
├── run.sh              # Test runner script
└── README.md           # This file
```

## Building the Project

1. **Setup the source directory and copy files:**
   ```bash
   make setup
   ```

2. **Build the syntax analyzer:**
   ```bash
   make
   ```

   This will:
   - Generate lexer.c from lexer.l using Flex
   - Generate parser.tab.c and parser.tab.h from parser.y using Bison
   - Compile and link everything into the `syntax_analyzer` executable

## Running the Syntax Analyzer

### Single Test File
```bash
./syntax_analyzer <input_file>
```

Example:
```bash
./syntax_analyzer test/test1_valid.c
```

### All Test Cases
```bash
chmod +x run.sh
./run.sh
```

Or use make:
```bash
make test
```

## Expected Output

### For Valid Programs
The analyzer will output a table showing identified tokens and their types:

```
Token                     Token_Type
---------------------------------------------
main                     IDENTIFIER
main                     PROCEDURE
x                        IDENTIFIER
y                        IDENTIFIER
z                        IDENTIFIER
10                       INTEGER_LITERAL
20                       INTEGER_LITERAL
...

Syntax analysis completed successfully.
```

### For Invalid Programs
The analyzer will report syntax errors:

```
Syntax error at line 5 near 'int': syntax error
Syntax error at line 9 near 'return': syntax error

Syntax analysis failed with 2 syntax errors.
```

## Features Implemented

### Basic Features
- ✅ All arithmetic and logical operators
- ✅ if-else statements
- ✅ for loops
- ✅ while loops
- ✅ do-while loops
- ✅ switch-case statements
- ✅ Arrays (integer and char)
- ✅ Pointers
- ✅ Structures
- ✅ Function calls with arguments
- ✅ goto statements
- ✅ break and continue
- ✅ static keyword

### Advanced Features
- ✅ Recursive function calls
- ✅ Function pointers
- ✅ Multi-dimensional arrays
- ✅ typedef
- ✅ Enumerations
- ✅ Preprocessor directives
- ✅ Complex expressions with proper precedence
- ✅ Error recovery and reporting

## Test Cases Description

1. **test1_valid.c**: Basic program with variables and arithmetic operations
2. **test2_control.c**: Control structures (if-else, while, for loops)
3. **test3_struct.c**: Structures and multi-dimensional arrays
4. **test4_pointers.c**: Pointer operations and function calls
5. **test5_error.c**: Program with syntax errors (missing semicolons)
6. **test6_advanced.c**: Advanced features (enums, switch, goto, typedef)
7. **test7_complex.c**: Complex expressions and preprocessor directives

## Grammar Rules

The parser implements a comprehensive C-like grammar including:

- **Declarations**: Variables, functions, structures, enums, typedefs
- **Statements**: Expression, compound, selection, iteration, jump
- **Expressions**: Assignment, conditional, logical, arithmetic, bitwise
- **Types**: Basic types, pointers, arrays, structures
- **Control Flow**: if-else, loops, switch-case, goto
- **Error Recovery**: Graceful handling of syntax errors

## Error Handling

The syntax analyzer provides:

1. **Lexical Error Reporting**: Invalid tokens, unterminated strings/comments
2. **Syntax Error Reporting**: Grammar violations with line numbers
3. **Error Recovery**: Continues parsing after errors to find more issues
4. **Detailed Messages**: Specific error descriptions with context

## Cleaning Up

```bash
make clean      # Remove generated files
make distclean  # Remove everything including src directory
```

## Troubleshooting

### Common Issues

1. **"flex: command not found"**
   - Install flex: `sudo apt-get install flex`

2. **"bison: command not found"**  
   - Install bison: `sudo apt-get install bison`

3. **"undefined reference to `yywrap`"**
   - Make sure `%option noyywrap` is in the lexer file

4. **Parser conflicts**
   - Check the grammar rules for ambiguities
   - Use precedence declarations to resolve conflicts

### Debug Mode

To see detailed parser information:
```bash
bison -v -t -d src/parser.y
```

This creates parser.output with state machine details.

## Commands to Execute Everything

Here are the complete commands to set up and run everything:

```bash
# 1. Copy the provided files to appropriate locations
cp lexer.l src/
cp parser.y src/
cp tokens.h src/
mkdir -p test
cp test*.c test/

# 2. Build the project
make setup
make

# 3. Run all tests
chmod +x run.sh
./run.sh

# 4. Or run individual tests
./syntax_analyzer test/test1_valid.c
./syntax_analyzer test/test5_error.c
```

That's it! The complete syntax analyzer is ready to use.