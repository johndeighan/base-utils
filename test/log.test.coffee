# log.test.coffee

import {
	undef, defined, notdefined, pass, jsType, spaces,
	} from '@jdeighan/base-utils'
import {getPrefix} from '@jdeighan/base-utils/prefix'
import * as lib from '@jdeighan/base-utils/log'
Object.assign(global, lib)
import {
	UnitTester, equal, notequal, like,
	truthy, falsy, fails, succeeds,
	} from '@jdeighan/base-utils/utest'

echoLogs false
fiveSpaces = ' '.repeat(5)

# ---------------------------------------------------------------------------

equal orderedStringify(['a', 42, [1,2]]), """
	---
	- a
	- 42
	- - 1
	  - 2
	"""

# ---------------------------------------------------------------------------

equal getPrefix(0), ''
equal getPrefix(1), spaces(4)
equal getPrefix(2), spaces(8)

# ---------------------------------------------------------------------------

clearAllLogs('noecho')
LOG "abc"
equal getMyLogs(), """
	abc
	"""

clearAllLogs('noecho')
LOG "abc"
LOG "def"
equal getMyLogs(), """
	abc
	def
	"""

# NOTE: Because logs are destined for the console,
#       which doesn't allow defining how to display TAB chars,
#       indentation defaults to 4 space chars, not TAB chars

clearAllLogs('noecho')
LOG "abc"
LOG "def", getPrefix(1)
LOG "ghi", getPrefix(2)
equal getMyLogs(), """
	abc
	#{spaces(4)}def
	#{spaces(4)}#{spaces(4)}ghi
	"""

# ---------------------------------------------------------------------------

clearAllLogs('noecho')
LOGVALUE 'x', undef
equal getMyLogs(), """
	x = undef
	"""

clearAllLogs('noecho')
LOGVALUE 'x', null
equal getMyLogs(), """
	x = null
	"""

clearAllLogs('noecho')
LOGVALUE 'x', 'abc'
equal getMyLogs(), """
	x = 'abc'
	"""

clearAllLogs('noecho')
LOGVALUE 'x', 'abc def'
equal getMyLogs(), """
	x = 'abc˳def'
	"""

clearAllLogs('noecho')
LOGVALUE 'x', '"abc"'
equal getMyLogs(), """
	x = '"abc"'
	"""

clearAllLogs('noecho')
LOGVALUE 'x', "'abc'"
equal getMyLogs(), """
	x = "'abc'"
	"""

clearAllLogs('noecho')
LOGVALUE 'x', "'\"abc\"'"
equal getMyLogs(), """
	x = «'"abc"'»
	"""

# --- long string

clearAllLogs('noecho')
LOGVALUE 'x', 'a'.repeat(80)
equal getMyLogs(), """
	x = \"\"\"
		#{'a'.repeat(80)}
		\"\"\"
	"""

# --- multi line string

clearAllLogs('noecho')
LOGVALUE 'x', 'abc\ndef'
equal getMyLogs(), """
	x = 'abc▼def'
	"""

# --- hash (OL doesn't fit)

clearAllLogs('noecho')
setLogWidth 5
LOGVALUE 'h', {xyz: 42, abc: 99}
resetLogWidth()
equal getMyLogs(), """
	h =
		---
		abc: 99
		xyz: 42
	"""

# --- hash (OL fits)

clearAllLogs('noecho')
LOGVALUE 'h', {xyz: 42, abc: 99}
equal getMyLogs(), """
	h = {"xyz":42,"abc":99}
	"""

# --- array  (OL doesn't fit)

clearAllLogs('noecho')
setLogWidth 5
LOGVALUE 'l', ['xyz', 42, false, undef]
resetLogWidth()
equal getMyLogs(), """
	l =
		---
		- xyz
		- 42
		- false
		- undef
	"""

# --- array (OL fits)

clearAllLogs('noecho')
LOGVALUE 'l', ['xyz', 42, false, undef]
equal getMyLogs(), """
	l = ["xyz",42,false,null]
	"""

# --- object

class Node1
	constructor: (@str, @level) ->
		@name = 'node1'
node1 = new Node1('abc', 2)

clearAllLogs('noecho')
LOGVALUE 'Node1', node1
equal getMyLogs(), """
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

clearAllLogs('noecho')
LOGVALUE 'Node2', node2
equal getMyLogs(), """
	Node2 =
		HERE IT IS
		str is abc
		name is node2
		level is 2
		THAT'S ALL FOLKS!
	"""

clearAllLogs('noecho')

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

LOGVALUE 'hProc', hProc

equal getMyLogs(), """
	hProc =
		---
		Script: "[Function: Script]"
		code: "[Function: code]"
		html: "[Function: html]"
	"""

clearAllLogs('noecho')
setLogWidth 5
LOGTAML 'lItems', ['xyz', 42, false, undef]
resetLogWidth()
equal getMyLogs(), """
	lItems = <<<
	#{spaces(3)}---
	#{spaces(3)}- xyz
	#{spaces(3)}- 42
	#{spaces(3)}- false
	#{spaces(3)}- undef
	"""

clearAllLogs('noecho')
setLogWidth 5
LOGJSON 'lItems', ['xyz', 42, false, undef]
resetLogWidth()
equal getMyLogs(), """
	lItems =
	[
	#{spaces(3)}"xyz",
	#{spaces(3)}42,
	#{spaces(3)}false,
	#{spaces(3)}null
	]
	"""
