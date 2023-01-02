# base-utils.test.coffee

import test from 'ava'

import {utest} from '@jdeighan/base-utils/utest'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, pass, defined, notdefined, untabify, prefixBlock,
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

test "line 26", (t) => t.truthy(isHashComment('   # something'))
test "line 27", (t) => t.truthy(isHashComment('   #'))
test "line 28", (t) => t.falsy(isHashComment('   abc'))
test "line 29", (t) => t.falsy(isHashComment('#abc'))

test "line 31", (t) => t.is(undef, undefined)

test "line 33", (t) => t.truthy(isFunction(pass))

(() ->
	passTest = () =>
		pass()
	test "line 38", (t) => t.notThrows(passTest, "pass fails")
	)()

test "line 41", (t) => t.truthy(defined(''))
test "line 42", (t) => t.truthy(defined(5))
test "line 43", (t) => t.truthy(defined([]))
test "line 44", (t) => t.truthy(defined({}))
test "line 45", (t) => t.falsy(defined(undef))
test "line 46", (t) => t.falsy(defined(null))

test "line 48", (t) => t.truthy(notdefined(undef))
test "line 49", (t) => t.truthy(notdefined(null))
test "line 50", (t) => t.falsy(notdefined(''))
test "line 51", (t) => t.falsy(notdefined(5))
test "line 52", (t) => t.falsy(notdefined([]))
test "line 53", (t) => t.falsy(notdefined({}))

(() ->
	prefix = '   '    # 3 spaces

	test "line 58", (t) => t.is(untabify("""
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

test "line 71", (t) => t.is(prefixBlock("""
	abc
	def
	""", '--'), """
	--abc
	--def
	""")

# ---------------------------------------------------------------------------

test "line 81", (t) => t.is(escapeStr("\t\tXXX\n"), "→→XXX®")

hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}

test "line 89", (t) => t.is(escapeStr("\thas quote: \"\nnext line", hEsc),
	"\\thas quote: \\\"\\nnext line")

# ---------------------------------------------------------------------------

test "line 94", (t) => t.is(OL(undef), "undef")
test "line 95", (t) => t.is(OL("\t\tabc\nxyz"), "'→→abc®xyz'")
test "line 96", (t) => t.is(OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}')

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

test "line 104", (t) => t.is(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}')

# ---------------------------------------------------------------------------

test "line 108", (t) => t.is(OLS(['abc', 3]), "'abc',3")
test "line 109", (t) => t.is(OLS([]), "")
test "line 110", (t) => t.is(OLS([undef, {a:1}]), 'undef,{"a":1}')

# ---------------------------------------------------------------------------

test "line 99",  (t) => t.truthy(inList('a', 'b', 'a', 'c'))
test "line 115", (t) => t.falsy( inList('a', 'b', 'c'))

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

	test "line 135", (t) => t.falsy(isString(undef))
	test "line 136", (t) => t.falsy(isString(h))
	test "line 137", (t) => t.falsy(isString(l))
	test "line 138", (t) => t.falsy(isString(o))
	test "line 139", (t) => t.falsy(isString(n))
	test "line 140", (t) => t.falsy(isString(n2))

	test "line 142", (t) => t.truthy(isString(s))
	test "line 143", (t) => t.truthy(isString(s2))

	test "line 145", (t) => t.truthy(isNonEmptyString('abc'))
	test "line 146", (t) => t.truthy(isNonEmptyString('abc def'))
	test "line 147", (t) => t.falsy(isNonEmptyString(''))
	test "line 148", (t) => t.falsy(isNonEmptyString('  '))

	test "line 150", (t) => t.truthy(isIdentifier('abc'))
	test "line 151", (t) => t.truthy(isIdentifier('_Abc'))
	test "line 152", (t) => t.falsy(isIdentifier('abc def'))
	test "line 153", (t) => t.falsy(isIdentifier('abc-def'))
	test "line 154", (t) => t.falsy(isIdentifier('class.method'))

	test "line 156", (t) => t.truthy(isFunctionName('abc'))
	test "line 157", (t) => t.truthy(isFunctionName('_Abc'))
	test "line 158", (t) => t.falsy(isFunctionName('abc def'))
	test "line 159", (t) => t.falsy(isFunctionName('abc-def'))
	test "line 160", (t) => t.falsy(isFunctionName('D()'))
	test "line 161", (t) => t.truthy(isFunctionName('class.method'))

	generatorFunc = () ->
		yield 1
		yield 2
		yield 3
		return

	test "line 169", (t) => t.truthy(isIterable(generatorFunc()))

	test "line 171", (t) => t.falsy(isNumber(h))
	test "line 172", (t) => t.falsy(isNumber(l))
	test "line 173", (t) => t.falsy(isNumber(o))
	test "line 174", (t) => t.truthy(isNumber(n))
	test "line 175", (t) => t.truthy(isNumber(n2))
	test "line 176", (t) => t.falsy(isNumber(s))
	test "line 177", (t) => t.falsy(isNumber(s2))

	test "line 179", (t) => t.truthy(isNumber(42.0, {min: 42.0}))
	test "line 180", (t) => t.falsy(isNumber(42.0, {min: 42.1}))
	test "line 181", (t) => t.truthy(isNumber(42.0, {max: 42.0}))
	test "line 182", (t) => t.falsy(isNumber(42.0, {max: 41.9}))

	test "line 184", (t) => t.truthy(isInteger(42))
	test "line 185", (t) => t.truthy(isInteger(new Number(42)))
	test "line 186", (t) => t.falsy(isInteger('abc'))
	test "line 187", (t) => t.falsy(isInteger({}))
	test "line 188", (t) => t.falsy(isInteger([]))
	test "line 189", (t) => t.truthy(isInteger(42, {min:  0}))
	test "line 190", (t) => t.falsy(isInteger(42, {min: 50}))
	test "line 191", (t) => t.truthy(isInteger(42, {max: 50}))
	test "line 192", (t) => t.falsy(isInteger(42, {max:  0}))

	test "line 194", (t) => t.truthy(isHash(h))
	test "line 195", (t) => t.falsy(isHash(l))
	test "line 196", (t) => t.falsy(isHash(o))
	test "line 197", (t) => t.falsy(isHash(n))
	test "line 198", (t) => t.falsy(isHash(n2))
	test "line 199", (t) => t.falsy(isHash(s))
	test "line 200", (t) => t.falsy(isHash(s2))

	test "line 202", (t) => t.falsy(isArray(h))
	test "line 203", (t) => t.truthy(isArray(l))
	test "line 204", (t) => t.falsy(isArray(o))
	test "line 205", (t) => t.falsy(isArray(n))
	test "line 206", (t) => t.falsy(isArray(n2))
	test "line 207", (t) => t.falsy(isArray(s))
	test "line 208", (t) => t.falsy(isArray(s2))

	test "line 210", (t) => t.truthy(isBoolean(true))
	test "line 211", (t) => t.truthy(isBoolean(false))
	test "line 212", (t) => t.falsy(isBoolean(42))
	test "line 213", (t) => t.falsy(isBoolean("true"))

	test "line 215", (t) => t.truthy(isClass(NewClass))
	test "line 216", (t) => t.falsy(isClass(o))

	test "line 218", (t) => t.truthy(isConstructor(NewClass))
	test "line 219", (t) => t.falsy(isConstructor(o))

	test "line 221", (t) => t.truthy(isFunction(() -> 42))
	test "line 222", (t) => t.truthy(isFunction(() => 42))
	test "line 223", (t) => t.falsy(isFunction(42))
	test "line 224", (t) => t.falsy(isFunction(n))

	test "line 226", (t) => t.truthy(isRegExp(/^abc$/))
	test "line 227", (t) => t.truthy(isRegExp(///^ \s* where \s+ areyou $///))
	test "line 228", (t) => t.falsy(isRegExp(42))
	test "line 229", (t) => t.falsy(isRegExp('abc'))
	test "line 230", (t) => t.falsy(isRegExp([1,'a']))
	test "line 231", (t) => t.falsy(isRegExp({a:1, b:'ccc'}))
	test "line 232", (t) => t.falsy(isRegExp(undef))
	test "line 233", (t) => t.truthy(isRegExp(/\.coffee/))

	test "line 235", (t) => t.falsy(isObject(h))
	test "line 236", (t) => t.falsy(isObject(l))
	test "line 237", (t) => t.truthy(isObject(o))
	test "line 238", (t) => t.truthy(isObject(o, ['name','doIt']))
	test "line 239", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 240", (t) => t.falsy(isObject(o, ['name','doIt','missing']))
	test "line 241", (t) => t.falsy(isObject(o, "name doIt missing"))
	test "line 242", (t) => t.falsy(isObject(n))
	test "line 243", (t) => t.falsy(isObject(n2))
	test "line 244", (t) => t.falsy(isObject(s))
	test "line 245", (t) => t.falsy(isObject(s2))
	test "line 246", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 247", (t) => t.truthy(isObject(o, "name doIt meth"))
	test "line 248", (t) => t.truthy(isObject(o, "name &doIt &meth"))
	test "line 249", (t) => t.falsy(isObject(o, "&name"))

	test "line 251", (t) => t.deepEqual(jsType(undef), [undef, 'undef'])
	test "line 252", (t) => t.deepEqual(jsType(null),  [undef, 'null'])
	test "line 253", (t) => t.deepEqual(jsType(s), ['string', undef])
	test "line 254", (t) => t.deepEqual(jsType(''), ['string', 'empty'])
	test "line 255", (t) => t.deepEqual(jsType("\t\t"), ['string', 'empty'])
	test "line 256", (t) => t.deepEqual(jsType("  "), ['string', 'empty'])
	test "line 257", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 258", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 259", (t) => t.deepEqual(jsType(3.14159), ['number', undef])
	test "line 260", (t) => t.deepEqual(jsType(42), ['number', 'integer'])
	test "line 261", (t) => t.deepEqual(jsType(true), ['boolean', undef])
	test "line 262", (t) => t.deepEqual(jsType(false), ['boolean', undef])
	test "line 263", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 264", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 265", (t) => t.deepEqual(jsType(l), ['array', undef])
	test "line 266", (t) => t.deepEqual(jsType([]), ['array', 'empty'])
	test "line 267", (t) => t.deepEqual(jsType(/abc/), ['regexp', undef])

	func1 = (x) ->
		return

	func2 = (x) =>
		return

	# --- NOTE: regular functions can't be distinguished from constructors
	test "line 276", (t) => t.deepEqual(jsType(func1), ['class', undef])

	test "line 278", (t) => t.deepEqual(jsType(func2), ['function', undef])
	test "line 279", (t) => t.deepEqual(jsType(NewClass), ['class', undef])
	test "line 280", (t) => t.deepEqual(jsType(o), ['object', undef])
	)()

# ---------------------------------------------------------------------------

test "line 285", (t) => t.truthy(isEmpty(''))
test "line 286", (t) => t.truthy(isEmpty('  \t\t'))
test "line 287", (t) => t.truthy(isEmpty([]))
test "line 288", (t) => t.truthy(isEmpty({}))

test "line 290", (t) => t.truthy(nonEmpty('a'))
test "line 291", (t) => t.truthy(nonEmpty('.'))
test "line 292", (t) => t.truthy(nonEmpty([2]))
test "line 293", (t) => t.truthy(nonEmpty({width: 2}))

# ---------------------------------------------------------------------------

test "line 297", (t) => t.deepEqual(blockToArray(undef), [])
test "line 298", (t) => t.deepEqual(blockToArray(''), [])
test "line 299", (t) => t.deepEqual(blockToArray('a'), ['a'])
test "line 300", (t) => t.deepEqual(blockToArray("a\nb"), ['a','b'])
test "line 301", (t) => t.deepEqual(blockToArray("a\r\nb"), ['a','b'])
test "line 302", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 307", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 312", (t) => t.deepEqual(blockToArray("abc\n\nxyz"), [
	'abc'
	''
	'xyz'
	])

# ---------------------------------------------------------------------------

test "line 320", (t) => t.deepEqual(toArray("abc\ndef"), ['abc','def'])
test "line 321", (t) => t.deepEqual(toArray(['a','b']), ['a','b'])

test "line 323", (t) => t.deepEqual(toArray(["a\nb","c\nd"]), ['a','b','c','d'])

# ---------------------------------------------------------------------------

test "line 327", (t) => t.deepEqual(arrayToBlock(undef), '')
test "line 328", (t) => t.deepEqual(arrayToBlock([]), '')
test "line 329", (t) => t.deepEqual(arrayToBlock([undef]), '')
test "line 330", (t) => t.deepEqual(arrayToBlock(['a  ','b\t\t']), "a\nb")
test "line 331", (t) => t.deepEqual(arrayToBlock(['a','b','c']), "a\nb\nc")
test "line 332", (t) => t.deepEqual(arrayToBlock(['a',undef,'b','c']), "a\nb\nc")
test "line 333", (t) => t.deepEqual(arrayToBlock([undef,'a','b','c',undef]), "a\nb\nc")

# ---------------------------------------------------------------------------

test "line 337", (t) => t.deepEqual(toBlock(['abc','def']), "abc\ndef")
test "line 338", (t) => t.deepEqual(toBlock("abc\ndef"), "abc\ndef")

# ---------------------------------------------------------------------------

test "line 342", (t) => t.is(rtrim("abc"), "abc")
test "line 343", (t) => t.is(rtrim("  abc"), "  abc")
test "line 344", (t) => t.is(rtrim("abc  "), "abc")
test "line 345", (t) => t.is(rtrim("  abc  "), "  abc")

# ---------------------------------------------------------------------------

test "line 355", (t) => t.deepEqual(words(''), [])
test "line 356", (t) => t.deepEqual(words('  \t\t'), [])
test "line 357", (t) => t.deepEqual(words('a b c'), ['a', 'b', 'c'])
test "line 358", (t) => t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c'])
test "line 359", (t) => t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd'])
test "line 360", (t) => t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word'])

test "line 367", (t) => t.truthy hasChar('abc', 'b')
test "line 368", (t) => t.falsy  hasChar('abc', 'x')
test "line 369", (t) => t.falsy  hasChar("\t\t", ' ')

# ---------------------------------------------------------------------------

test "line 373", (t) => t.is(quoted('abc'), "'abc'")
test "line 374", (t) => t.is(quoted('"abc"'), "'\"abc\"'")
test "line 375", (t) => t.is(quoted("'abc'"), "\"'abc'\"")
test "line 376", (t) => t.is(quoted("'\"abc\"'"), "<'\"abc\"'>")
test "line 377", (t) => t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>")

# ---------------------------------------------------------------------------

test "line 381", (t) => t.deepEqual(getOptions(), {})
test "line 382", (t) => t.deepEqual(getOptions(undef, {x:1}), {x:1})
test "line 383", (t) => t.deepEqual(getOptions({x:1}, {x:3,y:4}), {x:1,y:4})
test "line 384", (t) => t.deepEqual(getOptions('asText'), {asText: true})
test "line 385", (t) => t.deepEqual(getOptions('!binary'), {binary: false})
test "line 386", (t) => t.deepEqual(getOptions('label=this'), {label: 'this'})
test "line 387", (t) => t.deepEqual(getOptions('asText !binary label=this'), {
	asText: true
	binary: false
	label: 'this'
	})

# ---------------------------------------------------------------------------

test "line 395", (t) => t.deepEqual(range(3), [0,1,2])

# ---------------------------------------------------------------------------

utest.truthy 399, isHashComment('#')
utest.truthy 400, isHashComment('# a comment')
utest.truthy 401, isHashComment('#\ta comment')
utest.falsy  402, isHashComment('#comment')
utest.falsy  403, isHashComment('')
utest.falsy  404, isHashComment('a comment')

# ---------------------------------------------------------------------------

utest.truthy 432, isEmpty('')
utest.truthy 433, isEmpty('  \t\t')
utest.truthy 434, isEmpty([])
utest.truthy 435, isEmpty({})

utest.truthy 437, nonEmpty('a')
utest.truthy 438, nonEmpty('.')
utest.truthy 439, nonEmpty([2])
utest.truthy 440, nonEmpty({width: 2})

utest.truthy 442, isNonEmptyString('abc')
utest.falsy  443, isNonEmptyString(undef)
utest.falsy  444, isNonEmptyString('')
utest.falsy  445, isNonEmptyString('   ')
utest.falsy  446, isNonEmptyString("\t\t\t")
utest.falsy  447, isNonEmptyString(5)

# ---------------------------------------------------------------------------

utest.truthy 454, oneof('a', 'a', 'b', 'c')
utest.truthy 455, oneof('b', 'a', 'b', 'c')
utest.truthy 456, oneof('c', 'a', 'b', 'c')
utest.falsy  457, oneof('d', 'a', 'b', 'c')
utest.falsy  458, oneof('x')

# ---------------------------------------------------------------------------

utest.equal 467, uniq([1,2,2,3,3]), [1,2,3]
utest.equal 468, uniq(['a','b','b','c','c']),['a','b','c']

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

utest.equal 483, rtrim("abc"), "abc"
utest.equal 484, rtrim("  abc"), "  abc"
utest.equal 485, rtrim("abc  "), "abc"
utest.equal 486, rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

utest.equal 490, words('a b c'), ['a', 'b', 'c']
utest.equal 491, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

utest.equal 495, escapeStr("\t\tXXX\n"), "→→XXX®"
hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}
utest.equal 501, escapeStr("\thas quote: \"\nnext line", hEsc), \
	"\\thas quote: \\\"\\nnext line"

# ---------------------------------------------------------------------------

utest.equal 506, rtrunc('/user/lib/.env', 5), '/user/lib'
utest.equal 507, ltrunc('abcdefg', 3), 'defg'

utest.equal 509, CWS("""
		abc
		def
				ghi
		"""), "abc def ghi"

# ---------------------------------------------------------------------------

utest.truthy 517, isArrayOfStrings([])
utest.truthy 518, isArrayOfStrings(['a','b','c'])
utest.truthy 519, isArrayOfStrings(['a',undef, null, 'b'])

# ---------------------------------------------------------------------------

utest.truthy 523, isArrayOfHashes([])
utest.truthy 524, isArrayOfHashes([{}, {}])
utest.truthy 525, isArrayOfHashes([{a:1, b:2}, {}])
utest.truthy 526, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}])
utest.truthy 527, isArrayOfHashes([{a:1, b:2}, undef, null, {}])

utest.falsy  529, isArrayOfHashes({})
utest.falsy  530, isArrayOfHashes([1,2,3])
utest.falsy  531, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, 4])
utest.falsy  532, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}, [1,2]])

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

	utest.truthy 551, isHash(h)
	utest.falsy  552, isHash(l)
	utest.falsy  553, isHash(o)
	utest.falsy  554, isHash(n)
	utest.falsy  555, isHash(n2)
	utest.falsy  556, isHash(s)
	utest.falsy  557, isHash(s2)

	utest.falsy  559, isArray(h)
	utest.truthy 560, isArray(l)
	utest.falsy  561, isArray(o)
	utest.falsy  562, isArray(n)
	utest.falsy  563, isArray(n2)
	utest.falsy  564, isArray(s)
	utest.falsy  565, isArray(s2)

	utest.falsy  567, isString(undef)
	utest.falsy  568, isString(h)
	utest.falsy  569, isString(l)
	utest.falsy  570, isString(o)
	utest.falsy  571, isString(n)
	utest.falsy  572, isString(n2)
	utest.truthy 573, isString(s)
	utest.truthy 574, isString(s2)

	utest.falsy  576, isObject(h)
	utest.falsy  577, isObject(l)
	utest.truthy 578, isObject(o)
	utest.truthy 579, isObject(o, ['name','doIt'])
	utest.falsy  580, isObject(o, ['name','doIt','missing'])
	utest.falsy  581, isObject(n)
	utest.falsy  582, isObject(n2)
	utest.falsy  583, isObject(s)
	utest.falsy  584, isObject(s2)

	utest.falsy  586, isNumber(h)
	utest.falsy  587, isNumber(l)
	utest.falsy  588, isNumber(o)
	utest.truthy 589, isNumber(n)
	utest.truthy 590, isNumber(n2)
	utest.falsy  591, isNumber(s)
	utest.falsy  592, isNumber(s2)

	utest.truthy 594, isNumber(42.0, {min: 42.0})
	utest.falsy  595, isNumber(42.0, {min: 42.1})
	utest.truthy 596, isNumber(42.0, {max: 42.0})
	utest.falsy  597, isNumber(42.0, {max: 41.9})
	)()

# ---------------------------------------------------------------------------

utest.truthy 602, isFunction(() -> pass)
utest.falsy  603, isFunction(23)

utest.truthy 605, isInteger(42)
utest.truthy 606, isInteger(new Number(42))
utest.falsy  607, isInteger('abc')
utest.falsy  608, isInteger({})
utest.falsy  609, isInteger([])
utest.truthy 610, isInteger(42, {min:  0})
utest.falsy  611, isInteger(42, {min: 50})
utest.truthy 612, isInteger(42, {max: 50})
utest.falsy  613, isInteger(42, {max:  0})

# ---------------------------------------------------------------------------

utest.equal 617, OL(undef), "undef"
utest.equal 618, OL("\t\tabc\nxyz"), "'→→abc®xyz'"
utest.equal 619, OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

utest.equal 623, CWS("""
		a utest
		error message
		"""), "a utest error message"

# ---------------------------------------------------------------------------
# test isRegExp()

utest.truthy 631, isRegExp(/^abc$/)
utest.truthy 632, isRegExp(///^
		\s*
		where
		\s+
		areyou
		$///)
utest.falsy  638, isRegExp(42)
utest.falsy  639, isRegExp('abc')
utest.falsy  640, isRegExp([1,'a'])
utest.falsy  641, isRegExp({a:1, b:'ccc'})
utest.falsy  642, isRegExp(undef)

utest.truthy 644, isRegExp(/\.coffee/)

# ---------------------------------------------------------------------------

utest.equal 648, extractMatches("..3 and 4 plus 5", /\d+/g, parseInt),
	[3, 4, 5]
utest.equal 650, extractMatches("And This Is A String", /A/g), ['A','A']

# ---------------------------------------------------------------------------

utest.truthy 738, notdefined(undef)
utest.truthy 739, notdefined(null)
utest.truthy 740, defined('')
utest.truthy 741, defined(5)
utest.truthy 742, defined([])
utest.truthy 743, defined({})

utest.falsy 745, defined(undef)
utest.falsy 746, defined(null)
utest.falsy 747, notdefined('')
utest.falsy 748, notdefined(5)
utest.falsy 749, notdefined([])
utest.falsy 750, notdefined({})

# ---------------------------------------------------------------------------

utest.truthy 754, isIterable([])
utest.truthy 755, isIterable(['a','b'])

gen = () ->
	yield 1
	yield 2
	yield 3
	return

utest.truthy 763, isIterable(gen())

# ---------------------------------------------------------------------------

(() ->
	class MyClass
		constructor: (str) ->
			@mystr = str

	utest.equal 772, className(MyClass), 'MyClass'

	)()

# ---------------------------------------------------------------------------

utest.equal 799, getOptions('a b c'), {'a':true, 'b':true, 'c':true}
utest.equal 800, getOptions('abc'), {'abc':true}
utest.equal 801, getOptions({'a':true, 'b':false, 'c':42}), {'a':true, 'b':false, 'c':42}
utest.equal 802, getOptions(), {}
