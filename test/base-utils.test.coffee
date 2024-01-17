# base-utils.test.coffee

import test from 'ava'

import {utest} from '@jdeighan/base-utils/utest'
import {
	undef, pass, defined, notdefined,
	keys, hasKey, subkeys,
	tabify, untabify, prefixBlock,
	escapeStr, OL, OLS,  isHashComment, splitPrefix, hasPrefix,
	isString, isNumber, isInteger, isHash, isArray, isBoolean,
	isClass, isConstructor, removeKeys, extractMatches,
	isFunction, isRegExp, isObject, jsType, deepEqual,
	isEmpty, nonEmpty, isNonEmptyString, isIdentifier,
	isFunctionName, isIterable, hashFromString,
	blockToArray, arrayToBlock, toArray, toBlock,
	rtrim, words, hasChar, quoted, getOptions, range, rev_range,
	oneof, uniq, rtrunc, ltrunc, CWS, className,
	isArrayOfStrings, isArrayOfHashes, isArrayOfArrays,
	forEachLine, mapEachLine, getProxy, sleep, schedule,
	eachCharInString, runCmd, hit, choose, shuffle,
	deepCopy, timestamp, msSinceEpoch, formatDate, pad,
	} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

test "line 25", (t) => t.truthy(deepEqual({a:1, b:2}, {a:1, b:2}))
test "line 26", (t) => t.falsy (deepEqual({a:1, b:2}, {a:1, b:3}))

# ---------------------------------------------------------------------------

test "line 30", (t) => t.truthy(isHashComment('   # something'))
test "line 31", (t) => t.truthy(isHashComment('   #'))
test "line 32", (t) => t.falsy(isHashComment('   abc'))
test "line 33", (t) => t.falsy(isHashComment('#abc'))

test "line 35", (t) => t.is(undef, undefined)

test "line 37", (t) => t.truthy(isFunction(pass))

(() ->
	passTest = () =>
		pass()
	test "line 42", (t) => t.notThrows(passTest, "pass fails")
	)()

test "line 45", (t) => t.truthy(defined(''))
test "line 46", (t) => t.truthy(defined(5))
test "line 47", (t) => t.truthy(defined([]))
test "line 48", (t) => t.truthy(defined({}))
test "line 49", (t) => t.falsy(defined(undef))
test "line 50", (t) => t.falsy(defined(null))

test "line 52", (t) => t.truthy(notdefined(undef))
test "line 53", (t) => t.truthy(notdefined(null))
test "line 54", (t) => t.falsy(notdefined(''))
test "line 55", (t) => t.falsy(notdefined(5))
test "line 56", (t) => t.falsy(notdefined([]))
test "line 57", (t) => t.falsy(notdefined({}))

# ---------------------------------------------------------------------------

test "line 61", (t) => t.deepEqual(splitPrefix("abc"),     ["", "abc"])
test "line 62", (t) => t.deepEqual(splitPrefix("\tabc"),   ["\t", "abc"])
test "line 63", (t) => t.deepEqual(splitPrefix("\t\tabc"), ["\t\t", "abc"])
test "line 64", (t) => t.deepEqual(splitPrefix(""),        ["", ""])
test "line 65", (t) => t.deepEqual(splitPrefix("\t\t\t"),  ["", ""])
test "line 66", (t) => t.deepEqual(splitPrefix("\t \t"),   ["", ""])
test "line 67", (t) => t.deepEqual(splitPrefix("   "),     ["", ""])

# ---------------------------------------------------------------------------

test "line 71", (t) => t.falsy (hasPrefix("abc"))
test "line 72", (t) => t.truthy(hasPrefix("   abc"))

# ---------------------------------------------------------------------------

(() ->
	prefix = '   '    # 3 spaces

	test "line 79", (t) => t.is(untabify("""
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

	utest.equal 95, tabify("""
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

	utest.equal 112, tabify("""
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

	utest.equal 128, untabify("""
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

test "line 141", (t) => t.is(prefixBlock("""
	abc
	def
	""", '--'), """
	--abc
	--def
	""")

# ---------------------------------------------------------------------------

test "line 151", (t) => t.is(escapeStr("\t\tXXX\n"), "→→XXX®")

hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}

test "line 159", (t) => t.is(escapeStr("\thas quote: \"\nnext line", hEsc),
	"\\thas quote: \\\"\\nnext line")

# ---------------------------------------------------------------------------

test "line 164", (t) => t.is(OL(undef), "undef")
test "line 165", (t) => t.is(OL("\t\tabc\nxyz"), "'→→abc®xyz'")
test "line 166", (t) => t.is(OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}')

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

test "line 174", (t) => t.is(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}')

# ---------------------------------------------------------------------------

test "line 178", (t) => t.is(OLS(['abc', 3]), "'abc',3")
test "line 179", (t) => t.is(OLS([]), "")
test "line 180", (t) => t.is(OLS([undef, {a:1}]), 'undef,{"a":1}')

# ---------------------------------------------------------------------------

test "line 99",  (t) => t.truthy(oneof('a', 'b', 'a', 'c'))
test "line 185", (t) => t.falsy( oneof('a', 'b', 'c'))

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

	test "line 205", (t) => t.falsy(isString(undef))
	test "line 206", (t) => t.falsy(isString(h))
	test "line 207", (t) => t.falsy(isString(l))
	test "line 208", (t) => t.falsy(isString(o))
	test "line 209", (t) => t.falsy(isString(n))
	test "line 210", (t) => t.falsy(isString(n2))

	test "line 212", (t) => t.truthy(isString(s))
	test "line 213", (t) => t.truthy(isString(s2))

	test "line 215", (t) => t.truthy(isNonEmptyString('abc'))
	test "line 216", (t) => t.truthy(isNonEmptyString('abc def'))
	test "line 217", (t) => t.falsy(isNonEmptyString(''))
	test "line 218", (t) => t.falsy(isNonEmptyString('  '))

	test "line 220", (t) => t.truthy(isIdentifier('abc'))
	test "line 221", (t) => t.truthy(isIdentifier('_Abc'))
	test "line 222", (t) => t.falsy(isIdentifier('abc def'))
	test "line 223", (t) => t.falsy(isIdentifier('abc-def'))
	test "line 224", (t) => t.falsy(isIdentifier('class.method'))

	test "line 226", (t) => t.truthy(isFunctionName('abc'))
	test "line 227", (t) => t.truthy(isFunctionName('_Abc'))
	test "line 228", (t) => t.falsy(isFunctionName('abc def'))
	test "line 229", (t) => t.falsy(isFunctionName('abc-def'))
	test "line 230", (t) => t.falsy(isFunctionName('D()'))
	test "line 231", (t) => t.truthy(isFunctionName('class.method'))

	generatorFunc = () ->
		yield 1
		yield 2
		yield 3
		return

	test "line 239", (t) => t.truthy(isIterable(generatorFunc()))

	test "line 241", (t) => t.falsy(isNumber(undef))
	test "line 242", (t) => t.falsy(isNumber(null))
	test "line 243", (t) => t.truthy(isNumber(NaN))
	test "line 244", (t) => t.falsy(isNumber(h))
	test "line 245", (t) => t.falsy(isNumber(l))
	test "line 246", (t) => t.falsy(isNumber(o))
	test "line 247", (t) => t.truthy(isNumber(n))
	test "line 248", (t) => t.truthy(isNumber(n2))
	test "line 249", (t) => t.falsy(isNumber(s))
	test "line 250", (t) => t.falsy(isNumber(s2))

	test "line 252", (t) => t.truthy(isNumber(42.0, {min: 42.0}))
	test "line 253", (t) => t.falsy(isNumber(42.0, {min: 42.1}))
	test "line 254", (t) => t.truthy(isNumber(42.0, {max: 42.0}))
	test "line 255", (t) => t.falsy(isNumber(42.0, {max: 41.9}))

	test "line 257", (t) => t.truthy(isInteger(42))
	test "line 258", (t) => t.truthy(isInteger(new Number(42)))
	test "line 259", (t) => t.falsy(isInteger('abc'))
	test "line 260", (t) => t.falsy(isInteger({}))
	test "line 261", (t) => t.falsy(isInteger([]))
	test "line 262", (t) => t.truthy(isInteger(42, {min:  0}))
	test "line 263", (t) => t.falsy(isInteger(42, {min: 50}))
	test "line 264", (t) => t.truthy(isInteger(42, {max: 50}))
	test "line 265", (t) => t.falsy(isInteger(42, {max:  0}))

	test "line 267", (t) => t.truthy(isHash(h))
	test "line 268", (t) => t.falsy(isHash(l))
	test "line 269", (t) => t.falsy(isHash(o))
	test "line 270", (t) => t.falsy(isHash(n))
	test "line 271", (t) => t.falsy(isHash(n2))
	test "line 272", (t) => t.falsy(isHash(s))
	test "line 273", (t) => t.falsy(isHash(s2))

	test "line 275", (t) => t.falsy(isArray(h))
	test "line 276", (t) => t.truthy(isArray(l))
	test "line 277", (t) => t.falsy(isArray(o))
	test "line 278", (t) => t.falsy(isArray(n))
	test "line 279", (t) => t.falsy(isArray(n2))
	test "line 280", (t) => t.falsy(isArray(s))
	test "line 281", (t) => t.falsy(isArray(s2))

	test "line 283", (t) => t.truthy(isBoolean(true))
	test "line 284", (t) => t.truthy(isBoolean(false))
	test "line 285", (t) => t.falsy(isBoolean(42))
	test "line 286", (t) => t.falsy(isBoolean("true"))

	test "line 288", (t) => t.truthy(isClass(NewClass))
	test "line 289", (t) => t.falsy(isClass(o))

	test "line 291", (t) => t.truthy(isConstructor(NewClass))
	test "line 292", (t) => t.falsy(isConstructor(o))

	test "line 294", (t) => t.truthy(isFunction(() -> 42))
	test "line 295", (t) => t.truthy(isFunction(() => 42))
	test "line 296", (t) => t.falsy(isFunction(undef))
	test "line 297", (t) => t.falsy(isFunction(null))
	test "line 298", (t) => t.falsy(isFunction(42))
	test "line 299", (t) => t.falsy(isFunction(n))

	test "line 301", (t) => t.truthy(isRegExp(/^abc$/))
	test "line 302", (t) => t.truthy(isRegExp(///^ \s* where \s+ areyou $///))
	test "line 303", (t) => t.falsy(isRegExp(42))
	test "line 304", (t) => t.falsy(isRegExp('abc'))
	test "line 305", (t) => t.falsy(isRegExp([1,'a']))
	test "line 306", (t) => t.falsy(isRegExp({a:1, b:'ccc'}))
	test "line 307", (t) => t.falsy(isRegExp(undef))
	test "line 308", (t) => t.truthy(isRegExp(/\.coffee/))

	test "line 310", (t) => t.falsy(isObject(h))
	test "line 311", (t) => t.falsy(isObject(l))
	test "line 312", (t) => t.truthy(isObject(o))
	test "line 313", (t) => t.truthy(isObject(o, ['name','doIt']))
	test "line 314", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 315", (t) => t.falsy(isObject(o, ['name','doIt','missing']))
	test "line 316", (t) => t.falsy(isObject(o, "name doIt missing"))
	test "line 317", (t) => t.falsy(isObject(n))
	test "line 318", (t) => t.falsy(isObject(n2))
	test "line 319", (t) => t.falsy(isObject(s))
	test "line 320", (t) => t.falsy(isObject(s2))
	test "line 321", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 322", (t) => t.truthy(isObject(o, "name doIt meth"))
	test "line 323", (t) => t.truthy(isObject(o, "name &doIt &meth"))
	test "line 324", (t) => t.falsy(isObject(o, "&name"))

	test "line 326", (t) => t.deepEqual(jsType(undef), [undef, undef])
	test "line 327", (t) => t.deepEqual(jsType(null),  [undef, 'null'])
	test "line 328", (t) => t.deepEqual(jsType(s), ['string', undef])
	test "line 329", (t) => t.deepEqual(jsType(''), ['string', 'empty'])
	test "line 330", (t) => t.deepEqual(jsType("\t\t"), ['string', 'empty'])
	test "line 331", (t) => t.deepEqual(jsType("  "), ['string', 'empty'])
	test "line 332", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 333", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 334", (t) => t.deepEqual(jsType(3.14159), ['number', undef])
	test "line 335", (t) => t.deepEqual(jsType(42), ['number', 'integer'])
	test "line 336", (t) => t.deepEqual(jsType(true), ['boolean', undef])
	test "line 337", (t) => t.deepEqual(jsType(false), ['boolean', undef])
	test "line 338", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 339", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 340", (t) => t.deepEqual(jsType(l), ['array', undef])
	test "line 341", (t) => t.deepEqual(jsType([]), ['array', 'empty'])
	test "line 342", (t) => t.deepEqual(jsType(/abc/), ['regexp', undef])

	func1 = (x) ->
		return

	func2 = (x) =>
		return

	# --- NOTE: regular functions can't be distinguished from constructors
	test "line 351", (t) => t.deepEqual(jsType(func1), ['class', undef])

	test "line 353", (t) => t.deepEqual(jsType(func2), ['function', undef])
	test "line 354", (t) => t.deepEqual(jsType(NewClass), ['class', undef])
	test "line 355", (t) => t.deepEqual(jsType(o), ['object', undef])
	)()

# ---------------------------------------------------------------------------

test "line 360", (t) => t.deepEqual(blockToArray(undef), [])
test "line 361", (t) => t.deepEqual(blockToArray(''), [])
test "line 362", (t) => t.deepEqual(blockToArray('a'), ['a'])
test "line 363", (t) => t.deepEqual(blockToArray("a\nb"), ['a','b'])
test "line 364", (t) => t.deepEqual(blockToArray("a\r\nb"), ['a','b'])
test "line 365", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 370", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 375", (t) => t.deepEqual(blockToArray("abc\n\nxyz"), [
	'abc'
	''
	'xyz'
	])

# ---------------------------------------------------------------------------

test "line 383", (t) => t.deepEqual(toArray("abc\ndef"), ['abc','def'])
test "line 384", (t) => t.deepEqual(toArray(['a','b']), ['a','b'])

test "line 386", (t) => t.deepEqual(toArray(["a\nb","c\nd"]), ['a','b','c','d'])

# ---------------------------------------------------------------------------

test "line 390", (t) => t.deepEqual(arrayToBlock(undef), '')
test "line 391", (t) => t.deepEqual(arrayToBlock([]), '')
test "line 392", (t) => t.deepEqual(arrayToBlock([undef]), '')
test "line 393", (t) => t.deepEqual(arrayToBlock(['a  ','b\t\t']), "a\nb")
test "line 394", (t) => t.deepEqual(arrayToBlock(['a','b','c']), "a\nb\nc")
test "line 395", (t) => t.deepEqual(arrayToBlock(['a',undef,'b','c']), "a\nb\nc")
test "line 396", (t) => t.deepEqual(arrayToBlock([undef,'a','b','c',undef]), "a\nb\nc")

# ---------------------------------------------------------------------------

test "line 400", (t) => t.deepEqual(toBlock(['abc','def']), "abc\ndef")
test "line 401", (t) => t.deepEqual(toBlock("abc\ndef"), "abc\ndef")

# ---------------------------------------------------------------------------

test "line 405", (t) => t.is(rtrim("abc"), "abc")
test "line 406", (t) => t.is(rtrim("  abc"), "  abc")
test "line 407", (t) => t.is(rtrim("abc  "), "abc")
test "line 408", (t) => t.is(rtrim("  abc  "), "  abc")

# ---------------------------------------------------------------------------

test "line 412", (t) => t.deepEqual(words(''), [])
test "line 413", (t) => t.deepEqual(words('  \t\t'), [])
test "line 414", (t) => t.deepEqual(words('a b c'), ['a', 'b', 'c'])
test "line 415", (t) => t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c'])
test "line 416", (t) => t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd'])
test "line 417", (t) => t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word'])

test "line 419", (t) => t.truthy hasChar('abc', 'b')
test "line 420", (t) => t.falsy  hasChar('abc', 'x')
test "line 421", (t) => t.falsy  hasChar("\t\t", ' ')

# ---------------------------------------------------------------------------

test "line 425", (t) => t.is(quoted('abc'), "'abc'")
test "line 426", (t) => t.is(quoted('"abc"'), "'\"abc\"'")
test "line 427", (t) => t.is(quoted("'abc'"), "\"'abc'\"")
test "line 428", (t) => t.is(quoted("'\"abc\"'"), "<'\"abc\"'>")
test "line 429", (t) => t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>")

# ---------------------------------------------------------------------------

test "line 433", (t) => t.deepEqual(getOptions(), {})
test "line 434", (t) => t.deepEqual(getOptions(undef, {x:1}), {x:1})
test "line 435", (t) => t.deepEqual(getOptions({x:1}, {x:3,y:4}), {x:1,y:4})
test "line 436", (t) => t.deepEqual(getOptions('asText'), {asText: true})
test "line 437", (t) => t.deepEqual(getOptions('!binary'), {binary: false})
test "line 438", (t) => t.deepEqual(getOptions('label=this'), {label: 'this'})
test "line 439", (t) => t.deepEqual(getOptions('width=42'), {width: 42})
test "line 440", (t) => t.deepEqual(getOptions('asText !binary label=this'), {
	asText: true
	binary: false
	label: 'this'
	})

# ---------------------------------------------------------------------------

test "line 448", (t) => t.deepEqual(range(3), [0,1,2])
test "line 449", (t) => t.deepEqual(rev_range(3), [2,1,0])

# ---------------------------------------------------------------------------

utest.truthy 453, isHashComment('#')
utest.truthy 454, isHashComment('# a comment')
utest.truthy 455, isHashComment('#\ta comment')
utest.falsy  456, isHashComment('#comment')
utest.falsy  457, isHashComment('')
utest.falsy  458, isHashComment('a comment')

# ---------------------------------------------------------------------------

utest.truthy 462, isEmpty('')
utest.truthy 463, isEmpty('  \t\t')
utest.truthy 464, isEmpty([])
utest.truthy 465, isEmpty({})

utest.truthy 467, nonEmpty('a')
utest.truthy 468, nonEmpty('.')
utest.truthy 469, nonEmpty([2])
utest.truthy 470, nonEmpty({width: 2})

utest.truthy 472, isNonEmptyString('abc')
utest.falsy  473, isNonEmptyString(undef)
utest.falsy  474, isNonEmptyString('')
utest.falsy  475, isNonEmptyString('   ')
utest.falsy  476, isNonEmptyString("\t\t\t")
utest.falsy  477, isNonEmptyString(5)

# ---------------------------------------------------------------------------

utest.truthy 481, oneof('a', 'a', 'b', 'c')
utest.truthy 482, oneof('b', 'a', 'b', 'c')
utest.truthy 483, oneof('c', 'a', 'b', 'c')
utest.falsy  484, oneof('d', 'a', 'b', 'c')
utest.falsy  485, oneof('x')

# ---------------------------------------------------------------------------

utest.equal 489, uniq([1,2,2,3,3]), [1,2,3]
utest.equal 490, uniq(['a','b','b','c','c']),['a','b','c']

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

utest.equal 505, rtrim("abc"), "abc"
utest.equal 506, rtrim("  abc"), "  abc"
utest.equal 507, rtrim("abc  "), "abc"
utest.equal 508, rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

utest.equal 512, words('a b c'), ['a', 'b', 'c']
utest.equal 513, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

utest.equal 517, escapeStr("\t\tXXX\n"), "→→XXX®"
hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}
utest.equal 523, escapeStr("\thas quote: \"\nnext line", hEsc), \
	"\\thas quote: \\\"\\nnext line"

# ---------------------------------------------------------------------------

utest.equal 528, rtrunc('/user/lib/.env', 5), '/user/lib'
utest.equal 529, ltrunc('abcdefg', 3), 'defg'

utest.equal 531, CWS("""
		abc
		def
				ghi
		"""), "abc def ghi"

# ---------------------------------------------------------------------------

utest.truthy 539, isArrayOfStrings([])
utest.truthy 540, isArrayOfStrings(['a','b','c'])
utest.truthy 541, isArrayOfStrings(['a',undef, null, 'b'])

# ---------------------------------------------------------------------------

utest.truthy 545, isArrayOfArrays([])
utest.truthy 546, isArrayOfArrays([[], []])
utest.truthy 547, isArrayOfArrays([[1,2], []])
utest.truthy 548, isArrayOfArrays([[1,2,[1,2,3]], []])
utest.truthy 549, isArrayOfArrays([[1,2], undef, null, []])

utest.falsy  551, isArrayOfArrays({})
utest.falsy  552, isArrayOfArrays([1,2,3])
utest.falsy  553, isArrayOfArrays([[1,2,[3,4]], 4])
utest.falsy  554, isArrayOfArrays([[1,2,[3,4]], [], {a:1,b:2}])

utest.truthy 556, isArrayOfArrays([[1,2],[3,4],[4,5]], 2)
utest.falsy  557, isArrayOfArrays([[1,2],[3],[4,5]], 2)
utest.falsy  558, isArrayOfArrays([[1,2],[3,4,5],[4,5]], 2)

# ---------------------------------------------------------------------------

utest.truthy 562, isArrayOfHashes([])
utest.truthy 563, isArrayOfHashes([{}, {}])
utest.truthy 564, isArrayOfHashes([{a:1, b:2}, {}])
utest.truthy 565, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}])
utest.truthy 566, isArrayOfHashes([{a:1, b:2}, undef, null, {}])

utest.falsy  568, isArrayOfHashes({})
utest.falsy  569, isArrayOfHashes([1,2,3])
utest.falsy  570, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, 4])
utest.falsy  571, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}, [1,2]])

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

	utest.truthy 590, isHash(h)
	utest.falsy  591, isHash(l)
	utest.falsy  592, isHash(o)
	utest.falsy  593, isHash(n)
	utest.falsy  594, isHash(n2)
	utest.falsy  595, isHash(s)
	utest.falsy  596, isHash(s2)

	utest.falsy  598, isArray(h)
	utest.truthy 599, isArray(l)
	utest.falsy  600, isArray(o)
	utest.falsy  601, isArray(n)
	utest.falsy  602, isArray(n2)
	utest.falsy  603, isArray(s)
	utest.falsy  604, isArray(s2)

	utest.falsy  606, isString(undef)
	utest.falsy  607, isString(h)
	utest.falsy  608, isString(l)
	utest.falsy  609, isString(o)
	utest.falsy  610, isString(n)
	utest.falsy  611, isString(n2)
	utest.truthy 612, isString(s)
	utest.truthy 613, isString(s2)

	utest.falsy  615, isObject(h)
	utest.falsy  616, isObject(l)
	utest.truthy 617, isObject(o)
	utest.truthy 618, isObject(o, ['name','doIt'])
	utest.falsy  619, isObject(o, ['name','doIt','missing'])
	utest.falsy  620, isObject(n)
	utest.falsy  621, isObject(n2)
	utest.falsy  622, isObject(s)
	utest.falsy  623, isObject(s2)

	utest.falsy  625, isNumber(h)
	utest.falsy  626, isNumber(l)
	utest.falsy  627, isNumber(o)
	utest.truthy 628, isNumber(n)
	utest.truthy 629, isNumber(n2)
	utest.falsy  630, isNumber(s)
	utest.falsy  631, isNumber(s2)

	utest.truthy 633, isNumber(42.0, {min: 42.0})
	utest.falsy  634, isNumber(42.0, {min: 42.1})
	utest.truthy 635, isNumber(42.0, {max: 42.0})
	utest.falsy  636, isNumber(42.0, {max: 41.9})
	)()

# ---------------------------------------------------------------------------

utest.truthy 641, isFunction(() -> pass)
utest.falsy  642, isFunction(23)

utest.truthy 644, isInteger(42)
utest.truthy 645, isInteger(new Number(42))
utest.falsy  646, isInteger('abc')
utest.falsy  647, isInteger({})
utest.falsy  648, isInteger([])
utest.truthy 649, isInteger(42, {min:  0})
utest.falsy  650, isInteger(42, {min: 50})
utest.truthy 651, isInteger(42, {max: 50})
utest.falsy  652, isInteger(42, {max:  0})

# ---------------------------------------------------------------------------

utest.equal 656, OL(undef), "undef"
utest.equal 657, OL("\t\tabc\nxyz"), "'→→abc®xyz'"
utest.equal 658, OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

utest.equal 662, CWS("""
		a utest
		error message
		"""), "a utest error message"

# ---------------------------------------------------------------------------
# test isRegExp()

utest.truthy 670, isRegExp(/^abc$/)
utest.truthy 671, isRegExp(///^
		\s*
		where
		\s+
		areyou
		$///)
utest.falsy  677, isRegExp(42)
utest.falsy  678, isRegExp('abc')
utest.falsy  679, isRegExp([1,'a'])
utest.falsy  680, isRegExp({a:1, b:'ccc'})
utest.falsy  681, isRegExp(undef)

utest.truthy 683, isRegExp(/\.coffee/)

# ---------------------------------------------------------------------------

utest.equal 687, extractMatches("..3 and 4 plus 5", /\d+/g, parseInt),
	[3, 4, 5]
utest.equal 689, extractMatches("And This Is A String", /A/g), ['A','A']

# ---------------------------------------------------------------------------

utest.truthy 693, notdefined(undef)
utest.truthy 694, notdefined(null)
utest.truthy 695, defined('')
utest.truthy 696, defined(5)
utest.truthy 697, defined([])
utest.truthy 698, defined({})

utest.falsy 700, defined(undef)
utest.falsy 701, defined(null)
utest.falsy 702, notdefined('')
utest.falsy 703, notdefined(5)
utest.falsy 704, notdefined([])
utest.falsy 705, notdefined({})

# ---------------------------------------------------------------------------

utest.truthy 709, isIterable([])
utest.truthy 710, isIterable(['a','b'])

gen = () ->
	yield 1
	yield 2
	yield 3
	return

utest.truthy 718, isIterable(gen())

# ---------------------------------------------------------------------------

(() ->
	class MyClass
		constructor: (str) ->
			@mystr = str

	utest.equal 727, className(MyClass), 'MyClass'

	)()

# ---------------------------------------------------------------------------

utest.equal 733, getOptions('a b c'), {'a':true, 'b':true, 'c':true}
utest.equal 734, getOptions('abc'), {'abc':true}
utest.equal 735, getOptions({'a':true, 'b':false, 'c':42}), {'a':true, 'b':false, 'c':42}
utest.equal 736, getOptions(), {}

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
	utest.equal 751, lResult, ['ABC','DEF', 'GHI']
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

	utest.equal 767, lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		lResult.push line.toUpperCase()
		return false
	utest.equal 776, lResult, ['ABC','DEF', 'GHI']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		if (line == 'ghi')
			return true
		lResult.push line.toUpperCase()
		return false

	utest.equal 788, lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line, hInfo) =>
		if (line == 'ghi')
			return true
		lResult.push "#{hInfo.lineNum} #{line.toUpperCase()} #{hInfo.nextLine}"
		return false

	utest.equal 800, lResult, ['1 ABC def','2 DEF ghi']
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
	utest.equal 814, newblock, """
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
	utest.equal 832, newblock, """
		ABC
		GHI
		"""
	)()

(() =>
	item = ['abc','def','ghi']
	newblock = mapEachLine item, (line) =>
		return line.toUpperCase()
	utest.equal 842, newblock, [
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
	utest.equal 856, newblock, [
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
	utest.equal 871, newblock, [
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

	utest.equal 897, removeKeys(hAST, ['start','end']), {
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

	utest.equal 928, removeKeys(hAST, ['start','end']), {
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

	utest.equal 968, hToDo.task, 'go shopping'
	utest.equal 969, h.task, 'GO SHOPPING'

	h.task = 'do something'
	utest.equal 972, hToDo.task, 'do something'
	utest.equal 973, h.task, 'DO SOMETHING'

	h.task = 'nothing'
	utest.equal 976, hToDo.task, 'do something'
	utest.equal 977, h.task, 'DO SOMETHING'

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

	utest.equal 998, await run1(), 'abc,def,ghi'
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

	utest.equal 1015, await run2(), 'def,ghi'
	)()

# ---------------------------------------------------------------------------
# test eachCharInString()

utest.truthy 1021, eachCharInString 'ABC', (ch) => ch == ch.toUpperCase()
utest.falsy  1022, eachCharInString 'abc', (ch) => ch == ch.toUpperCase()
utest.falsy  1023, eachCharInString 'AbC', (ch) => ch == ch.toUpperCase()

# ---------------------------------------------------------------------------
# test runCmd()

utest.equal 1028, runCmd("echo abc"), "abc\r\n"
utest.equal 1029, runCmd("noSuchCmd"), undef

# ---------------------------------------------------------------------------
# test choose()

lItems = ['apple','orange','pear']
utest.truthy 1035, lItems.includes(choose(lItems))
utest.truthy 1036, lItems.includes(choose(lItems))
utest.truthy 1037, lItems.includes(choose(lItems))

# ---------------------------------------------------------------------------
# test shuffle()

lShuffled = deepCopy(lItems)
shuffle(lShuffled)
utest.truthy 1044, lShuffled.includes('apple')
utest.truthy 1045, lShuffled.includes('orange')
utest.truthy 1046, lShuffled.includes('pear')
utest.truthy 1047, lShuffled.length == lItems.length

# ---------------------------------------------------------------------------
# test some date functions

dateStr = '2023-01-01 05:00:00'
utest.equal 1053, timestamp(dateStr), "1/1/2023 5:00:00 AM"
utest.equal 1054, msSinceEpoch(dateStr), 1672567200000
utest.equal 1055, formatDate(dateStr), "Jan 1, 2023"


# ---------------------------------------------------------------------------
# test pad()

utest.equal 1061, pad(23, 5), "   23"
utest.equal 1062, pad(23, 5, 'justify=left'), '23   '
utest.equal 1063, pad('abc', 6), 'abc   '
utest.equal 1064, pad('abc', 6, 'justify=center'), ' abc  '
utest.equal 1065, pad(true, 3), 'true'
utest.equal 1066, pad(false, 3, 'truncate'), 'fal'

# ---------------------------------------------------------------------------
# test keys(), hasKey(), subkeys()

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

utest.equal  1092, keys(h), ['2023-Nov','2023-Dec']
utest.truthy 1093, hasKey(h, '2023-Nov')
utest.falsy  1094, hasKey(h, '2023-Oct')
utest.equal  1095, subkeys(h), ['Dining','Hardware','Insurance']

