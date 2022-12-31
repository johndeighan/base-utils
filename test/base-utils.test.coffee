# base-utils.test.coffee

import test from 'ava'

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, pass, defined, notdefined, untabify, prefixBlock,
	escapeStr, unescapeStr, OL, OLS, inList,  isHashComment,
	isString, isNumber, isInteger, isHash, isArray, isBoolean,
	isConstructor, isFunction, isRegExp, isObject, jsType,
	isEmpty, nonEmpty, isNonEmptyString, isIdentifier,
	isFunctionName, isIterable,
	blockToArray, arrayToBlock, toArray, toBlock,
	chomp, rtrim, setCharsAt, words, firstWord,
	hasChar, quoted, getOptions, range,
	} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

test "line 20", (t) => t.truthy(isHashComment('   # something'))
test "line 21", (t) => t.truthy(isHashComment('   #'))
test "line 22", (t) => t.falsy(isHashComment('   abc'))
test "line 23", (t) => t.falsy(isHashComment('#abc'))

test "line 25", (t) => t.is(undef, undefined)

test "line 27", (t) => t.truthy(isFunction(pass))

(() ->
	passTest = () =>
		pass()
	test "line 32", (t) => t.notThrows(passTest, "pass fails")
	)()

test "line 35", (t) => t.truthy(defined(''))
test "line 36", (t) => t.truthy(defined(5))
test "line 37", (t) => t.truthy(defined([]))
test "line 38", (t) => t.truthy(defined({}))
test "line 39", (t) => t.falsy(defined(undef))
test "line 40", (t) => t.falsy(defined(null))

test "line 42", (t) => t.truthy(notdefined(undef))
test "line 43", (t) => t.truthy(notdefined(null))
test "line 44", (t) => t.falsy(notdefined(''))
test "line 45", (t) => t.falsy(notdefined(5))
test "line 46", (t) => t.falsy(notdefined([]))
test "line 47", (t) => t.falsy(notdefined({}))

(() ->
	prefix = '   '    # 3 spaces

	test "line 52", (t) => t.is(untabify("""
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

test "line 65", (t) => t.is(prefixBlock("""
	abc
	def
	""", '--'), """
	--abc
	--def
	""")

# ---------------------------------------------------------------------------

test "line 75", (t) => t.is(escapeStr("\t\tXXX\n"), "→→XXX®")

hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}

test "line 83", (t) => t.is(escapeStr("\thas quote: \"\nnext line", hEsc),
	"\\thas quote: \\\"\\nnext line")

test "line 86", (t) => t.is(unescapeStr("˳˳˳"), "   ")
test "line 87", (t) => t.is(unescapeStr("®®®"), "\n\n\n")
test "line 88", (t) => t.is(unescapeStr("→→→"), "\t\t\t")

# ---------------------------------------------------------------------------

test "line 92", (t) => t.is(OL(undef), "undef")
test "line 93", (t) => t.is(OL("\t\tabc\nxyz"), "'→→abc®xyz'")
test "line 94", (t) => t.is(OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}')

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

test "line 102", (t) => t.is(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}')

# ---------------------------------------------------------------------------

test "line 106", (t) => t.is(OLS(['abc', 3]), "'abc',3")
test "line 107", (t) => t.is(OLS([]), "")
test "line 108", (t) => t.is(OLS([undef, {a:1}]), 'undef,{"a":1}')

# ---------------------------------------------------------------------------

test "line 99",  (t) => t.truthy(inList('a', 'b', 'a', 'c'))
test "line 113", (t) => t.falsy( inList('a', 'b', 'c'))

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

	test "line 133", (t) => t.falsy(isString(undef))
	test "line 134", (t) => t.falsy(isString(h))
	test "line 135", (t) => t.falsy(isString(l))
	test "line 136", (t) => t.falsy(isString(o))
	test "line 137", (t) => t.falsy(isString(n))
	test "line 138", (t) => t.falsy(isString(n2))

	test "line 140", (t) => t.truthy(isString(s))
	test "line 141", (t) => t.truthy(isString(s2))

	test "line 143", (t) => t.truthy(isNonEmptyString('abc'))
	test "line 144", (t) => t.truthy(isNonEmptyString('abc def'))
	test "line 145", (t) => t.falsy(isNonEmptyString(''))
	test "line 146", (t) => t.falsy(isNonEmptyString('  '))

	test "line 148", (t) => t.truthy(isIdentifier('abc'))
	test "line 149", (t) => t.truthy(isIdentifier('_Abc'))
	test "line 150", (t) => t.falsy(isIdentifier('abc def'))
	test "line 151", (t) => t.falsy(isIdentifier('abc-def'))
	test "line 152", (t) => t.falsy(isIdentifier('class.method'))

	test "line 154", (t) => t.truthy(isFunctionName('abc'))
	test "line 155", (t) => t.truthy(isFunctionName('_Abc'))
	test "line 156", (t) => t.falsy(isFunctionName('abc def'))
	test "line 157", (t) => t.falsy(isFunctionName('abc-def'))
	test "line 158", (t) => t.falsy(isFunctionName('D()'))
	test "line 159", (t) => t.truthy(isFunctionName('class.method'))

	generatorFunc = () ->
		yield 1
		yield 2
		yield 3
		return

	test "line 167", (t) => t.truthy(isIterable(generatorFunc()))

	test "line 169", (t) => t.falsy(isNumber(h))
	test "line 170", (t) => t.falsy(isNumber(l))
	test "line 171", (t) => t.falsy(isNumber(o))
	test "line 172", (t) => t.truthy(isNumber(n))
	test "line 173", (t) => t.truthy(isNumber(n2))
	test "line 174", (t) => t.falsy(isNumber(s))
	test "line 175", (t) => t.falsy(isNumber(s2))

	test "line 177", (t) => t.truthy(isNumber(42.0, {min: 42.0}))
	test "line 178", (t) => t.falsy(isNumber(42.0, {min: 42.1}))
	test "line 179", (t) => t.truthy(isNumber(42.0, {max: 42.0}))
	test "line 180", (t) => t.falsy(isNumber(42.0, {max: 41.9}))

	test "line 182", (t) => t.truthy(isInteger(42))
	test "line 183", (t) => t.truthy(isInteger(new Number(42)))
	test "line 184", (t) => t.falsy(isInteger('abc'))
	test "line 185", (t) => t.falsy(isInteger({}))
	test "line 186", (t) => t.falsy(isInteger([]))
	test "line 187", (t) => t.truthy(isInteger(42, {min:  0}))
	test "line 188", (t) => t.falsy(isInteger(42, {min: 50}))
	test "line 189", (t) => t.truthy(isInteger(42, {max: 50}))
	test "line 190", (t) => t.falsy(isInteger(42, {max:  0}))

	test "line 192", (t) => t.truthy(isHash(h))
	test "line 193", (t) => t.falsy(isHash(l))
	test "line 194", (t) => t.falsy(isHash(o))
	test "line 195", (t) => t.falsy(isHash(n))
	test "line 196", (t) => t.falsy(isHash(n2))
	test "line 197", (t) => t.falsy(isHash(s))
	test "line 198", (t) => t.falsy(isHash(s2))

	test "line 200", (t) => t.falsy(isArray(h))
	test "line 201", (t) => t.truthy(isArray(l))
	test "line 202", (t) => t.falsy(isArray(o))
	test "line 203", (t) => t.falsy(isArray(n))
	test "line 204", (t) => t.falsy(isArray(n2))
	test "line 205", (t) => t.falsy(isArray(s))
	test "line 206", (t) => t.falsy(isArray(s2))

	test "line 208", (t) => t.truthy(isBoolean(true))
	test "line 209", (t) => t.truthy(isBoolean(false))
	test "line 210", (t) => t.falsy(isBoolean(42))
	test "line 211", (t) => t.falsy(isBoolean("true"))

	test "line 213", (t) => t.truthy(isConstructor(NewClass))
	test "line 214", (t) => t.falsy(isConstructor(o))

	test "line 216", (t) => t.truthy(isFunction(() -> 42))
	test "line 217", (t) => t.truthy(isFunction(() => 42))
	test "line 218", (t) => t.falsy(isFunction(42))
	test "line 219", (t) => t.falsy(isFunction(n))

	test "line 221", (t) => t.truthy(isRegExp(/^abc$/))
	test "line 222", (t) => t.truthy(isRegExp(///^ \s* where \s+ areyou $///))
	test "line 223", (t) => t.falsy(isRegExp(42))
	test "line 224", (t) => t.falsy(isRegExp('abc'))
	test "line 225", (t) => t.falsy(isRegExp([1,'a']))
	test "line 226", (t) => t.falsy(isRegExp({a:1, b:'ccc'}))
	test "line 227", (t) => t.falsy(isRegExp(undef))
	test "line 228", (t) => t.truthy(isRegExp(/\.coffee/))

	test "line 230", (t) => t.falsy(isObject(h))
	test "line 231", (t) => t.falsy(isObject(l))
	test "line 232", (t) => t.truthy(isObject(o))
	test "line 233", (t) => t.truthy(isObject(o, ['name','doIt']))
	test "line 234", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 235", (t) => t.falsy(isObject(o, ['name','doIt','missing']))
	test "line 236", (t) => t.falsy(isObject(o, "name doIt missing"))
	test "line 237", (t) => t.falsy(isObject(n))
	test "line 238", (t) => t.falsy(isObject(n2))
	test "line 239", (t) => t.falsy(isObject(s))
	test "line 240", (t) => t.falsy(isObject(s2))
	test "line 241", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 242", (t) => t.truthy(isObject(o, "name doIt meth"))
	test "line 243", (t) => t.truthy(isObject(o, "name &doIt &meth"))
	test "line 244", (t) => t.falsy(isObject(o, "&name"))

	test "line 246", (t) => t.deepEqual(jsType(undef), [undef, 'undef'])
	test "line 247", (t) => t.deepEqual(jsType(null),  [undef, 'null'])
	test "line 248", (t) => t.deepEqual(jsType(s), ['string', undef])
	test "line 249", (t) => t.deepEqual(jsType(''), ['string', 'empty'])
	test "line 250", (t) => t.deepEqual(jsType("\t\t"), ['string', 'empty'])
	test "line 251", (t) => t.deepEqual(jsType("  "), ['string', 'empty'])
	test "line 252", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 253", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 254", (t) => t.deepEqual(jsType(3.14159), ['number', undef])
	test "line 255", (t) => t.deepEqual(jsType(42), ['number', 'integer'])
	test "line 256", (t) => t.deepEqual(jsType(true), ['boolean', 'true'])
	test "line 257", (t) => t.deepEqual(jsType(false), ['boolean', 'false'])
	test "line 258", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 259", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 260", (t) => t.deepEqual(jsType(l), ['array', undef])
	test "line 261", (t) => t.deepEqual(jsType([]), ['array', 'empty'])
	test "line 262", (t) => t.deepEqual(jsType(/abc/), ['regexp', undef])
	func1 = (x) ->
		return
	func2 = (x) =>
		return

	# --- NOTE: regular functions can't be distinguished from constructors
	test "line 269", (t) => t.deepEqual(jsType(func1), ['function', 'constructor'])

	test "line 271", (t) => t.deepEqual(jsType(func2), ['function', undef])
	test "line 272", (t) => t.deepEqual(jsType(NewClass), ['function', 'constructor'])
	test "line 273", (t) => t.deepEqual(jsType(o), ['object', undef])
	)()

# ---------------------------------------------------------------------------

test "line 278", (t) => t.truthy(isEmpty(''))
test "line 279", (t) => t.truthy(isEmpty('  \t\t'))
test "line 280", (t) => t.truthy(isEmpty([]))
test "line 281", (t) => t.truthy(isEmpty({}))

test "line 283", (t) => t.truthy(nonEmpty('a'))
test "line 284", (t) => t.truthy(nonEmpty('.'))
test "line 285", (t) => t.truthy(nonEmpty([2]))
test "line 286", (t) => t.truthy(nonEmpty({width: 2}))

# ---------------------------------------------------------------------------

test "line 290", (t) => t.deepEqual(blockToArray(undef), [])
test "line 291", (t) => t.deepEqual(blockToArray(''), [])
test "line 292", (t) => t.deepEqual(blockToArray('a'), ['a'])
test "line 293", (t) => t.deepEqual(blockToArray("a\nb"), ['a','b'])
test "line 294", (t) => t.deepEqual(blockToArray("a\r\nb"), ['a','b'])
test "line 295", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 300", (t) => t.deepEqual(blockToArray("abc\nxyz"), [
	'abc'
	'xyz'
	])

test "line 305", (t) => t.deepEqual(blockToArray("abc\n\nxyz"), [
	'abc'
	''
	'xyz'
	])

# ---------------------------------------------------------------------------

test "line 313", (t) => t.deepEqual(toArray("abc\ndef"), ['abc','def'])
test "line 314", (t) => t.deepEqual(toArray(['a','b']), ['a','b'])

test "line 316", (t) => t.deepEqual(toArray(["a\nb","c\nd"]), ['a','b','c','d'])

# ---------------------------------------------------------------------------

test "line 320", (t) => t.deepEqual(arrayToBlock(undef), '')
test "line 321", (t) => t.deepEqual(arrayToBlock([]), '')
test "line 322", (t) => t.deepEqual(arrayToBlock([undef]), '')
test "line 323", (t) => t.deepEqual(arrayToBlock(['a  ','b\t\t']), "a\nb")
test "line 324", (t) => t.deepEqual(arrayToBlock(['a','b','c']), "a\nb\nc")
test "line 325", (t) => t.deepEqual(arrayToBlock(['a',undef,'b','c']), "a\nb\nc")
test "line 326", (t) => t.deepEqual(arrayToBlock([undef,'a','b','c',undef]), "a\nb\nc")

# ---------------------------------------------------------------------------

test "line 330", (t) => t.deepEqual(toBlock(['abc','def']), "abc\ndef")
test "line 331", (t) => t.deepEqual(toBlock("abc\ndef"), "abc\ndef")

# ---------------------------------------------------------------------------

test "line 335", (t) => t.is(chomp('abc'), 'abc')
test "line 336", (t) => t.is(chomp('abc\n'), 'abc')
test "line 337", (t) => t.is(chomp('abc\r\n'), 'abc')

test "line 339", (t) => t.is(chomp('abc\ndef'), 'abc\ndef')
test "line 340", (t) => t.is(chomp('abc\ndef\n'), 'abc\ndef')
test "line 341", (t) => t.is(chomp('abc\ndef\r\n'), 'abc\ndef')

test "line 343", (t) => t.is(chomp('abc\r\ndef'), 'abc\r\ndef')
test "line 344", (t) => t.is(chomp('abc\r\ndef\n'), 'abc\r\ndef')
test "line 345", (t) => t.is(chomp('abc\r\ndef\r\n'), 'abc\r\ndef')

# ---------------------------------------------------------------------------

test "line 349", (t) => t.is(rtrim("abc"), "abc")
test "line 350", (t) => t.is(rtrim("  abc"), "  abc")
test "line 351", (t) => t.is(rtrim("abc  "), "abc")
test "line 352", (t) => t.is(rtrim("  abc  "), "  abc")

# ---------------------------------------------------------------------------

test "line 356", (t) => t.is(setCharsAt('abc', 1, 'x'), 'axc')
test "line 357", (t) => t.is(setCharsAt('abc', 1, 'xy'), 'axy')
test "line 358", (t) => t.is(setCharsAt('abc', 1, 'xyz'), 'axyz')

# ---------------------------------------------------------------------------

test "line 362", (t) => t.deepEqual(words(''), [])
test "line 363", (t) => t.deepEqual(words('  \t\t'), [])
test "line 364", (t) => t.deepEqual(words('a b c'), ['a', 'b', 'c'])
test "line 365", (t) => t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c'])
test "line 366", (t) => t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd'])
test "line 367", (t) => t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word'])

test "line 369", (t) => t.is firstWord("abc"), "abc"
test "line 370", (t) => t.is firstWord(" abc"), ""
test "line 371", (t) => t.is firstWord("abc def"), "abc"
test "line 372", (t) => t.is firstWord("! not this"), "!"

test "line 374", (t) => t.truthy hasChar('abc', 'b')
test "line 375", (t) => t.falsy  hasChar('abc', 'x')
test "line 376", (t) => t.falsy  hasChar("\t\t", ' ')

# ---------------------------------------------------------------------------

test "line 380", (t) => t.is(quoted('abc'), "'abc'")
test "line 381", (t) => t.is(quoted('"abc"'), "'\"abc\"'")
test "line 382", (t) => t.is(quoted("'abc'"), "\"'abc'\"")
test "line 383", (t) => t.is(quoted("'\"abc\"'"), "<'\"abc\"'>")
test "line 384", (t) => t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>")

# ---------------------------------------------------------------------------

test "line 388", (t) => t.deepEqual(getOptions(), {})
test "line 389", (t) => t.deepEqual(getOptions(undef, {x:1}), {x:1})
test "line 390", (t) => t.deepEqual(getOptions({x:1}, {x:3,y:4}), {x:1,y:4})
test "line 391", (t) => t.deepEqual(getOptions('asText'), {asText: true})
test "line 392", (t) => t.deepEqual(getOptions('!binary'), {binary: false})
test "line 393", (t) => t.deepEqual(getOptions('label=this'), {label: 'this'})
test "line 394", (t) => t.deepEqual(getOptions('asText !binary label=this'), {
	asText: true
	binary: false
	label: 'this'
	})

# ---------------------------------------------------------------------------

test "line 402", (t) => t.deepEqual(range(3), [0,1,2])
