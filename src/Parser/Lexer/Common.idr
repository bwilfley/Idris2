module Parser.Lexer.Common

import public Text.Lexer

%default total

||| In `comment` we are careful not to parse closing delimiters as
||| valid comments. i.e. you may not write many dashes followed by
||| a closing brace and call it a valid comment.
export
comment : Lexer
comment
   =  is '-' <+> is '-'                  -- comment opener
  <+> many (is '-') <+> reject (is '}')  -- not a closing delimiter
  <+> many (isNot '\n')                  -- till the end of line

-- Identifier Lexer
-- There are multiple variants.

public export
data Flavour = Capitalised | AllowDashes | Normal

export
isIdentStart : Flavour -> Char -> Bool
isIdentStart _           '_' = True
isIdentStart Capitalised  x  = isUpper x || x > chr 160
isIdentStart _            x  = isAlpha x || x > chr 160

export
isIdentTrailing : Flavour -> Char -> Bool
isIdentTrailing AllowDashes '-'  = True
isIdentTrailing _           '\'' = True
isIdentTrailing _           '_'  = True
isIdentTrailing _            x   = isAlphaNum x || x > chr 160

export %inline
isIdent : Flavour -> String -> Bool
isIdent flavour string =
  case unpack string of
    []      => False
    (x::xs) => isIdentStart flavour x && all (isIdentTrailing flavour) xs

export %inline
ident : Flavour -> Lexer
ident flavour =
  (pred $ isIdentStart flavour) <+>
    (many . pred $ isIdentTrailing flavour)
