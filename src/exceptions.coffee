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
# --- export only to allow unit tests

export toTAML = (obj) ->
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

	if ! doLog
		return
	switch lArgs.length
		when 0
			console.log ""
		when 1
			console.log lArgs[0]
		when 2
			# --- There's both a label and an item
			[label, item] = lArgs
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
			console.log "TOO MANY ARGS for LOG(): #{lArgs.length}"
	return true   # to allow use in boolean expressions

# --- Use this instead to make it easier to remove all instances
export DEBUG = LOG   # synonym

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
