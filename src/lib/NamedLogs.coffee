# NamedLogs.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, isString, isNonEmptyString, OL,
	} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

export class NamedLogs

	constructor: (@hDefaultKeys={}) ->

		# --- <name> must be undef or a non-empty string
		@hLogs = {}   # --- { <name>: { lLogs: [<str>, ...], ... }}

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
		if h.hasOwnProperty(key)
			return h[key]
		else if @hDefaultKeys.hasOwnProperty(key)
			return @hDefaultKeys[key]
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
