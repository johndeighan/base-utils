cmdargs
  = ident
  / option

ident = id: [A-Za-z_] [A-Za-z0-9_]*   {return id}
option = opt:\- ident (= value)?

additive
  = left:multiplicative "+" right:additive { return left + right; }
  / multiplicative

multiplicative
  = left:primary "*" right:multiplicative { return left * right; }
  / primary

primary
  = integer
  / "(" additive:additive ")" { return additive; }

integer "simple number"
  = digits:[0-9]+ { return parseInt(digits.join(""), 10); }
