grammar CFML;

// Parser Rules
// ============

block : (blockTag | lineTag)* ;

blockTag
  : cfcomment
  | tagFunction
  | tagIf
  | tagLoop
  | tagScript
  | tagSwitch
  | tagTry
  ;

lineTag
  : tagAbort
  | tagBreak
  | tagInclude
  | tagParam
  | tagRethrow
  | tagSet
  | tagThrow
  ;

/* `cfcomment` must be a parser rule, so that the listener will hear
about it, but it must be implemented as a lexer rule, so that it can
have higher precedence than the `WS` rule. */
cfcomment : CFCOMMENT ;

tagBreak : CFBREAK ;
tagIf : CFIF block tagElseIf* tagElse? ENDCFIF ;
tagElseIf : CFELSEIF block ;
tagElse : CFELSE block ;
tagFinally  : CFFINALLY block ENDCFFINALLY ;
tagInclude : CFINCLUDE 'template' '=' STRING_LITERAL TE ;
tagLoop : (tagLoopList | tagLoopArray | tagLoopFrom) ;
tagLoopArray : CFLOOP (ATR_ARRAY | ATR_INDEX)* TE block ENDCFLOOP ;
tagLoopFrom : CFLOOP (ATR_FROM | ATR_TO | ATR_INDEX | ATR_STEP)* TE block ENDCFLOOP ;
tagLoopList : CFLOOP (ATR_LIST | ATR_INDEX)* TE block ENDCFLOOP ;
tagParam : CFPARAM ;
tagScript : CFSCRIPT ;
tagSet : CFSET ;
tagThrow : CFTHROW ;
tagAbort : CFABORT ;
tagTry : CFTRY block tagCatch* tagFinally? ENDCFTRY ;
tagCatch : CFCATCH ('type' '=' STRING_LITERAL)? TE block ENDCFCATCH ;
tagRethrow : CFRETHROW ;

tagSwitch : CFSWITCH 'expression' '=' STRING_LITERAL TE tagCase* tagDefaultCase? ENDCFSWITCH ;
tagCase   : CFCASE 'value' '=' STRING_LITERAL TE block ENDCFCASE ;
tagDefaultCase : CFDEFAULTCASE block ENDCFDEFAULTCASE ;

tagFunction
  : CFFUNCTION
  (
      ATR_NAME
      | ATR_RETURNTYPE
      | ATR_OUTPUT
      | ATR_ACCESS
  )*
  TE
  block
  tagReturn?
  ENDCFFUNCTION
  ;

tagReturn : CFRETURN ;

// Lexer Rules
// ===========

CFCOMMENT : '<!---' .*? '--->' ;

// Tags with no attributes or expressions
CFABORT     : TS 'abort' TE ;
CFBREAK     : TS 'break' TE ;
CFDEFAULTCASE : TS 'defaultcase' TE ;
CFELSE      : TS 'else' TE ;
CFFINALLY   : TS 'finally' TE ;
CFRETHROW   : TS 'rethrow' TE ;
CFTRY       : TS 'try' TE ;

// Tags with expressions
CFIF        : TS 'if' .*? TE ;
CFELSEIF    : TS 'elseif' .*? TE ;
CFRETURN    : TS 'return' .*? TE ;
CFSET       : TS 'set' .*? TE ;

// Tags with attributes
CFCASE      : TS 'case' ;
CFCATCH     : TS 'catch' ;
CFFUNCTION  : TS 'function' ;
CFINCLUDE   : TS 'include' ;
CFLOOP      : TS 'loop' ;
CFPARAM     : TS 'param' .*? TE ;
CFSWITCH    : TS 'switch' ;
CFTHROW     : TS 'throw' .*? TE ;

// Tags with unparsed blocks
CFSCRIPT    : TS 'script' TE .*? ENDCFSCRIPT ;

// Closing tags
ENDCFCASE   : TC 'case' TE ;
ENDCFCATCH  : TC 'catch' TE ;
ENDCFDEFAULTCASE : TC 'defaultcase' TE ;
ENDCFFINALLY : TC 'finally' TE ;
ENDCFFUNCTION : TC 'function' TE ;
ENDCFIF     : TC 'if' TE ;
ENDCFLOOP   : TC 'loop' TE ;
ENDCFSCRIPT : TC 'script' TE ;
ENDCFSWITCH : TC 'switch' TE ;
ENDCFTRY    : TC 'try' TE ;

// Attributes
ATR_ACCESS      : 'access'      '=' STRING_LITERAL ;
ATR_ARRAY       : 'array'       '=' STRING_LITERAL ;
ATR_FROM        : 'from'        '=' STRING_LITERAL ;
ATR_INDEX       : 'index'       '=' STRING_LITERAL ;
ATR_LIST        : 'list'        '=' STRING_LITERAL ;
ATR_NAME        : 'name'        '=' STRING_LITERAL ;
ATR_OUTPUT      : 'output'      '=' STRING_LITERAL ;
ATR_RETURNTYPE  : 'returntype'  '=' STRING_LITERAL ;
ATR_STEP        : 'step'        '=' STRING_LITERAL ;
ATR_TO          : 'to'          '=' STRING_LITERAL ;

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