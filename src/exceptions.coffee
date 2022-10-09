# exceptions.coffee

import yaml from 'js-yaml'

import {
	undef, sep_dash, sep_eq, isString, untabify, LOG, toTAML,
	} from '@jdeighan/exceptions/utils'

doHaltOnError = false
doLog = true

# ---------------------------------------------------------------------------

export haltOnError = (flag=true) ->
	# --- return existing setting

	save = doHaltOnError
	doHaltOnError = flag
	return save

# ---------------------------------------------------------------------------

export logErrors = (flag=true) ->

	save = doLog
	doLog = flag
	return save

# ---------------------------------------------------------------------------

getCallers = (stackTrace, lExclude=[]) ->

	iter = stackTrace.matchAll(///
			at
			\s+
			(?:
				async
				\s+
				)?
			([^\s(]+)
			///g)
	if !iter
		return ["<unknown>"]

	lCallers = []
	for lMatches from iter
		[_, caller] = lMatches
		if (caller.indexOf('file://') == 0)
			break
		if caller not in lExclude
			lCallers.push caller

	return lCallers

# ---------------------------------------------------------------------------
#   assert - mimic nodejs's assert
#   return true so we can use it in boolean expressions

export assert = (cond, msg) ->

	if ! cond
		if doLog
			stackTrace = new Error().stack
			lCallers = getCallers(stackTrace, ['assert'])

			console.log '--------------------'
			console.log 'JavaScript CALL STACK:'
			for caller in lCallers
				console.log "   #{caller}"
			console.log '--------------------'
			console.log "ERROR: #{msg} (in #{lCallers[0]}())"
		croak msg
	return true

# ---------------------------------------------------------------------------
#   croak - throws an error after possibly printing useful info
#           err can be a string or an Error object

export croak = (err, label=undef, obj=undef) ->

	if isString(err)
		curmsg = err
	else
		curmsg = err.message

	if isEmpty(label)
		newmsg = "ERROR (croak): #{curmsg}"
	else
		newmsg = """
			ERROR (croak): #{curmsg}
			#{label}:
			#{toTAML(obj)}
			"""
	if doHaltOnError
		LOG newmsg
		process.exit()
	else
		# --- re-throw the error
		throw new Error(newmsg)
