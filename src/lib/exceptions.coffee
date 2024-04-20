# exceptions.coffee

import {
	undef, defined, notdefined, isEmpty, isString,
	jsType,
	} from '@jdeighan/base-utils'
import {
	getV8Stack, nodeStr,
	} from '@jdeighan/base-utils/v8-stack'

doHaltOnError = false
doLog = true

# ---------------------------------------------------------------------------
# simple redirect to an array - useful in unit tests

lExceptionLog = undef

export exReset = () =>
	lExceptionLog = []
	return

export exGetLog = () =>
	result = lExceptionLog.join("\n")
	lExceptionLog = undef
	return result

# ---------------------------------------------------------------------------
`/** prevents logging of exceptions */`
export suppressExceptionLogging = () =>

	doLog = false
	exReset()
	return

# ---------------------------------------------------------------------------

export haltOnError = (flag=true) =>
	# --- return existing setting

	save = doHaltOnError
	doHaltOnError = flag
	return save

# ---------------------------------------------------------------------------

EXLOG = (obj) =>

	if lExceptionLog
		if isString(obj)
			lExceptionLog.push obj
		else
			lExceptionLog.push JSON.stringify(obj)
	else if doLog
		console.log obj

# ---------------------------------------------------------------------------
#   assert - mimic nodejs's assert
#   return true so we can use it in boolean expressions

export assert = (cond, msg, obj=undef, label=undef) =>

	if ! cond

		if defined(obj)
			EXLOG '-------------------------'
			if defined(label)
				EXLOG label
			EXLOG obj
			EXLOG '-------------------------'

		lFrames = getV8Stack()
		EXLOG '-------------------------'
		EXLOG 'JavaScript CALL STACK:'
		for node in lFrames
			EXLOG "   #{nodeStr(node)}"
		EXLOG '-------------------------'
		EXLOG "ERROR: #{msg}"
		croak msg
	return true

# ---------------------------------------------------------------------------

export isType = (type, label, obj) =>

	article = if (type=='array') then 'an' else 'a'
	assert((jsType(obj)[0] == type),
			"#{label} is not #{article} #{type}",
			obj, label
			)
	return

# ---------------------------------------------------------------------------
#   croak - throws an error after possibly printing useful info
#           err can be a string or an Error object

export croak = (err="unknown error", label=undef, obj=undef) =>

	if (typeof err == 'string') || (err instanceof String)
		curmsg = err
	else
		curmsg = err.message || "unknown error"

	if isEmpty(label)
		newmsg = "ERROR (croak): #{curmsg}"
	else
		newmsg = """
			ERROR (croak): #{curmsg}
			#{label}:
			#{JSON.stringify(obj)}
			"""

	if doHaltOnError
		EXLOG newmsg
		process.exit()
	else
		# --- re-throw the error
		doLog = true    # reset for next error
		throw new Error(newmsg)
