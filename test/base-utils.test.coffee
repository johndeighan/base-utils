# base-utils.test.coffee

import {
	UnitTester,
	equal, like, notequal, succeeds, fails, truthy, falsy,
	} from '@jdeighan/base-utils/utest'
import * as lib from '@jdeighan/base-utils'
Object.assign(global, lib)

equal  undef, undefined
succeeds () -> pass()
truthy pass()
truthy defined(1)
falsy  defined(undefined)
truthy notdefined(undefined)
falsy  notdefined(12)
succeeds () => pass()

# ---------------------------------------------------------------------------

truthy deepEqual({a:1, b:2}, {a:1, b:2})
falsy  deepEqual({a:1, b:2}, {a:1, b:3})

# ---------------------------------------------------------------------------

truthy isEmpty('')
truthy isEmpty('  \t\t')
truthy isEmpty([])
truthy isEmpty({})

truthy nonEmpty('a')
truthy nonEmpty('.')
truthy nonEmpty([2])
truthy nonEmpty({width: 2})

# ---------------------------------------------------------------------------

a = undef
b = null
c = 42
d = 'dog'
e = {a: 42}

truthy alldefined(c,d,e)
falsy  alldefined(a,b,c,d,e)
falsy  alldefined(a,c,d,e)
falsy  alldefined(b,c,d,e)
equal  deepCopy(e), {a: 42}

# ---------------------------------------------------------------------------

equal    {a:1, b:2}, {a:1, b:2}
notequal {a:1, b:2}, {a:1, b:3}

# ---------------------------------------------------------------------------

truthy isHashComment('   # something')
truthy isHashComment('   #')
falsy  isHashComment('   abc')
falsy  isHashComment('#abc')

truthy isFunction(pass)

passTest = () =>
	pass()
succeeds(passTest)

truthy defined('')
truthy defined(5)
truthy defined([])
truthy defined({})
falsy  defined(undef)
falsy  defined(null)

truthy notdefined(undef)
truthy notdefined(null)
falsy  notdefined('')
falsy  notdefined(5)
falsy  notdefined([])
falsy  notdefined({})

# ---------------------------------------------------------------------------

equal splitPrefix("abc"),     ["", "abc"]
equal splitPrefix("\tabc"),   ["\t", "abc"]
equal splitPrefix("\t\tabc"), ["\t\t", "abc"]
equal splitPrefix(""),        ["", ""]
equal splitPrefix("\t\t\t"),  ["", ""]
equal splitPrefix("\t \t"),   ["", ""]
equal splitPrefix("   "),     ["", ""]

# ---------------------------------------------------------------------------

falsy  hasPrefix("abc")
truthy hasPrefix("   abc")

# ---------------------------------------------------------------------------

equal spaces(3), '   '
equal tabs(3), "\t\t\t"
equal centeredText('abc', 7), '  abc  '
equal centeredText('xyz', 11, 'char=-'), '--  xyz  --'

# ---------------------------------------------------------------------------

threeSpaces = spaces(3)
fourSpaces = spaces(4)

equal tabify("""
	first line
	#{threeSpaces}second line
	#{threeSpaces}#{threeSpaces}third line
	""", 3), """
	first line
	\tsecond line
	\t\tthird line
	"""

# ---------------------------------------------------------------------------
# you don't need to tell it number of spaces
# it knows from the 1st line that contains spaces

equal tabify("""
	first line
	#{threeSpaces}second line
	#{threeSpaces}#{threeSpaces}third line
	"""), """
	first line
	\tsecond line
	\t\tthird line
	"""

equal tabify("""
	first line
	#{fourSpaces}second line
	#{fourSpaces}#{fourSpaces}third line
	"""), """
	first line
	\tsecond line
	\t\tthird line
	"""

# ---------------------------------------------------------------------------

equal untabify("""
	first line
	\tsecond line
	\t\tthird line
	""", 3), """
	first line
	#{threeSpaces}second line
	#{threeSpaces}#{threeSpaces}third line
	"""

# ---------------------------------------------------------------------------

equal untabify("""
	first line
	\tsecond line
	\t\tthird line
	""", 4), """
	first line
	#{fourSpaces}second line
	#{fourSpaces}#{fourSpaces}third line
	"""

# ---------------------------------------------------------------------------

equal prefixBlock("""
	abc
	def
	""", '--'), """
	--abc
	--def
	"""

# ---------------------------------------------------------------------------

equal escapeStr("   XXX\n"),  "˳˳˳XXX▼"
equal escapeStr("\t ABC\n"),  "→˳ABC▼"
equal escapeStr("X\nX\nX\n"), "X▼X▼X▼"
equal escapeStr("XXX\n\t\t"), "XXX▼→→"
equal escapeStr("XXX\n  "),   "XXX▼˳˳"

(() =>
	t = new UnitTester()
	t.transformValue = (str) => escapeStr(str)

	t.equal "   XXX\n",  "˳˳˳XXX▼"
	t.equal "\t ABC\n",  "→˳ABC▼"
	t.equal "X\nX\nX\n", "X▼X▼X▼"
	t.equal "XXX\n\t\t", "XXX▼→→"
	t.equal "XXX\n  ",   "XXX▼˳˳"
	)()

hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}

equal escapeStr("\thas quote: \"\nnext line", hEsc),
	"\\thas quote: \\\"\\nnext line"

# ---------------------------------------------------------------------------

equal OL(undef), "undef"
equal OL("\t\tabc\nxyz"), "'→→abc▼xyz'"
equal OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

equal OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}'

# ---------------------------------------------------------------------------

equal OLS(['abc', 3]), "'abc',3"
equal OLS([]), ""
equal OLS([undef, {a:1}]), 'undef,{"a":1}'

# ---------------------------------------------------------------------------

truthy oneof('a', 'b', 'a', 'c')
falsy  oneof('a', 'b', 'c')

# ---------------------------------------------------------------------------
#        jsTypes:

(() ->
	class NewClass
		constructor: (@name = 'bob') ->
			@doIt = pass
		meth: (x) ->
			return 2 * x

	h = {a:1, b:2}
	l = [1,2,2]
	o = new NewClass()
	n = 42
	n2 = new Number(42)
	s = 'simple'
	s2 = new String('abc')

	falsy isString(undef)
	falsy isString(h)
	falsy isString(l)
	falsy isString(o)
	falsy isString(n)
	falsy isString(n2)

	truthy isString(s)
	truthy isString(s2)

	truthy isNonEmptyString('abc')
	truthy isNonEmptyString('abc def')
	falsy  isNonEmptyString('')
	falsy  isNonEmptyString('  ')

	truthy isIdentifier('abc')
	truthy isIdentifier('_Abc')
	falsy  isIdentifier('abc def')
	falsy  isIdentifier('abc-def')
	falsy  isIdentifier('class.method')

	truthy isFunctionName('abc')
	truthy isFunctionName('_Abc')
	falsy  isFunctionName('abc def')
	falsy  isFunctionName('abc-def')
	falsy  isFunctionName('D()')
	truthy isFunctionName('class.method')

	generatorFunc = () ->
		yield 1
		yield 2
		yield 3
		return

	truthy isIterable(generatorFunc())

	falsy  isNumber(undef)
	falsy  isNumber(null)
	truthy isNumber(NaN)
	falsy  isNumber(h)
	falsy  isNumber(l)
	falsy  isNumber(o)
	truthy isNumber(n)
	truthy isNumber(n2)
	falsy  isNumber(s)
	falsy  isNumber(s2)

	truthy isNumber(42.0, {min: 42.0})
	falsy  isNumber(42.0, {min: 42.1})
	truthy isNumber(42.0, {max: 42.0})
	falsy  isNumber(42.0, {max: 41.9})

	truthy isInteger(42)
	truthy isInteger(new Number(42))
	falsy  isInteger('abc')
	falsy  isInteger({})
	falsy  isInteger([])
	truthy isInteger(42, {min:  0})
	falsy  isInteger(42, {min: 50})
	truthy isInteger(42, {max: 50})
	falsy  isInteger(42, {max:  0})

	truthy isHash(h)
	falsy  isHash(l)
	falsy  isHash(o)
	falsy  isHash(n)
	falsy  isHash(n2)
	falsy  isHash(s)
	falsy  isHash(s2)

	falsy  isArray(h)
	truthy isArray(l)
	falsy  isArray(o)
	falsy  isArray(n)
	falsy  isArray(n2)
	falsy  isArray(s)
	falsy  isArray(s2)

	truthy isBoolean(true)
	truthy isBoolean(false)
	falsy  isBoolean(42)
	falsy  isBoolean("true")

	truthy isClass(NewClass)
	falsy  isClass(o)

	truthy isConstructor(NewClass)
	falsy  isConstructor(o)

	truthy isFunction(() -> 42)
	truthy isFunction(() => 42)
	falsy  isFunction(undef)
	falsy  isFunction(null)
	falsy  isFunction(42)
	falsy  isFunction(n)

	truthy isRegExp(/^abc$/)
	truthy isRegExp(///^ \s* where \s+ areyou $///)
	falsy  isRegExp(42)
	falsy  isRegExp('abc')
	falsy  isRegExp([1,'a'])
	falsy  isRegExp({a:1, b:'ccc'})
	falsy  isRegExp(undef)
	truthy isRegExp(/\.coffee/)

	falsy  isObject(h)
	falsy  isObject(l)
	truthy isObject(o)
	truthy isObject(o, ['name','doIt'])
	truthy isObject(o, "name doIt")
	falsy  isObject(o, ['name','doIt','missing'])
	falsy  isObject(o, "name doIt missing")
	falsy  isObject(n)
	falsy  isObject(n2)
	falsy  isObject(s)
	falsy  isObject(s2)
	truthy isObject(o, "name doIt")
	truthy isObject(o, "name doIt meth")
	truthy isObject(o, "name &doIt &meth")
	falsy  isObject(o, "&name")

	equal jsType(undef), [undef, undef]
	equal jsType(null),  [undef, 'null']
	equal jsType(s), ['string', undef]
	equal jsType(''), ['string', 'empty']
	equal jsType("\t\t"), ['string', 'empty']
	equal jsType("  "), ['string', 'empty']
	equal jsType(h), ['hash', undef]
	equal jsType({}), ['hash', 'empty']
	equal jsType(3.14159), ['number', undef]
	equal jsType(42), ['number', 'integer']
	equal jsType(true), ['boolean', undef]
	equal jsType(false), ['boolean', undef]
	equal jsType(h), ['hash', undef]
	equal jsType({}), ['hash', 'empty']
	equal jsType(l), ['array', undef]
	equal jsType([]), ['array', 'empty']
	equal jsType(/abc/), ['regexp', undef]

	func1 = (x) ->
		return

	func2 = (x) =>
		return

	# --- NOTE: regular functions can't be distinguished from constructors
	equal(jsType(func1), ['class', undef])
	equal jsType(() -> 42), ['class', undef]

	equal jsType(func2), ['function', 'func2']
	equal jsType(() => 42), ['function', undef]
	equal jsType(NewClass), ['class', undef]
	equal jsType(o), ['object', undef]
	)()

# ---------------------------------------------------------------------------

equal blockToArray(undef), []
equal blockToArray(''), []
equal blockToArray('a'), ['a']
equal blockToArray("a\nb"), ['a','b']
equal blockToArray("a\r\nb"), ['a','b']
equal blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	]

equal blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	]

equal blockToArray("abc\n\nxyz"), [
	'abc'
	''
	'xyz'
	]

# ---------------------------------------------------------------------------

equal toArray("abc\ndef"), ['abc','def']
equal toArray(['a','b']), ['a','b']

equal toArray(["a\nb","c\nd"]), ['a','b','c','d']

# ---------------------------------------------------------------------------

equal arrayToBlock(undef), ''
equal arrayToBlock([]), ''
equal arrayToBlock([undef]), ''
equal arrayToBlock(['a  ','b\t\t']), "a\nb"
equal arrayToBlock(['a','b','c']), "a\nb\nc"
equal arrayToBlock(['a',undef,'b','c']), "a\nb\nc"
equal arrayToBlock([undef,'a','b','c',undef]), "a\nb\nc"

# ---------------------------------------------------------------------------

equal toBlock(['abc','def']), "abc\ndef"
equal toBlock("abc\ndef"), "abc\ndef"

# ---------------------------------------------------------------------------

equal rtrim("abc"), "abc"
equal rtrim("  abc"), "  abc"
equal rtrim("abc  "), "abc"
equal rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

equal words(''), []
equal words('  \t\t'), []
equal words('a b c'), ['a', 'b', 'c']
equal words('  a   b   c  '), ['a', 'b', 'c']
equal words('a b', 'c d'), ['a', 'b', 'c', 'd']
equal words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word']

# ---------------------------------------------------------------------------

equal mkword('a', 'b', 'c'), 'abc'
equal mkword(['a','b','c']), 'abc'
equal mkword('a', ' ', 'c'), 'a c'
equal mkword(['a',' ','c']), 'a c'
equal mkword([null, ['4','2'], null]), '42'

# ---------------------------------------------------------------------------

truthy hasChar('abc', 'b')
falsy  hasChar('abc', 'x')
falsy  hasChar("\t\t", ' ')

# ---------------------------------------------------------------------------

equal quoted('abc'), "'abc'"
equal quoted('"abc"'), "'\"abc\"'"
equal quoted("'abc'"), "\"'abc'\""
equal quoted("'\"abc\"'"), "«'\"abc\"'»"
equal quoted("'\"<abc>\"'"), "«'\"<abc>\"'»"

# ---------------------------------------------------------------------------

equal getOptions(), {}
equal getOptions(undef, {x:1}), {x:1}
equal getOptions({x:1}, {x:3,y:4}), {x:1,y:4}
equal getOptions('asText'), {asText: true}
equal getOptions('!binary'), {binary: false}
equal getOptions('label=this'), {label: 'this'}
equal getOptions('width=42'), {width: 42}
equal getOptions('asText !binary label=this'), {
	asText: true
	binary: false
	label: 'this'
	}

# ---------------------------------------------------------------------------

equal range(3), [0,1,2]
equal rev_range(3), [2,1,0]

# ---------------------------------------------------------------------------

truthy isHashComment('#')
truthy isHashComment('# a comment')
truthy isHashComment('#\ta comment')
falsy  isHashComment('#comment')
falsy  isHashComment('')
falsy  isHashComment('a comment')

# ---------------------------------------------------------------------------

truthy isEmpty('')
truthy isEmpty('  \t\t')
truthy isEmpty([])
truthy isEmpty({})

truthy nonEmpty('a')
truthy nonEmpty('.')
truthy nonEmpty([2])
truthy nonEmpty({width: 2})

truthy isNonEmptyString('abc')
falsy  isNonEmptyString(undef)
falsy  isNonEmptyString('')
falsy  isNonEmptyString('   ')
falsy  isNonEmptyString("\t\t\t")
falsy  isNonEmptyString(5)

# ---------------------------------------------------------------------------

truthy oneof('a', 'a', 'b', 'c')
truthy oneof('b', 'a', 'b', 'c')
truthy oneof('c', 'a', 'b', 'c')
falsy  oneof('d', 'a', 'b', 'c')
falsy  oneof('x')

# ---------------------------------------------------------------------------

equal uniq([1,2,2,3,3]), [1,2,3]
equal uniq(['a','b','b','c','c']),['a','b','c']

# ---------------------------------------------------------------------------

equal rtrim("abc"), "abc"
equal rtrim("  abc"), "  abc"
equal rtrim("abc  "), "abc"
equal rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

equal words('a b c'), ['a', 'b', 'c']
equal words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

equal escapeStr("\t\tXXX\n"), "→→XXX▼"
hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}
equal escapeStr("\thas quote: \"\nnext line", hEsc), \
	"\\thas quote: \\\"\\nnext line"

# ---------------------------------------------------------------------------

equal rtrunc('/user/lib/.env', 5), '/user/lib'
equal ltrunc('abcdefg', 3), 'defg'

# ---------------------------------------------------------------------------

equal CWS("""
		abc
		def
				ghi
		"""), "abc def ghi"

# ---------------------------------------------------------------------------

equal trimArray(['', 'abc']), ['abc']
equal trimArray(['abc', '']), ['abc']
equal trimArray(['', '   ', 'abc', '', "\t"]), ['abc']

# ---------------------------------------------------------------------------

equal removeEmptyLines(['', 'abc', '']), ['abc']
equal removeEmptyLines([' ', 'abc', ' ']), ['abc']
equal removeEmptyLines(['\t', 'abc', '\n']), ['abc']

# ---------------------------------------------------------------------------

equal CWSALL("""
	one    line
	    second      line
	"""), """
	one line
	second line
	"""

equal CWSALL([
	'one    line'
	'    second      line'
	]), [
	'one line'
	'second line'
	]

equal CWSALL("""

	one    line
	    second      line

	"""), """
	one line
	second line
	"""

equal CWSALL([
	''
	'one    line'
	'    second      line'
	''
	]), [
	'one line'
	'second line'
	]

# ---------------------------------------------------------------------------

truthy isArrayOfStrings([])
truthy isArrayOfStrings(['a','b','c'])
truthy isArrayOfStrings(['a',undef, null, 'b'])

# ---------------------------------------------------------------------------

truthy isArrayOfArrays([])
truthy isArrayOfArrays([[], []])
truthy isArrayOfArrays([[1,2], []])
truthy isArrayOfArrays([[1,2,[1,2,3]], []])
truthy isArrayOfArrays([[1,2], undef, null, []])

falsy isArrayOfArrays({})
falsy isArrayOfArrays([1,2,3])
falsy isArrayOfArrays([[1,2,[3,4]], 4])
falsy isArrayOfArrays([[1,2,[3,4]], [], {a:1,b:2}])

truthy isArrayOfArrays([[1,2],[3,4],[4,5]], 2)
falsy  isArrayOfArrays([[1,2],[3],[4,5]], 2)
falsy  isArrayOfArrays([[1,2],[3,4,5],[4,5]], 2)

# ---------------------------------------------------------------------------

truthy isArrayOfHashes([])
truthy isArrayOfHashes([{}, {}])
truthy isArrayOfHashes([{a:1, b:2}, {}])
truthy isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}])
truthy isArrayOfHashes([{a:1, b:2}, undef, null, {}])

falsy isArrayOfHashes({})
falsy isArrayOfHashes([1,2,3])
falsy isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, 4])
falsy isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}, [1,2]])

# ---------------------------------------------------------------------------

(() ->
	class NewClass
		constructor: (@name = 'bob') ->
			pass
		doIt: () ->
			pass

	h = {a:1, b:2}
	l = [1,2,2]
	o = new NewClass()
	n = 42
	n2 = new Number(42)
	s = 'u'
	s2 = new String('abc')

	truthy isHash(h)
	falsy isHash(l)
	falsy isHash(o)
	falsy isHash(n)
	falsy isHash(n2)
	falsy isHash(s)
	falsy isHash(s2)

	falsy isArray(h)
	truthy isArray(l)
	falsy isArray(o)
	falsy isArray(n)
	falsy isArray(n2)
	falsy isArray(s)
	falsy isArray(s2)

	falsy isString(undef)
	falsy isString(h)
	falsy isString(l)
	falsy isString(o)
	falsy isString(n)
	falsy isString(n2)
	truthy isString(s)
	truthy isString(s2)

	falsy isObject(h)
	falsy isObject(l)
	truthy isObject(o)
	truthy isObject(o, ['name','doIt'])
	falsy isObject(o, ['name','doIt','missing'])
	falsy isObject(n)
	falsy isObject(n2)
	falsy isObject(s)
	falsy isObject(s2)

	falsy isNumber(h)
	falsy isNumber(l)
	falsy isNumber(o)
	truthy isNumber(n)
	truthy isNumber(n2)
	falsy isNumber(s)
	falsy isNumber(s2)

	truthy isNumber(42.0, {min: 42.0})
	falsy isNumber(42.0, {min: 42.1})
	truthy isNumber(42.0, {max: 42.0})
	falsy isNumber(42.0, {max: 41.9})
	)()

# ---------------------------------------------------------------------------

truthy isFunction(() -> pass)
falsy isFunction(23)

truthy isInteger(42)
truthy isInteger(new Number(42))
falsy isInteger('abc')
falsy isInteger({})
falsy isInteger([])
truthy isInteger(42, {min:  0})
falsy isInteger(42, {min: 50})
truthy isInteger(42, {max: 50})
falsy isInteger(42, {max:  0})

# ---------------------------------------------------------------------------

equal OL(undef), "undef"
equal OL("\t\tabc\nxyz"), "'→→abc▼xyz'"
equal OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

equal CWS("""
		a u
		error message
		"""), "a u error message"

# ---------------------------------------------------------------------------
# test isRegExp()

truthy isRegExp(/^abc$/)
truthy isRegExp(///^
		\s*
		where
		\s+
		areyou
		$///)
falsy isRegExp(42)
falsy isRegExp('abc')
falsy isRegExp([1,'a'])
falsy isRegExp({a:1, b:'ccc'})
falsy isRegExp(undef)

truthy isRegExp(/\.coffee/)

# ---------------------------------------------------------------------------

equal extractMatches("..3 and 4 plus 5", /\d+/g, parseInt),
	[3, 4, 5]
equal extractMatches("And This Is A String", /A/g), ['A','A']

# ---------------------------------------------------------------------------

truthy notdefined(undef)
truthy notdefined(null)
truthy defined('')
truthy defined(5)
truthy defined([])
truthy defined({})

falsy defined(undef)
falsy defined(null)
falsy notdefined('')
falsy notdefined(5)
falsy notdefined([])
falsy notdefined({})

# ---------------------------------------------------------------------------

truthy isIterable([])
truthy isIterable(['a','b'])

gen = () ->
	yield 1
	yield 2
	yield 3
	return

truthy isIterable(gen())

# ---------------------------------------------------------------------------

(() ->
	class MyClass
		constructor: (str) ->
			@mystr = str

	equal className(MyClass), 'MyClass'

	)()

# ---------------------------------------------------------------------------

equal getOptions('a b c'), {'a':true, 'b':true, 'c':true}
equal getOptions('abc'), {'abc':true}
equal getOptions({'a':true, 'b':false, 'c':42}), {'a':true, 'b':false, 'c':42}
equal getOptions(), {}

# ---------------------------------------------------------------------------
# --- test forEachLine

(() =>
	lResult = []
	block = """
		abc
		def
		ghi
		"""
	forEachLine block, (line) =>
		lResult.push line.toUpperCase()
		return false
	equal lResult, ['ABC','DEF', 'GHI']
	)()

(() =>
	lResult = []
	block = """
		abc
		def
		ghi
		"""
	forEachLine block, (line) =>
		if (line == 'ghi')
			return true
		lResult.push line.toUpperCase()
		return false

	equal lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		lResult.push line.toUpperCase()
		return false
	equal lResult, ['ABC','DEF', 'GHI']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		if (line == 'ghi')
			return true
		lResult.push line.toUpperCase()
		return false

	equal lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line, hInfo) =>
		if (line == 'ghi')
			return true
		lResult.push "#{hInfo.lineNum} #{line.toUpperCase()} #{hInfo.nextLine}"
		return false

	equal lResult, ['1 ABC def','2 DEF ghi']
	)()

# ---------------------------------------------------------------------------
# --- test mapEachLine

(() =>
	block = """
		abc
		def
		ghi
		"""
	newblock = mapEachLine block, (line) =>
		return line.toUpperCase()
	equal newblock, """
		ABC
		DEF
		GHI
		"""
	)()

(() =>
	block = """
		abc
		def
		ghi
		"""
	newblock = mapEachLine block, (line) =>
		if (line == 'def')
			return undef
		else
			return line.toUpperCase()
	equal newblock, """
		ABC
		GHI
		"""
	)()

(() =>
	item = ['abc','def','ghi']
	newblock = mapEachLine item, (line) =>
		return line.toUpperCase()
	equal newblock, [
		'ABC'
		'DEF'
		'GHI'
		]
	)()

(() =>
	item = ['abc','def','ghi']
	newblock = mapEachLine item, (line) =>
		if (line == 'def')
			return undef
		else
			return line.toUpperCase()
	equal newblock, [
		'ABC'
		'GHI'
		]
	)()

(() =>
	item = ['abc','def','ghi']
	newblock = mapEachLine item, (line, hInfo) =>
		if (line == 'def')
			return undef
		else if defined(hInfo.nextLine)
			return "#{hInfo.lineNum} #{line.toUpperCase()} #{hInfo.nextLine}"
		else
			return "#{hInfo.lineNum} #{line.toUpperCase()}"
	equal newblock, [
		'1 ABC def'
		'3 GHI'
		]
	)()

# ---------------------------------------------------------------------------
# --- test removeKeys

(() =>
	hAST = {
		body: [
			{
				declarations: Array [{start:0}],
				end: 11,
				kind: 'let',
				start: 0,
				type: 'VariableDeclaration',
				},
			],
		end: 11,
		sourceType: 'script',
		start: 0,
		type: 'Program',
		}

	equal removeKeys(hAST, ['start','end']), {
		body: [
			{
				declarations: Array [{}],
				kind: 'let',
				type: 'VariableDeclaration',
				},
			],
		sourceType: 'script',
		type: 'Program',
		}

	)()

(() =>
	hAST = {
		body: [
			{
				declarations: Array [{start:0}],
				end: 12,
				kind: 'let',
				start: 0,
				type: 'VariableDeclaration',
				},
			],
		end: 12,
		sourceType: 'script',
		start: 0,
		type: 'Program',
		}

	equal removeKeys(hAST, ['start','end']), {
		body: [
			{
				declarations: Array [{}],
				kind: 'let',
				type: 'VariableDeclaration',
				},
			],
		sourceType: 'script',
		type: 'Program',
		}

	)()

# ---------------------------------------------------------------------------
# test getProxy()

(() =>
	hToDo = {
		task: 'go shopping'
		notes: 'broccoli, milk'
		}

	# ..........................................................

	h = getProxy hToDo, {

		get: (obj, prop, value) ->

			return value.toUpperCase() # return in upper case

		set: (obj, prop, value) ->
			# --- only allow setting tasks to 'do <something>'

			if (prop == 'task') && (value.indexOf('do ') != 0)
				return undef
			else
				return value
		}

	equal hToDo.task, 'go shopping'
	equal h.task, 'GO SHOPPING'

	h.task = 'do something'
	equal hToDo.task, 'do something'
	equal h.task, 'DO SOMETHING'

	h.task = 'nothing'
	equal hToDo.task, 'do something'
	equal h.task, 'DO SOMETHING'

	)()

# ---------------------------------------------------------------------------
# test doDelayed()

(() =>
	lLines = undef
	LOG = (str) =>
		lLines.push str

	run1 = () =>
		lLines = []
		schedule 1, 1, LOG, 'abc'
		schedule 2, 2, LOG, 'def'
		await sleep 5
		schedule 3, 1, LOG, 'ghi'
		await sleep 5
		return lLines.join(',')

	equal await run1(), 'abc,def,ghi'
	)()

(() =>
	lLines = undef
	LOG = (str) =>
		lLines.push str

	run2 = () =>

		lLines = []
		schedule 1, 1, LOG, 'abc'
		schedule 2, 2, LOG, 'def'
		schedule 3, 1, LOG, 'ghi'
		await sleep 5
		return lLines.join(',')

	equal await run2(), 'def,ghi'
	)()

# ---------------------------------------------------------------------------
# test eachCharInString()

truthy eachCharInString 'ABC', (ch) => ch == ch.toUpperCase()
falsy  eachCharInString 'abc', (ch) => ch == ch.toUpperCase()
falsy  eachCharInString 'AbC', (ch) => ch == ch.toUpperCase()

# ---------------------------------------------------------------------------
# test choose()

lItems = ['apple','orange','pear']
truthy lItems.includes(choose(lItems))
truthy lItems.includes(choose(lItems))
truthy lItems.includes(choose(lItems))

# ---------------------------------------------------------------------------
# test shuffle()

lShuffled = deepCopy(lItems)
shuffle(lShuffled)
truthy lShuffled.includes('apple')
truthy lShuffled.includes('orange')
truthy lShuffled.includes('pear')
truthy lShuffled.length == lItems.length

# ---------------------------------------------------------------------------
# test some date functions

dateStr = '2023-01-01 05:00:00'
equal timestamp(dateStr), "1/1/2023 5:00:00 AM"
equal msSinceEpoch(dateStr), 1672567200000
equal formatDate(dateStr), "Jan 1, 2023"


# ---------------------------------------------------------------------------
# test pad()

equal pad(23, 5), "   23"
equal pad(23, 5, 'justify=left'), '23   '
equal pad('abc', 6), 'abc   '
equal pad('abc', 6, 'justify=center'), ' abc  '
equal pad(true, 3), 'true'
equal pad(false, 3, 'truncate'), 'fal'

# ---------------------------------------------------------------------------
# test keys(), hasKey(), hasAllKeys(), hasAnyKey(), subkeys()

(() =>
	h = {
		'2023-Nov': {
			Dining: {
				amt: 200
				}
			Hardware: {
				amt: 50
				}
			}
		'2023-Dec': {
			Dining: {
				amt: 300
				}
			Insurance: {
				amt: 150
				}
			}
		}

	equal keys(h), ['2023-Nov','2023-Dec']
	truthy hasKey(h, '2023-Nov')
	falsy hasKey(h, '2023-Oct')
	equal subkeys(h), ['Dining','Hardware','Insurance']

	truthy hasAllKeys(h, '2023-Nov', '2023-Dec')
	truthy hasAllKeys(h, '2023-Nov')
	falsy hasAllKeys(h, '2023-Oct', '2023-Nov', '2023-Dec')

	truthy hasAnyKey(h, '2023-Oct', '2023-Nov', '2023-Dec')
	truthy hasAnyKey(h, '2023-Oct', '2023-Nov')
	falsy hasAnyKey(h, '2023-Jan', '2023-Feb', '2023-Mar')
	)()

# ---------------------------------------------------------------------------
# --- test extractKey()

(() =>
	h = {
		Nov: {
			Dining: {
				amt: 200
				}
			Hardware: {
				amt: 50
				}
			}
		Dec: {
			Dining: {
				amt: 300
				}
			Insurance: {
				amt: 150
				}
			}
		}

	val1 = extractKey(h, 'Nov')
	equal val1, {
		Dining: {
			amt: 200
			}
		Hardware: {
			amt: 50
			}
		}

	equal h, {
		Dec: {
			Dining: {
				amt: 300
				}
			Insurance: {
				amt: 150
				}
			}
		}

	h2 = {
		fName: 'John'
		lName: 'Deighan'
		}

	val2 = extractKey(h2, 'fName')
	equal val2, 'John'
	equal h2, {lName: 'Deighan'}

	)()

# ---------------------------------------------------------------------------

equal keys({a:1, b:2},{c:3, b:5}), ['a','b','c']

(() =>
	hJan = {
		Gas: 210
		Dining: 345
		Insurance: 910
		}
	hFeb = {
		Insurance: 450
		Dining: 440
		}
	hMar = {
		Dining: 550
		Gas: 200
		Starbucks: 125
		}
	equal keys(hJan, hFeb, hMar), [
		'Gas'
		'Dining'
		'Insurance'
		'Starbucks'
		]
	)()

# ---------------------------------------------------------------------------
# --- test forEachItem()

(() =>
	lWords = ['bridge', 'highway', 'garbage']
	result = forEachItem lWords, (item, h) =>
		return item
	equal result, lWords
	)()

(() =>
	lWords = ['bridge', 'highway', 'garbage']
	result = forEachItem lWords, (item, h) =>
		if (item == 'highway')
			return undef
		else
			return item
	equal result, ['bridge', 'garbage']
	)()

(() =>
	lWords = ['bridge', 'highway', 'garbage']
	result = forEachItem lWords, (item, h) =>
		return item.toUpperCase()
	equal result, ['BRIDGE', 'HIGHWAY', 'GARBAGE']
	)()

(() =>
	lWords = ['bridge', 'highway', 'garbage']
	result = forEachItem lWords, (item, h) =>
		if (item == 'garbage')
			throw 'stop'
		return item
	equal result, ['bridge', 'highway']
	)()

(() =>
	lWords = ['bridge', 'highway', 'garbage']
	result = forEachItem lWords, (item, h) =>
		if (h._index == 2)
			throw 'stop'
		return item
	equal result, ['bridge', 'highway']
	)()

(() =>
	lWords = ['bridge', 'highway', 'garbage']
	fails () =>
		result = forEachItem lWords, (item, h) =>
			throw new Error("unknown error")
	)()

(() =>
	countGenerator = () ->
		yield 1
		yield 2
		yield 3
		yield 4
		return

	callback = (item, hContext) =>
		if (item > 2)
			return "#{hContext.label} #{item}"
		else
			return undef

	result = forEachItem countGenerator(), callback, {label: 'X'}
	equal result, ['X 3', 'X 4']
	)()

# ---------------------------------------------------------------------------

(() =>
	obj = addToHash {}, [2024, 'Mar', 'Eat Out', 'Starbucks'], 23
	equal obj, {
		'2024': { Mar: { 'Eat Out': { Starbucks: 23 } } }
		}
	equal obj[2024]['Mar']['Eat Out']['Starbucks'], 23
	)()

(() =>
	obj = {}
	addToHash obj, 'Mar', 23
	equal obj, {Mar: 23}
	)()

(() =>
	obj = {}
	addToHash obj, 2, 23
	equal obj, {'2': 23}
	)()

# ---------------------------------------------------------------------------
# --- test chomp()

equal chomp('abc'), 'abc'
equal chomp('abc\n'), 'abc'
equal chomp('abc\r\n'), 'abc'

# ---------------------------------------------------------------------------
# --- test flattenToHash()

(() =>
	equal flattenToHash({a:1, b:2}), {a:1, b:2}
	equal flattenToHash([{a:1}, {b:2}]), {a:1,b:2}
	equal flattenToHash([{a:1}, [{b:2}]]), {a:1,b:2}
	equal flattenToHash([[{a:1}], {b:2}]), {a:1,b:2}
	equal flattenToHash([[{a:1,c:3}], {b:2,d:4}]), {a:1,b:2,c:3,d:4}
	lItems = [
		{a:1, b:2}
		[{c:3}, {d:4}, [{e:5}]]
		]
	equal flattenToHash(lItems), {
		a:1
		b:2
		c:3
		d:4
		e:5
		}
	)()

# ---------------------------------------------------------------------------
# --- test sortArrayOfHashes()

(() =>
	equal sortArrayOfHashes([
		{a:1}
		{a:3}
		{a:2}
		], 'a'), [
		{a:1}
		{a:2}
		{a:3}
		]

	equal sortArrayOfHashes([
		{name: 'John', age: 71}
		{name: 'Arathi', age: 35}
		{name: 'Lewis', age: 33}
		{name: 'Ben', age: 39}
		], 'name'), [
		{name: 'Arathi', age: 35}
		{name: 'Ben', age: 39}
		{name: 'John', age: 71}
		{name: 'Lewis', age: 33}
		]

	equal sortArrayOfHashes([
		{name: 'John', age: 71}
		{name: 'Arathi', age: 35}
		{name: 'Lewis', age: 33}
		{name: 'Ben', age: 39}
		], 'age'), [
		{name: 'Lewis', age: 33}
		{name: 'Arathi', age: 35}
		{name: 'Ben', age: 39}
		{name: 'John', age: 71}
		]

	)()

# ---------------------------------------------------------------------------
# --- test buildCmdLine()

(() =>
	equal buildCmdLine('doit'), 'doit'
	equal buildCmdLine('doit', {debug:true}),
		'doit -debug=true'
	equal buildCmdLine('doit', {glob:'*'}),
		'doit -glob=*'
	equal buildCmdLine('npx doit', {
		glob: '*.coffee',
		d: true,
		f: true,
		g: false
		}),
		'npx doit -glob=*.coffee -g=false -df'
	equal buildCmdLine('npx doit', {
		glob: '*.coffee',
		d: true,
		f: true,
		g: false
		}, ['willy', 'wonka', 'this is it']),
		'npx doit -glob=*.coffee -g=false -df willy wonka "this is it"'
	)()

# ---------------------------------------------------------------------------
# --- test execCmd()

(() =>
	like execCmd("echo abc"), "abc"
	like execCmd('echo my word'), 'my word'
	)()
