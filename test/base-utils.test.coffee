# base-utils.test.coffee

import test from 'ava'

import {utest} from '@jdeighan/base-utils/utest'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, pass, defined, notdefined, tabify, untabify, prefixBlock,
	escapeStr, OL, OLS, inList,  isHashComment,
	isString, isNumber, isInteger, isHash, isArray, isBoolean,
	isClass, isConstructor,
	isFunction, isRegExp, isObject, jsType,
	isEmpty, nonEmpty, isNonEmptyString, isIdentifier,
	isFunctionName, isIterable,
	blockToArray, arrayToBlock, toArray, toBlock,
	rtrim, words, hasChar, quoted, getOptions, range,
	oneof, uniq, rtrunc, ltrunc, CWS, className,
	isArrayOfStrings, isArrayOfHashes, extractMatches,
	} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

test "line 23", (t) => t.truthy(isHashComment('   # something'))
test "line 24", (t) => t.truthy(isHashComment('   #'))
test "line 25", (t) => t.falsy(isHashComment('   abc'))
test "line 26", (t) => t.falsy(isHashComment('#abc'))

test "line 28", (t) => t.is(undef, undefined)

test "line 30", (t) => t.truthy(isFunction(pass))

(() ->
	passTest = () =>
		pass()
	test "line 35", (t) => t.notThrows(passTest, "pass fails")
	)()

test "line 38", (t) => t.truthy(defined(''))
test "line 39", (t) => t.truthy(defined(5))
test "line 40", (t) => t.truthy(defined([]))
test "line 41", (t) => t.truthy(defined({}))
test "line 42", (t) => t.falsy(defined(undef))
test "line 43", (t) => t.falsy(defined(null))

test "line 45", (t) => t.truthy(notdefined(undef))
test "line 46", (t) => t.truthy(notdefined(null))
test "line 47", (t) => t.falsy(notdefined(''))
test "line 48", (t) => t.falsy(notdefined(5))
test "line 49", (t) => t.falsy(notdefined([]))
test "line 50", (t) => t.falsy(notdefined({}))

# ---------------------------------------------------------------------------

(() ->
	prefix = '   '    # 3 spaces

	test "line 57", (t) => t.is(untabify("""
		first line
		\tsecond line
		\t\tthird line
		""", 3), """
		first line
		#{prefix}second line
		#{prefix}#{prefix}third line
		""")
	)()

# ---------------------------------------------------------------------------

(() ->
	prefix = '   '    # 3 spaces

	utest.equal 73, tabify("""
		first line
		#{prefix}second line
		#{prefix}#{prefix}third line
		""", 3), """
		first line
		\tsecond line
		\t\tthird line
		"""
	)()

# ---------------------------------------------------------------------------
# you don't need to tell it number of spaces

(() ->
	prefix = '   '    # 3 spaces

	utest.equal 90, tabify("""
		first line
		#{prefix}second line
		#{prefix}#{prefix}third line
		"""), """
		first line
		\tsecond line
		\t\tthird line
		"""
	)()

# ---------------------------------------------------------------------------

(() ->
	prefix = '   '    # 3 spaces

	utest.equal 106, untabify("""
		first line
		\tsecond line
		\t\tthird line
		""", 3), """
		first line
		#{prefix}second line
		#{prefix}#{prefix}third line
		"""
	)()

# ---------------------------------------------------------------------------

test "line 119", (t) => t.is(prefixBlock("""
	abc
	def
	""", '--'), """
	--abc
	--def
	""")

# ---------------------------------------------------------------------------

test "line 129", (t) => t.is(escapeStr("\t\tXXX\n"), "→→XXX®")

hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}

test "line 137", (t) => t.is(escapeStr("\thas quote: \"\nnext line", hEsc),
	"\\thas quote: \\\"\\nnext line")

# ---------------------------------------------------------------------------

test "line 142", (t) => t.is(OL(undef), "undef")
test "line 143", (t) => t.is(OL("\t\tabc\nxyz"), "'→→abc®xyz'")
test "line 144", (t) => t.is(OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}')

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

test "line 152", (t) => t.is(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}')

# ---------------------------------------------------------------------------

test "line 156", (t) => t.is(OLS(['abc', 3]), "'abc',3")
test "line 157", (t) => t.is(OLS([]), "")
test "line 158", (t) => t.is(OLS([undef, {a:1}]), 'undef,{"a":1}')

# ---------------------------------------------------------------------------

test "line 99",  (t) => t.truthy(inList('a', 'b', 'a', 'c'))
test "line 163", (t) => t.falsy( inList('a', 'b', 'c'))

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

	test "line 183", (t) => t.falsy(isString(undef))
	test "line 184", (t) => t.falsy(isString(h))
	test "line 185", (t) => t.falsy(isString(l))
	test "line 186", (t) => t.falsy(isString(o))
	test "line 187", (t) => t.falsy(isString(n))
	test "line 188", (t) => t.falsy(isString(n2))

	test "line 190", (t) => t.truthy(isString(s))
	test "line 191", (t) => t.truthy(isString(s2))

	test "line 193", (t) => t.truthy(isNonEmptyString('abc'))
	test "line 194", (t) => t.truthy(isNonEmptyString('abc def'))
	test "line 195", (t) => t.falsy(isNonEmptyString(''))
	test "line 196", (t) => t.falsy(isNonEmptyString('  '))

	test "line 198", (t) => t.truthy(isIdentifier('abc'))
	test "line 199", (t) => t.truthy(isIdentifier('_Abc'))
	test "line 200", (t) => t.falsy(isIdentifier('abc def'))
	test "line 201", (t) => t.falsy(isIdentifier('abc-def'))
	test "line 202", (t) => t.falsy(isIdentifier('class.method'))

	test "line 204", (t) => t.truthy(isFunctionName('abc'))
	test "line 205", (t) => t.truthy(isFunctionName('_Abc'))
	test "line 206", (t) => t.falsy(isFunctionName('abc def'))
	test "line 207", (t) => t.falsy(isFunctionName('abc-def'))
	test "line 208", (t) => t.falsy(isFunctionName('D()'))
	test "line 209", (t) => t.truthy(isFunctionName('class.method'))

	generatorFunc = () ->
		yield 1
		yield 2
		yield 3
		return

	test "line 217", (t) => t.truthy(isIterable(generatorFunc()))

	test "line 219", (t) => t.falsy(isNumber(h))
	test "line 220", (t) => t.falsy(isNumber(l))
	test "line 221", (t) => t.falsy(isNumber(o))
	test "line 222", (t) => t.truthy(isNumber(n))
	test "line 223", (t) => t.truthy(isNumber(n2))
	test "line 224", (t) => t.falsy(isNumber(s))
	test "line 225", (t) => t.falsy(isNumber(s2))

	test "line 227", (t) => t.truthy(isNumber(42.0, {min: 42.0}))
	test "line 228", (t) => t.falsy(isNumber(42.0, {min: 42.1}))
	test "line 229", (t) => t.truthy(isNumber(42.0, {max: 42.0}))
	test "line 230", (t) => t.falsy(isNumber(42.0, {max: 41.9}))

	test "line 232", (t) => t.truthy(isInteger(42))
	test "line 233", (t) => t.truthy(isInteger(new Number(42)))
	test "line 234", (t) => t.falsy(isInteger('abc'))
	test "line 235", (t) => t.falsy(isInteger({}))
	test "line 236", (t) => t.falsy(isInteger([]))
	test "line 237", (t) => t.truthy(isInteger(42, {min:  0}))
	test "line 238", (t) => t.falsy(isInteger(42, {min: 50}))
	test "line 239", (t) => t.truthy(isInteger(42, {max: 50}))
	test "line 240", (t) => t.falsy(isInteger(42, {max:  0}))

	test "line 242", (t) => t.truthy(isHash(h))
	test "line 243", (t) => t.falsy(isHash(l))
	test "line 244", (t) => t.falsy(isHash(o))
	test "line 245", (t) => t.falsy(isHash(n))
	test "line 246", (t) => t.falsy(isHash(n2))
	test "line 247", (t) => t.falsy(isHash(s))
	test "line 248", (t) => t.falsy(isHash(s2))

	test "line 250", (t) => t.falsy(isArray(h))
	test "line 251", (t) => t.truthy(isArray(l))
	test "line 252", (t) => t.falsy(isArray(o))
	test "line 253", (t) => t.falsy(isArray(n))
	test "line 254", (t) => t.falsy(isArray(n2))
	test "line 255", (t) => t.falsy(isArray(s))
	test "line 256", (t) => t.falsy(isArray(s2))

	test "line 258", (t) => t.truthy(isBoolean(true))
	test "line 259", (t) => t.truthy(isBoolean(false))
	test "line 260", (t) => t.falsy(isBoolean(42))
	test "line 261", (t) => t.falsy(isBoolean("true"))

	test "line 263", (t) => t.truthy(isClass(NewClass))
	test "line 264", (t) => t.falsy(isClass(o))

	test "line 266", (t) => t.truthy(isConstructor(NewClass))
	test "line 267", (t) => t.falsy(isConstructor(o))

	test "line 269", (t) => t.truthy(isFunction(() -> 42))
	test "line 270", (t) => t.truthy(isFunction(() => 42))
	test "line 271", (t) => t.falsy(isFunction(42))
	test "line 272", (t) => t.falsy(isFunction(n))

	test "line 274", (t) => t.truthy(isRegExp(/^abc$/))
	test "line 275", (t) => t.truthy(isRegExp(///^ \s* where \s+ areyou $///))
	test "line 276", (t) => t.falsy(isRegExp(42))
	test "line 277", (t) => t.falsy(isRegExp('abc'))
	test "line 278", (t) => t.falsy(isRegExp([1,'a']))
	test "line 279", (t) => t.falsy(isRegExp({a:1, b:'ccc'}))
	test "line 280", (t) => t.falsy(isRegExp(undef))
	test "line 281", (t) => t.truthy(isRegExp(/\.coffee/))

	test "line 283", (t) => t.falsy(isObject(h))
	test "line 284", (t) => t.falsy(isObject(l))
	test "line 285", (t) => t.truthy(isObject(o))
	test "line 286", (t) => t.truthy(isObject(o, ['name','doIt']))
	test "line 287", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 288", (t) => t.falsy(isObject(o, ['name','doIt','missing']))
	test "line 289", (t) => t.falsy(isObject(o, "name doIt missing"))
	test "line 290", (t) => t.falsy(isObject(n))
	test "line 291", (t) => t.falsy(isObject(n2))
	test "line 292", (t) => t.falsy(isObject(s))
	test "line 293", (t) => t.falsy(isObject(s2))
	test "line 294", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 295", (t) => t.truthy(isObject(o, "name doIt meth"))
	test "line 296", (t) => t.truthy(isObject(o, "name &doIt &meth"))
	test "line 297", (t) => t.falsy(isObject(o, "&name"))

	test "line 299", (t) => t.deepEqual(jsType(undef), [undef, 'undef'])
	test "line 300", (t) => t.deepEqual(jsType(null),  [undef, 'null'])
	test "line 301", (t) => t.deepEqual(jsType(s), ['string', undef])
	test "line 302", (t) => t.deepEqual(jsType(''), ['string', 'empty'])
	test "line 303", (t) => t.deepEqual(jsType("\t\t"), ['string', 'empty'])
	test "line 304", (t) => t.deepEqual(jsType("  "), ['string', 'empty'])
	test "line 305", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 306", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 307", (t) => t.deepEqual(jsType(3.14159), ['number', undef])
	test "line 308", (t) => t.deepEqual(jsType(42), ['number', 'integer'])
	test "line 309", (t) => t.deepEqual(jsType(true), ['boolean', undef])
	test "line 310", (t) => t.deepEqual(jsType(false), ['boolean', undef])
	test "line 311", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 312", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 313", (t) => t.deepEqual(jsType(l), ['array', undef])
	test "line 314", (t) => t.deepEqual(jsType([]), ['array', 'empty'])
	test "line 315", (t) => t.deepEqual(jsType(/abc/), ['regexp', undef])

	func1 = (x) ->
		return

	func2 = (x) =>
		return

	# --- NOTE: regular functions can't be distinguished from constructors
	test "line 324", (t) => t.deepEqual(jsType(func1), ['class', undef])

	test "line 326", (t) => t.deepEqual(jsType(func2), ['function', undef])
	test "line 327", (t) => t.deepEqual(jsType(NewClass), ['class', undef])
	test "line 328", (t) => t.deepEqual(jsType(o), ['object', undef])
	)()

# ---------------------------------------------------------------------------

test "line 333", (t) => t.truthy(isEmpty(''))
test "line 334", (t) => t.truthy(isEmpty('  \t\t'))
test "line 335", (t) => t.truthy(isEmpty([]))
test "line 336", (t) => t.truthy(isEmpty({}))

test "line 338", (t) => t.truthy(nonEmpty('a'))
test "line 339", (t) => t.truthy(nonEmpty('.'))
test "line 340", (t) => t.truthy(nonEmpty([2]))
test "line 341", (t) => t.truthy(nonEmpty({width: 2}))

# ---------------------------------------------------------------------------

test "line 345", (t) => t.deepEqual(blockToArray(undef), [])
test "line 346", (t) => t.deepEqual(blockToArray(''), [])
test "line 347", (t) => t.deepEqual(blockToArray('a'), ['a'])
test "line 348", (t) => t.deepEqual(blockToArray("a\nb"), ['a','b'])
test "line 349", (t) => t.deepEqual(blockToArray("a\r\nb"), ['a','b'])
test "line 350", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 355", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 360", (t) => t.deepEqual(blockToArray("abc\n\nxyz"), [
	'abc'
	''
	'xyz'
	])

# ---------------------------------------------------------------------------

test "line 368", (t) => t.deepEqual(toArray("abc\ndef"), ['abc','def'])
test "line 369", (t) => t.deepEqual(toArray(['a','b']), ['a','b'])

test "line 371", (t) => t.deepEqual(toArray(["a\nb","c\nd"]), ['a','b','c','d'])

# ---------------------------------------------------------------------------

test "line 375", (t) => t.deepEqual(arrayToBlock(undef), '')
test "line 376", (t) => t.deepEqual(arrayToBlock([]), '')
test "line 377", (t) => t.deepEqual(arrayToBlock([undef]), '')
test "line 378", (t) => t.deepEqual(arrayToBlock(['a  ','b\t\t']), "a\nb")
test "line 379", (t) => t.deepEqual(arrayToBlock(['a','b','c']), "a\nb\nc")
test "line 380", (t) => t.deepEqual(arrayToBlock(['a',undef,'b','c']), "a\nb\nc")
test "line 381", (t) => t.deepEqual(arrayToBlock([undef,'a','b','c',undef]), "a\nb\nc")

# ---------------------------------------------------------------------------

test "line 385", (t) => t.deepEqual(toBlock(['abc','def']), "abc\ndef")
test "line 386", (t) => t.deepEqual(toBlock("abc\ndef"), "abc\ndef")

# ---------------------------------------------------------------------------

test "line 390", (t) => t.is(rtrim("abc"), "abc")
test "line 391", (t) => t.is(rtrim("  abc"), "  abc")
test "line 392", (t) => t.is(rtrim("abc  "), "abc")
test "line 393", (t) => t.is(rtrim("  abc  "), "  abc")

# ---------------------------------------------------------------------------

test "line 397", (t) => t.deepEqual(words(''), [])
test "line 398", (t) => t.deepEqual(words('  \t\t'), [])
test "line 399", (t) => t.deepEqual(words('a b c'), ['a', 'b', 'c'])
test "line 400", (t) => t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c'])
test "line 401", (t) => t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd'])
test "line 402", (t) => t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word'])

test "line 404", (t) => t.truthy hasChar('abc', 'b')
test "line 405", (t) => t.falsy  hasChar('abc', 'x')
test "line 406", (t) => t.falsy  hasChar("\t\t", ' ')

# ---------------------------------------------------------------------------

test "line 410", (t) => t.is(quoted('abc'), "'abc'")
test "line 411", (t) => t.is(quoted('"abc"'), "'\"abc\"'")
test "line 412", (t) => t.is(quoted("'abc'"), "\"'abc'\"")
test "line 413", (t) => t.is(quoted("'\"abc\"'"), "<'\"abc\"'>")
test "line 414", (t) => t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>")

# ---------------------------------------------------------------------------

test "line 418", (t) => t.deepEqual(getOptions(), {})
test "line 419", (t) => t.deepEqual(getOptions(undef, {x:1}), {x:1})
test "line 420", (t) => t.deepEqual(getOptions({x:1}, {x:3,y:4}), {x:1,y:4})
test "line 421", (t) => t.deepEqual(getOptions('asText'), {asText: true})
test "line 422", (t) => t.deepEqual(getOptions('!binary'), {binary: false})
test "line 423", (t) => t.deepEqual(getOptions('label=this'), {label: 'this'})
test "line 424", (t) => t.deepEqual(getOptions('asText !binary label=this'), {
	asText: true
	binary: false
	label: 'this'
	})

# ---------------------------------------------------------------------------

test "line 432", (t) => t.deepEqual(range(3), [0,1,2])

# ---------------------------------------------------------------------------

utest.truthy 436, isHashComment('#')
utest.truthy 437, isHashComment('# a comment')
utest.truthy 438, isHashComment('#\ta comment')
utest.falsy  439, isHashComment('#comment')
utest.falsy  440, isHashComment('')
utest.falsy  441, isHashComment('a comment')

# ---------------------------------------------------------------------------

utest.truthy 445, isEmpty('')
utest.truthy 446, isEmpty('  \t\t')
utest.truthy 447, isEmpty([])
utest.truthy 448, isEmpty({})

utest.truthy 450, nonEmpty('a')
utest.truthy 451, nonEmpty('.')
utest.truthy 452, nonEmpty([2])
utest.truthy 453, nonEmpty({width: 2})

utest.truthy 455, isNonEmptyString('abc')
utest.falsy  456, isNonEmptyString(undef)
utest.falsy  457, isNonEmptyString('')
utest.falsy  458, isNonEmptyString('   ')
utest.falsy  459, isNonEmptyString("\t\t\t")
utest.falsy  460, isNonEmptyString(5)

# ---------------------------------------------------------------------------

utest.truthy 464, oneof('a', 'a', 'b', 'c')
utest.truthy 465, oneof('b', 'a', 'b', 'c')
utest.truthy 466, oneof('c', 'a', 'b', 'c')
utest.falsy  467, oneof('d', 'a', 'b', 'c')
utest.falsy  468, oneof('x')

# ---------------------------------------------------------------------------

utest.equal 472, uniq([1,2,2,3,3]), [1,2,3]
utest.equal 473, uniq(['a','b','b','c','c']),['a','b','c']

# ---------------------------------------------------------------------------
# CURRENTLY DOES NOT PASS

# utest.equal {{LINE}}, hashToStr({c:3, b:2, a:1}), """
# 		{
# 		   "a": 1,
# 		   "b": 2,
# 		   "c": 3
# 		}
# 		"""

# ---------------------------------------------------------------------------

utest.equal 488, rtrim("abc"), "abc"
utest.equal 489, rtrim("  abc"), "  abc"
utest.equal 490, rtrim("abc  "), "abc"
utest.equal 491, rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

utest.equal 495, words('a b c'), ['a', 'b', 'c']
utest.equal 496, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

utest.equal 500, escapeStr("\t\tXXX\n"), "→→XXX®"
hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}
utest.equal 506, escapeStr("\thas quote: \"\nnext line", hEsc), \
	"\\thas quote: \\\"\\nnext line"

# ---------------------------------------------------------------------------

utest.equal 511, rtrunc('/user/lib/.env', 5), '/user/lib'
utest.equal 512, ltrunc('abcdefg', 3), 'defg'

utest.equal 514, CWS("""
		abc
		def
				ghi
		"""), "abc def ghi"

# ---------------------------------------------------------------------------

utest.truthy 522, isArrayOfStrings([])
utest.truthy 523, isArrayOfStrings(['a','b','c'])
utest.truthy 524, isArrayOfStrings(['a',undef, null, 'b'])

# ---------------------------------------------------------------------------

utest.truthy 528, isArrayOfHashes([])
utest.truthy 529, isArrayOfHashes([{}, {}])
utest.truthy 530, isArrayOfHashes([{a:1, b:2}, {}])
utest.truthy 531, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}])
utest.truthy 532, isArrayOfHashes([{a:1, b:2}, undef, null, {}])

utest.falsy  534, isArrayOfHashes({})
utest.falsy  535, isArrayOfHashes([1,2,3])
utest.falsy  536, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, 4])
utest.falsy  537, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}, [1,2]])

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
	s = 'utest'
	s2 = new String('abc')

	utest.truthy 556, isHash(h)
	utest.falsy  557, isHash(l)
	utest.falsy  558, isHash(o)
	utest.falsy  559, isHash(n)
	utest.falsy  560, isHash(n2)
	utest.falsy  561, isHash(s)
	utest.falsy  562, isHash(s2)

	utest.falsy  564, isArray(h)
	utest.truthy 565, isArray(l)
	utest.falsy  566, isArray(o)
	utest.falsy  567, isArray(n)
	utest.falsy  568, isArray(n2)
	utest.falsy  569, isArray(s)
	utest.falsy  570, isArray(s2)

	utest.falsy  572, isString(undef)
	utest.falsy  573, isString(h)
	utest.falsy  574, isString(l)
	utest.falsy  575, isString(o)
	utest.falsy  576, isString(n)
	utest.falsy  577, isString(n2)
	utest.truthy 578, isString(s)
	utest.truthy 579, isString(s2)

	utest.falsy  581, isObject(h)
	utest.falsy  582, isObject(l)
	utest.truthy 583, isObject(o)
	utest.truthy 584, isObject(o, ['name','doIt'])
	utest.falsy  585, isObject(o, ['name','doIt','missing'])
	utest.falsy  586, isObject(n)
	utest.falsy  587, isObject(n2)
	utest.falsy  588, isObject(s)
	utest.falsy  589, isObject(s2)

	utest.falsy  591, isNumber(h)
	utest.falsy  592, isNumber(l)
	utest.falsy  593, isNumber(o)
	utest.truthy 594, isNumber(n)
	utest.truthy 595, isNumber(n2)
	utest.falsy  596, isNumber(s)
	utest.falsy  597, isNumber(s2)

	utest.truthy 599, isNumber(42.0, {min: 42.0})
	utest.falsy  600, isNumber(42.0, {min: 42.1})
	utest.truthy 601, isNumber(42.0, {max: 42.0})
	utest.falsy  602, isNumber(42.0, {max: 41.9})
	)()

# ---------------------------------------------------------------------------

utest.truthy 607, isFunction(() -> pass)
utest.falsy  608, isFunction(23)

utest.truthy 610, isInteger(42)
utest.truthy 611, isInteger(new Number(42))
utest.falsy  612, isInteger('abc')
utest.falsy  613, isInteger({})
utest.falsy  614, isInteger([])
utest.truthy 615, isInteger(42, {min:  0})
utest.falsy  616, isInteger(42, {min: 50})
utest.truthy 617, isInteger(42, {max: 50})
utest.falsy  618, isInteger(42, {max:  0})

# ---------------------------------------------------------------------------

utest.equal 622, OL(undef), "undef"
utest.equal 623, OL("\t\tabc\nxyz"), "'→→abc®xyz'"
utest.equal 624, OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

utest.equal 628, CWS("""
		a utest
		error message
		"""), "a utest error message"

# ---------------------------------------------------------------------------
# test isRegExp()

utest.truthy 636, isRegExp(/^abc$/)
utest.truthy 637, isRegExp(///^
		\s*
		where
		\s+
		areyou
		$///)
utest.falsy  643, isRegExp(42)
utest.falsy  644, isRegExp('abc')
utest.falsy  645, isRegExp([1,'a'])
utest.falsy  646, isRegExp({a:1, b:'ccc'})
utest.falsy  647, isRegExp(undef)

utest.truthy 649, isRegExp(/\.coffee/)

# ---------------------------------------------------------------------------

utest.equal 653, extractMatches("..3 and 4 plus 5", /\d+/g, parseInt),
	[3, 4, 5]
utest.equal 655, extractMatches("And This Is A String", /A/g), ['A','A']

# ---------------------------------------------------------------------------

utest.truthy 659, notdefined(undef)
utest.truthy 660, notdefined(null)
utest.truthy 661, defined('')
utest.truthy 662, defined(5)
utest.truthy 663, defined([])
utest.truthy 664, defined({})

utest.falsy 666, defined(undef)
utest.falsy 667, defined(null)
utest.falsy 668, notdefined('')
utest.falsy 669, notdefined(5)
utest.falsy 670, notdefined([])
utest.falsy 671, notdefined({})

# ---------------------------------------------------------------------------

utest.truthy 675, isIterable([])
utest.truthy 676, isIterable(['a','b'])

gen = () ->
	yield 1
	yield 2
	yield 3
	return

utest.truthy 684, isIterable(gen())

# ---------------------------------------------------------------------------

(() ->
	class MyClass
		constructor: (str) ->
			@mystr = str

	utest.equal 693, className(MyClass), 'MyClass'

	)()

# ---------------------------------------------------------------------------

utest.equal 699, getOptions('a b c'), {'a':true, 'b':true, 'c':true}
utest.equal 700, getOptions('abc'), {'abc':true}
utest.equal 701, getOptions({'a':true, 'b':false, 'c':42}), {'a':true, 'b':false, 'c':42}
utest.equal 702, getOptions(), {}
