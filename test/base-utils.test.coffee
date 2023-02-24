# base-utils.test.coffee

import test from 'ava'

import {utest} from '@jdeighan/base-utils/utest'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, pass, defined, notdefined, tabify, untabify, prefixBlock,
	escapeStr, OL, OLS, inList,  isHashComment, splitPrefix,
	isString, isNumber, isInteger, isHash, isArray, isBoolean,
	isClass, isConstructor, removeKeys, extractMatches,
	isFunction, isRegExp, isObject, jsType,
	isEmpty, nonEmpty, isNonEmptyString, isIdentifier,
	isFunctionName, isIterable, hashFromString,
	blockToArray, arrayToBlock, toArray, toBlock,
	rtrim, words, hasChar, quoted, getOptions, range,
	oneof, uniq, rtrunc, ltrunc, CWS, className,
	isArrayOfStrings, isArrayOfHashes, isArrayOfArrays,
	forEachLine, mapEachLine, getProxy, sleep, schedule,
	} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

test "line 24", (t) => t.truthy(isHashComment('   # something'))
test "line 25", (t) => t.truthy(isHashComment('   #'))
test "line 26", (t) => t.falsy(isHashComment('   abc'))
test "line 27", (t) => t.falsy(isHashComment('#abc'))

test "line 29", (t) => t.is(undef, undefined)

test "line 31", (t) => t.truthy(isFunction(pass))

(() ->
	passTest = () =>
		pass()
	test "line 36", (t) => t.notThrows(passTest, "pass fails")
	)()

test "line 39", (t) => t.truthy(defined(''))
test "line 40", (t) => t.truthy(defined(5))
test "line 41", (t) => t.truthy(defined([]))
test "line 42", (t) => t.truthy(defined({}))
test "line 43", (t) => t.falsy(defined(undef))
test "line 44", (t) => t.falsy(defined(null))

test "line 46", (t) => t.truthy(notdefined(undef))
test "line 47", (t) => t.truthy(notdefined(null))
test "line 48", (t) => t.falsy(notdefined(''))
test "line 49", (t) => t.falsy(notdefined(5))
test "line 50", (t) => t.falsy(notdefined([]))
test "line 51", (t) => t.falsy(notdefined({}))

# ---------------------------------------------------------------------------

test "line 55", (t) => t.deepEqual(splitPrefix("abc"),     ["", "abc"])
test "line 56", (t) => t.deepEqual(splitPrefix("\tabc"),   ["\t", "abc"])
test "line 57", (t) => t.deepEqual(splitPrefix("\t\tabc"), ["\t\t", "abc"])
test "line 58", (t) => t.deepEqual(splitPrefix(""),        ["", ""])
test "line 59", (t) => t.deepEqual(splitPrefix("\t\t\t"),  ["", ""])
test "line 60", (t) => t.deepEqual(splitPrefix("\t \t"),   ["", ""])
test "line 61", (t) => t.deepEqual(splitPrefix("   "),     ["", ""])

# ---------------------------------------------------------------------------

(() ->
	prefix = '   '    # 3 spaces

	test "line 68", (t) => t.is(untabify("""
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

	utest.equal 84, tabify("""
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

	utest.equal 101, tabify("""
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

	utest.equal 117, untabify("""
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

test "line 130", (t) => t.is(prefixBlock("""
	abc
	def
	""", '--'), """
	--abc
	--def
	""")

# ---------------------------------------------------------------------------

test "line 140", (t) => t.is(escapeStr("\t\tXXX\n"), "→→XXX®")

hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}

test "line 148", (t) => t.is(escapeStr("\thas quote: \"\nnext line", hEsc),
	"\\thas quote: \\\"\\nnext line")

# ---------------------------------------------------------------------------

test "line 153", (t) => t.is(OL(undef), "undef")
test "line 154", (t) => t.is(OL("\t\tabc\nxyz"), "'→→abc®xyz'")
test "line 155", (t) => t.is(OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}')

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

test "line 163", (t) => t.is(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}')

# ---------------------------------------------------------------------------

test "line 167", (t) => t.is(OLS(['abc', 3]), "'abc',3")
test "line 168", (t) => t.is(OLS([]), "")
test "line 169", (t) => t.is(OLS([undef, {a:1}]), 'undef,{"a":1}')

# ---------------------------------------------------------------------------

test "line 99",  (t) => t.truthy(inList('a', 'b', 'a', 'c'))
test "line 174", (t) => t.falsy( inList('a', 'b', 'c'))

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

	test "line 194", (t) => t.falsy(isString(undef))
	test "line 195", (t) => t.falsy(isString(h))
	test "line 196", (t) => t.falsy(isString(l))
	test "line 197", (t) => t.falsy(isString(o))
	test "line 198", (t) => t.falsy(isString(n))
	test "line 199", (t) => t.falsy(isString(n2))

	test "line 201", (t) => t.truthy(isString(s))
	test "line 202", (t) => t.truthy(isString(s2))

	test "line 204", (t) => t.truthy(isNonEmptyString('abc'))
	test "line 205", (t) => t.truthy(isNonEmptyString('abc def'))
	test "line 206", (t) => t.falsy(isNonEmptyString(''))
	test "line 207", (t) => t.falsy(isNonEmptyString('  '))

	test "line 209", (t) => t.truthy(isIdentifier('abc'))
	test "line 210", (t) => t.truthy(isIdentifier('_Abc'))
	test "line 211", (t) => t.falsy(isIdentifier('abc def'))
	test "line 212", (t) => t.falsy(isIdentifier('abc-def'))
	test "line 213", (t) => t.falsy(isIdentifier('class.method'))

	test "line 215", (t) => t.truthy(isFunctionName('abc'))
	test "line 216", (t) => t.truthy(isFunctionName('_Abc'))
	test "line 217", (t) => t.falsy(isFunctionName('abc def'))
	test "line 218", (t) => t.falsy(isFunctionName('abc-def'))
	test "line 219", (t) => t.falsy(isFunctionName('D()'))
	test "line 220", (t) => t.truthy(isFunctionName('class.method'))

	generatorFunc = () ->
		yield 1
		yield 2
		yield 3
		return

	test "line 228", (t) => t.truthy(isIterable(generatorFunc()))

	test "line 230", (t) => t.falsy(isNumber(undef))
	test "line 231", (t) => t.falsy(isNumber(null))
	test "line 232", (t) => t.falsy(isNumber(NaN))
	test "line 233", (t) => t.falsy(isNumber(h))
	test "line 234", (t) => t.falsy(isNumber(l))
	test "line 235", (t) => t.falsy(isNumber(o))
	test "line 236", (t) => t.truthy(isNumber(n))
	test "line 237", (t) => t.truthy(isNumber(n2))
	test "line 238", (t) => t.falsy(isNumber(s))
	test "line 239", (t) => t.falsy(isNumber(s2))

	test "line 241", (t) => t.truthy(isNumber(42.0, {min: 42.0}))
	test "line 242", (t) => t.falsy(isNumber(42.0, {min: 42.1}))
	test "line 243", (t) => t.truthy(isNumber(42.0, {max: 42.0}))
	test "line 244", (t) => t.falsy(isNumber(42.0, {max: 41.9}))

	test "line 246", (t) => t.truthy(isInteger(42))
	test "line 247", (t) => t.truthy(isInteger(new Number(42)))
	test "line 248", (t) => t.falsy(isInteger('abc'))
	test "line 249", (t) => t.falsy(isInteger({}))
	test "line 250", (t) => t.falsy(isInteger([]))
	test "line 251", (t) => t.truthy(isInteger(42, {min:  0}))
	test "line 252", (t) => t.falsy(isInteger(42, {min: 50}))
	test "line 253", (t) => t.truthy(isInteger(42, {max: 50}))
	test "line 254", (t) => t.falsy(isInteger(42, {max:  0}))

	test "line 256", (t) => t.truthy(isHash(h))
	test "line 257", (t) => t.falsy(isHash(l))
	test "line 258", (t) => t.falsy(isHash(o))
	test "line 259", (t) => t.falsy(isHash(n))
	test "line 260", (t) => t.falsy(isHash(n2))
	test "line 261", (t) => t.falsy(isHash(s))
	test "line 262", (t) => t.falsy(isHash(s2))

	test "line 264", (t) => t.falsy(isArray(h))
	test "line 265", (t) => t.truthy(isArray(l))
	test "line 266", (t) => t.falsy(isArray(o))
	test "line 267", (t) => t.falsy(isArray(n))
	test "line 268", (t) => t.falsy(isArray(n2))
	test "line 269", (t) => t.falsy(isArray(s))
	test "line 270", (t) => t.falsy(isArray(s2))

	test "line 272", (t) => t.truthy(isBoolean(true))
	test "line 273", (t) => t.truthy(isBoolean(false))
	test "line 274", (t) => t.falsy(isBoolean(42))
	test "line 275", (t) => t.falsy(isBoolean("true"))

	test "line 277", (t) => t.truthy(isClass(NewClass))
	test "line 278", (t) => t.falsy(isClass(o))

	test "line 280", (t) => t.truthy(isConstructor(NewClass))
	test "line 281", (t) => t.falsy(isConstructor(o))

	test "line 283", (t) => t.truthy(isFunction(() -> 42))
	test "line 284", (t) => t.truthy(isFunction(() => 42))
	test "line 285", (t) => t.falsy(isFunction(42))
	test "line 286", (t) => t.falsy(isFunction(n))

	test "line 288", (t) => t.truthy(isRegExp(/^abc$/))
	test "line 289", (t) => t.truthy(isRegExp(///^ \s* where \s+ areyou $///))
	test "line 290", (t) => t.falsy(isRegExp(42))
	test "line 291", (t) => t.falsy(isRegExp('abc'))
	test "line 292", (t) => t.falsy(isRegExp([1,'a']))
	test "line 293", (t) => t.falsy(isRegExp({a:1, b:'ccc'}))
	test "line 294", (t) => t.falsy(isRegExp(undef))
	test "line 295", (t) => t.truthy(isRegExp(/\.coffee/))

	test "line 297", (t) => t.falsy(isObject(h))
	test "line 298", (t) => t.falsy(isObject(l))
	test "line 299", (t) => t.truthy(isObject(o))
	test "line 300", (t) => t.truthy(isObject(o, ['name','doIt']))
	test "line 301", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 302", (t) => t.falsy(isObject(o, ['name','doIt','missing']))
	test "line 303", (t) => t.falsy(isObject(o, "name doIt missing"))
	test "line 304", (t) => t.falsy(isObject(n))
	test "line 305", (t) => t.falsy(isObject(n2))
	test "line 306", (t) => t.falsy(isObject(s))
	test "line 307", (t) => t.falsy(isObject(s2))
	test "line 308", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 309", (t) => t.truthy(isObject(o, "name doIt meth"))
	test "line 310", (t) => t.truthy(isObject(o, "name &doIt &meth"))
	test "line 311", (t) => t.falsy(isObject(o, "&name"))

	test "line 313", (t) => t.deepEqual(jsType(undef), [undef, 'undef'])
	test "line 314", (t) => t.deepEqual(jsType(null),  [undef, 'null'])
	test "line 315", (t) => t.deepEqual(jsType(s), ['string', undef])
	test "line 316", (t) => t.deepEqual(jsType(''), ['string', 'empty'])
	test "line 317", (t) => t.deepEqual(jsType("\t\t"), ['string', 'empty'])
	test "line 318", (t) => t.deepEqual(jsType("  "), ['string', 'empty'])
	test "line 319", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 320", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 321", (t) => t.deepEqual(jsType(3.14159), ['number', undef])
	test "line 322", (t) => t.deepEqual(jsType(42), ['number', 'integer'])
	test "line 323", (t) => t.deepEqual(jsType(true), ['boolean', undef])
	test "line 324", (t) => t.deepEqual(jsType(false), ['boolean', undef])
	test "line 325", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 326", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 327", (t) => t.deepEqual(jsType(l), ['array', undef])
	test "line 328", (t) => t.deepEqual(jsType([]), ['array', 'empty'])
	test "line 329", (t) => t.deepEqual(jsType(/abc/), ['regexp', undef])

	func1 = (x) ->
		return

	func2 = (x) =>
		return

	# --- NOTE: regular functions can't be distinguished from constructors
	test "line 338", (t) => t.deepEqual(jsType(func1), ['class', undef])

	test "line 340", (t) => t.deepEqual(jsType(func2), ['function', undef])
	test "line 341", (t) => t.deepEqual(jsType(NewClass), ['class', undef])
	test "line 342", (t) => t.deepEqual(jsType(o), ['object', undef])
	)()

# ---------------------------------------------------------------------------

test "line 347", (t) => t.truthy(isEmpty(''))
test "line 348", (t) => t.truthy(isEmpty('  \t\t'))
test "line 349", (t) => t.truthy(isEmpty([]))
test "line 350", (t) => t.truthy(isEmpty({}))

test "line 352", (t) => t.truthy(nonEmpty('a'))
test "line 353", (t) => t.truthy(nonEmpty('.'))
test "line 354", (t) => t.truthy(nonEmpty([2]))
test "line 355", (t) => t.truthy(nonEmpty({width: 2}))

# ---------------------------------------------------------------------------

test "line 359", (t) => t.deepEqual(blockToArray(undef), [])
test "line 360", (t) => t.deepEqual(blockToArray(''), [])
test "line 361", (t) => t.deepEqual(blockToArray('a'), ['a'])
test "line 362", (t) => t.deepEqual(blockToArray("a\nb"), ['a','b'])
test "line 363", (t) => t.deepEqual(blockToArray("a\r\nb"), ['a','b'])
test "line 364", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 369", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 374", (t) => t.deepEqual(blockToArray("abc\n\nxyz"), [
	'abc'
	''
	'xyz'
	])

# ---------------------------------------------------------------------------

test "line 382", (t) => t.deepEqual(toArray("abc\ndef"), ['abc','def'])
test "line 383", (t) => t.deepEqual(toArray(['a','b']), ['a','b'])

test "line 385", (t) => t.deepEqual(toArray(["a\nb","c\nd"]), ['a','b','c','d'])

# ---------------------------------------------------------------------------

test "line 389", (t) => t.deepEqual(arrayToBlock(undef), '')
test "line 390", (t) => t.deepEqual(arrayToBlock([]), '')
test "line 391", (t) => t.deepEqual(arrayToBlock([undef]), '')
test "line 392", (t) => t.deepEqual(arrayToBlock(['a  ','b\t\t']), "a\nb")
test "line 393", (t) => t.deepEqual(arrayToBlock(['a','b','c']), "a\nb\nc")
test "line 394", (t) => t.deepEqual(arrayToBlock(['a',undef,'b','c']), "a\nb\nc")
test "line 395", (t) => t.deepEqual(arrayToBlock([undef,'a','b','c',undef]), "a\nb\nc")

# ---------------------------------------------------------------------------

test "line 399", (t) => t.deepEqual(toBlock(['abc','def']), "abc\ndef")
test "line 400", (t) => t.deepEqual(toBlock("abc\ndef"), "abc\ndef")

# ---------------------------------------------------------------------------

test "line 404", (t) => t.is(rtrim("abc"), "abc")
test "line 405", (t) => t.is(rtrim("  abc"), "  abc")
test "line 406", (t) => t.is(rtrim("abc  "), "abc")
test "line 407", (t) => t.is(rtrim("  abc  "), "  abc")

# ---------------------------------------------------------------------------

test "line 411", (t) => t.deepEqual(words(''), [])
test "line 412", (t) => t.deepEqual(words('  \t\t'), [])
test "line 413", (t) => t.deepEqual(words('a b c'), ['a', 'b', 'c'])
test "line 414", (t) => t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c'])
test "line 415", (t) => t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd'])
test "line 416", (t) => t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word'])

test "line 418", (t) => t.truthy hasChar('abc', 'b')
test "line 419", (t) => t.falsy  hasChar('abc', 'x')
test "line 420", (t) => t.falsy  hasChar("\t\t", ' ')

# ---------------------------------------------------------------------------

test "line 424", (t) => t.is(quoted('abc'), "'abc'")
test "line 425", (t) => t.is(quoted('"abc"'), "'\"abc\"'")
test "line 426", (t) => t.is(quoted("'abc'"), "\"'abc'\"")
test "line 427", (t) => t.is(quoted("'\"abc\"'"), "<'\"abc\"'>")
test "line 428", (t) => t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>")

# ---------------------------------------------------------------------------

test "line 432", (t) => t.deepEqual(getOptions(), {})
test "line 433", (t) => t.deepEqual(getOptions(undef, {x:1}), {x:1})
test "line 434", (t) => t.deepEqual(getOptions({x:1}, {x:3,y:4}), {x:1,y:4})
test "line 435", (t) => t.deepEqual(getOptions('asText'), {asText: true})
test "line 436", (t) => t.deepEqual(getOptions('!binary'), {binary: false})
test "line 437", (t) => t.deepEqual(getOptions('label=this'), {label: 'this'})
test "line 438", (t) => t.deepEqual(getOptions('width=42'), {width: 42})
test "line 439", (t) => t.deepEqual(getOptions('asText !binary label=this'), {
	asText: true
	binary: false
	label: 'this'
	})

# ---------------------------------------------------------------------------

test "line 447", (t) => t.deepEqual(range(3), [0,1,2])

# ---------------------------------------------------------------------------

utest.truthy 451, isHashComment('#')
utest.truthy 452, isHashComment('# a comment')
utest.truthy 453, isHashComment('#\ta comment')
utest.falsy  454, isHashComment('#comment')
utest.falsy  455, isHashComment('')
utest.falsy  456, isHashComment('a comment')

# ---------------------------------------------------------------------------

utest.truthy 460, isEmpty('')
utest.truthy 461, isEmpty('  \t\t')
utest.truthy 462, isEmpty([])
utest.truthy 463, isEmpty({})

utest.truthy 465, nonEmpty('a')
utest.truthy 466, nonEmpty('.')
utest.truthy 467, nonEmpty([2])
utest.truthy 468, nonEmpty({width: 2})

utest.truthy 470, isNonEmptyString('abc')
utest.falsy  471, isNonEmptyString(undef)
utest.falsy  472, isNonEmptyString('')
utest.falsy  473, isNonEmptyString('   ')
utest.falsy  474, isNonEmptyString("\t\t\t")
utest.falsy  475, isNonEmptyString(5)

# ---------------------------------------------------------------------------

utest.truthy 479, oneof('a', 'a', 'b', 'c')
utest.truthy 480, oneof('b', 'a', 'b', 'c')
utest.truthy 481, oneof('c', 'a', 'b', 'c')
utest.falsy  482, oneof('d', 'a', 'b', 'c')
utest.falsy  483, oneof('x')

# ---------------------------------------------------------------------------

utest.equal 487, uniq([1,2,2,3,3]), [1,2,3]
utest.equal 488, uniq(['a','b','b','c','c']),['a','b','c']

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

utest.equal 503, rtrim("abc"), "abc"
utest.equal 504, rtrim("  abc"), "  abc"
utest.equal 505, rtrim("abc  "), "abc"
utest.equal 506, rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

utest.equal 510, words('a b c'), ['a', 'b', 'c']
utest.equal 511, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

utest.equal 515, escapeStr("\t\tXXX\n"), "→→XXX®"
hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}
utest.equal 521, escapeStr("\thas quote: \"\nnext line", hEsc), \
	"\\thas quote: \\\"\\nnext line"

# ---------------------------------------------------------------------------

utest.equal 526, rtrunc('/user/lib/.env', 5), '/user/lib'
utest.equal 527, ltrunc('abcdefg', 3), 'defg'

utest.equal 529, CWS("""
		abc
		def
				ghi
		"""), "abc def ghi"

# ---------------------------------------------------------------------------

utest.truthy 537, isArrayOfStrings([])
utest.truthy 538, isArrayOfStrings(['a','b','c'])
utest.truthy 539, isArrayOfStrings(['a',undef, null, 'b'])

# ---------------------------------------------------------------------------

utest.truthy 543, isArrayOfArrays([])
utest.truthy 544, isArrayOfArrays([[], []])
utest.truthy 545, isArrayOfArrays([[1,2], []])
utest.truthy 546, isArrayOfArrays([[1,2,[1,2,3]], []])
utest.truthy 547, isArrayOfArrays([[1,2], undef, null, []])

utest.falsy  549, isArrayOfArrays({})
utest.falsy  550, isArrayOfArrays([1,2,3])
utest.falsy  551, isArrayOfArrays([[1,2,[3,4]], 4])
utest.falsy  552, isArrayOfArrays([[1,2,[3,4]], [], {a:1,b:2}])

utest.truthy 554, isArrayOfArrays([[1,2],[3,4],[4,5]], 2)
utest.falsy  555, isArrayOfArrays([[1,2],[3],[4,5]], 2)
utest.falsy  556, isArrayOfArrays([[1,2],[3,4,5],[4,5]], 2)

# ---------------------------------------------------------------------------

utest.truthy 560, isArrayOfHashes([])
utest.truthy 561, isArrayOfHashes([{}, {}])
utest.truthy 562, isArrayOfHashes([{a:1, b:2}, {}])
utest.truthy 563, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}])
utest.truthy 564, isArrayOfHashes([{a:1, b:2}, undef, null, {}])

utest.falsy  566, isArrayOfHashes({})
utest.falsy  567, isArrayOfHashes([1,2,3])
utest.falsy  568, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, 4])
utest.falsy  569, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}, [1,2]])

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

	utest.truthy 588, isHash(h)
	utest.falsy  589, isHash(l)
	utest.falsy  590, isHash(o)
	utest.falsy  591, isHash(n)
	utest.falsy  592, isHash(n2)
	utest.falsy  593, isHash(s)
	utest.falsy  594, isHash(s2)

	utest.falsy  596, isArray(h)
	utest.truthy 597, isArray(l)
	utest.falsy  598, isArray(o)
	utest.falsy  599, isArray(n)
	utest.falsy  600, isArray(n2)
	utest.falsy  601, isArray(s)
	utest.falsy  602, isArray(s2)

	utest.falsy  604, isString(undef)
	utest.falsy  605, isString(h)
	utest.falsy  606, isString(l)
	utest.falsy  607, isString(o)
	utest.falsy  608, isString(n)
	utest.falsy  609, isString(n2)
	utest.truthy 610, isString(s)
	utest.truthy 611, isString(s2)

	utest.falsy  613, isObject(h)
	utest.falsy  614, isObject(l)
	utest.truthy 615, isObject(o)
	utest.truthy 616, isObject(o, ['name','doIt'])
	utest.falsy  617, isObject(o, ['name','doIt','missing'])
	utest.falsy  618, isObject(n)
	utest.falsy  619, isObject(n2)
	utest.falsy  620, isObject(s)
	utest.falsy  621, isObject(s2)

	utest.falsy  623, isNumber(h)
	utest.falsy  624, isNumber(l)
	utest.falsy  625, isNumber(o)
	utest.truthy 626, isNumber(n)
	utest.truthy 627, isNumber(n2)
	utest.falsy  628, isNumber(s)
	utest.falsy  629, isNumber(s2)

	utest.truthy 631, isNumber(42.0, {min: 42.0})
	utest.falsy  632, isNumber(42.0, {min: 42.1})
	utest.truthy 633, isNumber(42.0, {max: 42.0})
	utest.falsy  634, isNumber(42.0, {max: 41.9})
	)()

# ---------------------------------------------------------------------------

utest.truthy 639, isFunction(() -> pass)
utest.falsy  640, isFunction(23)

utest.truthy 642, isInteger(42)
utest.truthy 643, isInteger(new Number(42))
utest.falsy  644, isInteger('abc')
utest.falsy  645, isInteger({})
utest.falsy  646, isInteger([])
utest.truthy 647, isInteger(42, {min:  0})
utest.falsy  648, isInteger(42, {min: 50})
utest.truthy 649, isInteger(42, {max: 50})
utest.falsy  650, isInteger(42, {max:  0})

# ---------------------------------------------------------------------------

utest.equal 654, OL(undef), "undef"
utest.equal 655, OL("\t\tabc\nxyz"), "'→→abc®xyz'"
utest.equal 656, OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

utest.equal 660, CWS("""
		a utest
		error message
		"""), "a utest error message"

# ---------------------------------------------------------------------------
# test isRegExp()

utest.truthy 668, isRegExp(/^abc$/)
utest.truthy 669, isRegExp(///^
		\s*
		where
		\s+
		areyou
		$///)
utest.falsy  675, isRegExp(42)
utest.falsy  676, isRegExp('abc')
utest.falsy  677, isRegExp([1,'a'])
utest.falsy  678, isRegExp({a:1, b:'ccc'})
utest.falsy  679, isRegExp(undef)

utest.truthy 681, isRegExp(/\.coffee/)

# ---------------------------------------------------------------------------

utest.equal 685, extractMatches("..3 and 4 plus 5", /\d+/g, parseInt),
	[3, 4, 5]
utest.equal 687, extractMatches("And This Is A String", /A/g), ['A','A']

# ---------------------------------------------------------------------------

utest.truthy 691, notdefined(undef)
utest.truthy 692, notdefined(null)
utest.truthy 693, defined('')
utest.truthy 694, defined(5)
utest.truthy 695, defined([])
utest.truthy 696, defined({})

utest.falsy 698, defined(undef)
utest.falsy 699, defined(null)
utest.falsy 700, notdefined('')
utest.falsy 701, notdefined(5)
utest.falsy 702, notdefined([])
utest.falsy 703, notdefined({})

# ---------------------------------------------------------------------------

utest.truthy 707, isIterable([])
utest.truthy 708, isIterable(['a','b'])

gen = () ->
	yield 1
	yield 2
	yield 3
	return

utest.truthy 716, isIterable(gen())

# ---------------------------------------------------------------------------

(() ->
	class MyClass
		constructor: (str) ->
			@mystr = str

	utest.equal 725, className(MyClass), 'MyClass'

	)()

# ---------------------------------------------------------------------------

utest.equal 731, getOptions('a b c'), {'a':true, 'b':true, 'c':true}
utest.equal 732, getOptions('abc'), {'abc':true}
utest.equal 733, getOptions({'a':true, 'b':false, 'c':42}), {'a':true, 'b':false, 'c':42}
utest.equal 734, getOptions(), {}

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
	utest.equal 749, lResult, ['ABC','DEF', 'GHI']
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

	utest.equal 765, lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		lResult.push line.toUpperCase()
		return false
	utest.equal 774, lResult, ['ABC','DEF', 'GHI']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		if (line == 'ghi')
			return true
		lResult.push line.toUpperCase()
		return false

	utest.equal 786, lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line, hInfo) =>
		if (line == 'ghi')
			return true
		lResult.push "#{hInfo.lineNum} #{line.toUpperCase()} #{hInfo.nextLine}"
		return false

	utest.equal 798, lResult, ['1 ABC def','2 DEF ghi']
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
	utest.equal 812, newblock, """
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
	utest.equal 830, newblock, """
		ABC
		GHI
		"""
	)()

(() =>
	item = ['abc','def','ghi']
	newblock = mapEachLine item, (line) =>
		return line.toUpperCase()
	utest.equal 840, newblock, [
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
	utest.equal 854, newblock, [
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
	utest.equal 869, newblock, [
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

	utest.equal 895, removeKeys(hAST, ['start','end']), {
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

	utest.equal 926, removeKeys(hAST, ['start','end']), {
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

	utest.equal 966, hToDo.task, 'go shopping'
	utest.equal 967, h.task, 'GO SHOPPING'

	h.task = 'do something'
	utest.equal 970, hToDo.task, 'do something'
	utest.equal 971, h.task, 'DO SOMETHING'

	h.task = 'nothing'
	utest.equal 974, hToDo.task, 'do something'
	utest.equal 975, h.task, 'DO SOMETHING'

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

	utest.equal 996, await run1(), 'abc,def,ghi'
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

	utest.equal 1013, await run2(), 'def,ghi'
	)()
