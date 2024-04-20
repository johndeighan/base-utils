---
type: coffee
shebang: true
---
program
	lStmts:statement*
		return {
			type: 'File'
			program: {
				type: 'Program'
				body: lStmts
				}
			}
statement
	num:number
		return {
			type: 'ExpressionStatement'
			expression: num
			}
number
	[0-9]+ ('.' [0-9]*)?
		return {
			type: 'NumericLiteral'
			value: parseFloat(text())
			}

_
	" "
