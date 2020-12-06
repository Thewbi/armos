grammar gcc_as;

program:
	(
	newline
	| line WS* newline
	| line WS* comment
	| comment
	| multiline_comment WS*)+
	EOF
	;

line:
	(
	preprocessor
	| directive
	| instruction 
	| label
	| label WS* (directive)?
	)
	;
	
comment: 
	(WS)* ('@' | ';' | '/''/') ~( '\n' )*
  	;
  	
multiline_comment:
    (WS)* '/*' .*? '*/'
    ;

expr:	
    expr WS* ('<''<' | '|' | '=''=') WS* expr
	| expr WS* ('*'|'/') WS* expr
    | expr WS* ('+'|'-') WS* expr
    | '#'? numeric_literal
    | Identifier
    | '#'? '(' WS* expr WS* ')'
    ;
    
label:
//	'.'? Identifier WS* ':' WS* (directive)?
    '.'? Identifier WS* ':'
	;
	
instruction:
	(WS)* Identifier (WS* param_list)?
	;
	
preprocessor:
	'#' Identifier (WS* param_list)?
	;
    
directive:
	(WS)* '.' (INT)? Identifier (WS+ param_list)?
	;
	
param_list:
	param (','? WS* param)*
	;
	
param:
    '[' WS* param_list WS* ']'
    |'{' WS* param_list WS* '}'
	| expr
    | Identifier '!'?
    | '.' WS* ('-')? Identifier
    | '#' WS* ('-')? Identifier
    | '%' WS* ('-')? Identifier
    | '=' WS* ('-')? Identifier
    | '=''#' WS* ('-')? Identifier
    | ('-')? numeric_literal
    | '#' WS* ('-')? numeric_literal
    | '=' WS* ('-')? numeric_literal
    | '=''#' WS* ('-')? numeric_literal
    | ('-')? StringLiteral
    ;
    
newline: 
	( '\r' '\n' )
	| ( '\n' ) 
	;
	
numeric_literal:
	INT
	| HEX
	;
	
INT: 
	DIGIT+
	;
	
HEX:
	'0' 'x' ([a-fA-F] | DIGIT)+
	;
	
DIGIT: 
	[0-9]
	;
	
QUOTE: 
	'"'
	;
	
AT_SIGN: 
	'@'
	;
	
EXCLAMATION_MARK: 
	'!'
	;
	
QUESTION_MARK: 
	'?'
	;
	
ELLIPSIS: 
	'…'
	;
	
OPENING_SQUARE_BRACKET: 
	'['
	;
	
CLOSEING_SQUARE_BRACKET: 
	']'
	;
	
OPENING_SQUIGGLY_BRACKET: 
	'{'
	;
	
CLOSEING_SQUIGGLY_BRACKET: 
	'}'
	;
	
GREATER_THAN: 
	'>'
	;
	
LESS_THAN: 
	'<'
	;
	
Identifier:
	(Letter | '_' ) (Letter | '_' | DIGIT)*
	;
	
Letter: 
	[a-zA-Z]
    ;
    
StringLiteral
  	: UnterminatedStringLiteral '"'
  	;

UnterminatedStringLiteral
  	: '"' (~["\\\r\n] | '\\' (. | EOF))*
  	;
  	
AMPERSAND:
   '&'
   ;
   
TICK:
    '\''
    ;
    
WS:   
	( 
	' '
    | '\t'
    | '\r'
    )
    ;
    