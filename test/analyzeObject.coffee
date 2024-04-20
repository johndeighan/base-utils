# analyzeObject.coffee

import {
	undef, pass, isClass, analyzeObj,
	} from '@jdeighan/base-utils'
import {
	TextTable,
	} from '@jdeighan/base-utils/text-table'

tt = new TextTable("l l r r r r r r r")
tt.fullsep '-'
tt.labels [
	'obj'
	'type'
	'def'
	'empty'
	'constr'
	'proto'
	'proto con'
	'con class'
	'pro class'
	]
tt.sep '-'

flag = (bool) => if bool then 'YES' else 'NO'

# ---------------------------------------------------------------------------

addObj = (obj, label) =>

	h = analyzeObj obj
	tt.data([
		label
		h.type
		flag(h.defined)
		flag(h.empty)
		flag(h.hasConstructor)
		flag(h.hasPrototype)
		flag(h.prototypeHasConstructor)
		flag(h.constructorIsClass)
		flag(h.prototypeConstructorIsClass)
		])
	return

# ---------------------------------------------------------------------------

class NewClass
	constructor: (@name = 'bob') ->
		@doIt = pass()
	meth: (x) ->
		return 2 * x

generatorFunc = () ->
	yield 1
	yield 2
	yield 3
	return


addObj undef, 'undef'
addObj null, 'null'
addObj true, 'true'
addObj false, 'false'
addObj {}, '{}'
addObj [], '[]'
addObj {a:1}, '{a:1}'
addObj [1,2], '[1,2]'
addObj NewClass, 'NewClass'
addObj new NewClass(), 'new NewClass()'
addObj 42, '42'
addObj 3.14, '3.14'
addObj new Number(42), 'new Number(42)'
addObj BigInt(42), 'BigInt(42)'
addObj 'abc', "'abc'"
addObj new String('abc'), "new String('abc')"
addObj (() -> return 3), "() -> return 3"
addObj (() => return 3), "() => return 3"
addObj /^ab$/, "/^ab$/"

# addObj generatorFunc, 'generatorFunc'
# addObj generatorFunc(), 'generatorFunc()'

tt.close(true)
tt.dumpInternals()

console.log tt.asString()
