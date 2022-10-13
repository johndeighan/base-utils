# taml.test.coffee

import test from 'ava'

import {assert, croak} from '@jdeighan/exceptions'
import {undef, untabify} from '@jdeighan/exceptions/utils'
import {LOG} from '@jdeighan/exceptions/log'
import {isTAML, toTAML, fromTAML} from '@jdeighan/exceptions/taml'

# ---------------------------------------------------------------------------

test "line 12", (t) =>
	t.truthy isTAML("---\n- first\n- second")

test "line 13", (t) =>
	t.falsy isTAML("x---\n5")

test "line 14", (t) =>
	t.falsy isTAML("---x\n5")

test "line 16", (t) =>
	t.is toTAML({a:1}), "---\na: 1"

test "line 17", (t) =>
	t.is toTAML({a:1, b:2}), "---\na: 1\nb: 2"

test "line 18", (t) =>
	t.is toTAML([1,'abc',{a:1}]), "---\n- 1\n- abc\n-\n   a: 1"


test "line 21", (t) =>
	t.is toTAML({a:1, b:2}), """
		---
		a: 1
		b: 2
		"""

test "line 27", (t) =>
	t.is toTAML(['a','b']), """
		---
		- a
		- b
		"""

test "line 33", (t) =>
	t.is toTAML(['a','b', {a:1}, ['x']]), untabify("""
		---
		- a
		- b
		-
			a: 1
		-
			- x
		""")

test "line 43", (t) =>
	t.deepEqual fromTAML("---\n- a\n- b"), ['a','b']

test "line 44", (t) =>
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

test "line 62", (t) =>
	t.deepEqual fromTAML("""
		---
		a: 1
		b: 2
		"""),
	{
		a: 1
		b: 2
		}


test "line 46", (t) =>
	t.is(toTAML(undef), "---\nundef")

test "line 47", (t) =>
	t.is(toTAML(null), "---\nnull")

test "line 48", (t) =>
	t.is(toTAML({a:1}), "---\na: 1")

test "line 49", (t) =>
	t.is(toTAML({a:1, b:2}), "---\na: 1\nb: 2")

test "line 50", (t) =>
	t.is(toTAML([1,'abc',{a:1}]), "---\n- 1\n- abc\n-\n   a: 1")

test "line 52", (t) =>
	t.is(toTAML({a:1, b:2}), """
		---
		a: 1
		b: 2
		""")

test "line 58", (t) =>
	t.is(toTAML(['a','b']), """
		---
		- a
		- b
		""")

test "line 64", (t) =>
	t.is(toTAML(['a','b', {a:1}, ['x']]), untabify("""
		---
		- a
		- b
		-
			a: 1
		-
			- x
		"""))

test "line 74", (t) =>
	t.is toTAML(['xyz', 42, false, 'false', undef]), """
		---
		- xyz
		- 42
		- false
		- 'false'
		- undef
		"""
