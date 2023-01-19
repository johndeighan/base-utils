# base-utils.test.coffee

import test from 'ava'

import {utest} from '@jdeighan/base-utils/utest'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, pass, defined, notdefined, tabify, untabify, prefixBlock,
	escapeStr, OL, OLS, inList,  isHashComment, splitPrefix,
	isString, isNumber, isInteger, isHash, isArray, isBoolean,
	isClass, isConstructor, removeKeys,
	isFunction, isRegExp, isObject, jsType,
	isEmpty, nonEmpty, isNonEmptyString, isIdentifier,
	isFunctionName, isIterable,
	blockToArray, arrayToBlock, toArray, toBlock,
	rtrim, words, hasChar, quoted, getOptions, range,
	oneof, uniq, rtrunc, ltrunc, CWS, className,
	isArrayOfStrings, isArrayOfHashes, extractMatches,
	forEachLine, mapEachLine,
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

	test "line 230", (t) => t.falsy(isNumber(h))
	test "line 231", (t) => t.falsy(isNumber(l))
	test "line 232", (t) => t.falsy(isNumber(o))
	test "line 233", (t) => t.truthy(isNumber(n))
	test "line 234", (t) => t.truthy(isNumber(n2))
	test "line 235", (t) => t.falsy(isNumber(s))
	test "line 236", (t) => t.falsy(isNumber(s2))

	test "line 238", (t) => t.truthy(isNumber(42.0, {min: 42.0}))
	test "line 239", (t) => t.falsy(isNumber(42.0, {min: 42.1}))
	test "line 240", (t) => t.truthy(isNumber(42.0, {max: 42.0}))
	test "line 241", (t) => t.falsy(isNumber(42.0, {max: 41.9}))

	test "line 243", (t) => t.truthy(isInteger(42))
	test "line 244", (t) => t.truthy(isInteger(new Number(42)))
	test "line 245", (t) => t.falsy(isInteger('abc'))
	test "line 246", (t) => t.falsy(isInteger({}))
	test "line 247", (t) => t.falsy(isInteger([]))
	test "line 248", (t) => t.truthy(isInteger(42, {min:  0}))
	test "line 249", (t) => t.falsy(isInteger(42, {min: 50}))
	test "line 250", (t) => t.truthy(isInteger(42, {max: 50}))
	test "line 251", (t) => t.falsy(isInteger(42, {max:  0}))

	test "line 253", (t) => t.truthy(isHash(h))
	test "line 254", (t) => t.falsy(isHash(l))
	test "line 255", (t) => t.falsy(isHash(o))
	test "line 256", (t) => t.falsy(isHash(n))
	test "line 257", (t) => t.falsy(isHash(n2))
	test "line 258", (t) => t.falsy(isHash(s))
	test "line 259", (t) => t.falsy(isHash(s2))

	test "line 261", (t) => t.falsy(isArray(h))
	test "line 262", (t) => t.truthy(isArray(l))
	test "line 263", (t) => t.falsy(isArray(o))
	test "line 264", (t) => t.falsy(isArray(n))
	test "line 265", (t) => t.falsy(isArray(n2))
	test "line 266", (t) => t.falsy(isArray(s))
	test "line 267", (t) => t.falsy(isArray(s2))

	test "line 269", (t) => t.truthy(isBoolean(true))
	test "line 270", (t) => t.truthy(isBoolean(false))
	test "line 271", (t) => t.falsy(isBoolean(42))
	test "line 272", (t) => t.falsy(isBoolean("true"))

	test "line 274", (t) => t.truthy(isClass(NewClass))
	test "line 275", (t) => t.falsy(isClass(o))

	test "line 277", (t) => t.truthy(isConstructor(NewClass))
	test "line 278", (t) => t.falsy(isConstructor(o))

	test "line 280", (t) => t.truthy(isFunction(() -> 42))
	test "line 281", (t) => t.truthy(isFunction(() => 42))
	test "line 282", (t) => t.falsy(isFunction(42))
	test "line 283", (t) => t.falsy(isFunction(n))

	test "line 285", (t) => t.truthy(isRegExp(/^abc$/))
	test "line 286", (t) => t.truthy(isRegExp(///^ \s* where \s+ areyou $///))
	test "line 287", (t) => t.falsy(isRegExp(42))
	test "line 288", (t) => t.falsy(isRegExp('abc'))
	test "line 289", (t) => t.falsy(isRegExp([1,'a']))
	test "line 290", (t) => t.falsy(isRegExp({a:1, b:'ccc'}))
	test "line 291", (t) => t.falsy(isRegExp(undef))
	test "line 292", (t) => t.truthy(isRegExp(/\.coffee/))

	test "line 294", (t) => t.falsy(isObject(h))
	test "line 295", (t) => t.falsy(isObject(l))
	test "line 296", (t) => t.truthy(isObject(o))
	test "line 297", (t) => t.truthy(isObject(o, ['name','doIt']))
	test "line 298", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 299", (t) => t.falsy(isObject(o, ['name','doIt','missing']))
	test "line 300", (t) => t.falsy(isObject(o, "name doIt missing"))
	test "line 301", (t) => t.falsy(isObject(n))
	test "line 302", (t) => t.falsy(isObject(n2))
	test "line 303", (t) => t.falsy(isObject(s))
	test "line 304", (t) => t.falsy(isObject(s2))
	test "line 305", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 306", (t) => t.truthy(isObject(o, "name doIt meth"))
	test "line 307", (t) => t.truthy(isObject(o, "name &doIt &meth"))
	test "line 308", (t) => t.falsy(isObject(o, "&name"))

	test "line 310", (t) => t.deepEqual(jsType(undef), [undef, 'undef'])
	test "line 311", (t) => t.deepEqual(jsType(null),  [undef, 'null'])
	test "line 312", (t) => t.deepEqual(jsType(s), ['string', undef])
	test "line 313", (t) => t.deepEqual(jsType(''), ['string', 'empty'])
	test "line 314", (t) => t.deepEqual(jsType("\t\t"), ['string', 'empty'])
	test "line 315", (t) => t.deepEqual(jsType("  "), ['string', 'empty'])
	test "line 316", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 317", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 318", (t) => t.deepEqual(jsType(3.14159), ['number', undef])
	test "line 319", (t) => t.deepEqual(jsType(42), ['number', 'integer'])
	test "line 320", (t) => t.deepEqual(jsType(true), ['boolean', undef])
	test "line 321", (t) => t.deepEqual(jsType(false), ['boolean', undef])
	test "line 322", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 323", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 324", (t) => t.deepEqual(jsType(l), ['array', undef])
	test "line 325", (t) => t.deepEqual(jsType([]), ['array', 'empty'])
	test "line 326", (t) => t.deepEqual(jsType(/abc/), ['regexp', undef])

	func1 = (x) ->
		return

	func2 = (x) =>
		return

	# --- NOTE: regular functions can't be distinguished from constructors
	test "line 335", (t) => t.deepEqual(jsType(func1), ['class', undef])

	test "line 337", (t) => t.deepEqual(jsType(func2), ['function', undef])
	test "line 338", (t) => t.deepEqual(jsType(NewClass), ['class', undef])
	test "line 339", (t) => t.deepEqual(jsType(o), ['object', undef])
	)()

# ---------------------------------------------------------------------------

test "line 344", (t) => t.truthy(isEmpty(''))
test "line 345", (t) => t.truthy(isEmpty('  \t\t'))
test "line 346", (t) => t.truthy(isEmpty([]))
test "line 347", (t) => t.truthy(isEmpty({}))

test "line 349", (t) => t.truthy(nonEmpty('a'))
test "line 350", (t) => t.truthy(nonEmpty('.'))
test "line 351", (t) => t.truthy(nonEmpty([2]))
test "line 352", (t) => t.truthy(nonEmpty({width: 2}))

# ---------------------------------------------------------------------------

test "line 356", (t) => t.deepEqual(blockToArray(undef), [])
test "line 357", (t) => t.deepEqual(blockToArray(''), [])
test "line 358", (t) => t.deepEqual(blockToArray('a'), ['a'])
test "line 359", (t) => t.deepEqual(blockToArray("a\nb"), ['a','b'])
test "line 360", (t) => t.deepEqual(blockToArray("a\r\nb"), ['a','b'])
test "line 361", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 366", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 371", (t) => t.deepEqual(blockToArray("abc\n\nxyz"), [
	'abc'
	''
	'xyz'
	])

# ---------------------------------------------------------------------------

test "line 379", (t) => t.deepEqual(toArray("abc\ndef"), ['abc','def'])
test "line 380", (t) => t.deepEqual(toArray(['a','b']), ['a','b'])

test "line 382", (t) => t.deepEqual(toArray(["a\nb","c\nd"]), ['a','b','c','d'])

# ---------------------------------------------------------------------------

test "line 386", (t) => t.deepEqual(arrayToBlock(undef), '')
test "line 387", (t) => t.deepEqual(arrayToBlock([]), '')
test "line 388", (t) => t.deepEqual(arrayToBlock([undef]), '')
test "line 389", (t) => t.deepEqual(arrayToBlock(['a  ','b\t\t']), "a\nb")
test "line 390", (t) => t.deepEqual(arrayToBlock(['a','b','c']), "a\nb\nc")
test "line 391", (t) => t.deepEqual(arrayToBlock(['a',undef,'b','c']), "a\nb\nc")
test "line 392", (t) => t.deepEqual(arrayToBlock([undef,'a','b','c',undef]), "a\nb\nc")

# ---------------------------------------------------------------------------

test "line 396", (t) => t.deepEqual(toBlock(['abc','def']), "abc\ndef")
test "line 397", (t) => t.deepEqual(toBlock("abc\ndef"), "abc\ndef")

# ---------------------------------------------------------------------------

test "line 401", (t) => t.is(rtrim("abc"), "abc")
test "line 402", (t) => t.is(rtrim("  abc"), "  abc")
test "line 403", (t) => t.is(rtrim("abc  "), "abc")
test "line 404", (t) => t.is(rtrim("  abc  "), "  abc")

# ---------------------------------------------------------------------------

test "line 408", (t) => t.deepEqual(words(''), [])
test "line 409", (t) => t.deepEqual(words('  \t\t'), [])
test "line 410", (t) => t.deepEqual(words('a b c'), ['a', 'b', 'c'])
test "line 411", (t) => t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c'])
test "line 412", (t) => t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd'])
test "line 413", (t) => t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word'])

test "line 415", (t) => t.truthy hasChar('abc', 'b')
test "line 416", (t) => t.falsy  hasChar('abc', 'x')
test "line 417", (t) => t.falsy  hasChar("\t\t", ' ')

# ---------------------------------------------------------------------------

test "line 421", (t) => t.is(quoted('abc'), "'abc'")
test "line 422", (t) => t.is(quoted('"abc"'), "'\"abc\"'")
test "line 423", (t) => t.is(quoted("'abc'"), "\"'abc'\"")
test "line 424", (t) => t.is(quoted("'\"abc\"'"), "<'\"abc\"'>")
test "line 425", (t) => t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>")

# ---------------------------------------------------------------------------

test "line 429", (t) => t.deepEqual(getOptions(), {})
test "line 430", (t) => t.deepEqual(getOptions(undef, {x:1}), {x:1})
test "line 431", (t) => t.deepEqual(getOptions({x:1}, {x:3,y:4}), {x:1,y:4})
test "line 432", (t) => t.deepEqual(getOptions('asText'), {asText: true})
test "line 433", (t) => t.deepEqual(getOptions('!binary'), {binary: false})
test "line 434", (t) => t.deepEqual(getOptions('label=this'), {label: 'this'})
test "line 435", (t) => t.deepEqual(getOptions('asText !binary label=this'), {
	asText: true
	binary: false
	label: 'this'
	})

# ---------------------------------------------------------------------------

test "line 443", (t) => t.deepEqual(range(3), [0,1,2])

# ---------------------------------------------------------------------------

utest.truthy 447, isHashComment('#')
utest.truthy 448, isHashComment('# a comment')
utest.truthy 449, isHashComment('#\ta comment')
utest.falsy  450, isHashComment('#comment')
utest.falsy  451, isHashComment('')
utest.falsy  452, isHashComment('a comment')

# ---------------------------------------------------------------------------

utest.truthy 456, isEmpty('')
utest.truthy 457, isEmpty('  \t\t')
utest.truthy 458, isEmpty([])
utest.truthy 459, isEmpty({})

utest.truthy 461, nonEmpty('a')
utest.truthy 462, nonEmpty('.')
utest.truthy 463, nonEmpty([2])
utest.truthy 464, nonEmpty({width: 2})

utest.truthy 466, isNonEmptyString('abc')
utest.falsy  467, isNonEmptyString(undef)
utest.falsy  468, isNonEmptyString('')
utest.falsy  469, isNonEmptyString('   ')
utest.falsy  470, isNonEmptyString("\t\t\t")
utest.falsy  471, isNonEmptyString(5)

# ---------------------------------------------------------------------------

utest.truthy 475, oneof('a', 'a', 'b', 'c')
utest.truthy 476, oneof('b', 'a', 'b', 'c')
utest.truthy 477, oneof('c', 'a', 'b', 'c')
utest.falsy  478, oneof('d', 'a', 'b', 'c')
utest.falsy  479, oneof('x')

# ---------------------------------------------------------------------------

utest.equal 483, uniq([1,2,2,3,3]), [1,2,3]
utest.equal 484, uniq(['a','b','b','c','c']),['a','b','c']

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

utest.equal 499, rtrim("abc"), "abc"
utest.equal 500, rtrim("  abc"), "  abc"
utest.equal 501, rtrim("abc  "), "abc"
utest.equal 502, rtrim("  abc  "), "  abc"

# ---------------------------------------------------------------------------

utest.equal 506, words('a b c'), ['a', 'b', 'c']
utest.equal 507, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

utest.equal 511, escapeStr("\t\tXXX\n"), "→→XXX®"
hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}
utest.equal 517, escapeStr("\thas quote: \"\nnext line", hEsc), \
	"\\thas quote: \\\"\\nnext line"

# ---------------------------------------------------------------------------

utest.equal 522, rtrunc('/user/lib/.env', 5), '/user/lib'
utest.equal 523, ltrunc('abcdefg', 3), 'defg'

utest.equal 525, CWS("""
		abc
		def
				ghi
		"""), "abc def ghi"

# ---------------------------------------------------------------------------

utest.truthy 533, isArrayOfStrings([])
utest.truthy 534, isArrayOfStrings(['a','b','c'])
utest.truthy 535, isArrayOfStrings(['a',undef, null, 'b'])

# ---------------------------------------------------------------------------

utest.truthy 539, isArrayOfHashes([])
utest.truthy 540, isArrayOfHashes([{}, {}])
utest.truthy 541, isArrayOfHashes([{a:1, b:2}, {}])
utest.truthy 542, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}])
utest.truthy 543, isArrayOfHashes([{a:1, b:2}, undef, null, {}])

utest.falsy  545, isArrayOfHashes({})
utest.falsy  546, isArrayOfHashes([1,2,3])
utest.falsy  547, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, 4])
utest.falsy  548, isArrayOfHashes([{a:1, b:2, c: [1,2,3]}, {}, [1,2]])

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

	utest.truthy 567, isHash(h)
	utest.falsy  568, isHash(l)
	utest.falsy  569, isHash(o)
	utest.falsy  570, isHash(n)
	utest.falsy  571, isHash(n2)
	utest.falsy  572, isHash(s)
	utest.falsy  573, isHash(s2)

	utest.falsy  575, isArray(h)
	utest.truthy 576, isArray(l)
	utest.falsy  577, isArray(o)
	utest.falsy  578, isArray(n)
	utest.falsy  579, isArray(n2)
	utest.falsy  580, isArray(s)
	utest.falsy  581, isArray(s2)

	utest.falsy  583, isString(undef)
	utest.falsy  584, isString(h)
	utest.falsy  585, isString(l)
	utest.falsy  586, isString(o)
	utest.falsy  587, isString(n)
	utest.falsy  588, isString(n2)
	utest.truthy 589, isString(s)
	utest.truthy 590, isString(s2)

	utest.falsy  592, isObject(h)
	utest.falsy  593, isObject(l)
	utest.truthy 594, isObject(o)
	utest.truthy 595, isObject(o, ['name','doIt'])
	utest.falsy  596, isObject(o, ['name','doIt','missing'])
	utest.falsy  597, isObject(n)
	utest.falsy  598, isObject(n2)
	utest.falsy  599, isObject(s)
	utest.falsy  600, isObject(s2)

	utest.falsy  602, isNumber(h)
	utest.falsy  603, isNumber(l)
	utest.falsy  604, isNumber(o)
	utest.truthy 605, isNumber(n)
	utest.truthy 606, isNumber(n2)
	utest.falsy  607, isNumber(s)
	utest.falsy  608, isNumber(s2)

	utest.truthy 610, isNumber(42.0, {min: 42.0})
	utest.falsy  611, isNumber(42.0, {min: 42.1})
	utest.truthy 612, isNumber(42.0, {max: 42.0})
	utest.falsy  613, isNumber(42.0, {max: 41.9})
	)()

# ---------------------------------------------------------------------------

utest.truthy 618, isFunction(() -> pass)
utest.falsy  619, isFunction(23)

utest.truthy 621, isInteger(42)
utest.truthy 622, isInteger(new Number(42))
utest.falsy  623, isInteger('abc')
utest.falsy  624, isInteger({})
utest.falsy  625, isInteger([])
utest.truthy 626, isInteger(42, {min:  0})
utest.falsy  627, isInteger(42, {min: 50})
utest.truthy 628, isInteger(42, {max: 50})
utest.falsy  629, isInteger(42, {max:  0})

# ---------------------------------------------------------------------------

utest.equal 633, OL(undef), "undef"
utest.equal 634, OL("\t\tabc\nxyz"), "'→→abc®xyz'"
utest.equal 635, OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}'

# ---------------------------------------------------------------------------

utest.equal 639, CWS("""
		a utest
		error message
		"""), "a utest error message"

# ---------------------------------------------------------------------------
# test isRegExp()

utest.truthy 647, isRegExp(/^abc$/)
utest.truthy 648, isRegExp(///^
		\s*
		where
		\s+
		areyou
		$///)
utest.falsy  654, isRegExp(42)
utest.falsy  655, isRegExp('abc')
utest.falsy  656, isRegExp([1,'a'])
utest.falsy  657, isRegExp({a:1, b:'ccc'})
utest.falsy  658, isRegExp(undef)

utest.truthy 660, isRegExp(/\.coffee/)

# ---------------------------------------------------------------------------

utest.equal 664, extractMatches("..3 and 4 plus 5", /\d+/g, parseInt),
	[3, 4, 5]
utest.equal 666, extractMatches("And This Is A String", /A/g), ['A','A']

# ---------------------------------------------------------------------------

utest.truthy 670, notdefined(undef)
utest.truthy 671, notdefined(null)
utest.truthy 672, defined('')
utest.truthy 673, defined(5)
utest.truthy 674, defined([])
utest.truthy 675, defined({})

utest.falsy 677, defined(undef)
utest.falsy 678, defined(null)
utest.falsy 679, notdefined('')
utest.falsy 680, notdefined(5)
utest.falsy 681, notdefined([])
utest.falsy 682, notdefined({})

# ---------------------------------------------------------------------------

utest.truthy 686, isIterable([])
utest.truthy 687, isIterable(['a','b'])

gen = () ->
	yield 1
	yield 2
	yield 3
	return

utest.truthy 695, isIterable(gen())

# ---------------------------------------------------------------------------

(() ->
	class MyClass
		constructor: (str) ->
			@mystr = str

	utest.equal 704, className(MyClass), 'MyClass'

	)()

# ---------------------------------------------------------------------------

utest.equal 710, getOptions('a b c'), {'a':true, 'b':true, 'c':true}
utest.equal 711, getOptions('abc'), {'abc':true}
utest.equal 712, getOptions({'a':true, 'b':false, 'c':42}), {'a':true, 'b':false, 'c':42}
utest.equal 713, getOptions(), {}

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
	utest.equal 728, lResult, ['ABC','DEF', 'GHI']
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

	utest.equal 744, lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		lResult.push line.toUpperCase()
		return false
	utest.equal 753, lResult, ['ABC','DEF', 'GHI']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line) =>
		if (line == 'ghi')
			return true
		lResult.push line.toUpperCase()
		return false

	utest.equal 765, lResult, ['ABC','DEF']
	)()

(() =>
	lResult = []
	item = ['abc','def','ghi']
	forEachLine item, (line, hInfo) =>
		if (line == 'ghi')
			return true
		lResult.push "#{hInfo.lineNum} #{line.toUpperCase()} #{hInfo.nextLine}"
		return false

	utest.equal 777, lResult, ['1 ABC def','2 DEF ghi']
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
	utest.equal 791, newblock, """
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
	utest.equal 809, newblock, """
		ABC
		GHI
		"""
	)()

(() =>
	item = ['abc','def','ghi']
	newblock = mapEachLine item, (line) =>
		return line.toUpperCase()
	utest.equal 819, newblock, [
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
	utest.equal 833, newblock, [
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
	utest.equal 848, newblock, [
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

	utest.equal 874, removeKeys(hAST, ['start','end']), {
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

	utest.equal 905, removeKeys(hAST, ['start','end']), {
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
