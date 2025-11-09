# Custom-Lexical-Analyzer

Harry Potter-Themed Lexical Analyzer<br>

About:<br>
•	A lexical analyzer for a Harry Potter–themed programming language.<br>
•	Recognizes keywords, identifiers, numbers, operators, strings, characters, and comments.<br>
•	Detects lexical errors like invalid identifiers, invalid numbers, or unclosed strings/comments.<br>
•	Logs tokens in tokens.txt and errors in errors.log.<br>

Key Features:<br>
•	Fun, thematic keywords: numspell, textspell, beginmagic, truthcharm, etc.<br>
•	Supports integers, floats, exponential numbers, strings, characters, and comments.<br>
•	Provides line and column info for all errors.<br>
•	Demonstrates regex-based tokenization and error handling.<br>

Usage:<br>
flex scanner.l<br>
gcc lex.yy.c -o scanner<br>
./scanner test.txt<br>

Outputs:<br>
•	tokens.txt → recognized tokens.<br>
•	errors.log → detailed lexical errors.<br>

