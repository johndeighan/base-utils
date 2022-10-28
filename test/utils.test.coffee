# utils.test.coffee

import test from 'ava'

import {
	undef, pass, defined, notdefined, untabify,
	escapeStr, unescapeStr, OL,
	isString, isNumber, isInteger, isHash, isArray, isBoolean,
	isConstructor, isFunction, isRegExp, isObject, jsType,
	isEmpty, nonEmpty,
	blockToArray, arrayToBlock,

	chomp, rtrim, setCharsAt, words, hasChar, quoted, getOptions,
	} from '@jdeighan/exceptions/utils'

# ---------------------------------------------------------------------------

test "line 18", (t) => t.is(undef, undefined)

test "line 20", (t) => t.truthy(isFunction(pass))

(() ->
	passTest = () =>
		pass()
	test "line 25", (t) => t.notThrows(passTest, "pass fails")
	)()

test "line 28", (t) => t.truthy(defined(''))
test "line 29", (t) => t.truthy(defined(5))
test "line 30", (t) => t.truthy(defined([]))
test "line 31", (t) => t.truthy(defined({}))
test "line 32", (t) => t.falsy(defined(undef))
test "line 33", (t) => t.falsy(defined(null))

test "line 35", (t) => t.truthy(notdefined(undef))
test "line 36", (t) => t.truthy(notdefined(null))
test "line 37", (t) => t.falsy(notdefined(''))
test "line 38", (t) => t.falsy(notdefined(5))
test "line 39", (t) => t.falsy(notdefined([]))
test "line 40", (t) => t.falsy(notdefined({}))

(() ->
	prefix = '   '    # 3 spaces

	test "line 45", (t) => t.is(untabify("""
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

test "line 58", (t) => t.is(escapeStr("\t\tXXX\n"), "→→XXX®")

hEsc = {
	"\n": "\\n"
	"\t": "\\t"
	"\"": "\\\""
	}

test "line 66", (t) => t.is(escapeStr("\thas quote: \"\nnext line", hEsc),
	"\\thas quote: \\\"\\nnext line")

test "line 69", (t) => t.is(unescapeStr("˳˳˳"), "   ")
test "line 70", (t) => t.is(unescapeStr("®®®"), "\n\n\n")
test "line 71", (t) => t.is(unescapeStr("→→→"), "\t\t\t")

# ---------------------------------------------------------------------------

test "line 75", (t) => t.is(OL(undef), "undef")
test "line 76", (t) => t.is(OL("\t\tabc\nxyz"), "'→→abc®xyz'")
test "line 77", (t) => t.is(OL({a:1, b:'xyz'}), '{"a":1,"b":"xyz"}')

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

test "line 85", (t) => t.is(OL(hProc), '{"code":"[Function: code]","html":"[Function: html]","Script":"[Function: Script]"}')

# ---------------------------------------------------------------------------
#        jsTypes:

(() ->
	class NewClass
		constructor: (@name = 'bob') ->
			@doIt = pass

	h = {a:1, b:2}
	l = [1,2,2]
	o = new NewClass()
	n = 42
	n2 = new Number(42)
	s = 'simple'
	s2 = new String('abc')

	test "line 103", (t) => t.falsy(isString(undef))
	test "line 104", (t) => t.falsy(isString(h))
	test "line 105", (t) => t.falsy(isString(l))
	test "line 106", (t) => t.falsy(isString(o))
	test "line 107", (t) => t.falsy(isString(n))
	test "line 108", (t) => t.falsy(isString(n2))

	test "line 110", (t) => t.truthy(isString(s))
	test "line 111", (t) => t.truthy(isString(s2))

	test "line 113", (t) => t.falsy(isNumber(h))
	test "line 114", (t) => t.falsy(isNumber(l))
	test "line 115", (t) => t.falsy(isNumber(o))
	test "line 116", (t) => t.truthy(isNumber(n))
	test "line 117", (t) => t.truthy(isNumber(n2))
	test "line 118", (t) => t.falsy(isNumber(s))
	test "line 119", (t) => t.falsy(isNumber(s2))

	test "line 121", (t) => t.truthy(isNumber(42.0, {min: 42.0}))
	test "line 122", (t) => t.falsy(isNumber(42.0, {min: 42.1}))
	test "line 123", (t) => t.truthy(isNumber(42.0, {max: 42.0}))
	test "line 124", (t) => t.falsy(isNumber(42.0, {max: 41.9}))

	test "line 126", (t) => t.truthy(isInteger(42))
	test "line 127", (t) => t.truthy(isInteger(new Number(42)))
	test "line 128", (t) => t.falsy(isInteger('abc'))
	test "line 129", (t) => t.falsy(isInteger({}))
	test "line 130", (t) => t.falsy(isInteger([]))
	test "line 131", (t) => t.truthy(isInteger(42, {min:  0}))
	test "line 132", (t) => t.falsy(isInteger(42, {min: 50}))
	test "line 133", (t) => t.truthy(isInteger(42, {max: 50}))
	test "line 134", (t) => t.falsy(isInteger(42, {max:  0}))

	test "line 136", (t) => t.truthy(isHash(h))
	test "line 137", (t) => t.falsy(isHash(l))
	test "line 138", (t) => t.falsy(isHash(o))
	test "line 139", (t) => t.falsy(isHash(n))
	test "line 140", (t) => t.falsy(isHash(n2))
	test "line 141", (t) => t.falsy(isHash(s))
	test "line 142", (t) => t.falsy(isHash(s2))

	test "line 144", (t) => t.falsy(isArray(h))
	test "line 145", (t) => t.truthy(isArray(l))
	test "line 146", (t) => t.falsy(isArray(o))
	test "line 147", (t) => t.falsy(isArray(n))
	test "line 148", (t) => t.falsy(isArray(n2))
	test "line 149", (t) => t.falsy(isArray(s))
	test "line 150", (t) => t.falsy(isArray(s2))

	test "line 152", (t) => t.truthy(isBoolean(true))
	test "line 153", (t) => t.truthy(isBoolean(false))
	test "line 154", (t) => t.falsy(isBoolean(42))
	test "line 155", (t) => t.falsy(isBoolean("true"))

	test "line 157", (t) => t.truthy(isConstructor(NewClass))
	test "line 158", (t) => t.falsy(isConstructor(o))

	test "line 160", (t) => t.truthy(isFunction(() -> 42))
	test "line 161", (t) => t.truthy(isFunction(() => 42))
	test "line 162", (t) => t.falsy(isFunction(42))
	test "line 163", (t) => t.falsy(isFunction(n))

	test "line 165", (t) => t.truthy(isRegExp(/^abc$/))
	test "line 166", (t) => t.truthy(isRegExp(///^ \s* where \s+ areyou $///))
	test "line 167", (t) => t.falsy(isRegExp(42))
	test "line 168", (t) => t.falsy(isRegExp('abc'))
	test "line 169", (t) => t.falsy(isRegExp([1,'a']))
	test "line 170", (t) => t.falsy(isRegExp({a:1, b:'ccc'}))
	test "line 171", (t) => t.falsy(isRegExp(undef))
	test "line 172", (t) => t.truthy(isRegExp(/\.coffee/))

	test "line 174", (t) => t.falsy(isObject(h))
	test "line 175", (t) => t.falsy(isObject(l))
	test "line 176", (t) => t.truthy(isObject(o))
	test "line 177", (t) => t.truthy(isObject(o, ['name','doIt']))
	test "line 178", (t) => t.falsy(isObject(o, ['name','doIt','missing']))
	test "line 179", (t) => t.falsy(isObject(n))
	test "line 180", (t) => t.falsy(isObject(n2))
	test "line 181", (t) => t.falsy(isObject(s))
	test "line 182", (t) => t.falsy(isObject(s2))

	test "line 184", (t) => t.deepEqual(jsType(undef), [undef, 'undef'])
	test "line 185", (t) => t.deepEqual(jsType(null),  [undef, 'null'])
	test "line 186", (t) => t.deepEqual(jsType(s), ['string', undef])
	test "line 187", (t) => t.deepEqual(jsType(''), ['string', 'empty'])
	test "line 188", (t) => t.deepEqual(jsType("\t\t"), ['string', 'empty'])
	test "line 189", (t) => t.deepEqual(jsType("  "), ['string', 'empty'])
	test "line 190", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 191", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 192", (t) => t.deepEqual(jsType(3.14159), ['number', undef])
	test "line 193", (t) => t.deepEqual(jsType(42), ['number', 'integer'])
	test "line 194", (t) => t.deepEqual(jsType(true), ['boolean', 'true'])
	test "line 195", (t) => t.deepEqual(jsType(false), ['boolean', 'false'])
	test "line 196", (t) => t.deepEqual(jsType(h), ['hash', undef])
	test "line 197", (t) => t.deepEqual(jsType({}), ['hash', 'empty'])
	test "line 198", (t) => t.deepEqual(jsType(l), ['array', undef])
	test "line 199", (t) => t.deepEqual(jsType([]), ['array', 'empty'])
	test "line 200", (t) => t.deepEqual(jsType(/abc/), ['regexp', undef])
	func1 = (x) ->
		return
	func2 = (x) =>
		return

	# --- NOTE: regular functions can't be distinguished from constructors
	test "line 207", (t) => t.deepEqual(jsType(func1), ['function', 'constructor'])

	test "line 209", (t) => t.deepEqual(jsType(func2), ['function', undef])
	test "line 210", (t) => t.deepEqual(jsType(NewClass), ['function', 'constructor'])
	test "line 211", (t) => t.deepEqual(jsType(o), ['object', undef])
	)()

# ---------------------------------------------------------------------------

test "line 216", (t) => t.truthy(isEmpty(''))
test "line 217", (t) => t.truthy(isEmpty('  \t\t'))
test "line 218", (t) => t.truthy(isEmpty([]))
test "line 219", (t) => t.truthy(isEmpty({}))

test "line 221", (t) => t.truthy(nonEmpty('a'))
test "line 222", (t) => t.truthy(nonEmpty('.'))
test "line 223", (t) => t.truthy(nonEmpty([2]))
test "line 224", (t) => t.truthy(nonEmpty({width: 2}))

# ---------------------------------------------------------------------------

test "line 228", (t) => t.deepEqual(blockToArray("abc\nxyz\n"), [
	'abc'
	'xyz'
	])

test "line 233", (t) => t.deepEqual(blockToArray("abc\nxyz\n\n\n\n"), [
	'abc'
	'xyz'
	])

test "line 238", (t) => t.deepEqual(blockToArray("abc\n\nxyz\n"), [
	'abc'
	''
	'xyz'
	])

# ---------------------------------------------------------------------------

test "line 246", (t) => t.deepEqual(arrayToBlock(['a','b','c']), "a\nb\nc")
test "line 247", (t) => t.deepEqual(arrayToBlock(['a',undef,'b','c']), "a\nb\nc")
test "line 248", (t) => t.deepEqual(arrayToBlock([undef,'a','b','c',undef]), "a\nb\nc")

# ---------------------------------------------------------------------------

test "line 252", (t) => t.is(chomp('abc'), 'abc')
test "line 253", (t) => t.is(chomp('abc\n'), 'abc')
test "line 254", (t) => t.is(chomp('abc\r\n'), 'abc')

test "line 256", (t) => t.is(chomp('abc\ndef'), 'abc\ndef')
test "line 257", (t) => t.is(chomp('abc\ndef\n'), 'abc\ndef')
test "line 258", (t) => t.is(chomp('abc\ndef\r\n'), 'abc\ndef')

test "line 260", (t) => t.is(chomp('abc\r\ndef'), 'abc\r\ndef')
test "line 261", (t) => t.is(chomp('abc\r\ndef\n'), 'abc\r\ndef')
test "line 262", (t) => t.is(chomp('abc\r\ndef\r\n'), 'abc\r\ndef')

# ---------------------------------------------------------------------------

test "line 266", (t) => t.is(rtrim("abc"), "abc")
test "line 267", (t) => t.is(rtrim("  abc"), "  abc")
test "line 268", (t) => t.is(rtrim("abc  "), "abc")
test "line 269", (t) => t.is(rtrim("  abc  "), "  abc")

# ---------------------------------------------------------------------------

test "line 273", (t) => t.is(setCharsAt('abc', 1, 'x'), 'axc')
test "line 274", (t) => t.is(setCharsAt('abc', 1, 'xy'), 'axy')
test "line 275", (t) => t.is(setCharsAt('abc', 1, 'xyz'), 'axyz')

# ---------------------------------------------------------------------------

test "line 279", (t) => t.deepEqual(words(''), [])
test "line 280", (t) => t.deepEqual(words('  \t\t'), [])
test "line 281", (t) => t.deepEqual(words('a b c'), ['a', 'b', 'c'])
test "line 282", (t) => t.deepEqual(words('  a   b   c  '), ['a', 'b', 'c'])
test "line 283", (t) => t.deepEqual(words('a b', 'c d'), ['a', 'b', 'c', 'd'])
test "line 284", (t) => t.deepEqual(words(' my word ', ' is  word  '), ['my', 'word', 'is', 'word'])

test "line 286", (t) => t.truthy hasChar('abc', 'b')
test "line 287", (t) => t.falsy  hasChar('abc', 'x')
test "line 288", (t) => t.falsy  hasChar("\t\t", ' ')

# ---------------------------------------------------------------------------

test "line 292", (t) => t.is(quoted('abc'), "'abc'")
test "line 293", (t) => t.is(quoted('"abc"'), "'\"abc\"'")
test "line 294", (t) => t.is(quoted("'abc'"), "\"'abc'\"")
test "line 295", (t) => t.is(quoted("'\"abc\"'"), "<'\"abc\"'>")
test "line 296", (t) => t.is(quoted("'\"<abc>\"'"), "<'\"<abc>\"'>")

# ---------------------------------------------------------------------------

test "line 300", (t) => t.deepEqual(getOptions(), {})
test "line 301", (t) => t.deepEqual(getOptions(undef, {x:1}), {x:1})
test "line 302", (t) => t.deepEqual(getOptions({x:1}, {x:3,y:4}), {x:1,y:4})
test "line 303", (t) => t.deepEqual(getOptions('asText'), {asText: true})
test "line 304", (t) => t.deepEqual(getOptions('!binary'), {binary: false})
test "line 305", (t) => t.deepEqual(getOptions('label=this'), {label: 'this'})
test "line 306", (t) => t.deepEqual(getOptions('asText !binary label=this'), {
	asText: true
	binary: false
	label: 'this'
	})
