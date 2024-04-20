---
shebang: true
---
# analyzeObj.coffee

import {
	undef, defined, notdefined, pass, keys,
	analyzeObj, isString, isBoolean, truncateStr,
	} from '@jdeighan/base-utils'
import {
	TextTable,
	} from '@jdeighan/base-utils/text-table'

# ---------------------------------------------------------------------------

# --- analyzeObj always returns an object with
#     the same set of keys

hObj = analyzeObj(undef)
lKeys = keys(hObj)
numKeys = lKeys.length
console.log "numKeys = #{numKeys}"

tt = new TextTable("l" + " l".repeat(numKeys))
tt.fullsep '-'
tt.labels ['value', lKeys...]
tt.sep '-'

flag = (bool) => if bool then 'YES' else 'NO'

# ---------------------------------------------------------------------------

addObj = (obj, label) =>

	h = analyzeObj obj
	lValues = [ label ]
	for key in lKeys
		value = h[key]
		if notdefined(value)
			lValues.push ''
		else if isString(value)
			lValues.push value
		else if isBoolean(value)
			lValues.push flag(value)
		else
			throw new Error("Bad object")
	tt.data(lValues)
	return

# ---------------------------------------------------------------------------

class NewClass
	constructor: (@name = 'bob') ->
		@doIt = pass()
	meth: (x) ->
		return 2 * x

func = () ->
	return 42

arrow = () =>
	return 42

gen = () ->
	yield 1
	yield 2
	yield 3
	return

addObj undef, 'undef'
addObj null, 'null'

addObj true, 'true'
addObj false, 'false'

addObj 42, '42'
addObj 3.14, '3.14'
addObj BigInt(42), 'BigInt(42)'

addObj 'abc', "'abc'"

addObj NewClass, 'NewClass'
addObj (() -> return 3), "() -> return 3"
addObj `function func2(x) {return 42;}`, "function func2(x) {return 42;}"
addObj (() => return 3), "() => return 3"
addObj func, "func"
addObj arrow, "arrow"
addObj gen, 'gen'

addObj {}, '{}'
addObj [], '[]'
addObj {a:1}, '{a:1}'
addObj [1,2], '[1,2]'
addObj new NewClass(), 'new NewClass()'
addObj new Number(42), 'new Number(42)'
addObj new String('abc'), "new String('abc')"
addObj /^ab$/, "/^ab$/"
addObj new Promise((x) => 42), "new Promise((x) => 42)"

addObj gen(), 'gen()'

console.log tt.asString()
