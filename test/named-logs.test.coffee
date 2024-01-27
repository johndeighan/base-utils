# NamedLogs.test.coffee

import {
	undef, defined, notdefined, pass, escapeStr,
	} from '@jdeighan/base-utils'
import {NamedLogs} from '@jdeighan/base-utils/named-logs'
import {utest} from '@jdeighan/base-utils/utest'

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs()

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'

	utest.equal logs.getLogs('A'), """
		first log
		second log
		"""
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs()

	logs.log 'A', 'first log'
	logs.log 'B', 'second log'

	utest.equal logs.getLogs('A'), """
		first log
		"""
	utest.equal logs.getLogs('B'), """
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

	utest.equal logs.getLogs('A'), ''
	utest.equal logs.getLogs('B'), """
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

	utest.equal logs.getLogs('A'), ''
	utest.equal logs.getLogs('B'), ''
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs()

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'
	logs.log 'B', 'first log'
	logs.log 'B', 'second log'
	logs.setKey 'A', 'doEcho', true
	logs.setKey 'B', 'doEcho', false

	utest.truthy logs.getKey('A', 'doEcho')
	utest.falsy logs.getKey('B', 'doEcho')
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs({doEcho: true})

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'
	logs.log 'B', 'first log'
	logs.log 'B', 'second log'

	utest.truthy logs.getKey('A', 'doEcho')
	utest.truthy logs.getKey('B', 'doEcho')
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs({doEcho: true})

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'
	logs.log 'B', 'first log'
	logs.log 'B', 'second log'
	logs.setKey 'B', 'doEcho', false

	utest.truthy logs.getKey('A', 'doEcho')
	utest.falsy logs.getKey('B', 'doEcho')
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs()

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'
	logs.log 'B', 'first log'
	logs.log 'B', 'second log'

	utest.equal logs.getAllLogs(), """
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

	utest.equal logs.getLogs(undef), """
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

	utest.equal logs.getLogs(undef, func), """
		first log
		second log
		"""
	utest.equal logs.getLogs('B', func), """
		first log
		second log
		"""
	)()
