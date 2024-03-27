# nice.test.coffee

import {undef} from '@jdeighan/base-utils'
import {
	UnitTester, equal, like, notequal,
	truthy, falsy, fails, succeeds,
	} from '@jdeighan/base-utils/utest'
import * as lib from '@jdeighan/base-utils/nice'
Object.assign(global, lib)

# ---------------------------------------------------------------------------
# --- test needsQuotes

falsy  needsQuotes("abc")
falsy  needsQuotes("\"Hi\", Alice's sheep said.")
truthy needsQuotes("- item")
truthy needsQuotes("   - item")
truthy needsQuotes("name:")
truthy needsQuotes("   name:")
truthy needsQuotes("name : John")

# --- whitespace is always made explicit

equal formatString("a word"), "a˳word"
equal formatString("\t\tword"), "→  →  word"
equal formatString("first\nsecond"), "first▼second"
equal formatString("first\r\nsecond\r\n"), "first◄▼second◄▼"

equal formatString("abc"), "abc"
equal formatString("mary's lamb"), 'mary\'s˳lamb'
equal formatString("mary's \"stuff\""), 'mary\'s˳"stuff"'

# --- If it looks like an array element, add quotes
equal formatString("- item"), "«-˳item»"
equal formatString("   - item"), "«˳˳˳-˳item»"
equal formatString("-    item"), "«-˳˳˳˳item»"

# ---------------------------------------------------------------------------
# --- repeat formatString() tests using toNICE()

(() =>
	# --- define a function:
	aFunc = () =>
		return 42

	# --- transform value using toNICE() automatically
	u = new UnitTester()
	u.transformValue = (str) => return toNICE(str)

	u.equal "a word", "a˳word"
	u.equal "\t\tword", "→  →  word"
	u.equal "first\nsecond", "first▼second"
	u.equal "abc", "abc"
	u.equal "mary's lamb", 'mary\'s˳lamb'
	u.equal "mary's \"stuff\"", 'mary\'s˳"stuff"'

	u.equal undef, ".undef."
	u.equal null, ".null."
	u.equal NaN, '.NaN.'
	u.equal 42, "42"
	u.equal true, '.true.'
	u.equal false, '.false.'
	u.equal (() => 42), '[Function]'
	u.equal aFunc, '[Function aFunc]'

	func2 = (x) =>
		return
	u.equal func2, "[Function func2]"

	u.equal ['a','b'], """
		- a
		- b
		"""
	u.equal [1,2], """
		- 1
		- 2
		"""
	u.equal ['1','2'], """
		- «1»
		- «2»
		"""
	u.equal {a: 1, b: 2}, """
		a: 1
		b: 2
		"""
	u.equal {a: 'a', b: 'b'}, """
		a: a
		b: b
		"""

	u.equal [ {a:1}, 'abc'], """
		-
			a: 1
		- abc
		"""

	u.equal {a: [1,2], b: 'abc'}, """
		a:
			- 1
			- 2
		b: abc
		"""

	u.equal {a:1, b:'abc', f: func2}, """
		a: 1
		b: abc
		f: [Function func2]
		"""

	u.equal {
		key: 'wood'
		value: [
			"a word"
			{a:1, b:2}
			undef,
			[1,2,"mary's lamb","mary's \"stuff\""]
			]
		items: ["\ta", 2, "\t\tb\n"]
		}, """
		key: wood
		value:
			- a˳word
			-
				a: 1
				b: 2
			- .undef.
			-
				- 1
				- 2
				- mary\'s˳lamb
				- mary\'s˳"stuff"
		items:
			- →  a
			- 2
			- →  →  b▼
		"""

	)()

# ---------------------------------------------------------------------------
# --- test toNICE() with options

(() =>
	# --- Create a hash
	h = {}
	h.mFirst = 'xyz'
	h.aSecond = 'mno'
	h.xThird = 'abc'

	# --- Without sorting, keys should come in insert order
	equal toNICE(h), """
		mFirst: xyz
		aSecond: mno
		xThird: abc
		"""

	# --- sort keys alphabetically
	equal toNICE(h, {sortKeys: true}), """
		aSecond: mno
		mFirst: xyz
		xThird: abc
		"""

	# --- CURRENTLY THIS TEST FAILS
	# --- sort keys in a specific order
	equal toNICE(h, {sortKeys: ['xThird']}), """
		xThird: abc
		aSecond: mno
		mFirst: xyz
		"""
	)()

# ---------------------------------------------------------------------------
# --- test fromNICE()

(() =>
	# --- transform value using fromNICE() automatically
	u = new UnitTester()
	u.transformValue = (str) => return fromNICE(str)

	u.equal """
		fileName: primitive-value
		type: coffee
		author: John Deighan
		include: pll-parser
		""", {
		fileName: 'primitive-value'
		type: 'coffee'
		author: 'John Deighan'
		include: 'pll-parser'
		}
	)()
