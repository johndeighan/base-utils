# exceptions.coffee

import yaml from 'js-yaml'

sep_dash = '-'.repeat(42)
sep_eq = '='.repeat(42)
`const undef = undefined`
isString = (x) => return (typeof x == 'string') || (x instanceof String)
untabify = (str) -> return str.replace(/\t/g, ' '.repeat(3))

doHaltOnError = false
doLog = true

# ---------------------------------------------------------------------------

export haltOnError = (flag=true) ->

	doHaltOnError = flag
	return

# ---------------------------------------------------------------------------

export logErrors = (flag=true) ->

	doLog = flag
	return

# ---------------------------------------------------------------------------

toTAML = (obj) ->
	str = yaml.dump(obj, {
		skipInvalid: true
		indent: 3
		sortKeys: true
		lineWidth: -1
		})
	return "---\n" + str

# ---------------------------------------------------------------------------
# This is useful for debugging

export LOG = (lArgs...) ->

	[label, item] = lArgs
	if lArgs.length > 1
		# --- There's both a label and an item
		if (item == undef)
			console.log "#{label} = undef"
		else if (item == null)
			console.log "#{label} = null"
		else
			console.log sep_dash
			console.log "#{label}:"
			if isString(item)
				console.log untabify(item)
			else
				console.log toTAML(item)
			console.log sep_dash
	else
		console.log label
	return true   # to allow use in boolean expressions

# --- Use this instead to make it easier to remove all instances
export DEBUG = LOG   # synonym

# ---------------------------------------------------------------------------
#   error - throw an error

export error = (message) ->

	if doHaltOnError
		console.trace("ERROR: #{message}")
		process.exit()
	throw new Error(message)

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
		if doHaltOnError
			process.exit()
		error msg
	return true

# ---------------------------------------------------------------------------
#   croak - throws an error after possibly printing useful info

export croak = (err, label, obj) ->

	if isString(err)
		curmsg = err
	else
		curmsg = err.message
	newmsg = """
			ERROR (croak): #{curmsg}
			#{label}:
			#{JSON.stringify(obj)}
			"""

	# --- re-throw the error
	throw new Error(newmsg)
