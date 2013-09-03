grammar CFML;

// Parser Rules
// ============

block : (cfcomment | tagIf | tagLoop | tagScript | line)* ;
line : tagAbort | tagBreak | tagInclude | tagSet ;

/* `cfcomment` must be a parser rule, so that the listener will hear
about it, but it must be implemented as a lexer rule, so that it can
have higher precedence than the `WS` rule. */
cfcomment : CFCOMMENT ;

tagBreak : CFBREAK ;
tagIf : CFIF block tagElseIf* tagElse? ENDCFIF ;
tagElseIf : CFELSEIF block ;
tagElse : CFELSE block ;
tagInclude : CFINCLUDE 'template' '=' STRING_LITERAL TE ;
tagLoop : (tagLoopList | tagLoopArray | tagLoopFrom) ;
tagLoopArray : CFLOOP (ATR_ARRAY | ATR_INDEX)* TE block ENDCFLOOP ;
tagLoopFrom : CFLOOP (ATR_FROM | ATR_TO | ATR_INDEX | ATR_STEP)* TE block ENDCFLOOP ;
tagLoopList : CFLOOP (ATR_LIST | ATR_INDEX)* TE block ENDCFLOOP ;
tagScript : CFSCRIPT ;
tagSet : CFSET ;
tagAbort : CFABORT ;

// Lexer Rules
// ===========

CFCOMMENT : '<!---' .*? '--->' ;

// Tags with no attributes
CFABORT : TS 'abort' TE ;
CFBREAK : TS 'break' TE ;
CFIF : TS 'if' .*? TE ;
CFELSE : TS 'else' TE ;
CFELSEIF : TS 'elseif' .*? TE ;
CFSCRIPT : TS 'script' TE .*? ENDCFSCRIPT ;
CFSET : TS 'set' .*? TE ;

// Tags with attributes (notice lack of TE)
CFINCLUDE : TS 'include' ;
CFLOOP : TS 'loop' ;

// Closing tags
ENDCFIF : TC 'if' TE ;
ENDCFLOOP : TC 'loop' TE ;
ENDCFSCRIPT : TC 'script' TE ;

// Attributes
ATR_ARRAY : 'array' '=' STRING_LITERAL ;
ATR_FROM : 'from' '=' STRING_LITERAL ;
ATR_INDEX : 'index' '=' STRING_LITERAL ;
ATR_LIST : 'list' '=' STRING_LITERAL ;
ATR_STEP : 'step' '=' STRING_LITERAL ;
ATR_TO : 'to' '=' STRING_LITERAL ;

TE : '/'? '>' ; // Tag End

STRING_LITERAL
  : '"' DoubleStringCharacter* '"'
  | '\'' SingleStringCharacter* '\''
  ;

/*
Lexer Rules: Skips
------------------

Skip whitespace (spaces, tabs, newlines, and formfeeds) unless
a rule above consumes it first.  Skip <cfsilent> because cfscript
is always silent.
*/

WS : [ \t\r\n\f]+ -> skip ;
CFSILENT : (TS | TC) 'silent' TE -> skip ;

// Lexer Fragments
// ===============

fragment DoubleStringCharacter
  : ~('"')
  | '""'
  ;

fragment SingleStringCharacter
  : ~('\'')
  | '\'\''
  ;

fragment TC : '</cf' ; // Tag Close
fragment TS : '<cf' ; // Tag Start
