# pll-parser.test.coffee

import {
	undef, defined, OL, sortArrayOfHashes,
	isString, toArray,
	} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'
import {LOG} from '@jdeighan/base-utils/log'
import {setDebugging} from '@jdeighan/base-utils/debug'
import {
	mkpath,
	} from '@jdeighan/base-utils/fs'
import {allFilesMatching, globFiles} from '@jdeighan/base-utils/read-file'
import * as lib from '@jdeighan/base-utils/pll-parser'
Object.assign(global, lib)
import {
	transformValue, transformExpected,
	equal, fails, succeeds,
	} from '@jdeighan/base-utils/utest'
import {pparse} from '@jdeighan/base-utils/peggy'

# ---------------------------------------------------------------------------

transformValue (item) => return pparse(parse, item)
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

succeeds () => pparse(parse, "abc")
succeeds () => pparse(parse, "abc\n\t\tdef");
succeeds () => pparse(parse, "abc\r\n\t\tdef");
fails    () => pparse(parse, "abc\t\tdef");
fails    () => pparse(parse, "\t \t ")

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
