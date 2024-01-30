# readline.test.coffee

import {undef, defined} from '@jdeighan/base-utils'
import {
	allLinesIn, forEachLineInFile,
	} from '@jdeighan/base-utils/readline'
import {u} from '@jdeighan/base-utils/utest'

# --- Similar files, but readline3 has terminating newline,
#        readline4 does not
filePath3 = './test/readline3.txt'
filePath4 = './test/readline4.txt'

# ---------------------------------------------------------------------------

(() =>

	lLines = []

	for line from allLinesIn(filePath4)
		lLines.push line

	u.equal lLines, ['ghi', 'jkl', '', 'mno', 'pqr']
	)()

# ---------------------------------------------------------------------------
# --- Produce capitalized version, with a prefix "> "
#        skipping blank lines

(() =>

	func = (line, hContext) =>
		if (line == '')
			return undef
		else
			return "#{hContext.prefix}#{line.toUpperCase()}"

	lLines = forEachLineInFile filePath3, func, {prefix: '> '}

	u.equal lLines, ['> GHI', '> JKL', '> MNO', '> PQR']
	)()

# ---------------------------------------------------------------------------
# --- Produce capitalized version, with a prefix "> "
#        skipping blank lines

(() =>

	func = (line, hContext) =>
		if (line == '')
			return undef
		else
			return "#{hContext.prefix}#{line.toUpperCase()}"

	lLines = forEachLineInFile filePath4, func, {prefix: '> '}

	u.equal lLines, ['> GHI', '> JKL', '> MNO', '> PQR']
	)()

# ---------------------------------------------------------------------------
# --- This time, stop processing when a blank line is found

(() =>

	func = (line, hContext) =>
		if (line == '')
			throw 'stop'
		else
			return "#{hContext.prefix}#{line.toUpperCase()}"

	lLines = forEachLineInFile filePath4, func, {prefix: '> '}

	u.equal lLines, ['> GHI', '> JKL']
	)()
