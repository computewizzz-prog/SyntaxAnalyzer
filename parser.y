%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"

extern int yylex();
extern char* yytext;
extern int yylineno;
extern FILE* yyin;
extern int num_errors;

int syntax_errors = 0;

void yyerror(const char* s);
void print_token_table();

typedef struct TokenTableEntry {
    char lexeme[256];
    char token_type[64];
    struct TokenTableEntry* next;
} TokenTableEntry;

TokenTableEntry* token_table = NULL;

void add_token_to_table(const char* lexeme, const char* token_type) {
    TokenTableEntry* entry = (TokenTableEntry*)malloc(sizeof(TokenTableEntry));
    strcpy(entry->lexeme, lexeme);
    strcpy(entry->token_type, token_type);
    entry->next = token_table;
    token_table = entry;
}

void print_token_table() {
    printf("%-25s %s\n", "Token", "Token_Type");
    printf("---------------------------------------------\n");
    
    TokenTableEntry* current = token_table;
    while (current != NULL) {
        printf("%-25s %s\n", current->lexeme, current->token_type);
        current = current->next;
    }
}

void free_token_table() {
    TokenTableEntry* current = token_table;
    while (current != NULL) {
        TokenTableEntry* next = current->next;
        free(current);
        current = next;
    }
    token_table = NULL;
}

%}

%union {
    char* str;
}

/* Token declarations */
%token <str> IDENTIFIER
%token <str> INTEGER_LITERAL
%token <str> FLOAT_LITERAL
%token <str> CHAR_LITERAL
%token <str> STRING_LITERAL

/* Keywords */
%token <str> KEYWORD_INT KEYWORD_CHAR KEYWORD_FLOAT KEYWORD_DOUBLE KEYWORD_VOID
%token <str> KEYWORD_IF KEYWORD_ELSE KEYWORD_FOR KEYWORD_WHILE KEYWORD_DO
%token <str> KEYWORD_RETURN KEYWORD_BREAK KEYWORD_CONTINUE
%token <str> KEYWORD_SWITCH KEYWORD_CASE KEYWORD_DEFAULT
%token <str> KEYWORD_GOTO KEYWORD_ENUM KEYWORD_STRUCT KEYWORD_UNION
%token <str> KEYWORD_TYPEDEF KEYWORD_STATIC KEYWORD_AUTO KEYWORD_CONST
%token <str> KEYWORD_SIZEOF KEYWORD_CLASS KEYWORD_PUBLIC KEYWORD_PRIVATE
%token <str> KEYWORD_PROTECTED KEYWORD_NEW KEYWORD_DELETE KEYWORD_USING
%token <str> KEYWORD_NAMESPACE KEYWORD_BOOL KEYWORD_LONG
%token <str> KEYWORD_TRUE KEYWORD_FALSE

/* Operators */
%token <str> OP_PLUS OP_MINUS OP_MULTIPLY OP_DIVIDE OP_MODULO
%token <str> OP_INCREMENT OP_DECREMENT OP_ASSIGN
%token <str> OP_ADD_ASSIGN OP_SUB_ASSIGN OP_MUL_ASSIGN OP_DIV_ASSIGN OP_MOD_ASSIGN
%token <str> OP_EQUAL OP_NOT_EQUAL OP_LESS_THAN OP_GREATER_THAN
%token <str> OP_LESS_THAN_EQUAL OP_GREATER_THAN_EQUAL
%token <str> OP_LOGICAL_AND OP_LOGICAL_OR OP_LOGICAL_NOT
%token <str> OP_BITWISE_AND OP_BITWISE_OR OP_BITWISE_XOR OP_BITWISE_NOT
%token <str> OP_LSHIFT OP_RSHIFT

/* Delimiters */
%token <str> SEMICOLON COMMA
%token <str> OPEN_PARENTHESIS CLOSE_PARENTHESIS
%token <str> OPEN_CURLY_BRACKET CLOSE_CURLY_BRACKET
%token <str> OPEN_BRACKET CLOSE_BRACKET
%token <str> COLON DOT POINTER_ARROW

/* Preprocessor */
%token <str> PREPROCESSOR_DIRECTIVE

/* Special tokens */
%token <str> ERROR_TOKEN

/* Precedence and associativity */
%right OP_ASSIGN OP_ADD_ASSIGN OP_SUB_ASSIGN OP_MUL_ASSIGN OP_DIV_ASSIGN OP_MOD_ASSIGN
%left OP_LOGICAL_OR
%left OP_LOGICAL_AND
%left OP_BITWISE_OR
%left OP_BITWISE_XOR
%left OP_BITWISE_AND
%left OP_EQUAL OP_NOT_EQUAL
%left OP_LESS_THAN OP_GREATER_THAN OP_LESS_THAN_EQUAL OP_GREATER_THAN_EQUAL
%left OP_LSHIFT OP_RSHIFT
%left OP_PLUS OP_MINUS
%left OP_MULTIPLY OP_DIVIDE OP_MODULO
%right OP_LOGICAL_NOT OP_BITWISE_NOT UNARY_MINUS UNARY_PLUS
%left OP_INCREMENT OP_DECREMENT
%left DOT POINTER_ARROW
%left OPEN_BRACKET CLOSE_BRACKET
%left OPEN_PARENTHESIS CLOSE_PARENTHESIS

/* Non-terminal types */
%type <str> program translation_unit external_declaration
%type <str> function_definition declaration
%type <str> declaration_specifiers init_declarator_list init_declarator
%type <str> storage_class_specifier type_specifier type_qualifier
%type <str> struct_or_union_specifier struct_or_union
%type <str> struct_declaration_list struct_declaration
%type <str> specifier_qualifier_list struct_declarator_list struct_declarator
%type <str> enum_specifier enumerator_list enumerator
%type <str> declarator direct_declarator pointer
%type <str> type_qualifier_list parameter_type_list parameter_list parameter_declaration
%type <str> identifier_list type_name abstract_declarator direct_abstract_declarator
%type <str> initializer initializer_list
%type <str> statement labeled_statement compound_statement expression_statement
%type <str> selection_statement iteration_statement jump_statement
%type <str> block_item_list block_item
%type <str> expression assignment_expression conditional_expression
%type <str> logical_or_expression logical_and_expression inclusive_or_expression
%type <str> exclusive_or_expression and_expression equality_expression
%type <str> relational_expression shift_expression additive_expression
%type <str> multiplicative_expression cast_expression unary_expression
%type <str> postfix_expression primary_expression argument_expression_list
%type <str> unary_operator assignment_operator constant_expression

%start program

%%

program
    : translation_unit {
        add_token_to_table("program", "PROGRAM");
        $$ = $1;
    }
    ;

translation_unit
    : external_declaration {
        $$ = $1;
    }
    | translation_unit external_declaration {
        $$ = $1;
    }
    ;

external_declaration
    : function_definition {
        $$ = $1;
    }
    | declaration {
        $$ = $1;
    }
    | PREPROCESSOR_DIRECTIVE {
        add_token_to_table($1, "PREPROCESSOR_DIRECTIVE");
        $$ = $1;
    }
    | error SEMICOLON {
        yyerrok;
        yyclearin;
        $$ = "error";
    }
    ;

function_definition
    : declaration_specifiers declarator compound_statement {
        add_token_to_table($2, "PROCEDURE");
        $$ = "function_definition";
    }
    | declarator compound_statement {
        add_token_to_table($1, "PROCEDURE");
        $$ = "function_definition";
    }
    ;

declaration
    : declaration_specifiers SEMICOLON {
        $$ = "declaration";
    }
    | declaration_specifiers init_declarator_list SEMICOLON {
        $$ = "declaration";
    }
    | error SEMICOLON {
        yyerrok;
        yyclearin;
        $$ = "error";
    }
    ;

declaration_specifiers
    : storage_class_specifier {
        $$ = $1;
    }
    | storage_class_specifier declaration_specifiers {
        $$ = $1;
    }
    | type_specifier {
        $$ = $1;
    }
    | type_specifier declaration_specifiers {
        $$ = $1;
    }
    | type_qualifier {
        $$ = $1;
    }
    | type_qualifier declaration_specifiers {
        $$ = $1;
    }
    ;

init_declarator_list
    : init_declarator {
        $$ = $1;
    }
    | init_declarator_list COMMA init_declarator {
        add_token_to_table($3, $1);
        $$ = $1;
    }
    ;

init_declarator
    : declarator {
        $$ = $1;
    }
    | declarator OP_ASSIGN initializer {
        $$ = $1;
    }
    ;

storage_class_specifier
    : KEYWORD_TYPEDEF {
        add_token_to_table($1, "TYPEDEF");
        $$ = "TYPEDEF";
    }
    | KEYWORD_STATIC {
        add_token_to_table($1, "STATIC");
        $$ = "STATIC";
    }
    | KEYWORD_AUTO {
        add_token_to_table($1, "AUTO");
        $$ = "AUTO";
    }
    ;

type_specifier
    : KEYWORD_VOID {
        add_token_to_table($1, "VOID");
        $$ = "VOID";
    }
    | KEYWORD_CHAR {
        add_token_to_table($1, "CHAR");
        $$ = "CHAR";
    }
    | KEYWORD_SHORT {
        add_token_to_table($1, "SHORT");
        $$ = "SHORT";
    }
    | KEYWORD_INT {
        add_token_to_table($1, "INT");
        $$ = "INT";
    }
    | KEYWORD_LONG {
        add_token_to_table($1, "LONG");
        $$ = "LONG";
    }
    | KEYWORD_FLOAT {
        add_token_to_table($1, "FLOAT");
        $$ = "FLOAT";
    }
    | KEYWORD_DOUBLE {
        add_token_to_table($1, "DOUBLE");
        $$ = "DOUBLE";
    }
    | KEYWORD_BOOL {
        add_token_to_table($1, "BOOL");
        $$ = "BOOL";
    }
    | struct_or_union_specifier {
        $$ = $1;
    }
    | enum_specifier {
        $$ = $1;
    }
    | KEYWORD_CLASS {
        add_token_to_table($1, "CLASS");
        $$ = "CLASS";
    }
    ;

struct_or_union_specifier
    : struct_or_union IDENTIFIER OPEN_CURLY_BRACKET struct_declaration_list CLOSE_CURLY_BRACKET {
        add_token_to_table($2, $1);
        $$ = $1;
    }
    | struct_or_union OPEN_CURLY_BRACKET struct_declaration_list CLOSE_CURLY_BRACKET {
        $$ = $1;
    }
    | struct_or_union IDENTIFIER {
        add_token_to_table($2, $1);
        $$ = $1;
    }
    ;

struct_or_union
    : KEYWORD_STRUCT {
        add_token_to_table($1, "STRUCT");
        $$ = "STRUCT";
    }
    | KEYWORD_UNION {
        add_token_to_table($1, "UNION");
        $$ = "UNION";
    }
    ;

struct_declaration_list
    : struct_declaration {
        $$ = $1;
    }
    | struct_declaration_list struct_declaration {
        $$ = $1;
    }
    ;

struct_declaration
    : specifier_qualifier_list struct_declarator_list SEMICOLON {
        $$ = $1;
    }
    | error SEMICOLON {
        yyerrok;
        yyclearin;
        $$ = "error";
    }
    ;

specifier_qualifier_list
    : type_specifier specifier_qualifier_list {
        $$ = $1;
    }
    | type_specifier {
        $$ = $1;
    }
    | type_qualifier specifier_qualifier_list {
        $$ = $1;
    }
    | type_qualifier {
        $$ = $1;
    }
    ;

struct_declarator_list
    : struct_declarator {
        $$ = $1;
    }
    | struct_declarator_list COMMA struct_declarator {
        add_token_to_table($3, $1);
        $$ = $1;
    }
    ;

struct_declarator
    : declarator {
        $$ = $1;
    }
    | COLON constant_expression {
        $$ = "BIT_FIELD";
    }
    | declarator COLON constant_expression {
        $$ = $1;
    }
    ;

enum_specifier
    : KEYWORD_ENUM OPEN_CURLY_BRACKET enumerator_list CLOSE_CURLY_BRACKET {
        add_token_to_table($1, "ENUM");
        $$ = "ENUM";
    }
    | KEYWORD_ENUM IDENTIFIER OPEN_CURLY_BRACKET enumerator_list CLOSE_CURLY_BRACKET {
        add_token_to_table($2, "ENUM");
        $$ = "ENUM";
    }
    | KEYWORD_ENUM IDENTIFIER {
        add_token_to_table($2, "ENUM");
        $$ = "ENUM";
    }
    ;

enumerator_list
    : enumerator {
        $$ = $1;
    }
    | enumerator_list COMMA enumerator {
        $$ = $1;
    }
    ;

enumerator
    : IDENTIFIER {
        add_token_to_table($1, "ENUMERATOR");
        $$ = "ENUMERATOR";
    }
    | IDENTIFIER OP_ASSIGN constant_expression {
        add_token_to_table($1, "ENUMERATOR");
        $$ = "ENUMERATOR";
    }
    ;

type_qualifier
    : KEYWORD_CONST {
        add_token_to_table($1, "CONST");
        $$ = "CONST";
    }
    ;

declarator
    : pointer direct_declarator {
        $$ = $2;
    }
    | direct_declarator {
        $$ = $1;
    }
    ;

direct_declarator
    : IDENTIFIER {
        add_token_to_table($1, "IDENTIFIER");
        $$ = $1;
    }
    | OPEN_PARENTHESIS declarator CLOSE_PARENTHESIS {
        $$ = $2;
    }
    | direct_declarator OPEN_BRACKET CLOSE_BRACKET {
        $$ = $1;
    }
    | direct_declarator OPEN_BRACKET constant_expression CLOSE_BRACKET {
        $$ = $1;
    }
    | direct_declarator OPEN_PARENTHESIS parameter_type_list CLOSE_PARENTHESIS {
        add_token_to_table($1, "PROCEDURE");
        $$ = $1;
    }
    | direct_declarator OPEN_PARENTHESIS identifier_list CLOSE_PARENTHESIS {
        add_token_to_table($1, "PROCEDURE");
        $$ = $1;
    }
    | direct_declarator OPEN_PARENTHESIS CLOSE_PARENTHESIS {
        add_token_to_table($1, "PROCEDURE");
        $$ = $1;
    }
    ;

pointer
    : OP_MULTIPLY {
        $$ = "POINTER";
    }
    | OP_MULTIPLY type_qualifier_list {
        $$ = "POINTER";
    }
    | OP_MULTIPLY pointer {
        $$ = "POINTER";
    }
    | OP_MULTIPLY type_qualifier_list pointer {
        $$ = "POINTER";
    }
    ;

type_qualifier_list
    : type_qualifier {
        $$ = $1;
    }
    | type_qualifier_list type_qualifier {
        $$ = $1;
    }
    ;

parameter_type_list
    : parameter_list {
        $$ = $1;
    }
    ;

parameter_list
    : parameter_declaration {
        $$ = $1;
    }
    | parameter_list COMMA parameter_declaration {
        $$ = $1;
    }
    ;

parameter_declaration
    : declaration_specifiers declarator {
        add_token_to_table($2, $1);
        $$ = $1;
    }
    | declaration_specifiers abstract_declarator {
        $$ = $1;
    }
    | declaration_specifiers {
        $$ = $1;
    }
    ;

identifier_list
    : IDENTIFIER {
        add_token_to_table($1, "IDENTIFIER");
        $$ = $1;
    }
    | identifier_list COMMA IDENTIFIER {
        add_token_to_table($3, "IDENTIFIER");
        $$ = $1;
    }
    ;

type_name
    : specifier_qualifier_list {
        $$ = $1;
    }
    | specifier_qualifier_list abstract_declarator {
        $$ = $1;
    }
    ;

abstract_declarator
    : pointer {
        $$ = $1;
    }
    | direct_abstract_declarator {
        $$ = $1;
    }
    | pointer direct_abstract_declarator {
        $$ = $1;
    }
    ;

direct_abstract_declarator
    : OPEN_PARENTHESIS abstract_declarator CLOSE_PARENTHESIS {
        $$ = $2;
    }
    | OPEN_BRACKET CLOSE_BRACKET {
        $$ = "ARRAY";
    }
    | OPEN_BRACKET constant_expression CLOSE_BRACKET {
        $$ = "ARRAY";
    }
    | direct_abstract_declarator OPEN_BRACKET CLOSE_BRACKET {
        $$ = "ARRAY";
    }
    | direct_abstract_declarator OPEN_BRACKET constant_expression CLOSE_BRACKET {
        $$ = "ARRAY";
    }
    | OPEN_PARENTHESIS CLOSE_PARENTHESIS {
        $$ = "FUNCTION";
    }
    | OPEN_PARENTHESIS parameter_type_list CLOSE_PARENTHESIS {
        $$ = "FUNCTION";
    }
    | direct_abstract_declarator OPEN_PARENTHESIS CLOSE_PARENTHESIS {
        $$ = "FUNCTION";
    }
    | direct_abstract_declarator OPEN_PARENTHESIS parameter_type_list CLOSE_PARENTHESIS {
        $$ = "FUNCTION";
    }
    ;

initializer
    : assignment_expression {
        $$ = $1;
    }
    | OPEN_CURLY_BRACKET initializer_list CLOSE_CURLY_BRACKET {
        $$ = "INITIALIZER_LIST";
    }
    | OPEN_CURLY_BRACKET initializer_list COMMA CLOSE_CURLY_BRACKET {
        $$ = "INITIALIZER_LIST";
    }
    ;

initializer_list
    : initializer {
        $$ = $1;
    }
    | initializer_list COMMA initializer {
        $$ = $1;
    }
    ;

statement
    : labeled_statement {
        $$ = $1;
    }
    | compound_statement {
        $$ = $1;
    }
    | expression_statement {
        $$ = $1;
    }
    | selection_statement {
        $$ = $1;
    }
    | iteration_statement {
        $$ = $1;
    }
    | jump_statement {
        $$ = $1;
    }
    ;

labeled_statement
    : IDENTIFIER COLON statement {
        add_token_to_table($1, "LABEL");
        $$ = "LABELED_STATEMENT";
    }
    | KEYWORD_CASE constant_expression COLON statement {
        $$ = "CASE_STATEMENT";
    }
    | KEYWORD_DEFAULT COLON statement {
        $$ = "DEFAULT_STATEMENT";
    }
    ;

compound_statement
    : OPEN_CURLY_BRACKET CLOSE_CURLY_BRACKET {
        $$ = "COMPOUND_STATEMENT";
    }
    | OPEN_CURLY_BRACKET block_item_list CLOSE_CURLY_BRACKET {
        $$ = "COMPOUND_STATEMENT";
    }
    ;

block_item_list
    : block_item {
        $$ = $1;
    }
    | block_item_list block_item {
        $$ = $1;
    }
    ;

block_item
    : declaration {
        $$ = $1;
    }
    | statement {
        $$ = $1;
    }
    | error SEMICOLON {
        yyerrok;
        yyclearin;
        $$ = "error";
    }
    ;

expression_statement
    : SEMICOLON {
        $$ = "EMPTY_STATEMENT";
    }
    | expression SEMICOLON {
        $$ = "EXPRESSION_STATEMENT";
    }
    ;

selection_statement
    : KEYWORD_IF OPEN_PARENTHESIS expression CLOSE_PARENTHESIS statement {
        $$ = "IF_STATEMENT";
    }
    | KEYWORD_IF OPEN_PARENTHESIS expression CLOSE_PARENTHESIS statement KEYWORD_ELSE statement {
        $$ = "IF_ELSE_STATEMENT";
    }
    | KEYWORD_SWITCH OPEN_PARENTHESIS expression CLOSE_PARENTHESIS statement {
        $$ = "SWITCH_STATEMENT";
    }
    ;

iteration_statement
    : KEYWORD_WHILE OPEN_PARENTHESIS expression CLOSE_PARENTHESIS statement {
        $$ = "WHILE_STATEMENT";
    }
    | KEYWORD_DO statement KEYWORD_WHILE OPEN_PARENTHESIS expression CLOSE_PARENTHESIS SEMICOLON {
        $$ = "DO_WHILE_STATEMENT";
    }
    | KEYWORD_FOR OPEN_PARENTHESIS expression_statement expression_statement CLOSE_PARENTHESIS statement {
        $$ = "FOR_STATEMENT";
    }
    | KEYWORD_FOR OPEN_PARENTHESIS expression_statement expression_statement expression CLOSE_PARENTHESIS statement {
        $$ = "FOR_STATEMENT";
    }
    | KEYWORD_FOR OPEN_PARENTHESIS declaration expression_statement CLOSE_PARENTHESIS statement {
        $$ = "FOR_STATEMENT";
    }
    | KEYWORD_FOR OPEN_PARENTHESIS declaration expression_statement expression CLOSE_PARENTHESIS statement {
        $$ = "FOR_STATEMENT";
    }
    ;

jump_statement
    : KEYWORD_GOTO IDENTIFIER SEMICOLON {
        add_token_to_table($2, "LABEL");
        $$ = "GOTO_STATEMENT";
    }
    | KEYWORD_CONTINUE SEMICOLON {
        $$ = "CONTINUE_STATEMENT";
    }
    | KEYWORD_BREAK SEMICOLON {
        $$ = "BREAK_STATEMENT";
    }
    | KEYWORD_RETURN SEMICOLON {
        $$ = "RETURN_STATEMENT";
    }
    | KEYWORD_RETURN expression SEMICOLON {
        $$ = "RETURN_STATEMENT";
    }
    ;

expression
    : assignment_expression {
        $$ = $1;
    }
    | expression COMMA assignment_expression {
        $$ = $1;
    }
    ;

assignment_expression
    : conditional_expression {
        $$ = $1;
    }
    | unary_expression assignment_operator assignment_expression {
        $$ = $1;
    }
    ;

assignment_operator
    : OP_ASSIGN { $$ = "ASSIGN"; }
    | OP_MUL_ASSIGN { $$ = "MUL_ASSIGN"; }
    | OP_DIV_ASSIGN { $$ = "DIV_ASSIGN"; }
    | OP_MOD_ASSIGN { $$ = "MOD_ASSIGN"; }
    | OP_ADD_ASSIGN { $$ = "ADD_ASSIGN"; }
    | OP_SUB_ASSIGN { $$ = "SUB_ASSIGN"; }
    ;

conditional_expression
    : logical_or_expression {
        $$ = $1;
    }
    ;

logical_or_expression
    : logical_and_expression {
        $$ = $1;
    }
    | logical_or_expression OP_LOGICAL_OR logical_and_expression {
        $$ = $1;
    }
    ;

logical_and_expression
    : inclusive_or_expression {
        $$ = $1;
    }
    | logical_and_expression OP_LOGICAL_AND inclusive_or_expression {
        $$ = $1;
    }
    ;

inclusive_or_expression
    : exclusive_or_expression {
        $$ = $1;
    }
    | inclusive_or_expression OP_BITWISE_OR exclusive_or_expression {
        $$ = $1;
    }
    ;

exclusive_or_expression
    : and_expression {
        $$ = $1;
    }
    | exclusive_or_expression OP_BITWISE_XOR and_expression {
        $$ = $1;
    }
    ;

and_expression
    : equality_expression {
        $$ = $1;
    }
    | and_expression OP_BITWISE_AND equality_expression {
        $$ = $1;
    }
    ;

equality_expression
    : relational_expression {
        $$ = $1;
    }
    | equality_expression OP_EQUAL relational_expression {
        $$ = $1;
    }
    | equality_expression OP_NOT_EQUAL relational_expression {
        $$ = $1;
    }
    ;

relational_expression
    : shift_expression {
        $$ = $1;
    }
    | relational_expression OP_LESS_THAN shift_expression {
        $$ = $1;
    }
    | relational_expression OP_GREATER_THAN shift_expression {
        $$ = $1;
    }
    | relational_expression OP_LESS_THAN_EQUAL shift_expression {
        $$ = $1;
    }
    | relational_expression OP_GREATER_THAN_EQUAL shift_expression {
        $$ = $1;
    }
    ;

shift_expression
    : additive_expression {
        $$ = $1;
    }
    | shift_expression OP_LSHIFT additive_expression {
        $$ = $1;
    }
    | shift_expression OP_RSHIFT additive_expression {
        $$ = $1;
    }
    ;

additive_expression
    : multiplicative_expression {
        $$ = $1;
    }
    | additive_expression OP_PLUS multiplicative_expression {
        $$ = $1;
    }
    | additive_expression OP_MINUS multiplicative_expression {
        $$ = $1;
    }
    ;

multiplicative_expression
    : cast_expression {
        $$ = $1;
    }
    | multiplicative_expression OP_MULTIPLY cast_expression {
        $$ = $1;
    }
    | multiplicative_expression OP_DIVIDE cast_expression {
        $$ = $1;
    }
    | multiplicative_expression OP_MODULO cast_expression {
        $$ = $1;
    }
    ;

cast_expression
    : unary_expression {
        $$ = $1;
    }
    | OPEN_PARENTHESIS type_name CLOSE_PARENTHESIS cast_expression {
        $$ = $4;
    }
    ;

unary_expression
    : postfix_expression {
        $$ = $1;
    }
    | OP_INCREMENT unary_expression {
        $$ = $2;
    }
    | OP_DECREMENT unary_expression {
        $$ = $2;
    }
    | unary_operator cast_expression {
        $$ = $2;
    }
    | KEYWORD_SIZEOF unary_expression {
        $$ = $2;
    }
    | KEYWORD_SIZEOF OPEN_PARENTHESIS type_name CLOSE_PARENTHESIS {
        $$ = "SIZEOF_EXPRESSION";
    }
    ;

unary_operator
    : OP_BITWISE_AND { $$ = "ADDRESS"; }
    | OP_MULTIPLY { $$ = "DEREFERENCE"; }
    | OP_PLUS { $$ = "UNARY_PLUS"; }
    | OP_MINUS { $$ = "UNARY_MINUS"; }
    | OP_BITWISE_NOT { $$ = "BITWISE_NOT"; }
    | OP_LOGICAL_NOT { $$ = "LOGICAL_NOT"; }
    ;

postfix_expression
    : primary_expression {
        $$ = $1;
    }
    | postfix_expression OPEN_BRACKET expression CLOSE_BRACKET {
        $$ = $1;
    }
    | postfix_expression OPEN_PARENTHESIS CLOSE_PARENTHESIS {
        add_token_to_table($1, "PROCEDURE");
        $$ = $1;
    }
    | postfix_expression OPEN_PARENTHESIS argument_expression_list CLOSE_PARENTHESIS {
        add_token_to_table($1, "PROCEDURE");
        $$ = $1;
    }
    | postfix_expression DOT IDENTIFIER {
        add_token_to_table($3, "MEMBER");
        $$ = $1;
    }
    | postfix_expression POINTER_ARROW IDENTIFIER {
        add_token_to_table($3, "MEMBER");
        $$ = $1;
    }
    | postfix_expression OP_INCREMENT {
        $$ = $1;
    }
    | postfix_expression OP_DECREMENT {
        $$ = $1;
    }
    ;

primary_expression
    : IDENTIFIER {
        add_token_to_table($1, "IDENTIFIER");
        $$ = $1;
    }
    | INTEGER_LITERAL {
        add_token_to_table($1, "INTEGER_LITERAL");
        $$ = $1;
    }
    | FLOAT_LITERAL {
        add_token_to_table($1, "FLOAT_LITERAL");
        $$ = $1;
    }
    | CHAR_LITERAL {
        add_token_to_table($1, "CHAR_LITERAL");
        $$ = $1;
    }
    | STRING_LITERAL {
        add_token_to_table($1, "STRING_LITERAL");
        $$ = $1;
    }
    | KEYWORD_TRUE {
        add_token_to_table($1, "BOOL_LITERAL");
        $$ = $1;
    }
    | KEYWORD_FALSE {
        add_token_to_table($1, "BOOL_LITERAL");
        $$ = $1;
    }
    | OPEN_PARENTHESIS expression CLOSE_PARENTHESIS {
        $$ = $2;
    }
    ;

argument_expression_list
    : assignment_expression {
        $$ = $1;
    }
    | argument_expression_list COMMA assignment_expression {
        $$ = $1;
    }
    ;

constant_expression
    : conditional_expression {
        $$ = $1;
    }
    ;

%%

void yyerror(const char* s) {
    syntax_errors++;
    fprintf(stderr, "Syntax error at line %d near '%s': %s\n", yylineno, yytext, s);
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE* file = fopen(argv[1], "r");
    if (!file) {
        fprintf(stderr, "Error: Could not open file %s\n", argv[1]);
        return 1;
    }

    yyin = file;
    
    int result = yyparse();
    
    fclose(file);
    
    if (result == 0 && syntax_errors == 0 && num_errors == 0) {
        print_token_table();
        printf("\nSyntax analysis completed successfully.\n");
        free_token_table();
        return 0;
    } else {
        if (syntax_errors > 0) {
            fprintf(stderr, "\nSyntax analysis failed with %d syntax errors.\n", syntax_errors);
        }
        if (num_errors > 0) {
            fprintf(stderr, "Lexical analysis failed with %d lexical errors.\n", num_errors);
        }
        free_token_table();
        return 1;
    }
}