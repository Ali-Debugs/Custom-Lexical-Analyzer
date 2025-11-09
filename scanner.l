%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// keeping track of where we are in the file
int line_num = 1;
int token_count = 0;
int error_count = 0;
int column_num = 1;
int last_line_length = 0;

FILE* token_file;
FILE* error_file;

void print_token(const char* type, const char* lexeme) {
    fprintf(token_file, "Line %d: %s -> %s\n", line_num, type, lexeme);
    token_count++;
    column_num += strlen(lexeme);
}

void print_error(const char* lexeme) {
    fprintf(token_file, "Line %d: ERROR -> %s\n", line_num, lexeme);
    fprintf(error_file, "Line %d, ERROR -> %s (Invalid token)\n", 
            line_num, lexeme);
    error_count++;
    column_num += strlen(lexeme);
}

void print_unterminated_error(const char* type, int start_line) {
    fprintf(error_file, "Line %d: ERROR -> Unterminated %s\n", start_line, type);
    error_count++;
}
%}

/* regex patterns for tokens */
DIGIT           [0-9]
LETTER          [a-zA-Z]

/* special characters that aren't allowed in identifiers */
SPECIAL_CHAR    [@%_#&\?\~\`\:!\^\\\$\{\}\[\];,\.\*\/\+\-\=\<\>\|]

/* any identifier-like token that contains special characters anywhere */
/* This catches: @test, test@, te@st, test_var, 5test, etc. */
INVALID_IDENTIFIER  ([a-zA-Z0-9]*{SPECIAL_CHAR}[a-zA-Z0-9]*)+|{DIGIT}+[a-zA-Z][a-zA-Z0-9]*

/* proper identifier: starts with a letter (lowercase or uppercase), can include digits */
IDENTIFIER      [a-zA-Z][a-zA-Z0-9]*

/* number types */
INTEGER         [+/-]?{DIGIT}+
FLOAT           [+/-]?{DIGIT}+\.{DIGIT}+
EXPONENTIAL     [+/-]?({INTEGER}|{FLOAT})[eE][+-]?{DIGIT}+

/* inproper numbers */
INVALID_FLOAT_START    [+/-]?\.{DIGIT}+
INVALID_FLOAT_END      [+/-]?{DIGIT}+\.
INVALID_EXP            [+/-]?({DIGIT}+|{DIGIT}+\.{DIGIT}*)[eE][+-]?

WHITESPACE      [ \t]+
NEWLINE         \n

/* strings and chars with escape sequences */
STRING          \"([^\"\n\\]|\\.)*\"
CHAR            \'([^\'\n\\]|\\.)\'

/* forgot to close the quote */
UNTERM_STRING   \"([^\"\n\\]|\\.)*
UNTERM_CHAR     \'([^\'\n\\]|\\.)*

/* comments */
SINGLE_COMMENT  "//".*
MULTI_COMMENT   "/*"([^*]|\*+[^*/])*\*+"/"
UNTERM_MULTI_COMMENT  "/*"([^*]|\*+[^*/])*

/* incomplete operators */
INVALID_OP      "#"[^=+\-!]|"#"

%x IN_COMMENT

%%

    /* Harry Potter themed keywords */
"numspell"          { print_token("KEYWORD", yytext); }
"textspell"         { print_token("KEYWORD", yytext); }
"floatspell"        { print_token("KEYWORD", yytext); }
"truthcharm"        { print_token("KEYWORD", yytext); }
"voidcharm"         { print_token("KEYWORD", yytext); }
"beginmagic"        { print_token("KEYWORD", yytext); }
"returncharm"       { print_token("KEYWORD", yytext); }
"house"             { print_token("KEYWORD", yytext); }
"ifcharm"           { print_token("KEYWORD", yytext); }
"elsecharm"         { print_token("KEYWORD", yytext); }
"loopcharm"         { print_token("KEYWORD", yytext); }
"spellcycle"        { print_token("KEYWORD", yytext); }
"breakcurse"        { print_token("KEYWORD", yytext); }
"skipcurse"         { print_token("KEYWORD", yytext); }
"reveal"            { print_token("KEYWORD", yytext); }
"listen"            { print_token("KEYWORD", yytext); }

    /* operators - multi-char first to avoid conflicts */
"#="                { print_token("OPERATOR", yytext); }
"#+"                { print_token("OPERATOR", yytext); }
"#-"                { print_token("OPERATOR", yytext); }
"#!"                { print_token("OPERATOR", yytext); }
"<="                { print_token("OPERATOR", yytext); }
">="                { print_token("OPERATOR", yytext); }
"=="                { print_token("OPERATOR", yytext); }
"!="                { print_token("OPERATOR", yytext); }
"&&"                { print_token("OPERATOR", yytext); }
"||"                { print_token("OPERATOR", yytext); }

"+"                 { print_token("OPERATOR", yytext); }
"-"                 { print_token("OPERATOR", yytext); }
"*"                 { print_token("OPERATOR", yytext); }
"/"                 { print_token("OPERATOR", yytext); }
"%"                 { print_token("OPERATOR", yytext); }
"="                 { print_token("OPERATOR", yytext); }
"<"                 { print_token("OPERATOR", yytext); }
">"                 { print_token("OPERATOR", yytext); }
"!"                 { print_token("OPERATOR", yytext); }
"&"                 { print_token("OPERATOR", yytext); }
"|"                 { print_token("OPERATOR", yytext); }

    /* punctuation marks */
"$"                 { print_token("PUNCTUATOR", yytext); }
"{"                 { print_token("PUNCTUATOR", yytext); }
"}"                 { print_token("PUNCTUATOR", yytext); }
"("                 { print_token("PUNCTUATOR", yytext); }
")"                 { print_token("PUNCTUATOR", yytext); }
"["                 { print_token("PUNCTUATOR", yytext); }
"]"                 { print_token("PUNCTUATOR", yytext); }
";"                 { print_token("PUNCTUATOR", yytext); }
","                 { print_token("PUNCTUATOR", yytext); }
"."                 { print_token("PUNCTUATOR", yytext); }

    /* numbers - order matters here */
{EXPONENTIAL}       { print_token("NUMBER_EXP", yytext); }
{FLOAT}             { print_token("NUMBER_FLOAT", yytext); }
{INTEGER}           { print_token("NUMBER_INT", yytext); }

{INVALID_FLOAT_START}   { print_error(yytext); }
{INVALID_FLOAT_END}     { print_error(yytext); }
{INVALID_EXP}           { print_error(yytext); }

{STRING}            { print_token("STRING_LITERAL", yytext); }
{CHAR}              { print_token("CHAR_LITERAL", yytext); }

    /* unclosed strings/chars */
{UNTERM_STRING}     { 
                        print_error(yytext); 
                        fprintf(error_file, "Line %d: WARNING -> Unterminated string literal\n", line_num);
                    }
{UNTERM_CHAR}       { 
                        print_error(yytext); 
                        fprintf(error_file, "Line %d: WARNING -> Unterminated character literal\n", line_num);
                    }

    /* skip comments but count lines in multi-line ones */
{SINGLE_COMMENT}    { column_num += strlen(yytext); }
{MULTI_COMMENT}     { 
                        int i;
                        for (i = 0; yytext[i] != '\0'; i++) {
                            if (yytext[i] == '\n') {
                                line_num++;
                                column_num = 1;
                            } else {
                                column_num++;
                            }
                        }
                    }
{UNTERM_MULTI_COMMENT}  {
                            int start_line = line_num;
                            int i;
                            for (i = 0; yytext[i] != '\0'; i++) {
                                if (yytext[i] == '\n') line_num++;
                            }
                            print_unterminated_error("multi-line comment", start_line);
                        }

    /* check for bad identifiers before accepting good ones */
{INVALID_IDENTIFIER}      { print_error(yytext); }

{IDENTIFIER}        { print_token("IDENTIFIER", yytext); }

{INVALID_OP}        { print_error(yytext); }

{WHITESPACE}        { column_num += strlen(yytext); }

{NEWLINE}           { 
                        line_num++; 
                        last_line_length = column_num;
                        column_num = 1; 
                    }

.                   { print_error(yytext); }

<<EOF>>             { return 0; }

%%

int yywrap() {
    return 1;
}

int main(int argc, char** argv) {
    FILE* input_file;
    
    if (argc < 2) {
        printf("Usage: %s <input_file>\n", argv[0]);
        printf("Output will be saved to tokens.txt and errors.log\n");
        return 1;
    }
    
    input_file = fopen(argv[1], "r");
    if (!input_file) {
        printf("Error: Cannot open input file '%s'\n", argv[1]);
        perror("Reason");
        return 1;
    }
    
    token_file = fopen("tokens.txt", "w");
    if (!token_file) {
        printf("Error: Cannot create tokens.txt\n");
        perror("Reason");
        fclose(input_file);
        return 1;
    }
    
    error_file = fopen("errors.log", "w");
    if (!error_file) {
        printf("Error: Cannot create errors.log\n");
        perror("Reason");
        fclose(input_file);
        fclose(token_file);
        return 1;
    }
    
    yyin = input_file;
    
    fprintf(token_file, "===============================================\n");
    fprintf(token_file, "  Ali'S LEXICAL ANALYZER\n");
    fprintf(token_file, "  Tokenization Output\n");
    fprintf(token_file, "===============================================\n\n");
    
    fprintf(error_file, "===============================================\n");
    fprintf(error_file, "  ERROR LOG\n");
    fprintf(error_file, "  Ali's Lexical Analyzer\n");
    fprintf(error_file, "===============================================\n\n");
    
    yylex();
    
    int actual_lines = line_num;
    
    fprintf(token_file, "\n===============================================\n");
    fprintf(token_file, "  TOKENIZATION SUMMARY\n");
    fprintf(token_file, "===============================================\n");
    fprintf(token_file, "Total lines processed: %d\n", actual_lines);
    fprintf(token_file, "Total tokens recognized: %d\n", token_count);
    fprintf(token_file, "Total errors found: %d\n", error_count);
    fprintf(token_file, "===============================================\n");
    
    if (error_count == 0) {
        fprintf(error_file, "No errors found! ✓\n");
        fprintf(error_file, "All tokens were successfully recognized.\n");
    } else {
        fprintf(error_file, "\n===============================================\n");
        fprintf(error_file, "  ERROR SUMMARY\n");
        fprintf(error_file, "===============================================\n");
        fprintf(error_file, "Total errors found: %d\n", error_count);
        fprintf(error_file, "===============================================\n");
        fprintf(error_file, "\nCommon causes:\n");
        fprintf(error_file, "  - Invalid characters (@, #, ~, `)\n");
        fprintf(error_file, "  - Special characters in middle of identifiers\n");
        fprintf(error_file, "  - Digit-prefixed identifiers\n");
        fprintf(error_file, "  - Underscores in identifiers\n");
        fprintf(error_file, "  - Bad number formats (.5, 5., 5e)\n");
        fprintf(error_file, "  - Unclosed strings/chars\n");
        fprintf(error_file, "  - Unclosed comments\n");
        fprintf(error_file, "  - Unknown symbols\n");
    }
    
    fclose(input_file);
    fclose(token_file);
    fclose(error_file);
    
    printf("\n===============================================\n");
    printf("  LEXICAL ANALYSIS COMPLETED\n");
    printf("===============================================\n");
    printf("Input file: %s\n", argv[1]);
    printf("Output files created:\n");
    printf("  - tokens.txt (all tokens and errors)\n");
    printf("  - errors.log (error details only)\n");
    printf("\n");
    printf("Total lines processed: %d\n", actual_lines);
    printf("Total tokens recognized: %d\n", token_count);
    printf("Total errors found: %d\n", error_count);
    printf("===============================================\n");
    
    if (error_count == 0) {
        printf("SUCCESS: No errors were found!\n");
    } else {
        printf("WARNING: %d errors are detected. Check errors.log for details\n", error_count);
    }
    printf("===============================================\n\n");
    
    return (error_count == 0) ? 0 : 1;
}