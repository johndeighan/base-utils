# NamedLogs.test.coffee

import {
	undef, defined, notdefined, pass, escapeStr,
	} from '@jdeighan/base-utils'
import {utest} from '@jdeighan/base-utils/utest'
import {NamedLogs} from '@jdeighan/base-utils/named-logs'

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs()

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'

	utest.equal 17, logs.getLogs('A'), """
		first log
		second log
		"""
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs()

	logs.log 'A', 'first log'
	logs.log 'B', 'second log'

	utest.equal 31, logs.getLogs('A'), """
		first log
		"""
	utest.equal 34, logs.getLogs('B'), """
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

	utest.equal 50, logs.getLogs('A'), ''
	utest.equal 51, logs.getLogs('B'), """
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

	utest.equal 68, logs.getLogs('A'), ''
	utest.equal 69, logs.getLogs('B'), ''
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

	utest.truthy 84, logs.getKey('A', 'doEcho')
	utest.falsy 85, logs.getKey('B', 'doEcho')
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs({doEcho: true})

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'
	logs.log 'B', 'first log'
	logs.log 'B', 'second log'

	utest.truthy 98, logs.getKey('A', 'doEcho')
	utest.truthy 99, logs.getKey('B', 'doEcho')
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs({doEcho: true})

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'
	logs.log 'B', 'first log'
	logs.log 'B', 'second log'
	logs.setKey 'B', 'doEcho', false

	utest.truthy 113, logs.getKey('A', 'doEcho')
	utest.falsy 114, logs.getKey('B', 'doEcho')
	)()

# ---------------------------------------------------------------------------

(() ->
	logs = new NamedLogs()

	logs.log 'A', 'first log'
	logs.log 'A', 'second log'
	logs.log 'B', 'first log'
	logs.log 'B', 'second log'

	utest.equal 127, logs.getAllLogs(), """
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

	utest.equal 145, logs.getLogs(undef), """
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

	utest.equal 145, logs.getLogs(undef, func), """
		first log
		second log
		"""
	utest.equal 145, logs.getLogs('B', func), """
		first log
		second log
		"""
	)()