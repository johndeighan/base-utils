# named-logs.coffee

import {
	undef, defined, notdefined, hasKey, isFunction,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'

# ---------------------------------------------------------------------------

export class NamedLogs

	constructor: () ->

		# --- {
		#        <name>: [<str>, ...],
		#        ...
		#        }
		@hLogs = {}

	# ..........................................................

	dump: () ->

		console.log "hLogs:"
		console.log JSON.stringify(@hLogs, null, 3)
		return

	# ..........................................................

	log: (name, str) ->

		if hasKey(@hLogs, name)
			@hLogs[name].push str
		else
			@hLogs[name] = [str]
		return

	# ..........................................................
	# --- func is a function to filter lines returned
	#     returns a block, i.e. multi-line string

	getLogs: (name, func=undef) ->

		if ! hasKey(@hLogs, name)
			return ''
		lLogs = @hLogs[name]
		if defined(func)
			assert isFunction(func), "filter not a function"
			return lLogs.filter(func).join("\n")
		else
			return lLogs.join("\n")

	# ..........................................................

	getAllLogs: (func=undef) ->

		lAllLogs = []
		for own name,h of @hLogs
			lAllLogs.push @getLogs(name, func)
		return lAllLogs.join("\n")

	# ..........................................................

	clear: (name) ->

		if hasKey(@hLogs, name)
			delete @hLogs[name]
		return

	# ..........................................................

	clearAllLogs: () ->

		@hLogs = {}
		return
