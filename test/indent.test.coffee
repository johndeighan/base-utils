# indent.test.coffee

import {undef, isInteger} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'
import {utest} from '@jdeighan/base-utils/utest'
import {
	indentLevel, isUndented, indentation, undented, splitLine,
	indented, enclose, getOneIndent,
	} from '@jdeighan/base-utils/indent'

# ---------------------------------------------------------------------------

utest.equal 13, getOneIndent("abc"), undef
utest.equal 14, getOneIndent(""), undef
utest.equal 15, getOneIndent("\tabc"), "\t"
utest.equal 16, getOneIndent("\t\tabc"), "\t"
utest.equal 17, getOneIndent(" abc"), " "
utest.equal 18, getOneIndent("   abc"), "   "
utest.fails 19, () -> getOneIndent(" \tabc")
utest.fails 20, () -> getOneIndent("\t abc")

# ---------------------------------------------------------------------------

utest.equal 24, indentLevel("abc"), 0
utest.equal 25, indentLevel("\tabc"), 1
utest.equal 26, indentLevel("\t\tabc"), 2

# ---------------------------------------------------------------------------

utest.truthy 30, isUndented("abc")
utest.falsy  31, isUndented("\tabc")
utest.falsy  32, isUndented("\t\tabc")

# ---------------------------------------------------------------------------

utest.equal 36, indentation(0), ''
utest.equal 37, indentation(1), "\t"
utest.equal 38, indentation(2), "\t\t"

# ---------------------------------------------------------------------------

utest.equal 42, undented("abc"), "abc"
utest.equal 43, undented("\tabc"), "abc"
utest.equal 44, undented("\t\tabc"), "abc"

utest.equal 46, undented([]), []
utest.equal 47, undented(['abc']), ['abc']
utest.equal 48, undented(['\tabc']), ['abc']
utest.equal 49, undented(['\t\tabc']), ['abc']

utest.equal 51, undented('\n\n\t\tabc\n\t\t\t\tdef'), """
	abc
			def
	"""

# ---------------------------------------------------------------------------
# --- test with spaces

utest.equal 59, undented("abc"), "abc"
utest.equal 60, undented("   abc"), "abc"
utest.equal 61, undented("      abc"), "abc"

utest.equal 63, undented([]), []
utest.equal 64, undented(['abc']), ['abc']
utest.equal 65, undented(['   abc']), ['abc']
utest.equal 66, undented(['      abc']), ['abc']

# ---------------------------------------------------------------------------
# --- test with multiple lines

utest.equal 71, undented([
	'abc'
	'\txyz'
	'mmm'
	]), [
	'abc'
	'\txyz'
	'mmm'
	]

utest.equal 81, undented([
	'\t\tabc'
	'\t\t\txyz'
	'\t\tmmm'
	]), [
	'abc'
	'\txyz'
	'mmm'
	]

# ---------------------------------------------------------------------------

(() ->
	block = "\t\tfirst\n\t\tsecond\n\t\t\tthird\n"
	expected = "first\nsecond\n\tthird\n"
	utest.equal 96, undented(block), expected
	)()

# ---------------------------------------------------------------------------

(() ->
	array = [
		"\t\tfirst",
		"\t\tsecond",
		"\t\t\tthird"
		]
	expected = [
		"first",
		"second",
		"\tthird"
		]
	utest.equal 112, undented(array), expected
	)()

# ---------------------------------------------------------------------------

utest.equal 117, splitLine("abc"), [0, "abc"]
utest.equal 118, splitLine("\tabc"), [1, "abc"]
utest.equal 119, splitLine("\t\tabc"), [2, "abc"]
utest.equal 120, splitLine(""),       [0, ""]
utest.equal 121, splitLine("\t\t\t"), [0, ""]
utest.equal 122, splitLine("\t \t"),  [0, ""]
utest.equal 123, splitLine("   "),    [0, ""]

# ---------------------------------------------------------------------------

utest.equal 127, indented("abc", 0), "abc"
utest.equal 128, indented("abc", 1), "\tabc"
utest.equal 129, indented("abc", 2), "\t\tabc"
utest.equal 130, indented("abc", 0, '  '), "abc"
utest.equal 131, indented("abc", 1, '  '), "  abc"
utest.equal 132, indented("abc", 2, '  '), "    abc"

# --- empty lines, indented, should just be empty lines
utest.equal 135, indented("abc\n\ndef", 2), "\t\tabc\n\n\t\tdef"

(() ->
	# --- test indenting multi-line strings

	block = """
		main
		\toverflow: auto

		nav
		\toverflow: auto
		"""
	exp = """
		\tmain
		\t\toverflow: auto

		\tnav
		\t\toverflow: auto
		"""
	utest.equal 154, indented(block, 1), exp
	)()

# --- indented also handles arrays, so test them, too

# --- empty lines, indented, should just be empty lines
utest.equal 160, indented(['abc','','def'], 2),
		['\t\tabc','','\t\tdef']

(() ->
	lLines = [
		'main'
		'\toverflow: auto'
		''
		'nav'
		'\toverflow: auto'
		]
	lExp   = [
		'\tmain'
		'\t\toverflow: auto'
		''
		'\tnav'
		'\t\toverflow: auto'
		]
	utest.equal 178, indented(lLines, 1), lExp
	)()

# --- make sure ALL internal lines are indented

utest.equal 183, indented(['abc\ndef','','ghi'], 1),
		['\tabc', '\tdef', '', '\tghi']

# ---------------------------------------------------------------------------

utest.equal 188, indented("export name = undef", 1), "\texport name = undef"
utest.equal 189, indented("export name = undef", 2), "\t\texport name = undef"

# ---------------------------------------------------------------------------
# make sure indentLevel() works for blocks

utest.equal 194, indentLevel("\t\tabc\n\t\tdef\n\t\t\tghi"), 2

# ---------------------------------------------------------------------------

(() ->
	block = """
		x = 42
		callme(x)
		"""

	utest.equal 204, enclose(block, '<script>', '</script>'), """
		<script>
			x = 42
			callme(x)
		</script>
		"""

	utest.equal 211, enclose(block, 'pre', 'post', '...'), """
		pre
		...x = 42
		...callme(x)
		post
		"""

	)()
