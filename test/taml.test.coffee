# taml.test.coffee

import test from 'ava'

import {
	undef, defined, notdefined, pass, escapeStr, OL,
	} from '@jdeighan/base-utils'
import {
	isTAML, toTAML, fromTAML,
	} from '@jdeighan/base-utils/taml'

# ---------------------------------------------------------------------------

test "line 14", (t) => t.is toTAML([]),            '---\n[]'
test "line 15", (t) => t.is toTAML({}),            '---\n{}'
test "line 16", (t) => t.is toTAML([1,2]),         '---\n- 1\n- 2'
test "line 17", (t) => t.is toTAML(['1','2']),     '---\n- "1"\n- "2"'
test "line 18", (t) => t.is toTAML({a:1,b:2}),     '---\na: 1\nb: 2'

h = {
	h: [
		{a: 1}
		{b: 2}
		]
	}
test "line 19", (t) => t.is toTAML(h), '---\nh:\n\t- a: 1\n\t- b: 2'

str = """
---
- index: 0
	state: learning
- index: 1
	state: learning
- index: 2
	state: learning
"""
test "line 37", (t) => t.deepEqual fromTAML(str), [
	{ index: 0, state: 'learning'}
	{ index: 1, state: 'learning'}
	{ index: 2, state: 'learning'}
	]
