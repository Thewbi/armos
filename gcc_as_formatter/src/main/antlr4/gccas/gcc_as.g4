grammar gcc_as;

program:
	(
        label? line 
	)+
	EOF
	;

line:
	(
    	preprocessor
    	| directive
    	| instruction 
    	
	)?
	(
        WS* multilineComment
    )?
	(
	    WS* comment
    )?
	(
	    WS* newline
	)
	;
	
comment: 
	(WS)* ('@' | ';' | '/''/') ~( '\n' )*
  	;
  	
multilineComment:
    (WS)* '/*' .*? '*/'
    ;

expr:	
    expr WS* ('<''<' | '|' | '=''=') WS* expr
	| expr WS* ('*'|'/') WS* expr
    | expr WS* ('+'|'-') WS* expr
    | '#'? numericLiteral
    | IDENTIFIER
    | '#'? '(' WS* expr WS* ')'
    ;
    
label:
    '.'? IDENTIFIER WS* ':'
	;
	
instruction:
	(WS)* IDENTIFIER (WS* paramList)?
	;
	
preprocessor:
	'#' IDENTIFIER (WS* paramList)?
	;
    
directive:
	(WS)* '.' (INT)? IDENTIFIER (WS+ paramList)?
	;
	
paramList:
	param (WS* ','? WS* param)*
	;
	
param:
    '[' WS* paramList WS* ']'
    |'{' WS* paramList WS* '}'
	| expr
    | IDENTIFIER '!'?
    | '.' WS* ('-')? IDENTIFIER
    | '#' WS* ('-')? IDENTIFIER
    | '%' WS* ('-')? IDENTIFIER
    | '=' WS* ('-')? IDENTIFIER
    | '=''#' WS* ('-')? IDENTIFIER
    | ('-')? numericLiteral
    | '#' WS* ('-')? numericLiteral
    | '=' WS* ('-')? numericLiteral
    | '=''#' WS* ('-')? numericLiteral
    | ('-')? STRING_LITERAL
    ;
    
newline: 
	( '\r' '\n' )
	| ( '\n' )
	| ( '\r' )
	;
	
numericLiteral:
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
	
IDENTIFIER:
	(LETTER | '_' ) (LETTER | '_' | DIGIT)*
	;
	
LETTER: 
	[a-zA-Z]
    ;
    
STRING_LITERAL
  	: UNTERMINATED_STRING_LITERAL '"'
  	;

UNTERMINATED_STRING_LITERAL
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
    