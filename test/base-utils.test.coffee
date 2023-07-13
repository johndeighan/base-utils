# base-utils.test.coffee

import test from 'ava'

import {utest} from '@jdeighan/base-utils/utest'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, pass, defined, notdefined, tabify, untabify, prefixBlock,
	escapeStr, OL, OLS, inList,  isHashComment, splitPrefix, hasPrefix,
	isString, isNumber, isInteger, isHash, isArray, isBoolean,
	isClass, isConstructor, removeKeys, extractMatches,
	isFunction, isRegExp, isObject, jsType, deepEqual,
	isEmpty, nonEmpty, isNonEmptyString, isIdentifier,
	isFunctionName, isIterable, hashFromString,
	blockToArray, arrayToBlock, toArray, toBlock,
	rtrim, words, hasChar, quoted, getOptions, range,
	oneof, uniq, rtrunc, ltrunc, CWS, className,
	isArrayOfStrings, isArrayOfHashes, isArrayOfArrays,
	forEachLine, mapEachLine, getProxy, sleep, schedule,
	} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

test "line 24", (t) => t.truthy(deepEqual({a:1, b:2}, {a:1, b:2}))
test "line 25", (t) => t.falsy (deepEqual({a:1, b:2}, {a:1, b:3}))

# ---------------------------------------------------------------------------

test "line 29", (t) => t.truthy(isHashComment('   # something'))
test "line 30", (t) => t.truthy(isHashComment('   #'))
test "line 31", (t) => t.falsy(isHashComment('   abc'))
test "line 32", (t) => t.falsy(isHashComment('#abc'))

test "line 34", (t) => t.is(undef, undefined)

test "line 36", (t) => t.truthy(isFunction(pass))

(() ->
	passTest = () =>
		pass()
	test "line 41", (t) => t.notThrows(passTest, "pass fails")
	)()

test "line 44", (t) => t.truthy(defined(''))
test "line 45", (t) => t.truthy(defined(5))
test "line 46", (t) => t.truthy(defined([]))
test "line 47", (t) => t.truthy(defined({}))
test "line 48", (t) => t.falsy(defined(undef))
test "line 49", (t) => t.falsy(defined(null))

test "line 51", (t) => t.truthy(notdefined(undef))
test "line 52", (t) => t.truthy(notdefined(null))
test "line 53", (t) => t.falsy(notdefined(''))
test "line 54", (t) => t.falsy(notdefined(5))
test "line 55", (t) => t.falsy(notdefined([]))
test "line 56", (t) => t.falsy(notdefined({}))

# ---------------------------------------------------------------------------

test "line 60", (t) => t.deepEqual(splitPrefix("abc"),     ["", "abc"])
test "line 61", (t) => t.deepEqual(splitPrefix("\tabc"),   ["\t", "abc"])
test "line 62", (t) => t.deepEqual(splitPrefix("\t\tabc"), ["\t\t", "abc"])
test "line 63", (t) => t.deepEqual(splitPrefix(""),        ["", ""])
test "line 64", (t) => t.deepEqual(splitPrefix("\t\t\t"),  ["", ""])
test "line 65", (t) => t.deepEqual(splitPrefix("\t \t"),   ["", ""])
test "line 66", (t) => t.deepEqual(splitPrefix("   "),     ["", ""])

# ---------------------------------------------------------------------------

test "line 70", (t) => t.falsy (hasPrefix("abc"))
test "line 71", (t) => t.truthy(hasPrefix("   abc"))

# ---------------------------------------------------------------------------

(() ->
	prefix = '   '    # 3 spaces

	test "line 78", (t) => t.is(untabify("""
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

	utest.equal 94, tabify("""
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

	utest.equal 111, tabify("""
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

	utest.equal 127, untabify("""
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

test "line 140", (t) => t.is(prefixBlock("""
	abc
	def
	""", '--'), """
	--abc
	--def
	""")

# ---------------------------------------------------------------------------

test "line 150", (t) => t.is(escapeStr("\t\tXXX\n"), "→→XXX®")

hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}

test "line 158", (t) => t.is(escapeStr("\thas quote: \"\nnext line", hEsc),
	"\\thas quote: \\\"\\nnext line")

# ---------------------------------------------------------------------------

test "line 163", (t) => t.is(OL(undef), "undef")
test "line 164", (t) => t.is(OL("\t\tabc\nxyz"), "'→→abc®xyz'")
test "line 165", (t) => t.is(OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}')

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

test "line 173", (t) => t.is(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}')

# ---------------------------------------------------------------------------

test "line 177", (t) => t.is(OLS(['abc', 3]), "'abc',3")
test "line 178", (t) => t.is(OLS([]), "")
test "line 179", (t) => t.is(OLS([undef, {a:1}]), 'undef,{"a":1}')

# ---------------------------------------------------------------------------

test "line 99",  (t) => t.truthy(inList('a', 'b', 'a', 'c'))
test "line 184", (t) => t.falsy( inList('a', 'b', 'c'))

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

	test "line 204", (t) => t.falsy(isString(undef))
	test "line 205", (t) => t.falsy(isString(h))
	test "line 206", (t) => t.falsy(isString(l))
	test "line 207", (t) => t.falsy(isString(o))
	test "line 208", (t) => t.falsy(isString(n))
	test "line 209", (t) => t.falsy(isString(n2))

	test "line 211", (t) => t.truthy(isString(s))
	test "line 212", (t) => t.truthy(isString(s2))

	test "line 214", (t) => t.truthy(isNonEmptyString('abc'))
	test "line 215", (t) => t.truthy(isNonEmptyString('abc def'))
	test "line 216", (t) => t.falsy(isNonEmptyString(''))
	test "line 217", (t) => t.falsy(isNonEmptyString('  '))

	test "line 219", (t) => t.truthy(isIdentifier('abc'))
	test "line 220", (t) => t.truthy(isIdentifier('_Abc'))
	test "line 221", (t) => t.falsy(isIdentifier('abc def'))
	test "line 222", (t) => t.falsy(isIdentifier('abc-def'))
	test "line 223", (t) => t.falsy(isIdentifier('class.method'))

	test "line 225", (t) => t.truthy(isFunctionName('abc'))
	test "line 226", (t) => t.truthy(isFunctionName('_Abc'))
	test "line 227", (t) => t.falsy(isFunctionName('abc def'))
	test "line 228", (t) => t.falsy(isFunctionName('abc-def'))
	test "line 229", (t) => t.falsy(isFunctionName('D()'))
	test "line 230", (t) => t.truthy(isFunctionName('class.method'))

	generatorFunc = () ->
		yield 1
		yield 2
		yield 3
		return

	test "line 238", (t) => t.truthy(isIterable(generatorFunc()))

	test "line 240", (t) => t.falsy(isNumber(undef))
	test "line 241", (t) => t.falsy(isNumber(null))
	test "line 242", (t) => t.falsy(isNumber(NaN))
	test "line 243", (t) => t.falsy(isNumber(h))
	test "line 244", (t) => t.falsy(isNumber(l))
	test "line 245", (t) => t.falsy(isNumber(o))
	test "line 246", (t) => t.truthy(isNumber(n))
	test "line 247", (t) => t.truthy(isNumber(n2))
	test "line 248", (t) => t.falsy(isNumber(s))
	test "line 249", (t) => t.falsy(isNumber(s2))

	test "line 251", (t) => t.truthy(isNumber(42.0, {min: 42.0}))
	test "line 252", (t) => t.falsy(isNumber(42.0, {min: 42.1}))
	test "line 253", (t) => t.truthy(isNumber(42.0, {max: 42.0}))
	test "line 254", (t) => t.falsy(isNumber(42.0, {max: 41.9}))

	test "line 256", (t) => t.truthy(isInteger(42))
	test "line 257", (t) => t.truthy(isInteger(new Number(42)))
	test "line 258", (t) => t.falsy(isInteger('abc'))
	test "line 259", (t) => t.falsy(isInteger({}))
	test "line 260", (t) => t.falsy(isInteger([]))
	test "line 261", (t) => t.truthy(isInteger(42, {min:  0}))
	test "line 262", (t) => t.falsy(isInteger(42, {min: 50}))
	test "line 263", (t) => t.truthy(isInteger(42, {max: 50}))
	test "line 264", (t) => t.falsy(isInteger(42, {max:  0}))

	test "line 266", (t) => t.truthy(isHash(h))
	test "line 267", (t) => t.falsy(isHash(l))
	test "line 268", (t) => t.falsy(isHash(o))
	test "line 269", (t) => t.falsy(isHash(n))
	test "line 270", (t) => t.falsy(isHash(n2))
	test "line 271", (t) => t.falsy(isHash(s))
	test "line 272", (t) => t.falsy(isHash(s2))

	test "line 274", (t) => t.falsy(isArray(h))
	test "line 275", (t) => t.truthy(isArray(l))
	test "line 276", (t) => t.falsy(isArray(o))
	test "line 277", (t) => t.falsy(isArray(n))
	test "line 278", (t) => t.falsy(isArray(n2))
	test "line 279", (t) => t.falsy(isArray(s))
	test "line 280", (t) => t.falsy(isArray(s2))

	test "line 282", (t) => t.truthy(isBoolean(true))
	test "line 283", (t) => t.truthy(isBoolean(false))
	test "line 284", (t) => t.falsy(isBoolean(42))
	test "line 285", (t) => t.falsy(isBoolean("true"))

	test "line 287", (t) => t.truthy(isClass(NewClass))
	test "line 288", (t) => t.falsy(isClass(o))

	test "line 290", (t) => t.truthy(isConstructor(NewClass))
	test "line 291", (t) => t.falsy(isConstructor(o))

	test "line 293", (t) => t.truthy(isFunction(() -> 42))
	test "line 294", (t) => t.truthy(isFunction(() => 42))
	test "line 295", (t) => t.falsy(isFunction(undef))
	test "line 296", (t) => t.falsy(isFunction(null))
	test "line 297", (t) => t.falsy(isFunction(42))
	test "line 298", (t) => t.falsy(isFunction(n))

	test "line 300", (t) => t.truthy(isRegExp(/^abc$/))
	test "line 301", (t) => t.truthy(isRegExp(///^ \s* where \s+ areyou $///))
	test "line 302", (t) => t.falsy(isRegExp(42))
	test "line 303", (t) => t.falsy(isRegExp('abc'))
	test "line 304", (t) => t.falsy(isRegExp([1,'a']))
	test "line 305", (t) => t.falsy(isRegExp({a:1, b:'ccc'}))
	test "line 306", (t) => t.falsy(isRegExp(undef))
	test "line 307", (t) => t.truthy(isRegExp(/\.coffee/))

	test "line 309", (t) => t.falsy(isObject(h))
	test "line 310", (t) => t.falsy(isObject(l))
	test "line 311", (t) => t.truthy(isObject(o))
	test "line 312", (t) => t.truthy(isObject(o, ['name','doIt']))
	test "line 313", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 314", (t) => t.falsy(isObject(o, ['name','doIt','missing']))
	test "line 315", (t) => t.falsy(isObject(o, "name doIt missing"))
	test "line 316", (t) => t.falsy(isObject(n))
	test "line 317", (t) => t.falsy(isObject(n2))
	test "line 318", (t) => t.falsy(isObject(s))
	test "line 319", (t) => t.falsy(isObject(s2))
	test "line 320", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 321", (t) => t.truthy(isObject(o, "name doIt meth"))
	test "line 322", (t) => t.truthy(isObject(o, "name &doIt &meth"))
	test "line 323", (t) => t.falsy(isObject(o, "&name"))

	test "line 325", (t) => t.deepEqual(jsType(undef), [undef, 'undef'])
	test "line 326", (t) => t.deepEqual(jsType(null),  [undef, 'null'])
	test "line 327", (t) => t.deepEqual(jsType(s), ['string', undef])
	test "line 328", (t) => t.deepEqual(jsType(''), ['string', 'empty'])
	test "line 329", (t) => t.deepEqual(jsType("\t\t"), ['string', 'empty'])
	test "line 330", (t) => t.deepEqual(jsType("  "), ['string', 'empty'])
	test "line 331", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 332", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 333", (t) => t.deepEqual(jsType(3.14159), ['number', undef])
	test "line 334", (t) => t.deepEqual(jsType(42), ['number', 'integer'])
	test "line 335", (t) => t.deepEqual(jsType(true), ['boolean', undef])
	test "line 336", (t) => t.deepEqual(jsType(false), ['boolean', undef])
	test "line 337", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 338", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 339", (t) => t.deepEqual(jsType(l), ['array', undef])
	test "line 340", (t) => t.deepEqual(jsType([]), ['array', 'empty'])
	test "line 341", (t) => t.deepEqual(jsType(/abc/), ['regexp', undef])

	func1 = (x) ->
		return

	func2 = (x) =>
		return

	# --- NOTE: regular functions can't be distinguished from constructors
	test "line 350", (t) => t.deepEqual(jsType(func1), ['class', undef])

	test "line 352", (t) => t.deepEqual(jsType(func2), ['function', undef])
	test "line 353", (t) => t.deepEqual(jsType(NewClass), ['class', undef])
	test "line 354", (t) => t.deepEqual(jsType(o), ['object', undef])
	)()

# ---------------------------------------------------------------------------

test "line 359", (t) => t.truthy(isEmpty(''))
test "line 360", (t) => t.truthy(isEmpty('  \t\t'))
test "line 361", (t) => t.truthy(isEmpty([]))
test "line 362", (t) => t.truthy(isEmpty({}))

test "line 364", (t) => t.truthy(nonEmpty('a'))
test "line 365", (t) => t.truthy(nonEmpty('.'))
test "line 366", (t) => t.truthy(nonEmpty([2]))
test "line 367", (t) => t.truthy(nonEmpty({width: 2}))

# ---------------------------------------------------------------------------

test "line 371", (t) => t.deepEqual(blockToArray(undef), [])
test "line 372", (t) => t.deepEqual(blockToArray(''), [])
test "line 373", (t) => t.deepEqual(blockToArray('a'), ['a'])
test "line 374", (t) => t.deepEqual(blockToArray("a\nb"), ['a','b'])
test "line 375", (t) => t.deepEqual(blockToArray("a\r\nb"), ['a','b'])
test "line 376", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 381", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 386", (t) => t.deepEqual(blockToArray("abc\n\nxyz"), [
	'abc'
	''
	'xyz'
	])

# ---------------------------------------------------------------------------

test "line 394", (t) => t.deepEqual(toArray("abc\ndef"), ['abc','def'])
test "line 395", (t) => t.deepEqual(toArray(['a','b']), ['a','b'])

test "line 397", (t) => t.deepEqual(toArray(["a\nb","c\nd"]), ['a','b','c','d'])

# ---------------------------------------------------------------------------

test "line 401", (t) => t.deepEqual(arrayToBlock(undef), '')
test "line 402", (t) => t.deepEqual(arrayToBlock([]), '')
test "line 403", (t) => t.deepEqual(arrayToBlock([undef]), '')
test "line 404", (t) => t.deepEqual(arrayToBlock(['a  ','b\t\t']), "a\nb")
test "line 405", (t) => t.deepEqual(arrayToBlock(['a','b','c']), "a\nb\nc")
test "line 406", (t) => t.deepEqual(arrayToBlock(['a',undef,'b','c']), "a\nb\nc")
test "line 407", (t) => t.deepEqual(arrayToBlock([undef,'a','b','c',undef]), "a\nb\nc")

# ---------------------------------------------------------------------------

test "line 411", (t) => t.deepEqual(toBlock(['abc','def']), "abc\ndef")
test "line 412", (t) => t.deepEqual(toBlock("abc\ndef"), "abc\ndef")

# ---------------------------------------------------------------------------

test "line 416", (t) => t.is(rtrim("abc"), "abc")
test "line 417", (t) => t.is(rtrim("  abc"), "  abc")
test "line 418", (t) => t.is(rtrim("abc  "), "abc")
test "line 419", (t) => t.is(rtrim("  abc  "), "  abc")

# ---------------------------------------------------------------------------

test "line 423", (t) => t.deepEqual(words(''), [])
test "line 424", (t) => t.deepEqual(words('  \t\t'), [])
test "line 425", (t) => t.deepEqual(words('a b c'), ['a', 'b', 'c'])
test "line 426", (t) => t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c'])
test "line 427", (t) => t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd'])
test "line 428", (t) => t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word'])

test "line 430", (t) => t.truthy hasChar('abc', 'b')
test "line 431", (t) => t.falsy  hasChar('abc', 'x')
test "line 432", (t) => t.falsy  hasChar("\t\t", ' ')

# ---------------------------------------------------------------------------

test "line 436", (t) => t.is(quoted('abc'), "'abc'")
test "line 437", (t) => t.is(quoted('"abc"'), "'\"abc\"'")
test "line 438", (t) => t.is(quoted("'abc'"), "\"'abc'\"")
test "line 439", (t) => t.is(quoted("'\"abc\"'"), "<'\"abc\"'>")
test "line 440", (t) => t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>")

# ---------------------------------------------------------------------------

test "line 444", (t) => t.deepEqual(getOptions(), {})
test "line 445", (t) => t.deepEqual(getOptions(undef, {x:1}), {x:1})
test "line 446", (t) => t.deepEqual(getOptions({x:1}, {x:3,y:4}), {x:1,y:4})
test "line 447", (t) => t.deepEqual(getOptions('asText'), {asText: true})
test "line 448", (t) => t.deepEqual(getOptions('!binary'), {binary: false})
test "line 449", (t) => t.deepEqual(getOptions('label=this'), {label: 'this'})
test "line 450", (t) => t.deepEqual(getOptions('width=42'), {width: 42})
test "line 451", (t) => t.deepEqual(getOptions('asText !binary label=this'), {
	asText: true
	binary: false
	label: 'this'
	})

# ---------------------------------------------------------------------------

test "line 459", (t) => t.deepEqual(range(3), [0,1,2])

# ---------------------------------------------------------------------------

utest.truthy 463, isHashComment('#')
utest.truthy 464, isHashComment('# a comment')
utest.truthy 465, isHashComment('#\ta comment')
utest.falsy  466, isHashComment('#comment')
utest.falsy  467, isHashComment('')
utest.falsy  468, isHashComment('a comment')

# ---------------------------------------------------------------------------

utest.truthy 472, isEmpty('')
utest.truthy 473, isEmpty('  \t\t')
utest.truthy 474, isEmpty([])
utest.truthy 475, isEmpty({})

utest.truthy 477, nonEmpty('a')
utest.truthy 478, nonEmpty('.')
utest.truthy 479, nonEmpty([2])
utest.truthy 480, nonEmpty({width: 2})

utest.truthy 482, isNonEmptyString('abc')
utest.falsy  483, isNonEmptyString(undef)
utest.falsy  484, isNonEmptyString('')
utest.falsy  485, isNonEmptyString('   ')
utest.falsy  486, isNonEmptyString("\t\t\t")
utest.falsy  487, isNonEmptyString(5)

# ---------------------------------------------------------------------------

utest.truthy 491, oneof('a', 'a', 'b', 'c')
utest.truthy 492, oneof('b', 'a', 'b', 'c')
utest.truthy 493, oneof('c', 'a', 'b', 'c')
utest.falsy  494, oneof('d', 'a', 'b', 'c')
utest.falsy  495, oneof('x')

# ---------------------------------------------------------------------------

utest.equal 499, uniq([1,2,2,3,3]), [1,2,3]
utest.equal 500, uniq(['a','b','b','c','c']),['a','b','c']

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

utest.equal 515, rtrim("abc"), "abc"
utest.equal 516, rtrim("  abc"), "  abc"
utest.equal 517, rtrim("abc  "), "abc"
utest.equal 518, rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

utest.equal 522, words('a b c'), ['a', 'b', 'c']
utest.equal 523, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

utest.equal 527, escapeStr("\t\tXXX\n"), "→→XXX®"
hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}
utest.equal 533, escapeStr("\thas quote: \"\nnext line", hEsc), \
	"\\thas quote: \\\"\\nnext line"

# ---------------------------------------------------------------------------

utest.equal 538, rtrunc('/user/lib/.env', 5), '/user/lib'
utest.equal 539, ltrunc('abcdefg', 3), 'defg'

utest.equal 541, CWS("""
		abc
		def
				ghi
		"""), "abc def ghi"

# ---------------------------------------------------------------------------

utest.truthy 549, isArrayOfStrings([])
utest.truthy 550, isArrayOfStrings(['a','b','c'])
utest.truthy 551, isArrayOfStrings(['a',undef, null, 'b'])

# ---------------------------------------------------------------------------

utest.truthy 555, isArrayOfArrays([])
utest.truthy 556, isArrayOfArrays([[], []])
utest.truthy 557, isArrayOfArrays([[1,2], []])
utest.truthy 558, isArrayOfArrays([[1,2,[1,2,3]], []])
utest.truthy 559, isArrayOfArrays([[1,2], undef, null, []])

utest.falsy  561, isArrayOfArrays({})
utest.falsy  562, isArrayOfArrays([1,2,3])
utest.falsy  563, isArrayOfArrays([[1,2,[3,4]], 4])
utest.falsy  564, isArrayOfArrays([[1,2,[3,4]], [], {a:1,b:2}])

utest.truthy 566, isArrayOfArrays([[1,2],[3,4],[4,5]], 2)
utest.falsy  567, isArrayOfArrays([[1,2],[3],[4,5]], 2)
utest.falsy  568, isArrayOfArrays([[1,2],[3,4,5],[4,5]], 2)

# ---------------------------------------------------------------------------

utest.truthy 572, isArrayOfHashes([])
utest.truthy 573, isArrayOfHashes([{}, {}])
utest.truthy 574, isArrayOfHashes([{a:1, b:2}, {}])
utest.truthy 575, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}])
utest.truthy 576, isArrayOfHashes([{a:1, b:2}, undef, null, {}])

utest.falsy  578, isArrayOfHashes({})
utest.falsy  579, isArrayOfHashes([1,2,3])
utest.falsy  580, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, 4])
utest.falsy  581, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}, [1,2]])

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

	utest.truthy 600, isHash(h)
	utest.falsy  601, isHash(l)
	utest.falsy  602, isHash(o)
	utest.falsy  603, isHash(n)
	utest.falsy  604, isHash(n2)
	utest.falsy  605, isHash(s)
	utest.falsy  606, isHash(s2)

	utest.falsy  608, isArray(h)
	utest.truthy 609, isArray(l)
	utest.falsy  610, isArray(o)
	utest.falsy  611, isArray(n)
	utest.falsy  612, isArray(n2)
	utest.falsy  613, isArray(s)
	utest.falsy  614, isArray(s2)

	utest.falsy  616, isString(undef)
	utest.falsy  617, isString(h)
	utest.falsy  618, isString(l)
	utest.falsy  619, isString(o)
	utest.falsy  620, isString(n)
	utest.falsy  621, isString(n2)
	utest.truthy 622, isString(s)
	utest.truthy 623, isString(s2)

	utest.falsy  625, isObject(h)
	utest.falsy  626, isObject(l)
	utest.truthy 627, isObject(o)
	utest.truthy 628, isObject(o, ['name','doIt'])
	utest.falsy  629, isObject(o, ['name','doIt','missing'])
	utest.falsy  630, isObject(n)
	utest.falsy  631, isObject(n2)
	utest.falsy  632, isObject(s)
	utest.falsy  633, isObject(s2)

	utest.falsy  635, isNumber(h)
	utest.falsy  636, isNumber(l)
	utest.falsy  637, isNumber(o)
	utest.truthy 638, isNumber(n)
	utest.truthy 639, isNumber(n2)
	utest.falsy  640, isNumber(s)
	utest.falsy  641, isNumber(s2)

	utest.truthy 643, isNumber(42.0, {min: 42.0})
	utest.falsy  644, isNumber(42.0, {min: 42.1})
	utest.truthy 645, isNumber(42.0, {max: 42.0})
	utest.falsy  646, isNumber(42.0, {max: 41.9})
	)()

# ---------------------------------------------------------------------------

utest.truthy 651, isFunction(() -> pass)
utest.falsy  652, isFunction(23)

utest.truthy 654, isInteger(42)
utest.truthy 655, isInteger(new Number(42))
utest.falsy  656, isInteger('abc')
utest.falsy  657, isInteger({})
utest.falsy  658, isInteger([])
utest.truthy 659, isInteger(42, {min:  0})
utest.falsy  660, isInteger(42, {min: 50})
utest.truthy 661, isInteger(42, {max: 50})
utest.falsy  662, isInteger(42, {max:  0})

# ---------------------------------------------------------------------------

utest.equal 666, OL(undef), "undef"
utest.equal 667, OL("\t\tabc\nxyz"), "'→→abc®xyz'"
utest.equal 668, OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

utest.equal 672, CWS("""
		a utest
		error message
		"""), "a utest error message"

# ---------------------------------------------------------------------------
# test isRegExp()

utest.truthy 680, isRegExp(/^abc$/)
utest.truthy 681, isRegExp(///^
		\s*
		where
		\s+
		areyou
		$///)
utest.falsy  687, isRegExp(42)
utest.falsy  688, isRegExp('abc')
utest.falsy  689, isRegExp([1,'a'])
utest.falsy  690, isRegExp({a:1, b:'ccc'})
utest.falsy  691, isRegExp(undef)

utest.truthy 693, isRegExp(/\.coffee/)

# ---------------------------------------------------------------------------

utest.equal 697, extractMatches("..3 and 4 plus 5", /\d+/g, parseInt),
	[3, 4, 5]
utest.equal 699, extractMatches("And This Is A String", /A/g), ['A','A']

# ---------------------------------------------------------------------------

utest.truthy 703, notdefined(undef)
utest.truthy 704, notdefined(null)
utest.truthy 705, defined('')
utest.truthy 706, defined(5)
utest.truthy 707, defined([])
utest.truthy 708, defined({})

utest.falsy 710, defined(undef)
utest.falsy 711, defined(null)
utest.falsy 712, notdefined('')
utest.falsy 713, notdefined(5)
utest.falsy 714, notdefined([])
utest.falsy 715, notdefined({})

# ---------------------------------------------------------------------------

utest.truthy 719, isIterable([])
utest.truthy 720, isIterable(['a','b'])

gen = () ->
	yield 1
	yield 2
	yield 3
	return

utest.truthy 728, isIterable(gen())

# ---------------------------------------------------------------------------

(() ->
	class MyClass
		constructor: (str) ->
			@mystr = str

	utest.equal 737, className(MyClass), 'MyClass'

	)()

# ---------------------------------------------------------------------------

utest.equal 743, getOptions('a b c'), {'a':true, 'b':true, 'c':true}
utest.equal 744, getOptions('abc'), {'abc':true}
utest.equal 745, getOptions({'a':true, 'b':false, 'c':42}), {'a':true, 'b':false, 'c':42}
utest.equal 746, getOptions(), {}

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
	utest.equal 761, lResult, ['ABC','DEF', 'GHI']
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

	utest.equal 777, lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		lResult.push line.toUpperCase()
		return false
	utest.equal 786, lResult, ['ABC','DEF', 'GHI']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		if (line == 'ghi')
			return true
		lResult.push line.toUpperCase()
		return false

	utest.equal 798, lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line, hInfo) =>
		if (line == 'ghi')
			return true
		lResult.push "#{hInfo.lineNum} #{line.toUpperCase()} #{hInfo.nextLine}"
		return false

	utest.equal 810, lResult, ['1 ABC def','2 DEF ghi']
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
	utest.equal 824, newblock, """
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
	utest.equal 842, newblock, """
		ABC
		GHI
		"""
	)()

(() =>
	item = ['abc','def','ghi']
	newblock = mapEachLine item, (line) =>
		return line.toUpperCase()
	utest.equal 852, newblock, [
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
	utest.equal 866, newblock, [
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
	utest.equal 881, newblock, [
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

	utest.equal 907, removeKeys(hAST, ['start','end']), {
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

	utest.equal 938, removeKeys(hAST, ['start','end']), {
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

	utest.equal 978, hToDo.task, 'go shopping'
	utest.equal 979, h.task, 'GO SHOPPING'

	h.task = 'do something'
	utest.equal 982, hToDo.task, 'do something'
	utest.equal 983, h.task, 'DO SOMETHING'

	h.task = 'nothing'
	utest.equal 986, hToDo.task, 'do something'
	utest.equal 987, h.task, 'DO SOMETHING'

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

	utest.equal 1008, await run1(), 'abc,def,ghi'
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

	utest.equal 1025, await run2(), 'def,ghi'
	)()
