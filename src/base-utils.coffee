# base-utils.coffee

import {
	undef, defined, notdefined, isString, isEmpty, untabify, OL,
	} from '@jdeighan/base-utils/utils'
import {isTAML, fromTAML, toTAML} from '@jdeighan/base-utils/taml'
import {
	LOG, LOGVALUE, LOGTAML, setLogger, sep_dash, sep_eq,
	} from '@jdeighan/base-utils/log'
import {
	setDebugging, resetDebugging, setCustomDebugLogger,
	} from '@jdeighan/base-utils/debug'

export {
	LOG, LOGVALUE, LOGTAML, setLogger,
	setDebugging, resetDebugging, setCustomDebugLogger,
	isTAML, fromTAML, toTAML}

doHaltOnError = false

# ---------------------------------------------------------------------------

export haltOnError = (flag=true) ->
	# --- return existing setting

	save = doHaltOnError
	doHaltOnError = flag
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
		stackTrace = new Error().stack
		lCallers = getCallers(stackTrace, ['assert'])

		LOG sep_dash
		LOG 'JavaScript CALL STACK:'
		for caller in lCallers
			LOG "   #{caller}"
		LOG sep_dash
		LOG "ERROR: #{msg} (in #{lCallers[0]}())"
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
