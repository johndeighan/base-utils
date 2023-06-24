# NamedLogs.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, OL,
	isString, isNonEmptyString, isHash,
	} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

export class NamedLogs

	constructor: (@hDefaultKeys={}) ->

		# --- <name> must be undef or a non-empty string
		@hLogs = {}   # --- { <name>: { lLogs: [<str>, ...], ... }}

	# ..........................................................

	dump: () ->

		console.log "hDefaultKeys:"
		console.log JSON.stringify(@hDefaultKeys, null, 3)
		console.log "hLogs:"
		console.log JSON.stringify(@hLogs, null, 3)
		return

	# ..........................................................

	log: (name, str) ->

		h = @getHash(name)
		h.lLogs.push str
		return

	# ..........................................................

	getLogs: (name) ->

		h = @getHash(name)
		return h.lLogs.join("\n")

	# ..........................................................

	getAllLogs: () ->

		lAllLogs = []
		for own name,h of @hLogs
			lAllLogs.push @getLogs(name)
		return lAllLogs.join("\n")

	# ..........................................................

	clear: (name) ->

		h = @getHash(name)
		h.lLogs = []
		return

	# ..........................................................

	clearAllLogs: () ->

		for own name,h of @hLogs
			h.lLogs = []
		return

	# ..........................................................

	setKey: (name, key, value) ->

		h = @getHash(name)
		h[key] = value
		return

	# ..........................................................

	getKey: (name, key) ->

		h = @getHash(name)
		assert isHash(h), "in getKey(), h = #{OL(h)}"
		if h.hasOwnProperty(key)
			result = h[key]
			return result
		else if @hDefaultKeys.hasOwnProperty(key)
			result = @hDefaultKeys[key]
			return result
		else
			return undef

	# ..........................................................

	getHash: (name) ->

		assert (name != 'undef'), "cannot use key 'undef'"
		if notdefined(name)
			name = 'undef'

		assert isNonEmptyString(name), "name = '#{OL(name)}'"
		assert (name != 'lLogs'), "cannot use key 'lLogs'"
		if ! @hLogs.hasOwnProperty(name)
			@hLogs[name] = {
				lLogs: []
				}
		return @hLogs[name]
