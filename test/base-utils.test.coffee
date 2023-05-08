# base-utils.test.coffee

import test from 'ava'

import {utest} from '@jdeighan/base-utils/utest'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, pass, defined, notdefined, tabify, untabify, prefixBlock,
	escapeStr, OL, OLS, inList,  isHashComment, splitPrefix, hasPrefix,
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

test "line 65", (t) => t.falsy (hasPrefix("abc"))
test "line 66", (t) => t.truthy(hasPrefix("   abc"))

# ---------------------------------------------------------------------------

(() ->
	prefix = '   '    # 3 spaces

	test "line 73", (t) => t.is(untabify("""
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

	utest.equal 89, tabify("""
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

	utest.equal 106, tabify("""
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

	utest.equal 122, untabify("""
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

test "line 135", (t) => t.is(prefixBlock("""
	abc
	def
	""", '--'), """
	--abc
	--def
	""")

# ---------------------------------------------------------------------------

test "line 145", (t) => t.is(escapeStr("\t\tXXX\n"), "→→XXX®")

hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}

test "line 153", (t) => t.is(escapeStr("\thas quote: \"\nnext line", hEsc),
	"\\thas quote: \\\"\\nnext line")

# ---------------------------------------------------------------------------

test "line 158", (t) => t.is(OL(undef), "undef")
test "line 159", (t) => t.is(OL("\t\tabc\nxyz"), "'→→abc®xyz'")
test "line 160", (t) => t.is(OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}')

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

test "line 168", (t) => t.is(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}')

# ---------------------------------------------------------------------------

test "line 172", (t) => t.is(OLS(['abc', 3]), "'abc',3")
test "line 173", (t) => t.is(OLS([]), "")
test "line 174", (t) => t.is(OLS([undef, {a:1}]), 'undef,{"a":1}')

# ---------------------------------------------------------------------------

test "line 99",  (t) => t.truthy(inList('a', 'b', 'a', 'c'))
test "line 179", (t) => t.falsy( inList('a', 'b', 'c'))

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

	test "line 199", (t) => t.falsy(isString(undef))
	test "line 200", (t) => t.falsy(isString(h))
	test "line 201", (t) => t.falsy(isString(l))
	test "line 202", (t) => t.falsy(isString(o))
	test "line 203", (t) => t.falsy(isString(n))
	test "line 204", (t) => t.falsy(isString(n2))

	test "line 206", (t) => t.truthy(isString(s))
	test "line 207", (t) => t.truthy(isString(s2))

	test "line 209", (t) => t.truthy(isNonEmptyString('abc'))
	test "line 210", (t) => t.truthy(isNonEmptyString('abc def'))
	test "line 211", (t) => t.falsy(isNonEmptyString(''))
	test "line 212", (t) => t.falsy(isNonEmptyString('  '))

	test "line 214", (t) => t.truthy(isIdentifier('abc'))
	test "line 215", (t) => t.truthy(isIdentifier('_Abc'))
	test "line 216", (t) => t.falsy(isIdentifier('abc def'))
	test "line 217", (t) => t.falsy(isIdentifier('abc-def'))
	test "line 218", (t) => t.falsy(isIdentifier('class.method'))

	test "line 220", (t) => t.truthy(isFunctionName('abc'))
	test "line 221", (t) => t.truthy(isFunctionName('_Abc'))
	test "line 222", (t) => t.falsy(isFunctionName('abc def'))
	test "line 223", (t) => t.falsy(isFunctionName('abc-def'))
	test "line 224", (t) => t.falsy(isFunctionName('D()'))
	test "line 225", (t) => t.truthy(isFunctionName('class.method'))

	generatorFunc = () ->
		yield 1
		yield 2
		yield 3
		return

	test "line 233", (t) => t.truthy(isIterable(generatorFunc()))

	test "line 235", (t) => t.falsy(isNumber(undef))
	test "line 236", (t) => t.falsy(isNumber(null))
	test "line 237", (t) => t.falsy(isNumber(NaN))
	test "line 238", (t) => t.falsy(isNumber(h))
	test "line 239", (t) => t.falsy(isNumber(l))
	test "line 240", (t) => t.falsy(isNumber(o))
	test "line 241", (t) => t.truthy(isNumber(n))
	test "line 242", (t) => t.truthy(isNumber(n2))
	test "line 243", (t) => t.falsy(isNumber(s))
	test "line 244", (t) => t.falsy(isNumber(s2))

	test "line 246", (t) => t.truthy(isNumber(42.0, {min: 42.0}))
	test "line 247", (t) => t.falsy(isNumber(42.0, {min: 42.1}))
	test "line 248", (t) => t.truthy(isNumber(42.0, {max: 42.0}))
	test "line 249", (t) => t.falsy(isNumber(42.0, {max: 41.9}))

	test "line 251", (t) => t.truthy(isInteger(42))
	test "line 252", (t) => t.truthy(isInteger(new Number(42)))
	test "line 253", (t) => t.falsy(isInteger('abc'))
	test "line 254", (t) => t.falsy(isInteger({}))
	test "line 255", (t) => t.falsy(isInteger([]))
	test "line 256", (t) => t.truthy(isInteger(42, {min:  0}))
	test "line 257", (t) => t.falsy(isInteger(42, {min: 50}))
	test "line 258", (t) => t.truthy(isInteger(42, {max: 50}))
	test "line 259", (t) => t.falsy(isInteger(42, {max:  0}))

	test "line 261", (t) => t.truthy(isHash(h))
	test "line 262", (t) => t.falsy(isHash(l))
	test "line 263", (t) => t.falsy(isHash(o))
	test "line 264", (t) => t.falsy(isHash(n))
	test "line 265", (t) => t.falsy(isHash(n2))
	test "line 266", (t) => t.falsy(isHash(s))
	test "line 267", (t) => t.falsy(isHash(s2))

	test "line 269", (t) => t.falsy(isArray(h))
	test "line 270", (t) => t.truthy(isArray(l))
	test "line 271", (t) => t.falsy(isArray(o))
	test "line 272", (t) => t.falsy(isArray(n))
	test "line 273", (t) => t.falsy(isArray(n2))
	test "line 274", (t) => t.falsy(isArray(s))
	test "line 275", (t) => t.falsy(isArray(s2))

	test "line 277", (t) => t.truthy(isBoolean(true))
	test "line 278", (t) => t.truthy(isBoolean(false))
	test "line 279", (t) => t.falsy(isBoolean(42))
	test "line 280", (t) => t.falsy(isBoolean("true"))

	test "line 282", (t) => t.truthy(isClass(NewClass))
	test "line 283", (t) => t.falsy(isClass(o))

	test "line 285", (t) => t.truthy(isConstructor(NewClass))
	test "line 286", (t) => t.falsy(isConstructor(o))

	test "line 288", (t) => t.truthy(isFunction(() -> 42))
	test "line 289", (t) => t.truthy(isFunction(() => 42))
	test "line 290", (t) => t.falsy(isFunction(42))
	test "line 291", (t) => t.falsy(isFunction(n))

	test "line 293", (t) => t.truthy(isRegExp(/^abc$/))
	test "line 294", (t) => t.truthy(isRegExp(///^ \s* where \s+ areyou $///))
	test "line 295", (t) => t.falsy(isRegExp(42))
	test "line 296", (t) => t.falsy(isRegExp('abc'))
	test "line 297", (t) => t.falsy(isRegExp([1,'a']))
	test "line 298", (t) => t.falsy(isRegExp({a:1, b:'ccc'}))
	test "line 299", (t) => t.falsy(isRegExp(undef))
	test "line 300", (t) => t.truthy(isRegExp(/\.coffee/))

	test "line 302", (t) => t.falsy(isObject(h))
	test "line 303", (t) => t.falsy(isObject(l))
	test "line 304", (t) => t.truthy(isObject(o))
	test "line 305", (t) => t.truthy(isObject(o, ['name','doIt']))
	test "line 306", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 307", (t) => t.falsy(isObject(o, ['name','doIt','missing']))
	test "line 308", (t) => t.falsy(isObject(o, "name doIt missing"))
	test "line 309", (t) => t.falsy(isObject(n))
	test "line 310", (t) => t.falsy(isObject(n2))
	test "line 311", (t) => t.falsy(isObject(s))
	test "line 312", (t) => t.falsy(isObject(s2))
	test "line 313", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 314", (t) => t.truthy(isObject(o, "name doIt meth"))
	test "line 315", (t) => t.truthy(isObject(o, "name &doIt &meth"))
	test "line 316", (t) => t.falsy(isObject(o, "&name"))

	test "line 318", (t) => t.deepEqual(jsType(undef), [undef, 'undef'])
	test "line 319", (t) => t.deepEqual(jsType(null),  [undef, 'null'])
	test "line 320", (t) => t.deepEqual(jsType(s), ['string', undef])
	test "line 321", (t) => t.deepEqual(jsType(''), ['string', 'empty'])
	test "line 322", (t) => t.deepEqual(jsType("\t\t"), ['string', 'empty'])
	test "line 323", (t) => t.deepEqual(jsType("  "), ['string', 'empty'])
	test "line 324", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 325", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 326", (t) => t.deepEqual(jsType(3.14159), ['number', undef])
	test "line 327", (t) => t.deepEqual(jsType(42), ['number', 'integer'])
	test "line 328", (t) => t.deepEqual(jsType(true), ['boolean', undef])
	test "line 329", (t) => t.deepEqual(jsType(false), ['boolean', undef])
	test "line 330", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 331", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 332", (t) => t.deepEqual(jsType(l), ['array', undef])
	test "line 333", (t) => t.deepEqual(jsType([]), ['array', 'empty'])
	test "line 334", (t) => t.deepEqual(jsType(/abc/), ['regexp', undef])

	func1 = (x) ->
		return

	func2 = (x) =>
		return

	# --- NOTE: regular functions can't be distinguished from constructors
	test "line 343", (t) => t.deepEqual(jsType(func1), ['class', undef])

	test "line 345", (t) => t.deepEqual(jsType(func2), ['function', undef])
	test "line 346", (t) => t.deepEqual(jsType(NewClass), ['class', undef])
	test "line 347", (t) => t.deepEqual(jsType(o), ['object', undef])
	)()

# ---------------------------------------------------------------------------

test "line 352", (t) => t.truthy(isEmpty(''))
test "line 353", (t) => t.truthy(isEmpty('  \t\t'))
test "line 354", (t) => t.truthy(isEmpty([]))
test "line 355", (t) => t.truthy(isEmpty({}))

test "line 357", (t) => t.truthy(nonEmpty('a'))
test "line 358", (t) => t.truthy(nonEmpty('.'))
test "line 359", (t) => t.truthy(nonEmpty([2]))
test "line 360", (t) => t.truthy(nonEmpty({width: 2}))

# ---------------------------------------------------------------------------

test "line 364", (t) => t.deepEqual(blockToArray(undef), [])
test "line 365", (t) => t.deepEqual(blockToArray(''), [])
test "line 366", (t) => t.deepEqual(blockToArray('a'), ['a'])
test "line 367", (t) => t.deepEqual(blockToArray("a\nb"), ['a','b'])
test "line 368", (t) => t.deepEqual(blockToArray("a\r\nb"), ['a','b'])
test "line 369", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 374", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 379", (t) => t.deepEqual(blockToArray("abc\n\nxyz"), [
	'abc'
	''
	'xyz'
	])

# ---------------------------------------------------------------------------

test "line 387", (t) => t.deepEqual(toArray("abc\ndef"), ['abc','def'])
test "line 388", (t) => t.deepEqual(toArray(['a','b']), ['a','b'])

test "line 390", (t) => t.deepEqual(toArray(["a\nb","c\nd"]), ['a','b','c','d'])

# ---------------------------------------------------------------------------

test "line 394", (t) => t.deepEqual(arrayToBlock(undef), '')
test "line 395", (t) => t.deepEqual(arrayToBlock([]), '')
test "line 396", (t) => t.deepEqual(arrayToBlock([undef]), '')
test "line 397", (t) => t.deepEqual(arrayToBlock(['a  ','b\t\t']), "a\nb")
test "line 398", (t) => t.deepEqual(arrayToBlock(['a','b','c']), "a\nb\nc")
test "line 399", (t) => t.deepEqual(arrayToBlock(['a',undef,'b','c']), "a\nb\nc")
test "line 400", (t) => t.deepEqual(arrayToBlock([undef,'a','b','c',undef]), "a\nb\nc")

# ---------------------------------------------------------------------------

test "line 404", (t) => t.deepEqual(toBlock(['abc','def']), "abc\ndef")
test "line 405", (t) => t.deepEqual(toBlock("abc\ndef"), "abc\ndef")

# ---------------------------------------------------------------------------

test "line 409", (t) => t.is(rtrim("abc"), "abc")
test "line 410", (t) => t.is(rtrim("  abc"), "  abc")
test "line 411", (t) => t.is(rtrim("abc  "), "abc")
test "line 412", (t) => t.is(rtrim("  abc  "), "  abc")

# ---------------------------------------------------------------------------

test "line 416", (t) => t.deepEqual(words(''), [])
test "line 417", (t) => t.deepEqual(words('  \t\t'), [])
test "line 418", (t) => t.deepEqual(words('a b c'), ['a', 'b', 'c'])
test "line 419", (t) => t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c'])
test "line 420", (t) => t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd'])
test "line 421", (t) => t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word'])

test "line 423", (t) => t.truthy hasChar('abc', 'b')
test "line 424", (t) => t.falsy  hasChar('abc', 'x')
test "line 425", (t) => t.falsy  hasChar("\t\t", ' ')

# ---------------------------------------------------------------------------

test "line 429", (t) => t.is(quoted('abc'), "'abc'")
test "line 430", (t) => t.is(quoted('"abc"'), "'\"abc\"'")
test "line 431", (t) => t.is(quoted("'abc'"), "\"'abc'\"")
test "line 432", (t) => t.is(quoted("'\"abc\"'"), "<'\"abc\"'>")
test "line 433", (t) => t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>")

# ---------------------------------------------------------------------------

test "line 437", (t) => t.deepEqual(getOptions(), {})
test "line 438", (t) => t.deepEqual(getOptions(undef, {x:1}), {x:1})
test "line 439", (t) => t.deepEqual(getOptions({x:1}, {x:3,y:4}), {x:1,y:4})
test "line 440", (t) => t.deepEqual(getOptions('asText'), {asText: true})
test "line 441", (t) => t.deepEqual(getOptions('!binary'), {binary: false})
test "line 442", (t) => t.deepEqual(getOptions('label=this'), {label: 'this'})
test "line 443", (t) => t.deepEqual(getOptions('width=42'), {width: 42})
test "line 444", (t) => t.deepEqual(getOptions('asText !binary label=this'), {
	asText: true
	binary: false
	label: 'this'
	})

# ---------------------------------------------------------------------------

test "line 452", (t) => t.deepEqual(range(3), [0,1,2])

# ---------------------------------------------------------------------------

utest.truthy 456, isHashComment('#')
utest.truthy 457, isHashComment('# a comment')
utest.truthy 458, isHashComment('#\ta comment')
utest.falsy  459, isHashComment('#comment')
utest.falsy  460, isHashComment('')
utest.falsy  461, isHashComment('a comment')

# ---------------------------------------------------------------------------

utest.truthy 465, isEmpty('')
utest.truthy 466, isEmpty('  \t\t')
utest.truthy 467, isEmpty([])
utest.truthy 468, isEmpty({})

utest.truthy 470, nonEmpty('a')
utest.truthy 471, nonEmpty('.')
utest.truthy 472, nonEmpty([2])
utest.truthy 473, nonEmpty({width: 2})

utest.truthy 475, isNonEmptyString('abc')
utest.falsy  476, isNonEmptyString(undef)
utest.falsy  477, isNonEmptyString('')
utest.falsy  478, isNonEmptyString('   ')
utest.falsy  479, isNonEmptyString("\t\t\t")
utest.falsy  480, isNonEmptyString(5)

# ---------------------------------------------------------------------------

utest.truthy 484, oneof('a', 'a', 'b', 'c')
utest.truthy 485, oneof('b', 'a', 'b', 'c')
utest.truthy 486, oneof('c', 'a', 'b', 'c')
utest.falsy  487, oneof('d', 'a', 'b', 'c')
utest.falsy  488, oneof('x')

# ---------------------------------------------------------------------------

utest.equal 492, uniq([1,2,2,3,3]), [1,2,3]
utest.equal 493, uniq(['a','b','b','c','c']),['a','b','c']

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

utest.equal 508, rtrim("abc"), "abc"
utest.equal 509, rtrim("  abc"), "  abc"
utest.equal 510, rtrim("abc  "), "abc"
utest.equal 511, rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

utest.equal 515, words('a b c'), ['a', 'b', 'c']
utest.equal 516, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

utest.equal 520, escapeStr("\t\tXXX\n"), "→→XXX®"
hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}
utest.equal 526, escapeStr("\thas quote: \"\nnext line", hEsc), \
	"\\thas quote: \\\"\\nnext line"

# ---------------------------------------------------------------------------

utest.equal 531, rtrunc('/user/lib/.env', 5), '/user/lib'
utest.equal 532, ltrunc('abcdefg', 3), 'defg'

utest.equal 534, CWS("""
		abc
		def
				ghi
		"""), "abc def ghi"

# ---------------------------------------------------------------------------

utest.truthy 542, isArrayOfStrings([])
utest.truthy 543, isArrayOfStrings(['a','b','c'])
utest.truthy 544, isArrayOfStrings(['a',undef, null, 'b'])

# ---------------------------------------------------------------------------

utest.truthy 548, isArrayOfArrays([])
utest.truthy 549, isArrayOfArrays([[], []])
utest.truthy 550, isArrayOfArrays([[1,2], []])
utest.truthy 551, isArrayOfArrays([[1,2,[1,2,3]], []])
utest.truthy 552, isArrayOfArrays([[1,2], undef, null, []])

utest.falsy  554, isArrayOfArrays({})
utest.falsy  555, isArrayOfArrays([1,2,3])
utest.falsy  556, isArrayOfArrays([[1,2,[3,4]], 4])
utest.falsy  557, isArrayOfArrays([[1,2,[3,4]], [], {a:1,b:2}])

utest.truthy 559, isArrayOfArrays([[1,2],[3,4],[4,5]], 2)
utest.falsy  560, isArrayOfArrays([[1,2],[3],[4,5]], 2)
utest.falsy  561, isArrayOfArrays([[1,2],[3,4,5],[4,5]], 2)

# ---------------------------------------------------------------------------

utest.truthy 565, isArrayOfHashes([])
utest.truthy 566, isArrayOfHashes([{}, {}])
utest.truthy 567, isArrayOfHashes([{a:1, b:2}, {}])
utest.truthy 568, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}])
utest.truthy 569, isArrayOfHashes([{a:1, b:2}, undef, null, {}])

utest.falsy  571, isArrayOfHashes({})
utest.falsy  572, isArrayOfHashes([1,2,3])
utest.falsy  573, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, 4])
utest.falsy  574, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}, [1,2]])

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

	utest.truthy 593, isHash(h)
	utest.falsy  594, isHash(l)
	utest.falsy  595, isHash(o)
	utest.falsy  596, isHash(n)
	utest.falsy  597, isHash(n2)
	utest.falsy  598, isHash(s)
	utest.falsy  599, isHash(s2)

	utest.falsy  601, isArray(h)
	utest.truthy 602, isArray(l)
	utest.falsy  603, isArray(o)
	utest.falsy  604, isArray(n)
	utest.falsy  605, isArray(n2)
	utest.falsy  606, isArray(s)
	utest.falsy  607, isArray(s2)

	utest.falsy  609, isString(undef)
	utest.falsy  610, isString(h)
	utest.falsy  611, isString(l)
	utest.falsy  612, isString(o)
	utest.falsy  613, isString(n)
	utest.falsy  614, isString(n2)
	utest.truthy 615, isString(s)
	utest.truthy 616, isString(s2)

	utest.falsy  618, isObject(h)
	utest.falsy  619, isObject(l)
	utest.truthy 620, isObject(o)
	utest.truthy 621, isObject(o, ['name','doIt'])
	utest.falsy  622, isObject(o, ['name','doIt','missing'])
	utest.falsy  623, isObject(n)
	utest.falsy  624, isObject(n2)
	utest.falsy  625, isObject(s)
	utest.falsy  626, isObject(s2)

	utest.falsy  628, isNumber(h)
	utest.falsy  629, isNumber(l)
	utest.falsy  630, isNumber(o)
	utest.truthy 631, isNumber(n)
	utest.truthy 632, isNumber(n2)
	utest.falsy  633, isNumber(s)
	utest.falsy  634, isNumber(s2)

	utest.truthy 636, isNumber(42.0, {min: 42.0})
	utest.falsy  637, isNumber(42.0, {min: 42.1})
	utest.truthy 638, isNumber(42.0, {max: 42.0})
	utest.falsy  639, isNumber(42.0, {max: 41.9})
	)()

# ---------------------------------------------------------------------------

utest.truthy 644, isFunction(() -> pass)
utest.falsy  645, isFunction(23)

utest.truthy 647, isInteger(42)
utest.truthy 648, isInteger(new Number(42))
utest.falsy  649, isInteger('abc')
utest.falsy  650, isInteger({})
utest.falsy  651, isInteger([])
utest.truthy 652, isInteger(42, {min:  0})
utest.falsy  653, isInteger(42, {min: 50})
utest.truthy 654, isInteger(42, {max: 50})
utest.falsy  655, isInteger(42, {max:  0})

# ---------------------------------------------------------------------------

utest.equal 659, OL(undef), "undef"
utest.equal 660, OL("\t\tabc\nxyz"), "'→→abc®xyz'"
utest.equal 661, OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

utest.equal 665, CWS("""
		a utest
		error message
		"""), "a utest error message"

# ---------------------------------------------------------------------------
# test isRegExp()

utest.truthy 673, isRegExp(/^abc$/)
utest.truthy 674, isRegExp(///^
		\s*
		where
		\s+
		areyou
		$///)
utest.falsy  680, isRegExp(42)
utest.falsy  681, isRegExp('abc')
utest.falsy  682, isRegExp([1,'a'])
utest.falsy  683, isRegExp({a:1, b:'ccc'})
utest.falsy  684, isRegExp(undef)

utest.truthy 686, isRegExp(/\.coffee/)

# ---------------------------------------------------------------------------

utest.equal 690, extractMatches("..3 and 4 plus 5", /\d+/g, parseInt),
	[3, 4, 5]
utest.equal 692, extractMatches("And This Is A String", /A/g), ['A','A']

# ---------------------------------------------------------------------------

utest.truthy 696, notdefined(undef)
utest.truthy 697, notdefined(null)
utest.truthy 698, defined('')
utest.truthy 699, defined(5)
utest.truthy 700, defined([])
utest.truthy 701, defined({})

utest.falsy 703, defined(undef)
utest.falsy 704, defined(null)
utest.falsy 705, notdefined('')
utest.falsy 706, notdefined(5)
utest.falsy 707, notdefined([])
utest.falsy 708, notdefined({})

# ---------------------------------------------------------------------------

utest.truthy 712, isIterable([])
utest.truthy 713, isIterable(['a','b'])

gen = () ->
	yield 1
	yield 2
	yield 3
	return

utest.truthy 721, isIterable(gen())

# ---------------------------------------------------------------------------

(() ->
	class MyClass
		constructor: (str) ->
			@mystr = str

	utest.equal 730, className(MyClass), 'MyClass'

	)()

# ---------------------------------------------------------------------------

utest.equal 736, getOptions('a b c'), {'a':true, 'b':true, 'c':true}
utest.equal 737, getOptions('abc'), {'abc':true}
utest.equal 738, getOptions({'a':true, 'b':false, 'c':42}), {'a':true, 'b':false, 'c':42}
utest.equal 739, getOptions(), {}

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
	utest.equal 754, lResult, ['ABC','DEF', 'GHI']
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

	utest.equal 770, lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		lResult.push line.toUpperCase()
		return false
	utest.equal 779, lResult, ['ABC','DEF', 'GHI']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		if (line == 'ghi')
			return true
		lResult.push line.toUpperCase()
		return false

	utest.equal 791, lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line, hInfo) =>
		if (line == 'ghi')
			return true
		lResult.push "#{hInfo.lineNum} #{line.toUpperCase()} #{hInfo.nextLine}"
		return false

	utest.equal 803, lResult, ['1 ABC def','2 DEF ghi']
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
	utest.equal 817, newblock, """
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
	utest.equal 835, newblock, """
		ABC
		GHI
		"""
	)()

(() =>
	item = ['abc','def','ghi']
	newblock = mapEachLine item, (line) =>
		return line.toUpperCase()
	utest.equal 845, newblock, [
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
	utest.equal 859, newblock, [
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
	utest.equal 874, newblock, [
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

	utest.equal 900, removeKeys(hAST, ['start','end']), {
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

	utest.equal 931, removeKeys(hAST, ['start','end']), {
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

	utest.equal 971, hToDo.task, 'go shopping'
	utest.equal 972, h.task, 'GO SHOPPING'

	h.task = 'do something'
	utest.equal 975, hToDo.task, 'do something'
	utest.equal 976, h.task, 'DO SOMETHING'

	h.task = 'nothing'
	utest.equal 979, hToDo.task, 'do something'
	utest.equal 980, h.task, 'DO SOMETHING'

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

	utest.equal 1001, await run1(), 'abc,def,ghi'
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

	utest.equal 1018, await run2(), 'def,ghi'
	)()
