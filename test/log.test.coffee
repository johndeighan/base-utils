# log.test.coffee

import test from 'ava'

import {
	undef, defined, notdefined, pass, jsType,
	} from '@jdeighan/base-utils'
import {getPrefix} from '@jdeighan/base-utils/prefix'
import {
	logWidth, sep_dash, sep_eq,
	setLogWidth, resetLogWidth, debugLogging,
	setStringifier, resetStringifier,
	stringify, tamlStringify, orderedStringify,
	LOG, LOGVALUE, LOGTAML, LOGJSON,
	clearAllLogs, getMyLog,
	} from '@jdeighan/base-utils/log'

fourSpaces = '    '

# ---------------------------------------------------------------------------

test "line 23", (t) =>
	t.deepEqual orderedStringify(['a', 42, [1,2]]), """
		---
		- a
		- 42
		-
		   - 1
		   - 2
		"""

# ---------------------------------------------------------------------------

test "line 35", (t) => t.is(logWidth, 42)

test "line 37", (t) =>
	setLogWidth 5
	t.is logWidth, 5
	t.is sep_dash, '-----'
	resetLogWidth()

test "line 43", (t) =>
	setLogWidth 5
	t.is logWidth, 5
	t.is sep_eq, '====='
	resetLogWidth()

# ---------------------------------------------------------------------------

test "line 51", (t) => t.is(getPrefix(0), '')
test "line 52", (t) => t.is(getPrefix(1), fourSpaces)
test "line 53", (t) => t.is(getPrefix(2), fourSpaces + fourSpaces)

# ---------------------------------------------------------------------------

test "line 57", (t) =>
	clearAllLogs('noecho')
	LOG "abc"
	t.is getMyLog(), """
		abc
		"""

test "line 64", (t) =>
	clearAllLogs('noecho')
	LOG "abc"
	LOG "def"
	t.is getMyLog(), """
		abc
		def
		"""

test "line 73", (t) =>
	clearAllLogs('noecho')
	LOG "abc"
	LOG "def", getPrefix(1)
	LOG "ghi", getPrefix(2)
	t.is getMyLog(), """
		abc
		    def
		        ghi
		"""

# ---------------------------------------------------------------------------

test "line 86", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'x', undef
	t.is getMyLog(), """
		x = undef
		"""

test "line 93", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'x', null
	t.is getMyLog(), """
		x = null
		"""

test "line 100", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'x', 'abc'
	t.is getMyLog(), """
		x = 'abc'
		"""

test "line 107", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'x', 'abc def'
	t.is getMyLog(), """
		x = 'abc˳def'
		"""

test "line 114", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'x', '"abc"'
	t.is getMyLog(), """
		x = '"abc"'
		"""

test "line 121", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'x', "'abc'"
	t.is getMyLog(), """
		x = "'abc'"
		"""

test "line 128", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'x', "'\"abc\"'"
	t.is getMyLog(), """
		x = <'"abc"'>
		"""

# --- long string

test "line 137", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'x', 'a'.repeat(80)
	t.is getMyLog(), """
		x = \"\"\"
			#{'a'.repeat(80)}
			\"\"\"
		"""

# --- multi line string

test "line 148", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'x', 'abc\ndef'
	t.is getMyLog(), """
		x = 'abc®def'
		"""

# --- hash (OL doesn't fit)

test "line 157", (t) =>
	clearAllLogs('noecho')
	setLogWidth 5
	LOGVALUE 'h', {xyz: 42, abc: 99}
	resetLogWidth()
	t.is getMyLog(), """
		h =
			---
			abc: 99
			xyz: 42
		"""

# --- hash (OL fits)

test "line 171", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'h', {xyz: 42, abc: 99}
	t.is getMyLog(), """
		h = {"xyz":42,"abc":99}
		"""

# --- array  (OL doesn't fit)

test "line 180", (t) =>
	clearAllLogs('noecho')
	setLogWidth 5
	LOGVALUE 'l', ['xyz', 42, false, undef]
	resetLogWidth()
	t.is getMyLog(), """
		l =
			---
			- xyz
			- 42
			- false
			- undef
		"""

# --- array (OL fits)

test "line 196", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'l', ['xyz', 42, false, undef]
	t.is getMyLog(), """
		l = ["xyz",42,false,null]
		"""

# --- object

class Node1
	constructor: (@str, @level) ->
		@name = 'node1'
node1 = new Node1('abc', 2)

test "line 210", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'Node1', node1
	t.is getMyLog(), """
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

test "line 240", (t) =>
	clearAllLogs('noecho')
	LOGVALUE 'Node2', node2
	t.is getMyLog(), """
		Node2 =
			HERE IT IS
			str is abc
			name is node2
			level is 2
			THAT'S ALL FOLKS!
		"""

test "line 252", (t) =>
	clearAllLogs('noecho')

	hProc = {
		code:   (block) -> return "#{block};"
		html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
		Script: (block) -> return elem('script', undef, block, "\t")
		}

	LOGVALUE 'hProc', hProc

	t.is getMyLog(), """
		hProc =
			---
			Script: '[Function: Script]'
			code: '[Function: code]'
			html: '[Function: html]'
		"""

test "line 271", (t) =>
	clearAllLogs('noecho')
	setLogWidth 5
	LOGTAML 'lItems', ['xyz', 42, false, undef]
	resetLogWidth()
	t.is getMyLog(), """
		lItems =
		   ---
		   - xyz
		   - 42
		   - false
		   - undef
		"""

test "line 284", (t) =>
	clearAllLogs('noecho')
	setLogWidth 5
	LOGJSON 'lItems', ['xyz', 42, false, undef]
	resetLogWidth()
	t.is getMyLog(), """
		lItems =
		[
		   "xyz",
		   42,
		   false,
		   null
		]
		"""
