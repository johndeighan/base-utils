# log.test.coffee

import test from 'ava'

import {
	undef, defined, notdefined, pass, jsType,
	} from '@jdeighan/exceptions/utils'
import {getPrefix} from '@jdeighan/exceptions/prefix'
import {
	logWidth, sep_dash, sep_eq, stringify,
	setLogWidth, resetLogWidth, debugLogging,
	setStringifier, resetStringifier,
	setLogger, resetLogger,
	tamlStringify, orderedStringify,
	LOG, LOGVALUE,
	utReset, utGetLog,
	} from '@jdeighan/exceptions/log'

fourSpaces = '    '

# ---------------------------------------------------------------------------

test "line 23", (t) => t.is(logWidth, 42)

test "line 25", (t) =>
	setLogWidth 5
	t.is logWidth, 5
	t.is sep_dash, '-----'
	resetLogWidth()

test "line 31", (t) =>
	setLogWidth 5
	t.is logWidth, 5
	t.is sep_eq, '====='
	resetLogWidth()

# ---------------------------------------------------------------------------

test "line 39", (t) => t.is(getPrefix(0), '')
test "line 40", (t) => t.is(getPrefix(1), fourSpaces)
test "line 41", (t) => t.is(getPrefix(2), fourSpaces + fourSpaces)

# ---------------------------------------------------------------------------

test "line 45", (t) =>
	utReset()
	LOG "abc"
	t.is utGetLog(), """
		abc
		"""

test "line 52", (t) =>
	utReset()
	LOG "abc"
	LOG "def"
	t.is utGetLog(), """
		abc
		def
		"""

test "line 61", (t) =>
	utReset()
	LOG "abc"
	LOG "def", getPrefix(1)
	LOG "ghi", getPrefix(2)
	t.is utGetLog(), """
		abc
		    def
		        ghi
		"""

# ---------------------------------------------------------------------------

test "line 74", (t) =>
	utReset()
	LOGVALUE 'x', undef
	t.is utGetLog(), """
		x = undef
		"""

test "line 81", (t) =>
	utReset()
	LOGVALUE 'x', null
	t.is utGetLog(), """
		x = null
		"""

test "line 88", (t) =>
	utReset()
	LOGVALUE 'x', 'abc'
	t.is utGetLog(), """
		x = 'abc'
		"""

test "line 95", (t) =>
	utReset()
	LOGVALUE 'x', 'abc def'
	t.is utGetLog(), """
		x = 'abc˳def'
		"""

test "line 102", (t) =>
	utReset()
	LOGVALUE 'x', '"abc"'
	t.is utGetLog(), """
		x = '"abc"'
		"""

test "line 109", (t) =>
	utReset()
	LOGVALUE 'x', "'abc'"
	t.is utGetLog(), """
		x = "'abc'"
		"""

test "line 116", (t) =>
	utReset()
	LOGVALUE 'x', "'\"abc\"'"
	t.is utGetLog(), """
		x = <'"abc"'>
		"""

# --- long string

test "line 125", (t) =>
	utReset()
	LOGVALUE 'x', 'a'.repeat(80)
	t.is utGetLog(), """
		x = '#{'a'.repeat(80)}'
		"""

# --- multi line string

test "line 134", (t) =>
	utReset()
	LOGVALUE 'x', 'abc\ndef'
	t.is utGetLog(), """
		x = 'abc®def'
		"""

# --- hash

test "line 143", (t) =>
	utReset()
	LOGVALUE 'h', {xyz: 42, abc: 99}
	t.is utGetLog(), """
		h =
		---
		abc: 99
		xyz: 42
		"""

# --- array

test "line 155", (t) =>
	utReset()
	LOGVALUE 'l', ['xyz', 42, false, undef]
	t.is utGetLog(), """
		l =
		---
		- xyz
		- 42
		- false
		- undef
		"""

# --- object

class Node1
	constructor: (@str, @level) ->
		@name = 'node1'
node1 = new Node1('abc', 2)

test "line 174", (t) =>
	utReset()
	LOGVALUE 'Node1', node1
	t.is utGetLog(), """
		Node1 =
		---
		level: 2
		name: node1
		str: abc
		"""

# --- object with toString method

class Node2

	constructor: (@str, @level) ->
		@name = 'node2'

	toLogString: () ->
		return """
			HERE IT IS
			str is #{@str}
			name is #{@name}
			level is #{@level}
			THAT'S ALL FOLKS!
			"""

node2 = new Node2('abc', 2)
[type, subtype] = jsType(node2)

test "line 200", (t) =>
	utReset()
	LOGVALUE 'Node2', node2
	t.is utGetLog(), """
		Node2 =
		HERE IT IS
		str is abc
		name is node2
		level is 2
		THAT'S ALL FOLKS!
		"""
