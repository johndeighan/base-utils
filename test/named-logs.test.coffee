# named-logs.test.coffee

import {
	undef, defined, notdefined, pass, escapeStr,
	} from '@jdeighan/base-utils'
import {NamedLogs} from '@jdeighan/base-utils/named-logs'
import {equal, truthy, falsy} from '@jdeighan/base-utils/utest'

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs()

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'

	equal logs.getLogs('A'), """
		first log
		second log
		"""
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs()

	logs.log 'A', 'first log'
	logs.log 'B', 'second log'

	equal logs.getLogs('A'), """
		first log
		"""
	equal logs.getLogs('B'), """
		second log
		"""
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs()

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'
	logs.log 'B', 'first log'
	logs.log 'B', 'second log'
	logs.clear 'A'

	equal logs.getLogs('A'), ''
	equal logs.getLogs('B'), """
		first log
		second log
		"""
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs()

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'
	logs.log 'B', 'first log'
	logs.log 'B', 'second log'
	logs.clearAllLogs()

	equal logs.getLogs('A'), ''
	equal logs.getLogs('B'), ''
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs()

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'
	logs.log 'B', 'first log'
	logs.log 'B', 'second log'

	equal logs.getAllLogs(), """
		first log
		second log
		first log
		second log
		"""
	)()

# ---------------------------------------------------------------------------
# --- test: name can be undef
(() ->
	logs = new NamedLogs()

	logs.log undef, 'first log'
	logs.log undef, 'second log'
	logs.log 'B', 'first log'
	logs.log 'B', 'second log'

	equal logs.getLogs(undef), """
		first log
		second log
		"""
	)()

# ---------------------------------------------------------------------------
# --- test: using a filter function
(() ->
	logs = new NamedLogs()

	logs.log undef, 'first log'
	logs.log undef, 'junk'
	logs.log undef, 'second log'
	logs.log 'B', 'first log'
	logs.log 'B', 'junk'
	logs.log 'B', 'second log'

	func = (str) =>
		str.match(/log/)

	equal logs.getLogs(undef, func), """
		first log
		second log
		"""
	equal logs.getLogs('B', func), """
		first log
		second log
		"""
	)()
