# utils.test.coffee

import test from 'ava'

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, pass, defined, notdefined, untabify, prefixBlock,
	escapeStr, unescapeStr, OL, OLS, inList,
	isString, isNumber, isInteger, isHash, isArray, isBoolean,
	isConstructor, isFunction, isRegExp, isObject, jsType,
	isEmpty, nonEmpty, isNonEmptyString, isIdentifier, isFunctionName,
	blockToArray, arrayToBlock,

	chomp, rtrim, setCharsAt, words, firstWord,
	hasChar, quoted, getOptions,
	} from '@jdeighan/base-utils/utils'

# ---------------------------------------------------------------------------

test "line 20", (t) => t.is(undef, undefined)

test "line 22", (t) => t.truthy(isFunction(pass))

(() ->
	passTest = () =>
		pass()
	test "line 27", (t) => t.notThrows(passTest, "pass fails")
	)()

test "line 30", (t) => t.truthy(defined(''))
test "line 31", (t) => t.truthy(defined(5))
test "line 32", (t) => t.truthy(defined([]))
test "line 33", (t) => t.truthy(defined({}))
test "line 34", (t) => t.falsy(defined(undef))
test "line 35", (t) => t.falsy(defined(null))

test "line 37", (t) => t.truthy(notdefined(undef))
test "line 38", (t) => t.truthy(notdefined(null))
test "line 39", (t) => t.falsy(notdefined(''))
test "line 40", (t) => t.falsy(notdefined(5))
test "line 41", (t) => t.falsy(notdefined([]))
test "line 42", (t) => t.falsy(notdefined({}))

(() ->
	prefix = '   '    # 3 spaces

	test "line 47", (t) => t.is(untabify("""
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

test "line 60", (t) => t.is(prefixBlock("""
	abc
	def
	""", '--'), """
	--abc
	--def
	""")

# ---------------------------------------------------------------------------

test "line 70", (t) => t.is(escapeStr("\t\tXXX\n"), "→→XXX®")

hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}

test "line 78", (t) => t.is(escapeStr("\thas quote: \"\nnext line", hEsc),
	"\\thas quote: \\\"\\nnext line")

test "line 81", (t) => t.is(unescapeStr("˳˳˳"), "   ")
test "line 82", (t) => t.is(unescapeStr("®®®"), "\n\n\n")
test "line 83", (t) => t.is(unescapeStr("→→→"), "\t\t\t")

# ---------------------------------------------------------------------------

test "line 87", (t) => t.is(OL(undef), "undef")
test "line 88", (t) => t.is(OL("\t\tabc\nxyz"), "'→→abc®xyz'")
test "line 89", (t) => t.is(OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}')

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

test "line 97", (t) => t.is(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}')

# ---------------------------------------------------------------------------

test "line 101", (t) => t.is(OLS(['abc', 3]), "'abc',3")
test "line 102", (t) => t.is(OLS([]), "")
test "line 103", (t) => t.is(OLS([undef, {a:1}]), 'undef,{"a":1}')

# ---------------------------------------------------------------------------

test "line 99",  (t) => t.truthy(inList('a', 'b', 'a', 'c'))
test "line 108", (t) => t.falsy( inList('a', 'b', 'c'))

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

	test "line 128", (t) => t.falsy(isString(undef))
	test "line 129", (t) => t.falsy(isString(h))
	test "line 130", (t) => t.falsy(isString(l))
	test "line 131", (t) => t.falsy(isString(o))
	test "line 132", (t) => t.falsy(isString(n))
	test "line 133", (t) => t.falsy(isString(n2))

	test "line 135", (t) => t.truthy(isString(s))
	test "line 136", (t) => t.truthy(isString(s2))

	test "line 138", (t) => t.truthy(isNonEmptyString('abc'))
	test "line 139", (t) => t.truthy(isNonEmptyString('abc def'))
	test "line 140", (t) => t.falsy(isNonEmptyString(''))
	test "line 141", (t) => t.falsy(isNonEmptyString('  '))

	test "line 143", (t) => t.truthy(isIdentifier('abc'))
	test "line 144", (t) => t.truthy(isIdentifier('_Abc'))
	test "line 145", (t) => t.falsy(isIdentifier('abc def'))
	test "line 146", (t) => t.falsy(isIdentifier('abc-def'))
	test "line 147", (t) => t.falsy(isIdentifier('class.method'))

	test "line 149", (t) => t.truthy(isFunctionName('abc'))
	test "line 150", (t) => t.truthy(isFunctionName('_Abc'))
	test "line 151", (t) => t.falsy(isFunctionName('abc def'))
	test "line 152", (t) => t.falsy(isFunctionName('abc-def'))
	test "line 153", (t) => t.falsy(isFunctionName('D()'))
	test "line 154", (t) => t.truthy(isFunctionName('class.method'))

	test "line 156", (t) => t.falsy(isNumber(h))
	test "line 157", (t) => t.falsy(isNumber(l))
	test "line 158", (t) => t.falsy(isNumber(o))
	test "line 159", (t) => t.truthy(isNumber(n))
	test "line 160", (t) => t.truthy(isNumber(n2))
	test "line 161", (t) => t.falsy(isNumber(s))
	test "line 162", (t) => t.falsy(isNumber(s2))

	test "line 164", (t) => t.truthy(isNumber(42.0, {min: 42.0}))
	test "line 165", (t) => t.falsy(isNumber(42.0, {min: 42.1}))
	test "line 166", (t) => t.truthy(isNumber(42.0, {max: 42.0}))
	test "line 167", (t) => t.falsy(isNumber(42.0, {max: 41.9}))

	test "line 169", (t) => t.truthy(isInteger(42))
	test "line 170", (t) => t.truthy(isInteger(new Number(42)))
	test "line 171", (t) => t.falsy(isInteger('abc'))
	test "line 172", (t) => t.falsy(isInteger({}))
	test "line 173", (t) => t.falsy(isInteger([]))
	test "line 174", (t) => t.truthy(isInteger(42, {min:  0}))
	test "line 175", (t) => t.falsy(isInteger(42, {min: 50}))
	test "line 176", (t) => t.truthy(isInteger(42, {max: 50}))
	test "line 177", (t) => t.falsy(isInteger(42, {max:  0}))

	test "line 179", (t) => t.truthy(isHash(h))
	test "line 180", (t) => t.falsy(isHash(l))
	test "line 181", (t) => t.falsy(isHash(o))
	test "line 182", (t) => t.falsy(isHash(n))
	test "line 183", (t) => t.falsy(isHash(n2))
	test "line 184", (t) => t.falsy(isHash(s))
	test "line 185", (t) => t.falsy(isHash(s2))

	test "line 187", (t) => t.falsy(isArray(h))
	test "line 188", (t) => t.truthy(isArray(l))
	test "line 189", (t) => t.falsy(isArray(o))
	test "line 190", (t) => t.falsy(isArray(n))
	test "line 191", (t) => t.falsy(isArray(n2))
	test "line 192", (t) => t.falsy(isArray(s))
	test "line 193", (t) => t.falsy(isArray(s2))

	test "line 195", (t) => t.truthy(isBoolean(true))
	test "line 196", (t) => t.truthy(isBoolean(false))
	test "line 197", (t) => t.falsy(isBoolean(42))
	test "line 198", (t) => t.falsy(isBoolean("true"))

	test "line 200", (t) => t.truthy(isConstructor(NewClass))
	test "line 201", (t) => t.falsy(isConstructor(o))

	test "line 203", (t) => t.truthy(isFunction(() -> 42))
	test "line 204", (t) => t.truthy(isFunction(() => 42))
	test "line 205", (t) => t.falsy(isFunction(42))
	test "line 206", (t) => t.falsy(isFunction(n))

	test "line 208", (t) => t.truthy(isRegExp(/^abc$/))
	test "line 209", (t) => t.truthy(isRegExp(///^ \s* where \s+ areyou $///))
	test "line 210", (t) => t.falsy(isRegExp(42))
	test "line 211", (t) => t.falsy(isRegExp('abc'))
	test "line 212", (t) => t.falsy(isRegExp([1,'a']))
	test "line 213", (t) => t.falsy(isRegExp({a:1, b:'ccc'}))
	test "line 214", (t) => t.falsy(isRegExp(undef))
	test "line 215", (t) => t.truthy(isRegExp(/\.coffee/))

	test "line 217", (t) => t.falsy(isObject(h))
	test "line 218", (t) => t.falsy(isObject(l))
	test "line 219", (t) => t.truthy(isObject(o))
	test "line 220", (t) => t.truthy(isObject(o, ['name','doIt']))
	test "line 221", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 222", (t) => t.falsy(isObject(o, ['name','doIt','missing']))
	test "line 223", (t) => t.falsy(isObject(o, "name doIt missing"))
	test "line 224", (t) => t.falsy(isObject(n))
	test "line 225", (t) => t.falsy(isObject(n2))
	test "line 226", (t) => t.falsy(isObject(s))
	test "line 227", (t) => t.falsy(isObject(s2))
	test "line 228", (t) => t.truthy(isObject(o, "name doIt"))
	test "line 229", (t) => t.truthy(isObject(o, "name doIt meth"))
	test "line 230", (t) => t.truthy(isObject(o, "name &doIt &meth"))
	test "line 231", (t) => t.falsy(isObject(o, "&name"))

	test "line 233", (t) => t.deepEqual(jsType(undef), [undef, 'undef'])
	test "line 234", (t) => t.deepEqual(jsType(null),  [undef, 'null'])
	test "line 235", (t) => t.deepEqual(jsType(s), ['string', undef])
	test "line 236", (t) => t.deepEqual(jsType(''), ['string', 'empty'])
	test "line 237", (t) => t.deepEqual(jsType("\t\t"), ['string', 'empty'])
	test "line 238", (t) => t.deepEqual(jsType("  "), ['string', 'empty'])
	test "line 239", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 240", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 241", (t) => t.deepEqual(jsType(3.14159), ['number', undef])
	test "line 242", (t) => t.deepEqual(jsType(42), ['number', 'integer'])
	test "line 243", (t) => t.deepEqual(jsType(true), ['boolean', 'true'])
	test "line 244", (t) => t.deepEqual(jsType(false), ['boolean', 'false'])
	test "line 245", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 246", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 247", (t) => t.deepEqual(jsType(l), ['array', undef])
	test "line 248", (t) => t.deepEqual(jsType([]), ['array', 'empty'])
	test "line 249", (t) => t.deepEqual(jsType(/abc/), ['regexp', undef])
	func1 = (x) ->
		return
	func2 = (x) =>
		return

	# --- NOTE: regular functions can't be distinguished from constructors
	test "line 256", (t) => t.deepEqual(jsType(func1), ['function', 'constructor'])

	test "line 258", (t) => t.deepEqual(jsType(func2), ['function', undef])
	test "line 259", (t) => t.deepEqual(jsType(NewClass), ['function', 'constructor'])
	test "line 260", (t) => t.deepEqual(jsType(o), ['object', undef])
	)()

# ---------------------------------------------------------------------------

test "line 265", (t) => t.truthy(isEmpty(''))
test "line 266", (t) => t.truthy(isEmpty('  \t\t'))
test "line 267", (t) => t.truthy(isEmpty([]))
test "line 268", (t) => t.truthy(isEmpty({}))

test "line 270", (t) => t.truthy(nonEmpty('a'))
test "line 271", (t) => t.truthy(nonEmpty('.'))
test "line 272", (t) => t.truthy(nonEmpty([2]))
test "line 273", (t) => t.truthy(nonEmpty({width: 2}))

# ---------------------------------------------------------------------------

test "line 277", (t) => t.deepEqual(blockToArray("abc\nxyz\n"), [
	'abc'
	'xyz'
	])

test "line 282", (t) => t.deepEqual(blockToArray("abc\nxyz\n\n\n\n"), [
	'abc'
	'xyz'
	])

test "line 287", (t) => t.deepEqual(blockToArray("abc\n\nxyz\n"), [
	'abc'
	''
	'xyz'
	])

# ---------------------------------------------------------------------------

test "line 295", (t) => t.deepEqual(arrayToBlock(['a','b','c']), "a\nb\nc")
test "line 296", (t) => t.deepEqual(arrayToBlock(['a',undef,'b','c']), "a\nb\nc")
test "line 297", (t) => t.deepEqual(arrayToBlock([undef,'a','b','c',undef]), "a\nb\nc")

# ---------------------------------------------------------------------------

test "line 301", (t) => t.is(chomp('abc'), 'abc')
test "line 302", (t) => t.is(chomp('abc\n'), 'abc')
test "line 303", (t) => t.is(chomp('abc\r\n'), 'abc')

test "line 305", (t) => t.is(chomp('abc\ndef'), 'abc\ndef')
test "line 306", (t) => t.is(chomp('abc\ndef\n'), 'abc\ndef')
test "line 307", (t) => t.is(chomp('abc\ndef\r\n'), 'abc\ndef')

test "line 309", (t) => t.is(chomp('abc\r\ndef'), 'abc\r\ndef')
test "line 310", (t) => t.is(chomp('abc\r\ndef\n'), 'abc\r\ndef')
test "line 311", (t) => t.is(chomp('abc\r\ndef\r\n'), 'abc\r\ndef')

# ---------------------------------------------------------------------------

test "line 315", (t) => t.is(rtrim("abc"), "abc")
test "line 316", (t) => t.is(rtrim("  abc"), "  abc")
test "line 317", (t) => t.is(rtrim("abc  "), "abc")
test "line 318", (t) => t.is(rtrim("  abc  "), "  abc")

# ---------------------------------------------------------------------------

test "line 322", (t) => t.is(setCharsAt('abc', 1, 'x'), 'axc')
test "line 323", (t) => t.is(setCharsAt('abc', 1, 'xy'), 'axy')
test "line 324", (t) => t.is(setCharsAt('abc', 1, 'xyz'), 'axyz')

# ---------------------------------------------------------------------------

test "line 328", (t) => t.deepEqual(words(''), [])
test "line 329", (t) => t.deepEqual(words('  \t\t'), [])
test "line 330", (t) => t.deepEqual(words('a b c'), ['a', 'b', 'c'])
test "line 331", (t) => t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c'])
test "line 332", (t) => t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd'])
test "line 333", (t) => t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word'])

test "line 335", (t) => t.is firstWord("abc"), "abc"
test "line 336", (t) => t.is firstWord(" abc"), ""
test "line 337", (t) => t.is firstWord("abc def"), "abc"
test "line 338", (t) => t.is firstWord("! not this"), "!"

test "line 340", (t) => t.truthy hasChar('abc', 'b')
test "line 341", (t) => t.falsy  hasChar('abc', 'x')
test "line 342", (t) => t.falsy  hasChar("\t\t", ' ')

# ---------------------------------------------------------------------------

test "line 346", (t) => t.is(quoted('abc'), "'abc'")
test "line 347", (t) => t.is(quoted('"abc"'), "'\"abc\"'")
test "line 348", (t) => t.is(quoted("'abc'"), "\"'abc'\"")
test "line 349", (t) => t.is(quoted("'\"abc\"'"), "<'\"abc\"'>")
test "line 350", (t) => t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>")

# ---------------------------------------------------------------------------

test "line 354", (t) => t.deepEqual(getOptions(), {})
test "line 355", (t) => t.deepEqual(getOptions(undef, {x:1}), {x:1})
test "line 356", (t) => t.deepEqual(getOptions({x:1}, {x:3,y:4}), {x:1,y:4})
test "line 357", (t) => t.deepEqual(getOptions('asText'), {asText: true})
test "line 358", (t) => t.deepEqual(getOptions('!binary'), {binary: false})
test "line 359", (t) => t.deepEqual(getOptions('label=this'), {label: 'this'})
test "line 360", (t) => t.deepEqual(getOptions('asText !binary label=this'), {
	asText: true
	binary: false
	label: 'this'
	})
