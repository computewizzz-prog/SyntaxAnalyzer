%{
    #include <stdio.h>
    #include <string.h>
    #include <limits.h>
    #include <stdlib.h>
    #include "parser.tab.h"
    
    // Counter for errors
    int num_errors = 0;
    
    // Declare external variables
    extern char* yytext;
    extern int yylineno;
    extern FILE* yyin;
    extern YYSTYPE yylval;
    
    // Helper function to check integer overflow
    int check_integer_overflow(const char* str) {
        char* endptr;
        long val = strtol(str, &endptr, 10);
        return (val > INT_MAX || val < INT_MIN || *endptr != '\0');
    }
    
    // Helper function to check identifier length
    int check_identifier_length(const char* str) {
        return strlen(str) > 255; // Common limit for identifiers
    }
%}

%option yylineno
%option noyywrap

%x COMMENT_STATE

DIGIT [0-9]
LETTER [a-zA-Z_]
IDENTIFIER {LETTER}({LETTER}|{DIGIT})*
INTEGER_LITERAL {DIGIT}+
CHAR_LITERAL '(\.|[^'\])'
EXPONENTIAL_PART [eE][+-]?{DIGIT}+
FLOAT_LITERAL ({DIGIT}+\.{DIGIT}*{EXPONENTIAL_PART}?|\.{DIGIT}+{EXPONENTIAL_PART}?|{DIGIT}+{EXPONENTIAL_PART})
STRING_LITERAL \"(\.|[^\"\])*\"
WHITESPACE [ \t\r]+
NEWLINE \n
INVALID_IDENTIFIER_START {DIGIT}({LETTER}|{DIGIT})*
INVALID_NUMBER {DIGIT}+[a-zA-Z_]+{DIGIT}*
INVALID_CHAR_IN_NUMBER {DIGIT}+[$@#%&*!^~`]({DIGIT}|[a-zA-Z_])*

%%

{WHITESPACE}    { /* Ignore */ }
{NEWLINE}       { /* yylineno is automatically incremented by flex */ }

"/*"                            { BEGIN(COMMENT_STATE); }
<COMMENT_STATE>"*/"             { BEGIN(INITIAL); }
<COMMENT_STATE>.                { /* Ignore everything inside the comment state */ }
<COMMENT_STATE>\n               { /* Also ignore newlines inside the comment */ }
<COMMENT_STATE><<EOF>>          {
    fprintf(stderr, "Lexical Error at line %d: Unterminated multi-line comment\n", yylineno);
    num_errors++;
}

"//"[^\n]*                      { /* Ignore single-line comments */ }

^"#"[^\n]*                      { 
    yylval.str = strdup(yytext); 
    return PREPROCESSOR_DIRECTIVE; 
}

"int"           { yylval.str = strdup(yytext); return KEYWORD_INT; }
"char"          { yylval.str = strdup(yytext); return KEYWORD_CHAR; }
"float"         { yylval.str = strdup(yytext); return KEYWORD_FLOAT; }
"double"        { yylval.str = strdup(yytext); return KEYWORD_DOUBLE; }
"void"          { yylval.str = strdup(yytext); return KEYWORD_VOID; }
"if"            { yylval.str = strdup(yytext); return KEYWORD_IF; }
"else"          { yylval.str = strdup(yytext); return KEYWORD_ELSE; }
"for"           { yylval.str = strdup(yytext); return KEYWORD_FOR; }
"while"         { yylval.str = strdup(yytext); return KEYWORD_WHILE; }
"return"        { yylval.str = strdup(yytext); return KEYWORD_RETURN; }
"break"         { yylval.str = strdup(yytext); return KEYWORD_BREAK; }
"continue"      { yylval.str = strdup(yytext); return KEYWORD_CONTINUE; }
"do"            { yylval.str = strdup(yytext); return KEYWORD_DO; }
"switch"        { yylval.str = strdup(yytext); return KEYWORD_SWITCH; }
"case"          { yylval.str = strdup(yytext); return KEYWORD_CASE; }
"default"       { yylval.str = strdup(yytext); return KEYWORD_DEFAULT; }
"goto"          { yylval.str = strdup(yytext); return KEYWORD_GOTO; }
"enum"          { yylval.str = strdup(yytext); return KEYWORD_ENUM; }
"struct"        { yylval.str = strdup(yytext); return KEYWORD_STRUCT; }
"union"         { yylval.str = strdup(yytext); return KEYWORD_UNION; }
"typedef"       { yylval.str = strdup(yytext); return KEYWORD_TYPEDEF; }
"static"        { yylval.str = strdup(yytext); return KEYWORD_STATIC; }
"auto"          { yylval.str = strdup(yytext); return KEYWORD_AUTO; }
"const"         { yylval.str = strdup(yytext); return KEYWORD_CONST; }
"sizeof"        { yylval.str = strdup(yytext); return KEYWORD_SIZEOF; }
"class"         { yylval.str = strdup(yytext); return KEYWORD_CLASS; }
"public"        { yylval.str = strdup(yytext); return KEYWORD_PUBLIC; }
"private"       { yylval.str = strdup(yytext); return KEYWORD_PRIVATE; }
"protected"     { yylval.str = strdup(yytext); return KEYWORD_PROTECTED; }
"new"           { yylval.str = strdup(yytext); return KEYWORD_NEW; }
"delete"        { yylval.str = strdup(yytext); return KEYWORD_DELETE; }
"using"         { yylval.str = strdup(yytext); return KEYWORD_USING; }
"namespace"     { yylval.str = strdup(yytext); return KEYWORD_NAMESPACE; }
"bool"          { yylval.str = strdup(yytext); return KEYWORD_BOOL; }
"long"          { yylval.str = strdup(yytext); return KEYWORD_LONG; }
"true"          { yylval.str = strdup(yytext); return KEYWORD_TRUE; }
"false"         { yylval.str = strdup(yytext); return KEYWORD_FALSE; }

{INTEGER_LITERAL}               { 
    if (check_integer_overflow(yytext)) {
        fprintf(stderr, "Lexical Error at line %d: Integer constant '%s' exceeds maximum value\n", yylineno, yytext);
        num_errors++;
        return ERROR_TOKEN;
    }
    yylval.str = strdup(yytext);
    return INTEGER_LITERAL; 
}

{FLOAT_LITERAL}                 { 
    yylval.str = strdup(yytext);
    return FLOAT_LITERAL; 
}

{CHAR_LITERAL}                  { 
    yylval.str = strdup(yytext);
    return CHAR_LITERAL; 
}

{STRING_LITERAL}                { 
    yylval.str = strdup(yytext);
    return STRING_LITERAL; 
}

\"([^\"\\]|\\.)*$            {
    fprintf(stderr, "Lexical Error at line %d: Unterminated string literal\n", yylineno);
    num_errors++;
    return ERROR_TOKEN;
}

'[^']*$                         {
    fprintf(stderr, "Lexical Error at line %d: Unterminated character literal\n", yylineno);
    num_errors++;
    return ERROR_TOKEN;
}

{INVALID_IDENTIFIER_START}      {
    fprintf(stderr, "Lexical Error at line %d: Invalid identifier '%s' - identifiers cannot start with a digit\n", yylineno, yytext);
    num_errors++;
    return ERROR_TOKEN;
}

{INVALID_NUMBER}                {
    fprintf(stderr, "Lexical Error at line %d: Invalid numeric constant '%s' - contains alphabetic characters\n", yylineno, yytext);
    num_errors++;
    return ERROR_TOKEN;
}

{INVALID_CHAR_IN_NUMBER}        {
    fprintf(stderr, "Lexical Error at line %d: Invalid numeric constant '%s' - contains illegal characters\n", yylineno, yytext);
    num_errors++;
    return ERROR_TOKEN;
}

{IDENTIFIER}                    { 
    if (check_identifier_length(yytext)) {
        fprintf(stderr, "Lexical Error at line %d: Identifier '%s' exceeds maximum length (255 characters)\n", yylineno, yytext);
        num_errors++;
        return ERROR_TOKEN;
    }
    yylval.str = strdup(yytext);
    return IDENTIFIER; 
}

"++"            { yylval.str = strdup(yytext); return OP_INCREMENT; }
"--"            { yylval.str = strdup(yytext); return OP_DECREMENT; }
"->"            { yylval.str = strdup(yytext); return POINTER_ARROW; }
"+"             { yylval.str = strdup(yytext); return OP_PLUS; }
"-"             { yylval.str = strdup(yytext); return OP_MINUS; }
"*"             { yylval.str = strdup(yytext); return OP_MULTIPLY; }
"/"             { yylval.str = strdup(yytext); return OP_DIVIDE; }
"%"             { yylval.str = strdup(yytext); return OP_MODULO; }
"+="            { yylval.str = strdup(yytext); return OP_ADD_ASSIGN; }
"-="            { yylval.str = strdup(yytext); return OP_SUB_ASSIGN; }
"*="            { yylval.str = strdup(yytext); return OP_MUL_ASSIGN; }
"/="            { yylval.str = strdup(yytext); return OP_DIV_ASSIGN; }
"%="            { yylval.str = strdup(yytext); return OP_MOD_ASSIGN; }
"=="            { yylval.str = strdup(yytext); return OP_EQUAL; }
"!="            { yylval.str = strdup(yytext); return OP_NOT_EQUAL; }
"<="            { yylval.str = strdup(yytext); return OP_LESS_THAN_EQUAL; }
">="            { yylval.str = strdup(yytext); return OP_GREATER_THAN_EQUAL; }
"<"             { yylval.str = strdup(yytext); return OP_LESS_THAN; }
">"             { yylval.str = strdup(yytext); return OP_GREATER_THAN; }
"&&"            { yylval.str = strdup(yytext); return OP_LOGICAL_AND; }
"||"            { yylval.str = strdup(yytext); return OP_LOGICAL_OR; }
"!"             { yylval.str = strdup(yytext); return OP_LOGICAL_NOT; }
"&"             { yylval.str = strdup(yytext); return OP_BITWISE_AND; }
"|"             { yylval.str = strdup(yytext); return OP_BITWISE_OR; }
"^"             { yylval.str = strdup(yytext); return OP_BITWISE_XOR; }
"~"             { yylval.str = strdup(yytext); return OP_BITWISE_NOT; }
"<<"            { yylval.str = strdup(yytext); return OP_LSHIFT; }
">>"            { yylval.str = strdup(yytext); return OP_RSHIFT; }
"="             { yylval.str = strdup(yytext); return OP_ASSIGN; }
";"             { yylval.str = strdup(yytext); return SEMICOLON; }
","             { yylval.str = strdup(yytext); return COMMA; }
"("             { yylval.str = strdup(yytext); return OPEN_PARENTHESIS; }
")"             { yylval.str = strdup(yytext); return CLOSE_PARENTHESIS; }
"{"             { yylval.str = strdup(yytext); return OPEN_CURLY_BRACKET; }
"}"             { yylval.str = strdup(yytext); return CLOSE_CURLY_BRACKET; }
"["             { yylval.str = strdup(yytext); return OPEN_BRACKET; }
"]"             { yylval.str = strdup(yytext); return CLOSE_BRACKET; }
":"             { yylval.str = strdup(yytext); return COLON; }
"."             { yylval.str = strdup(yytext); return DOT; }

[$@#`\]           { 
    fprintf(stderr, "Lexical Error at line %d: Illegal character '%s'\n", yylineno, yytext);
    num_errors++;
    return ERROR_TOKEN;
}

.               { 
    fprintf(stderr, "Lexical Error at line %d: Invalid token '%s'\n", yylineno, yytext);
    num_errors++;
    return ERROR_TOKEN;
}

%%