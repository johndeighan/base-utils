# pll-parser.test.coffee

import {
	undef, defined, LOG, OL, sortArrayOfHashes,
	isString, toArray,
	} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'
import {setDebugging} from '@jdeighan/base-utils/debug'
import {
	mkpath, allFilesIn, globFiles,
	} from '@jdeighan/base-utils/fs'
import {parse} from '@jdeighan/base-utils/pll-parser'
import {
	transformValue, transformExpected,
	equal, throws, succeeds,
	} from '@jdeighan/base-utils/utest'

# ---------------------------------------------------------------------------

transformValue (item) => return parse(item)
transformExpected (str) =>
	assert isString(str), "Not a string: #{OL(str)}"
	lTokens = []
	for line in toArray(str)
		if (line == '>>')
			lTokens.push {type: 'indent'}
		else if (line == '<<')
			lTokens.push {type: 'undent'}
		else
			lTokens.push {type: 'text', text: line}
	return lTokens

# ---------------------------------------------------------------------------

succeeds () => parse("abc")
succeeds () => parse("abc\n\t\tdef");
succeeds () => parse("abc\r\n\t\tdef");
throws () => parse("abc\t\tdef");
throws () => parse("\t \t ")

# ---------------------------------------------------------------------------

equal """
	line 1
		line 2
	line 3
	""", """
	line 1
	>>
	line 2
	<<
	line 3
	"""

# --- blank lines are ignored

equal """
	line 1
		line 2

	line 4
	""", """
	line 1
	>>
	line 2
	<<
	line 4
	"""

equal """
	line 1
		line 2
				and more
	line 4
	""", """
	line 1
	>>
	line 2 and more
	<<
	line 4
	"""

equal """
	line 1
		line 2
				and more
	line 4
		line 5
				and more
	line 7
	""", """
	line 1
	>>
	line 2 and more
	<<
	line 4
	>>
	line 5 and more
	<<
	line 7
	"""
