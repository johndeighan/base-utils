# exceptions.coffee

`const undef = void 0`
doHaltOnError = true
doLog = true

# ---------------------------------------------------------------------------

export suppressExceptionLogging = (flag=true) ->

	doLog = ! flag
	return

# ---------------------------------------------------------------------------

export haltOnError = (flag=true) ->
	# --- return existing setting

	save = doHaltOnError
	doHaltOnError = flag
	return save

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

LLOG = (str) ->

	if lExceptionLog
		lExceptionLog.push str
	else if doLog
		console.log str

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
	if ! iter
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

		LLOG '-------------------------'
		LLOG 'JavaScript CALL STACK:'
		for caller in lCallers
			LLOG "   #{caller}"
		LLOG '-------------------------'
		LLOG "ERROR: #{msg} (in #{lCallers[0]}())"
		croak msg
	return true

# ---------------------------------------------------------------------------
#   croak - throws an error after possibly printing useful info
#           err can be a string or an Error object

export croak = (err, label=undef, obj=undef) ->

	if (typeof err == 'string') || (err instanceof String)
		curmsg = err
	else
		curmsg = err.message

	if (label == undef) || (label == null) || (label == '')
		newmsg = "ERROR (croak): #{curmsg}"
	else
		newmsg = """
			ERROR (croak): #{curmsg}
			#{label}:
			#{JSON.stringify(obj)}
			"""

	if doHaltOnError
		LLOG newmsg
		process.exit()
	else
		# --- re-throw the error
		throw new Error(newmsg)
