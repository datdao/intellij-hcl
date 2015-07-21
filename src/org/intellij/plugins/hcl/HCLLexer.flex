package org.intellij.plugins.hcl;
import com.intellij.lexer.*;
import com.intellij.psi.tree.IElementType;
import java.util.EnumSet;
import static org.intellij.plugins.hcl.HCLElementTypes.*;
import static com.intellij.psi.TokenType.BAD_CHARACTER;

%%

%public
%class _HCLLexer
%implements FlexLexer
%function advance
%type IElementType
%unicode

EOL="\r"|"\n"|"\r\n"
LINE_WS=[\ \t\f]
WHITE_SPACE=({LINE_WS}|{EOL})+

LINE_COMMENT=("//".*)|(#.*)
BLOCK_COMMENT="/"\*([^*]|\*[^/])*\*?(\*"/")?
NUMBER=-?(0x)?(0|[1-9])[0-9]*(\.[0-9]+)?([eE][-+]?[0-9]+)?
ID=[a-zA-Z\.\-_][0-9a-zA-Z\.\-_]*

TIL_START=(\$\{)
TIL_STOP=(\})
TIL_ELEMENT=([^\"\'\r\n\$\{\}]|\\[^\r\n])*

%state D_STRING, S_STRING, TIL_EXPRESSION, IN_NUMBER
%{
  // This parameters can be getted from capabilities
    private boolean withNumbersWithBytesPostfix;
    private boolean withInterpolationLanguage;

    public _HCLLexer(EnumSet<HCLCapability> capabilities) {
      this((java.io.Reader)null);
      this.withNumbersWithBytesPostfix = capabilities.contains(HCLCapability.NUMBERS_WITH_BYTES_POSTFIX);
      this.withInterpolationLanguage = capabilities.contains(HCLCapability.INTERPOLATION_LANGUAGE);
    }
    enum StringType {
      None, SingleQ, DoubleQ
    }
  // State data
    StringType stringType = StringType.None;
    int stringStart = -1;
    int til = 0;

    private void til_inc() {
      til++;
    }
    private int til_dec() {
      assert til > 0;
      til--;
      return til;
    }

%}

%%

<D_STRING> {
   {TIL_START} { if (withInterpolationLanguage) {til_inc(); yybegin(TIL_EXPRESSION);} }
   \"          { yybegin(YYINITIAL); stringType = StringType.None; zzStartRead = stringStart; return DOUBLE_QUOTED_STRING; }
   {TIL_ELEMENT} {;}
   \$ {;}
   \{ {;}
   \} {;}
   \' {;}
   [^] { return BAD_CHARACTER; }
}

<S_STRING> {
   {TIL_START} { if (withInterpolationLanguage) {til_inc(); yybegin(TIL_EXPRESSION);} }
   \'          { yybegin(YYINITIAL); stringType = StringType.None; zzStartRead = stringStart; return SINGLE_QUOTED_STRING; }
   {TIL_ELEMENT} {;}
   \$ {;}
   \{ {;}
   \} {;}
   \" {;}
   [^] { return BAD_CHARACTER; }
}


<TIL_EXPRESSION> {
  {TIL_START} {til_inc();}
  {TIL_STOP} {if (til_dec() <= 0) yybegin(stringType == StringType.SingleQ ? S_STRING: D_STRING); }
  {TIL_ELEMENT} {;}
  \' {}
  \" {}
  \$ {}
  \{ {}
  \} {}
  [^] { return BAD_CHARACTER; }
}



<YYINITIAL>   \"  { stringType = StringType.DoubleQ; stringStart = zzStartRead; yybegin(D_STRING); }
<YYINITIAL>   \'  { stringType = StringType.SingleQ; stringStart = zzStartRead; yybegin(S_STRING); }

<YYINITIAL> {
  {WHITE_SPACE}               { return com.intellij.psi.TokenType.WHITE_SPACE; }

  "["                         { return L_BRACKET; }
  "]"                         { return R_BRACKET; }
  "{"                         { return L_CURLY; }
  "}"                         { return R_CURLY; }
  ","                         { return COMMA; }
  "="                         { return EQUALS; }
  "true"                      { return TRUE; }
  "false"                     { return FALSE; }
  "null"                      { return NULL; }

  {LINE_COMMENT}              { return LINE_COMMENT; }
  {BLOCK_COMMENT}             { return BLOCK_COMMENT; }
  {NUMBER}                    { if (!withNumbersWithBytesPostfix) return NUMBER;
                                yybegin(IN_NUMBER); yypushback(yylength());}
  {ID}                        { return ID; }

  [^] { return BAD_CHARACTER; }
}

<IN_NUMBER> {
  {NUMBER} ([(kKmMgG]b?) { yybegin(YYINITIAL); return NUMBER; }
  {NUMBER} { yybegin(YYINITIAL); return NUMBER; }
}