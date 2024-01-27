# taml.test.coffee

import {
	undef, defined, notdefined, pass, escapeStr, OL, spaces,
	} from '@jdeighan/base-utils'
import {
	isTAML, toTAML, fromTAML,
	llSplit, splitTaml, tamlFix, fixValStr,
	} from '@jdeighan/base-utils/taml'
import {utest} from '@jdeighan/base-utils/utest'

# ---------------------------------------------------------------------------

utest.equal llSplit("a: 53"), ["a: ","53"]
utest.equal llSplit("a: 53"), ["a: ","53"]
utest.equal llSplit("a  :   53"), ["a: ","53"]

utest.equal llSplit("- abc"), ["- ","abc"]
utest.equal llSplit("-   abc"), ["- ","abc"]

utest.equal llSplit("abc"), undef
utest.equal llSplit("24"), undef
utest.equal llSplit("'abc'"), undef

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

utest.equal fixValStr(''), ''
utest.equal fixValStr('[]'), '[]'
utest.equal fixValStr('{}'), '{}'
utest.equal fixValStr('42'), '42'
utest.equal fixValStr('"abc"'), '"abc"'
utest.equal fixValStr("'abc'"), "'abc'"
utest.equal fixValStr('true'), 'true'
utest.equal fixValStr('false'), 'false'

# --- quote everything else

utest.equal fixValStr("abc"), "'abc'"
utest.equal fixValStr("it's"), "'it''s'"

# ---------------------------------------------------------------------------

utest.equal splitTaml('a: - abc'), ['a: ','- ',"'abc'"]
utest.equal splitTaml('-  a:   53'), ['- ','a: ','53']
utest.equal splitTaml('"abc"'), ['"abc"']
utest.equal splitTaml('abc'), ["'abc'"]

# ---------------------------------------------------------------------------

utest.equal toTAML([]),         '---\n[]'
utest.equal toTAML({}),         '---\n{}'
utest.equal toTAML([1,2]),      '---\n- 1\n- 2'

utest.equal toTAML(['1','2']), """
	---
	- "1"
	- "2"
	"""

utest.equal toTAML({a:1,b:2}), """
	---
	a: 1
	b: 2
	"""

utest.equal toTAML({a:1,b:2}, '!useDashes'), """
	a: 1
	b: 2
	"""

utest.equal toTAML({a:1,b:2}, 'indent=3'), """
	\t\t\t---
	\t\t\ta: 1
	\t\t\tb: 2
	"""

utest.equal toTAML({a:1,b:2}, 'indent=3 !useTabs'), """
	#{spaces(6)}---
	#{spaces(6)}a: 1
	#{spaces(6)}b: 2
	"""

h = {
	h: [
		{a: 1}
		{b: 2}
		]
	}
utest.equal toTAML(h), '---\nh:\n\t- a: 1\n\t- b: 2'

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

	utest.equal fromTAML(str), [
		{ index: 0, state: 'learning'}
		{ index: 1, state: 'learning'}
		{ index: 2, state: 'learning'}
		]
	)()

# ---------------------------------------------------------------------------

(() =>
	str = """
	---
	-
		label: Help
		url: /help
	-
		label: Books
		url: /books
	"""

	utest.equal fromTAML(str), [
		{ label: 'Help', url: '/help'}
		{ label: 'Books', url: '/books'}
		]
	)()

# ---------------------------------------------------------------------------

(() =>
	str = """
	---
	-
		label: Help
		url: /help
	-
		label: Books
		url: /books
	"""

	utest.equal fromTAML(str), [
		{ label: 'Help', url: '/help'}
		{ label: 'Books', url: '/books'}
		]
	)()

# ---------------------------------------------------------------------------

(() =>
	str = """
		---
		File:
			lWalkTrees:
				- program
		WhileStatement:
			lWalkTrees:
				- test
				- body
		"""

	utest.equal fromTAML(str), {
		File: {
			lWalkTrees: ['program']
			}
		WhileStatement: {
			lWalkTrees: ['test','body']
			}
		}
	)()

# ---------------------------------------------------------------------------

(() =>
	str = """
		---
		type: function
		funcName: main
		source: C:/Users/johnd/base-utils/test/v8-stack.test.js
		"""

	utest.equal fromTAML(str), {
		type: 'function'
		funcName: 'main'
		source: 'C:/Users/johnd/base-utils/test/v8-stack.test.js'
		}
	)()
