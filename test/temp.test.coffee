# temp.test.coffee - from log.test.coffee

import test from 'ava'

import {
	undef, defined, notdefined, pass,
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

test "line 74", (t) =>
	utReset()
	LOGVALUE 'x', undef
	t.is utGetLog(), """
		x = undef
		"""
