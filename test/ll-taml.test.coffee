# ll-taml.test.coffee

import test from 'ava'

import {
	undef, defined, notdefined, pass, escapeStr, OL,
	} from '@jdeighan/base-utils'
import {
	isTAML, toTAML, fromTAML,
	llSplit, splitTaml, tamlFix, fixValStr,
	} from '@jdeighan/base-utils/ll-taml'

# ---------------------------------------------------------------------------

test "line 15", (t) => t.deepEqual llSplit("a: 53"), ["a: ","53"]
test "line 16", (t) => t.deepEqual llSplit("a: 53"), ["a: ","53"]
test "line 17", (t) => t.deepEqual llSplit("a  :   53"), ["a: ","53"]

test "line 19", (t) => t.deepEqual llSplit("- abc"), ["- ","abc"]
test "line 20", (t) => t.deepEqual llSplit("-   abc"), ["- ","abc"]

test "line 22", (t) => t.is llSplit("abc"), undef
test "line 23", (t) => t.is llSplit("24"), undef
test "line 24", (t) => t.is llSplit("'abc'"), undef

# ---------------------------------------------------------------------------
# Leave these alone:
#    empty string
#    []
#    {}
#    number
#    "<str>"
#    '<str>'
#    true
#    false

test "line 37", (t) => t.is fixValStr(''), ''
test "line 38", (t) => t.is fixValStr('[]'), '[]'
test "line 39", (t) => t.is fixValStr('{}'), '{}'
test "line 40", (t) => t.is fixValStr('42'), '42'
test "line 41", (t) => t.is fixValStr('"abc"'), '"abc"'
test "line 42", (t) => t.is fixValStr("'abc'"), "'abc'"
test "line 43", (t) => t.is fixValStr('true'), 'true'
test "line 44", (t) => t.is fixValStr('false'), 'false'

# --- quote everything else

test "line 48", (t) => t.is fixValStr("abc"), "'abc'"
test "line 49", (t) => t.is fixValStr("it's"), "'it''s'"

# ---------------------------------------------------------------------------

test "line 53", (t) => t.deepEqual splitTaml('a: - abc'), ['a: ','- ',"'abc'"]
test "line 54", (t) => t.deepEqual splitTaml('-  a:   53'), ['- ','a: ','53']
test "line 55", (t) => t.deepEqual splitTaml('"abc"'), ['"abc"']
test "line 56", (t) => t.deepEqual splitTaml('abc'), ["'abc'"]

# ---------------------------------------------------------------------------

test "line 60", (t) => t.is toTAML([]),            '---\n[]'
test "line 61", (t) => t.is toTAML({}),            '---\n{}'
test "line 62", (t) => t.is toTAML([1,2]),         '---\n- 1\n- 2'
test "line 63", (t) => t.is toTAML(['1','2']),     '---\n- "1"\n- "2"'
test "line 64", (t) => t.is toTAML({a:1,b:2}),     '---\na: 1\nb: 2'

h = {
	h: [
		{a: 1}
		{b: 2}
		]
	}
test "line 72", (t) => t.is toTAML(h), '---\nh:\n\t- a: 1\n\t- b: 2'

# ---------------------------------------------------------------------------

(() =>
	str = """
	---
	- index: 0
		state: learning
	- index: 1
		state: learning
	- index: 2
		state: learning
	"""

	test "line 87", (t) => t.deepEqual fromTAML(str), [
		{ index: 0, state: 'learning'}
		{ index: 1, state: 'learning'}
		{ index: 2, state: 'learning'}
		]
	)()

# ---------------------------------------------------------------------------

(() =>
	str = """
		---
		- en: sad
			index: 5
			type: adjective
			zh: []
		"""

	test "line 105", (t) => t.deepEqual fromTAML(str), [
		{ en: 'sad', index: 5, type: 'adjective', zh: []}
		]
	)()

# ---------------------------------------------------------------------------

(() =>
	str = """
		---
		type: function
		funcName: main
		source: C:/Users/johnd/base-utils/test/v8-stack.test.js
		"""

	test "line 120", (t) => t.deepEqual fromTAML(str), {
		type: 'function'
		funcName: 'main'
		source: 'C:/Users/johnd/base-utils/test/v8-stack.test.js'
		}
	)()
