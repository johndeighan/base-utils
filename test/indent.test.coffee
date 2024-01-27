# indent.test.coffee

import {undef, isInteger} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'
import {
	indentLevel, isUndented, indentation, undented, splitLine,
	indented, enclose, getOneIndent,
	} from '@jdeighan/base-utils/indent'
import {utest} from '@jdeighan/base-utils/utest'

# ---------------------------------------------------------------------------

utest.equal getOneIndent("abc"), undef
utest.equal getOneIndent(""), undef
utest.equal getOneIndent("\tabc"), "\t"
utest.equal getOneIndent("\t\tabc"), "\t"
utest.equal getOneIndent(" abc"), " "
utest.equal getOneIndent("   abc"), "   "
utest.throws () -> getOneIndent(" \tabc")
utest.throws () -> getOneIndent("\t abc")

# ---------------------------------------------------------------------------

utest.equal indentLevel("abc"), 0
utest.equal indentLevel("\tabc"), 1
utest.equal indentLevel("\t\tabc"), 2

# ---------------------------------------------------------------------------

utest.truthy isUndented("abc")
utest.falsy  isUndented("\tabc")
utest.falsy  isUndented("\t\tabc")

# ---------------------------------------------------------------------------

utest.equal indentation(0), ''
utest.equal indentation(1), "\t"
utest.equal indentation(2), "\t\t"

# ---------------------------------------------------------------------------

utest.equal undented("abc"), "abc"
utest.equal undented("\tabc"), "abc"
utest.equal undented("\t\tabc"), "abc"

utest.equal undented([]), []
utest.equal undented(['abc']), ['abc']
utest.equal undented(['\tabc']), ['abc']
utest.equal undented(['\t\tabc']), ['abc']

utest.equal undented('\n\n\t\tabc\n\t\t\t\tdef'), """
	abc
			def
	"""

# ---------------------------------------------------------------------------
# --- test with spaces

utest.equal undented("abc"), "abc"
utest.equal undented("   abc"), "abc"
utest.equal undented("      abc"), "abc"

utest.equal undented([]), []
utest.equal undented(['abc']), ['abc']
utest.equal undented(['   abc']), ['abc']
utest.equal undented(['      abc']), ['abc']

# ---------------------------------------------------------------------------
# --- test with multiple lines

utest.equal undented([
	'abc'
	'\txyz'
	'mmm'
	]), [
	'abc'
	'\txyz'
	'mmm'
	]

utest.equal undented([
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
	utest.equal undented(block), expected
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
	utest.equal undented(array), expected
	)()

# ---------------------------------------------------------------------------

utest.equal splitLine("abc"), [0, "abc"]
utest.equal splitLine("\tabc"), [1, "abc"]
utest.equal splitLine("\t\tabc"), [2, "abc"]
utest.equal splitLine(""),       [0, ""]
utest.equal splitLine("\t\t\t"), [0, ""]
utest.equal splitLine("\t \t"),  [0, ""]
utest.equal splitLine("   "),    [0, ""]

# ---------------------------------------------------------------------------

utest.equal indented("abc", 0), "abc"
utest.equal indented("abc", 1), "\tabc"
utest.equal indented("abc", 2), "\t\tabc"
utest.equal indented("abc", 0, '  '), "abc"
utest.equal indented("abc", 1, '  '), "  abc"
utest.equal indented("abc", 2, '  '), "    abc"

# --- empty lines, indented, should just be empty lines
utest.equal indented("abc\n\ndef", 2), "\t\tabc\n\n\t\tdef"

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
	utest.equal indented(block, 1), exp
	)()

# --- indented also handles arrays, so test them, too

# --- empty lines, indented, should just be empty lines
utest.equal indented(['abc','','def'], 2),
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
	utest.equal indented(lLines, 1), lExp
	)()

# --- make sure ALL internal lines are indented

utest.equal indented(['abc\ndef','','ghi'], 1),
		['\tabc', '\tdef', '', '\tghi']

# ---------------------------------------------------------------------------

utest.equal indented("export name = undef", 1), "\texport name = undef"
utest.equal indented("export name = undef", 2), "\t\texport name = undef"

# ---------------------------------------------------------------------------
# make sure indentLevel() works for blocks

utest.equal indentLevel("\t\tabc\n\t\tdef\n\t\t\tghi"), 2

# ---------------------------------------------------------------------------

(() ->
	block = """
		x = 42
		callme(x)
		"""

	utest.equal enclose(block, '<script>', '</script>'), """
		<script>
			x = 42
			callme(x)
		</script>
		"""

	utest.equal enclose(block, 'pre', 'post', '...'), """
		pre
		...x = 42
		...callme(x)
		post
		"""

	)()
