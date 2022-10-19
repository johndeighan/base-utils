# taml.test.coffee

import test from 'ava'

import {assert, croak} from '@jdeighan/exceptions'
import {undef, untabify} from '@jdeighan/exceptions/utils'
import {LOG} from '@jdeighan/exceptions/log'
import {isTAML, toTAML, fromTAML} from '@jdeighan/exceptions/taml'

# ---------------------------------------------------------------------------

test "line 12", (t) =>
	t.truthy isTAML("---\n- first\n- second")

test "line 15", (t) =>
	t.falsy isTAML("x---\n5")

test "line 18", (t) =>
	t.falsy isTAML("---x\n5")

test "line 21", (t) =>
	t.is toTAML({a:1}), "---\na: 1"

test "line 24", (t) =>
	t.is toTAML({a:1, b:2}), "---\na: 1\nb: 2"

test "line 27", (t) =>
	t.is toTAML([1,'abc',{a:1}]), "---\n- 1\n- abc\n-\n   a: 1"


test "line 31", (t) =>
	t.is toTAML({a:1, b:2}), """
		---
		a: 1
		b: 2
		"""

test "line 38", (t) =>
	t.is toTAML(['a','b']), """
		---
		- a
		- b
		"""

test "line 45", (t) =>
	t.is toTAML(['a','b', {a:1}, ['x']]), untabify("""
		---
		- a
		- b
		-
			a: 1
		-
			- x
		""")

test "line 56", (t) =>
	t.deepEqual fromTAML("---\n- a\n- b"), ['a','b']

test "line 59", (t) =>
	t.deepEqual fromTAML("""
		---
		title:
		\ten: Hello, she said.
		"""),
	{
		title: {
			en: 'Hello, she said.'
			}
		}

test "line 71", (t) =>
	t.deepEqual fromTAML("""
		---
		a: 1
		b: 2
		"""),
	{
		a: 1
		b: 2
		}


test "line 83", (t) =>
	t.is(toTAML(undef), "---\nundef")

test "line 86", (t) =>
	t.is(toTAML(null), "---\nnull")

test "line 89", (t) =>
	t.is(toTAML({a:1}), "---\na: 1")

test "line 92", (t) =>
	t.is(toTAML({a:1, b:2}), "---\na: 1\nb: 2")

test "line 95", (t) =>
	t.is(toTAML([1,'abc',{a:1}]), "---\n- 1\n- abc\n-\n   a: 1")

test "line 98", (t) =>
	t.is(toTAML({a:1, b:2}), """
		---
		a: 1
		b: 2
		""")

test "line 105", (t) =>
	t.is(toTAML(['a','b']), """
		---
		- a
		- b
		""")

test "line 112", (t) =>
	t.is(toTAML(['a','b', {a:1}, ['x']]), untabify("""
		---
		- a
		- b
		-
			a: 1
		-
			- x
		"""))

test "line 123", (t) =>
	t.is toTAML(['xyz', 42, false, 'false', undef]), """
		---
		- xyz
		- 42
		- false
		- 'false'
		- undef
		"""

# ---------------------------------------------------------------------------
# Test sorting keys

# --- Default is to sort keys

test "line 138", (t) =>
	t.is toTAML({c:3, b:2, a:1}), """
		---
		a: 1
		b: 2
		c: 3
		"""

# --- sortKeys array specifies order

test "line 148", (t) =>
	t.is toTAML({c:3, b:2, a:1}, {sortKeys: ['b','a','c']}), """
		---
		b: 2
		a: 1
		c: 3
		"""

test "line 156", (t) =>
	t.is toTAML({c:3, b:2, a:1}, {sortKeys: ['c','b','a']}), """
		---
		c: 3
		b: 2
		a: 1
		"""

# --- Keys not in the sortKeys array are put at end alphabetically

test "line 166", (t) =>
	t.is toTAML({e:5, d:4, c:3, b:2, a:1}, {sortKeys: ['c','b','a']}), """
		---
		c: 3
		b: 2
		a: 1
		d: 4
		e: 5
		"""
