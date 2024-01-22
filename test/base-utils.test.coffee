# base-utils.test.coffee

import test from 'ava'

import {utest} from '@jdeighan/base-utils/utest'
import {
	undef, pass, defined, notdefined, alldefined,
	ll_assert, ll_croak,
	keys, hasKey, hasAllKeys, hasAnyKey, subkeys,
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

test "line 25", (t) => t.is(undef, undefined)
test "line 26", (t) => t.truthy(pass())
test "line 27", (t) => t.truthy(defined(1))
test "line 28", (t) => t.falsy(defined(undefined))
test "line 29", (t) => t.truthy(notdefined(undefined))
test "line 30", (t) => t.falsy(notdefined(12))
test "line 31", (t) => t.notThrows(() => pass())
test "line 32", (t) => t.notThrows(() => ll_assert(12==12, "BAD"))

# ---------------------------------------------------------------------------

test "line 36", (t) => t.truthy(isEmpty(''))
test "line 37", (t) => t.truthy(isEmpty('  \t\t'))
test "line 38", (t) => t.truthy(isEmpty([]))
test "line 39", (t) => t.truthy(isEmpty({}))

test "line 41", (t) => t.truthy(nonEmpty('a'))
test "line 42", (t) => t.truthy(nonEmpty('.'))
test "line 43", (t) => t.truthy(nonEmpty([2]))
test "line 44", (t) => t.truthy(nonEmpty({width: 2}))

# ---------------------------------------------------------------------------

a = undef
b = null
c = 42
d = 'dog'
e = {a: 42}

test "line 54", (t) => t.truthy(alldefined(c,d,e))
test "line 55", (t) => t.falsy(alldefined(a,b,c,d,e))
test "line 56", (t) => t.falsy(alldefined(a,c,d,e))
test "line 57", (t) => t.falsy(alldefined(b,c,d,e))

test "line 59", (t) => t.deepEqual(deepCopy(e), {a: 42})

# ---------------------------------------------------------------------------

test "line 63", (t) => t.truthy(deepEqual({a:1, b:2}, {a:1, b:2}))
test "line 64", (t) => t.falsy (deepEqual({a:1, b:2}, {a:1, b:3}))

# ---------------------------------------------------------------------------

test "line 68", (t) => t.truthy(isHashComment('   # something'))
test "line 69", (t) => t.truthy(isHashComment('   #'))
test "line 70", (t) => t.falsy(isHashComment('   abc'))
test "line 71", (t) => t.falsy(isHashComment('#abc'))

test "line 73", (t) => t.is(undef, undefined)

test "line 75", (t) => t.truthy(isFunction(pass))

(() ->
	passTest = () =>
		pass()
	test "line 80", (t) => t.notThrows(passTest, "pass fails")
	)()

test "line 83", (t) => t.truthy(defined(''))
test "line 84", (t) => t.truthy(defined(5))
test "line 85", (t) => t.truthy(defined([]))
test "line 86", (t) => t.truthy(defined({}))
test "line 87", (t) => t.falsy(defined(undef))
test "line 88", (t) => t.falsy(defined(null))

test "line 90", (t) => t.truthy(notdefined(undef))
test "line 91", (t) => t.truthy(notdefined(null))
test "line 92", (t) => t.falsy(notdefined(''))
test "line 93", (t) => t.falsy(notdefined(5))
test "line 94", (t) => t.falsy(notdefined([]))
test "line 95", (t) => t.falsy(notdefined({}))

# ---------------------------------------------------------------------------

test "line 99", (t) => t.deepEqual(splitPrefix("abc"),     ["", "abc"])
test "line 100", (t) => t.deepEqual(splitPrefix("\tabc"),   ["\t", "abc"])
test "line 101", (t) => t.deepEqual(splitPrefix("\t\tabc"), ["\t\t", "abc"])
test "line 102", (t) => t.deepEqual(splitPrefix(""),        ["", ""])
test "line 103", (t) => t.deepEqual(splitPrefix("\t\t\t"),  ["", ""])
test "line 104", (t) => t.deepEqual(splitPrefix("\t \t"),   ["", ""])
test "line 105", (t) => t.deepEqual(splitPrefix("   "),     ["", ""])

# ---------------------------------------------------------------------------

test "line 109", (t) => t.falsy (hasPrefix("abc"))
test "line 110", (t) => t.truthy(hasPrefix("   abc"))

# ---------------------------------------------------------------------------

(() ->
	prefix = '   '    # 3 spaces

	test "line 117", (t) => t.is(untabify("""
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

	utest.equal 133, tabify("""
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

	utest.equal 150, tabify("""
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

	utest.equal 166, untabify("""
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

test "line 179", (t) => t.is(prefixBlock("""
	abc
	def
	""", '--'), """
	--abc
	--def
	""")

# ---------------------------------------------------------------------------

test "line 189", (t) => t.is(escapeStr("\t\tXXX\n"), "→→XXX®")

hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}

test "line 197", (t) => t.is(escapeStr("\thas quote: \"\nnext line", hEsc),
	"\\thas quote: \\\"\\nnext line")

# ---------------------------------------------------------------------------

test "line 202", (t) => t.is(OL(undef), "undef")
test "line 203", (t) => t.is(OL("\t\tabc\nxyz"), "'→→abc®xyz'")
test "line 204", (t) => t.is(OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}')

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

test "line 212", (t) => t.is(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}')

# ---------------------------------------------------------------------------

test "line 216", (t) => t.is(OLS(['abc', 3]), "'abc',3")
test "line 217", (t) => t.is(OLS([]), "")
test "line 218", (t) => t.is(OLS([undef, {a:1}]), 'undef,{"a":1}')

# ---------------------------------------------------------------------------

test "line 222", (t) => t.truthy(oneof('a', 'b', 'a', 'c'))
test "line 223", (t) => t.falsy( oneof('a', 'b', 'c'))

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

	test "line 243", (t) => t.falsy(isString(undef))
	test "line 244", (t) => t.falsy(isString(h))
	test "line 245", (t) => t.falsy(isString(l))
	test "line 246", (t) => t.falsy(isString(o))
	test "line 247", (t) => t.falsy(isString(n))
	test "line 248", (t) => t.falsy(isString(n2))

	test "line 250", (t) => t.truthy(isString(s))
	test "line 251", (t) => t.truthy(isString(s2))

	test "line 253", (t) => t.truthy(isNonEmptyString('abc'))
	test "line 254", (t) => t.truthy(isNonEmptyString('abc def'))
	test "line 255", (t) => t.falsy(isNonEmptyString(''))
	test "line 256", (t) => t.falsy(isNonEmptyString('  '))

	test "line 258", (t) => t.truthy(isIdentifier('abc'))
	test "line 259", (t) => t.truthy(isIdentifier('_Abc'))
	test "line 260", (t) => t.falsy(isIdentifier('abc def'))
	test "line 261", (t) => t.falsy(isIdentifier('abc-def'))
	test "line 262", (t) => t.falsy(isIdentifier('class.method'))

	test "line 264", (t) => t.truthy(isFunctionName('abc'))
	test "line 265", (t) => t.truthy(isFunctionName('_Abc'))
	test "line 266", (t) => t.falsy(isFunctionName('abc def'))
	test "line 267", (t) => t.falsy(isFunctionName('abc-def'))
	test "line 268", (t) => t.falsy(isFunctionName('D()'))
	test "line 269", (t) => t.truthy(isFunctionName('class.method'))

	generatorFunc = () ->
		yield 1
		yield 2
		yield 3
		return

	test "line 277", (t) => t.truthy(isIterable(generatorFunc()))

	test "line 279", (t) => t.falsy(isNumber(undef))
	test "line 280", (t) => t.falsy(isNumber(null))
	test "line 281", (t) => t.truthy(isNumber(NaN))
	test "line 282", (t) => t.falsy(isNumber(h))
	test "line 283", (t) => t.falsy(isNumber(l))
	test "line 284", (t) => t.falsy(isNumber(o))
	test "line 285", (t) => t.truthy(isNumber(n))
	test "line 286", (t) => t.truthy(isNumber(n2))
	test "line 287", (t) => t.falsy(isNumber(s))
	test "line 288", (t) => t.falsy(isNumber(s2))

	test "line 290", (t) => t.truthy(isNumber(42.0, {min: 42.0}))
	test "line 291", (t) => t.falsy(isNumber(42.0, {min: 42.1}))
	test "line 292", (t) => t.truthy(isNumber(42.0, {max: 42.0}))
	test "line 293", (t) => t.falsy(isNumber(42.0, {max: 41.9}))

	test "line 295", (t) => t.truthy(isInteger(42))
	test "line 296", (t) => t.truthy(isInteger(new Number(42)))
	test "line 297", (t) => t.falsy(isInteger('abc'))
	test "line 298", (t) => t.falsy(isInteger({}))
	test "line 299", (t) => t.falsy(isInteger([]))
	test "line 300", (t) => t.truthy(isInteger(42, {min:  0}))
	test "line 301", (t) => t.falsy(isInteger(42, {min: 50}))
	test "line 302", (t) => t.truthy(isInteger(42, {max: 50}))
	test "line 303", (t) => t.falsy(isInteger(42, {max:  0}))

	test "line 305", (t) => t.truthy(isHash(h))
	test "line 306", (t) => t.falsy(isHash(l))
	test "line 307", (t) => t.falsy(isHash(o))
	test "line 308", (t) => t.falsy(isHash(n))
	test "line 309", (t) => t.falsy(isHash(n2))
	test "line 310", (t) => t.falsy(isHash(s))
	test "line 311", (t) => t.falsy(isHash(s2))

	test "line 313", (t) => t.falsy(isArray(h))
	test "line 314", (t) => t.truthy(isArray(l))
	test "line 315", (t) => t.falsy(isArray(o))
	test "line 316", (t) => t.falsy(isArray(n))
	test "line 317", (t) => t.falsy(isArray(n2))
	test "line 318", (t) => t.falsy(isArray(s))
	test "line 319", (t) => t.falsy(isArray(s2))

	test "line 321", (t) => t.truthy(isBoolean(true))
	test "line 322", (t) => t.truthy(isBoolean(false))
	test "line 323", (t) => t.falsy(isBoolean(42))
	test "line 324", (t) => t.falsy(isBoolean("true"))

	test "line 326", (t) => t.truthy(isClass(NewClass))
	test "line 327", (t) => t.falsy(isClass(o))

	test "line 329", (t) => t.truthy(isConstructor(NewClass))
	test "line 330", (t) => t.falsy(isConstructor(o))

	test "line 332", (t) => t.truthy(isFunction(() -> 42))
	test "line 333", (t) => t.truthy(isFunction(() => 42))
	test "line 334", (t) => t.falsy(isFunction(undef))
	test "line 335", (t) => t.falsy(isFunction(null))
	test "line 336", (t) => t.falsy(isFunction(42))
	test "line 337", (t) => t.falsy(isFunction(n))

	test "line 339", (t) => t.truthy(isRegExp(/^abc$/))
	test "line 340", (t) => t.truthy(isRegExp(///^ \s* where \s+ areyou $///))
	test "line 341", (t) => t.falsy(isRegExp(42))
	test "line 342", (t) => t.falsy(isRegExp('abc'))
	test "line 343", (t) => t.falsy(isRegExp([1,'a']))
	test "line 344", (t) => t.falsy(isRegExp({a:1, b:'ccc'}))
	test "line 345", (t) => t.falsy(isRegExp(undef))
	test "line 346", (t) => t.truthy(isRegExp(/\.coffee/))

	test "line 348", (t) => t.falsy(isObject(h))
	test "line 349", (t) => t.falsy(isObject(l))
	test "line 350", (t) => t.truthy(isObject(o))
	test "line 351", (t) => t.truthy(isObject(o, ['name','doIt']))
	test "line 352", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 353", (t) => t.falsy(isObject(o, ['name','doIt','missing']))
	test "line 354", (t) => t.falsy(isObject(o, "name doIt missing"))
	test "line 355", (t) => t.falsy(isObject(n))
	test "line 356", (t) => t.falsy(isObject(n2))
	test "line 357", (t) => t.falsy(isObject(s))
	test "line 358", (t) => t.falsy(isObject(s2))
	test "line 359", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 360", (t) => t.truthy(isObject(o, "name doIt meth"))
	test "line 361", (t) => t.truthy(isObject(o, "name &doIt &meth"))
	test "line 362", (t) => t.falsy(isObject(o, "&name"))

	test "line 364", (t) => t.deepEqual(jsType(undef), [undef, undef])
	test "line 365", (t) => t.deepEqual(jsType(null),  [undef, 'null'])
	test "line 366", (t) => t.deepEqual(jsType(s), ['string', undef])
	test "line 367", (t) => t.deepEqual(jsType(''), ['string', 'empty'])
	test "line 368", (t) => t.deepEqual(jsType("\t\t"), ['string', 'empty'])
	test "line 369", (t) => t.deepEqual(jsType("  "), ['string', 'empty'])
	test "line 370", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 371", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 372", (t) => t.deepEqual(jsType(3.14159), ['number', undef])
	test "line 373", (t) => t.deepEqual(jsType(42), ['number', 'integer'])
	test "line 374", (t) => t.deepEqual(jsType(true), ['boolean', undef])
	test "line 375", (t) => t.deepEqual(jsType(false), ['boolean', undef])
	test "line 376", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 377", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 378", (t) => t.deepEqual(jsType(l), ['array', undef])
	test "line 379", (t) => t.deepEqual(jsType([]), ['array', 'empty'])
	test "line 380", (t) => t.deepEqual(jsType(/abc/), ['regexp', undef])

	func1 = (x) ->
		return

	func2 = (x) =>
		return

	# --- NOTE: regular functions can't be distinguished from constructors
	test "line 389", (t) => t.deepEqual(jsType(func1), ['class', undef])

	test "line 391", (t) => t.deepEqual(jsType(func2), ['function', undef])
	test "line 392", (t) => t.deepEqual(jsType(NewClass), ['class', undef])
	test "line 393", (t) => t.deepEqual(jsType(o), ['object', undef])
	)()

# ---------------------------------------------------------------------------

test "line 398", (t) => t.deepEqual(blockToArray(undef), [])
test "line 399", (t) => t.deepEqual(blockToArray(''), [])
test "line 400", (t) => t.deepEqual(blockToArray('a'), ['a'])
test "line 401", (t) => t.deepEqual(blockToArray("a\nb"), ['a','b'])
test "line 402", (t) => t.deepEqual(blockToArray("a\r\nb"), ['a','b'])
test "line 403", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 408", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 413", (t) => t.deepEqual(blockToArray("abc\n\nxyz"), [
	'abc'
	''
	'xyz'
	])

# ---------------------------------------------------------------------------

test "line 421", (t) => t.deepEqual(toArray("abc\ndef"), ['abc','def'])
test "line 422", (t) => t.deepEqual(toArray(['a','b']), ['a','b'])

test "line 424", (t) => t.deepEqual(toArray(["a\nb","c\nd"]), ['a','b','c','d'])

# ---------------------------------------------------------------------------

test "line 428", (t) => t.deepEqual(arrayToBlock(undef), '')
test "line 429", (t) => t.deepEqual(arrayToBlock([]), '')
test "line 430", (t) => t.deepEqual(arrayToBlock([undef]), '')
test "line 431", (t) => t.deepEqual(arrayToBlock(['a  ','b\t\t']), "a\nb")
test "line 432", (t) => t.deepEqual(arrayToBlock(['a','b','c']), "a\nb\nc")
test "line 433", (t) => t.deepEqual(arrayToBlock(['a',undef,'b','c']), "a\nb\nc")
test "line 434", (t) => t.deepEqual(arrayToBlock([undef,'a','b','c',undef]), "a\nb\nc")

# ---------------------------------------------------------------------------

test "line 438", (t) => t.deepEqual(toBlock(['abc','def']), "abc\ndef")
test "line 439", (t) => t.deepEqual(toBlock("abc\ndef"), "abc\ndef")

# ---------------------------------------------------------------------------

test "line 443", (t) => t.is(rtrim("abc"), "abc")
test "line 444", (t) => t.is(rtrim("  abc"), "  abc")
test "line 445", (t) => t.is(rtrim("abc  "), "abc")
test "line 446", (t) => t.is(rtrim("  abc  "), "  abc")

# ---------------------------------------------------------------------------

test "line 450", (t) => t.deepEqual(words(''), [])
test "line 451", (t) => t.deepEqual(words('  \t\t'), [])
test "line 452", (t) => t.deepEqual(words('a b c'), ['a', 'b', 'c'])
test "line 453", (t) => t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c'])
test "line 454", (t) => t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd'])
test "line 455", (t) => t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word'])

test "line 457", (t) => t.truthy hasChar('abc', 'b')
test "line 458", (t) => t.falsy  hasChar('abc', 'x')
test "line 459", (t) => t.falsy  hasChar("\t\t", ' ')

# ---------------------------------------------------------------------------

test "line 463", (t) => t.is(quoted('abc'), "'abc'")
test "line 464", (t) => t.is(quoted('"abc"'), "'\"abc\"'")
test "line 465", (t) => t.is(quoted("'abc'"), "\"'abc'\"")
test "line 466", (t) => t.is(quoted("'\"abc\"'"), "<'\"abc\"'>")
test "line 467", (t) => t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>")

# ---------------------------------------------------------------------------

test "line 471", (t) => t.deepEqual(getOptions(), {})
test "line 472", (t) => t.deepEqual(getOptions(undef, {x:1}), {x:1})
test "line 473", (t) => t.deepEqual(getOptions({x:1}, {x:3,y:4}), {x:1,y:4})
test "line 474", (t) => t.deepEqual(getOptions('asText'), {asText: true})
test "line 475", (t) => t.deepEqual(getOptions('!binary'), {binary: false})
test "line 476", (t) => t.deepEqual(getOptions('label=this'), {label: 'this'})
test "line 477", (t) => t.deepEqual(getOptions('width=42'), {width: 42})
test "line 478", (t) => t.deepEqual(getOptions('asText !binary label=this'), {
	asText: true
	binary: false
	label: 'this'
	})

# ---------------------------------------------------------------------------

test "line 486", (t) => t.deepEqual(range(3), [0,1,2])
test "line 487", (t) => t.deepEqual(rev_range(3), [2,1,0])

# ---------------------------------------------------------------------------

utest.truthy 491, isHashComment('#')
utest.truthy 492, isHashComment('# a comment')
utest.truthy 493, isHashComment('#\ta comment')
utest.falsy  494, isHashComment('#comment')
utest.falsy  495, isHashComment('')
utest.falsy  496, isHashComment('a comment')

# ---------------------------------------------------------------------------

utest.truthy 500, isEmpty('')
utest.truthy 501, isEmpty('  \t\t')
utest.truthy 502, isEmpty([])
utest.truthy 503, isEmpty({})

utest.truthy 505, nonEmpty('a')
utest.truthy 506, nonEmpty('.')
utest.truthy 507, nonEmpty([2])
utest.truthy 508, nonEmpty({width: 2})

utest.truthy 510, isNonEmptyString('abc')
utest.falsy  511, isNonEmptyString(undef)
utest.falsy  512, isNonEmptyString('')
utest.falsy  513, isNonEmptyString('   ')
utest.falsy  514, isNonEmptyString("\t\t\t")
utest.falsy  515, isNonEmptyString(5)

# ---------------------------------------------------------------------------

utest.truthy 519, oneof('a', 'a', 'b', 'c')
utest.truthy 520, oneof('b', 'a', 'b', 'c')
utest.truthy 521, oneof('c', 'a', 'b', 'c')
utest.falsy  522, oneof('d', 'a', 'b', 'c')
utest.falsy  523, oneof('x')

# ---------------------------------------------------------------------------

utest.equal 527, uniq([1,2,2,3,3]), [1,2,3]
utest.equal 528, uniq(['a','b','b','c','c']),['a','b','c']

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

utest.equal 543, rtrim("abc"), "abc"
utest.equal 544, rtrim("  abc"), "  abc"
utest.equal 545, rtrim("abc  "), "abc"
utest.equal 546, rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

utest.equal 550, words('a b c'), ['a', 'b', 'c']
utest.equal 551, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

utest.equal 555, escapeStr("\t\tXXX\n"), "→→XXX®"
hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}
utest.equal 561, escapeStr("\thas quote: \"\nnext line", hEsc), \
	"\\thas quote: \\\"\\nnext line"

# ---------------------------------------------------------------------------

utest.equal 566, rtrunc('/user/lib/.env', 5), '/user/lib'
utest.equal 567, ltrunc('abcdefg', 3), 'defg'

utest.equal 569, CWS("""
		abc
		def
				ghi
		"""), "abc def ghi"

# ---------------------------------------------------------------------------

utest.truthy 577, isArrayOfStrings([])
utest.truthy 578, isArrayOfStrings(['a','b','c'])
utest.truthy 579, isArrayOfStrings(['a',undef, null, 'b'])

# ---------------------------------------------------------------------------

utest.truthy 583, isArrayOfArrays([])
utest.truthy 584, isArrayOfArrays([[], []])
utest.truthy 585, isArrayOfArrays([[1,2], []])
utest.truthy 586, isArrayOfArrays([[1,2,[1,2,3]], []])
utest.truthy 587, isArrayOfArrays([[1,2], undef, null, []])

utest.falsy  589, isArrayOfArrays({})
utest.falsy  590, isArrayOfArrays([1,2,3])
utest.falsy  591, isArrayOfArrays([[1,2,[3,4]], 4])
utest.falsy  592, isArrayOfArrays([[1,2,[3,4]], [], {a:1,b:2}])

utest.truthy 594, isArrayOfArrays([[1,2],[3,4],[4,5]], 2)
utest.falsy  595, isArrayOfArrays([[1,2],[3],[4,5]], 2)
utest.falsy  596, isArrayOfArrays([[1,2],[3,4,5],[4,5]], 2)

# ---------------------------------------------------------------------------

utest.truthy 600, isArrayOfHashes([])
utest.truthy 601, isArrayOfHashes([{}, {}])
utest.truthy 602, isArrayOfHashes([{a:1, b:2}, {}])
utest.truthy 603, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}])
utest.truthy 604, isArrayOfHashes([{a:1, b:2}, undef, null, {}])

utest.falsy  606, isArrayOfHashes({})
utest.falsy  607, isArrayOfHashes([1,2,3])
utest.falsy  608, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, 4])
utest.falsy  609, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}, [1,2]])

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

	utest.truthy 628, isHash(h)
	utest.falsy  629, isHash(l)
	utest.falsy  630, isHash(o)
	utest.falsy  631, isHash(n)
	utest.falsy  632, isHash(n2)
	utest.falsy  633, isHash(s)
	utest.falsy  634, isHash(s2)

	utest.falsy  636, isArray(h)
	utest.truthy 637, isArray(l)
	utest.falsy  638, isArray(o)
	utest.falsy  639, isArray(n)
	utest.falsy  640, isArray(n2)
	utest.falsy  641, isArray(s)
	utest.falsy  642, isArray(s2)

	utest.falsy  644, isString(undef)
	utest.falsy  645, isString(h)
	utest.falsy  646, isString(l)
	utest.falsy  647, isString(o)
	utest.falsy  648, isString(n)
	utest.falsy  649, isString(n2)
	utest.truthy 650, isString(s)
	utest.truthy 651, isString(s2)

	utest.falsy  653, isObject(h)
	utest.falsy  654, isObject(l)
	utest.truthy 655, isObject(o)
	utest.truthy 656, isObject(o, ['name','doIt'])
	utest.falsy  657, isObject(o, ['name','doIt','missing'])
	utest.falsy  658, isObject(n)
	utest.falsy  659, isObject(n2)
	utest.falsy  660, isObject(s)
	utest.falsy  661, isObject(s2)

	utest.falsy  663, isNumber(h)
	utest.falsy  664, isNumber(l)
	utest.falsy  665, isNumber(o)
	utest.truthy 666, isNumber(n)
	utest.truthy 667, isNumber(n2)
	utest.falsy  668, isNumber(s)
	utest.falsy  669, isNumber(s2)

	utest.truthy 671, isNumber(42.0, {min: 42.0})
	utest.falsy  672, isNumber(42.0, {min: 42.1})
	utest.truthy 673, isNumber(42.0, {max: 42.0})
	utest.falsy  674, isNumber(42.0, {max: 41.9})
	)()

# ---------------------------------------------------------------------------

utest.truthy 679, isFunction(() -> pass)
utest.falsy  680, isFunction(23)

utest.truthy 682, isInteger(42)
utest.truthy 683, isInteger(new Number(42))
utest.falsy  684, isInteger('abc')
utest.falsy  685, isInteger({})
utest.falsy  686, isInteger([])
utest.truthy 687, isInteger(42, {min:  0})
utest.falsy  688, isInteger(42, {min: 50})
utest.truthy 689, isInteger(42, {max: 50})
utest.falsy  690, isInteger(42, {max:  0})

# ---------------------------------------------------------------------------

utest.equal 694, OL(undef), "undef"
utest.equal 695, OL("\t\tabc\nxyz"), "'→→abc®xyz'"
utest.equal 696, OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

utest.equal 700, CWS("""
		a utest
		error message
		"""), "a utest error message"

# ---------------------------------------------------------------------------
# test isRegExp()

utest.truthy 708, isRegExp(/^abc$/)
utest.truthy 709, isRegExp(///^
		\s*
		where
		\s+
		areyou
		$///)
utest.falsy  715, isRegExp(42)
utest.falsy  716, isRegExp('abc')
utest.falsy  717, isRegExp([1,'a'])
utest.falsy  718, isRegExp({a:1, b:'ccc'})
utest.falsy  719, isRegExp(undef)

utest.truthy 721, isRegExp(/\.coffee/)

# ---------------------------------------------------------------------------

utest.equal 725, extractMatches("..3 and 4 plus 5", /\d+/g, parseInt),
	[3, 4, 5]
utest.equal 727, extractMatches("And This Is A String", /A/g), ['A','A']

# ---------------------------------------------------------------------------

utest.truthy 731, notdefined(undef)
utest.truthy 732, notdefined(null)
utest.truthy 733, defined('')
utest.truthy 734, defined(5)
utest.truthy 735, defined([])
utest.truthy 736, defined({})

utest.falsy 738, defined(undef)
utest.falsy 739, defined(null)
utest.falsy 740, notdefined('')
utest.falsy 741, notdefined(5)
utest.falsy 742, notdefined([])
utest.falsy 743, notdefined({})

# ---------------------------------------------------------------------------

utest.truthy 747, isIterable([])
utest.truthy 748, isIterable(['a','b'])

gen = () ->
	yield 1
	yield 2
	yield 3
	return

utest.truthy 756, isIterable(gen())

# ---------------------------------------------------------------------------

(() ->
	class MyClass
		constructor: (str) ->
			@mystr = str

	utest.equal 765, className(MyClass), 'MyClass'

	)()

# ---------------------------------------------------------------------------

utest.equal 771, getOptions('a b c'), {'a':true, 'b':true, 'c':true}
utest.equal 772, getOptions('abc'), {'abc':true}
utest.equal 773, getOptions({'a':true, 'b':false, 'c':42}), {'a':true, 'b':false, 'c':42}
utest.equal 774, getOptions(), {}

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
	utest.equal 789, lResult, ['ABC','DEF', 'GHI']
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

	utest.equal 805, lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		lResult.push line.toUpperCase()
		return false
	utest.equal 814, lResult, ['ABC','DEF', 'GHI']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		if (line == 'ghi')
			return true
		lResult.push line.toUpperCase()
		return false

	utest.equal 826, lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line, hInfo) =>
		if (line == 'ghi')
			return true
		lResult.push "#{hInfo.lineNum} #{line.toUpperCase()} #{hInfo.nextLine}"
		return false

	utest.equal 838, lResult, ['1 ABC def','2 DEF ghi']
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
	utest.equal 852, newblock, """
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
	utest.equal 870, newblock, """
		ABC
		GHI
		"""
	)()

(() =>
	item = ['abc','def','ghi']
	newblock = mapEachLine item, (line) =>
		return line.toUpperCase()
	utest.equal 880, newblock, [
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
	utest.equal 894, newblock, [
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
	utest.equal 909, newblock, [
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

	utest.equal 935, removeKeys(hAST, ['start','end']), {
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

	utest.equal 966, removeKeys(hAST, ['start','end']), {
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

	utest.equal 1006, hToDo.task, 'go shopping'
	utest.equal 1007, h.task, 'GO SHOPPING'

	h.task = 'do something'
	utest.equal 1010, hToDo.task, 'do something'
	utest.equal 1011, h.task, 'DO SOMETHING'

	h.task = 'nothing'
	utest.equal 1014, hToDo.task, 'do something'
	utest.equal 1015, h.task, 'DO SOMETHING'

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

	utest.equal 1036, await run1(), 'abc,def,ghi'
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

	utest.equal 1053, await run2(), 'def,ghi'
	)()

# ---------------------------------------------------------------------------
# test eachCharInString()

utest.truthy 1059, eachCharInString 'ABC', (ch) => ch == ch.toUpperCase()
utest.falsy  1060, eachCharInString 'abc', (ch) => ch == ch.toUpperCase()
utest.falsy  1061, eachCharInString 'AbC', (ch) => ch == ch.toUpperCase()

# ---------------------------------------------------------------------------
# test runCmd()

utest.equal 1066, runCmd("echo abc"), "abc\r\n"
utest.equal 1067, runCmd("noSuchCmd"), undef

# ---------------------------------------------------------------------------
# test choose()

lItems = ['apple','orange','pear']
utest.truthy 1073, lItems.includes(choose(lItems))
utest.truthy 1074, lItems.includes(choose(lItems))
utest.truthy 1075, lItems.includes(choose(lItems))

# ---------------------------------------------------------------------------
# test shuffle()

lShuffled = deepCopy(lItems)
shuffle(lShuffled)
utest.truthy 1082, lShuffled.includes('apple')
utest.truthy 1083, lShuffled.includes('orange')
utest.truthy 1084, lShuffled.includes('pear')
utest.truthy 1085, lShuffled.length == lItems.length

# ---------------------------------------------------------------------------
# test some date functions

dateStr = '2023-01-01 05:00:00'
utest.equal 1091, timestamp(dateStr), "1/1/2023 5:00:00 AM"
utest.equal 1092, msSinceEpoch(dateStr), 1672567200000
utest.equal 1093, formatDate(dateStr), "Jan 1, 2023"


# ---------------------------------------------------------------------------
# test pad()

utest.equal 1099, pad(23, 5), "   23"
utest.equal 1100, pad(23, 5, 'justify=left'), '23   '
utest.equal 1101, pad('abc', 6), 'abc   '
utest.equal 1102, pad('abc', 6, 'justify=center'), ' abc  '
utest.equal 1103, pad(true, 3), 'true'
utest.equal 1104, pad(false, 3, 'truncate'), 'fal'

# ---------------------------------------------------------------------------
# test keys(), hasKey(), hasAllKeys(), hasAnyKey(), subkeys()

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

utest.equal  1128, keys(h), ['2023-Nov','2023-Dec']
utest.truthy 1129, hasKey(h, '2023-Nov')
utest.falsy  1130, hasKey(h, '2023-Oct')
utest.equal  1131, subkeys(h), ['Dining','Hardware','Insurance']

utest.truthy 1133, hasAllKeys(h, '2023-Nov', '2023-Dec')
utest.truthy 1134, hasAllKeys(h, '2023-Nov')
utest.falsy  1135, hasAllKeys(h, '2023-Oct', '2023-Nov', '2023-Dec')

utest.truthy 1137, hasAnyKey(h, '2023-Oct', '2023-Nov', '2023-Dec')
utest.truthy 1138, hasAnyKey(h, '2023-Oct', '2023-Nov')
utest.falsy  1139, hasAnyKey(h, '2023-Jan', '2023-Feb', '2023-Mar')
