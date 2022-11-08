# log.coffee

import {strict as assert} from 'node:assert'

import {
	pass, undef, defined, notdefined, deepCopy,
	hEsc, escapeStr, OL, untabify, isObject,
	blockToArray, arrayToBlock, prefixBlock,
	isNumber, isInteger, isString, isHash, isFunction, isBoolean,
	nonEmpty, hEscNoNL, jsType, hasChar, quoted,
	} from '@jdeighan/base-utils/utils'
import {toTAML} from '@jdeighan/base-utils/taml'
import {getPrefix} from '@jdeighan/base-utils/prefix'

export logWidth = 42
export sep_dash = '-'.repeat(logWidth)
export sep_eq = '='.repeat(logWidth)

export stringify = undef
internalDebugging = false
threeSpaces  = '   '

# --- This logger only ever gets passed a single string argument
#     ONLY called directly in PUTSTR
putstr = undef

# ---------------------------------------------------------------------------

export PUTSTR = (str) ->

	if (putstr == console.log) || notdefined(putstr)
		console.log untabify(str)
	else
		putstr str
	return

# ---------------------------------------------------------------------------

export setLogWidth = (w) =>

	logWidth = w
	sep_dash = '-'.repeat(logWidth)
	sep_eq = '='.repeat(logWidth)
	return

# ---------------------------------------------------------------------------

export resetLogWidth = () =>

	setLogWidth(42)
	return

# ---------------------------------------------------------------------------

export debugLogging = (flag=true) =>

	internalDebugging = flag
	if internalDebugging
		console.log "internalDebugging = #{flag}"
	return

# ---------------------------------------------------------------------------

export setStringifier = (func) =>

	orgStringifier = stringify
	assert isFunction(func), "setStringifier() arg is not a function"
	stringify = func
	return orgStringifier

# ---------------------------------------------------------------------------

export resetStringifier = () =>

	setStringifier orderedStringify

# ---------------------------------------------------------------------------

export setLogger = (func) =>

	assert isFunction(func), "setLogger() arg is not a function"
	orgLogger = putstr
	putstr = func
	return orgLogger

# ---------------------------------------------------------------------------

export resetLogger = () =>

	setLogger console.log

# ---------------------------------------------------------------------------

export tamlStringify = (obj, escape=false) =>

	return toTAML(obj, {
		useTabs: false
		sortKeys: false
		escape
		})

# ---------------------------------------------------------------------------

export orderedStringify = (obj, escape=false) =>

	return toTAML(obj, {
		useTabs: false
		sortKeys: true
		escape
		})

# ---------------------------------------------------------------------------

export LOG = (str="", prefix="") =>

	if internalDebugging
		console.log "CALL LOG(#{OL(str)}), prefix=#{OL(prefix)}"
		if defined(putstr) && (putstr != console.log)
			console.log "   - use custom logger"

	PUTSTR "#{prefix}#{str}"
	return true   # to allow use in boolean expressions

# ---------------------------------------------------------------------------

export LOGTAML = (label, value, prefix="", itemPrefix=undef) =>

	if internalDebugging
		str1 = OL(label)
		str2 = OL(value)
		str3 = OL(prefix)
		console.log "CALL LOGTAML(#{str1}, #{str2}), prefix=#{str3}"
	assert nonEmpty(label), "label is empty"

	if notdefined(itemPrefix)
		itemPrefix = prefix + "\t"

	if handleSimpleCase(label, value, prefix)
		return true

	PUTSTR "#{prefix}#{label} ="
	for str in blockToArray(toTAML(value, {sortKeys: true}))
		PUTSTR "#{itemPrefix}#{str}"
	return true

# ---------------------------------------------------------------------------

export LOGVALUE = (label, value, prefix="", itemPrefix=undef) =>

	if internalDebugging
		str1 = OL(label)
		str2 = OL(value)
		str3 = OL(prefix)
		console.log "CALL LOGVALUE(#{str1}, #{str2}), prefix=#{str3}"
	assert nonEmpty(label), "label is empty"

	if handleSimpleCase(label, value, prefix)
		return true

	# --- Try OL() - if it's short enough, use that
	str = "#{prefix}#{label} = #{OL(value)}"
	if internalDebugging
		console.log "Using OL(), strlen = #{str.length}, logWidth = #{logWidth}"
	if (str.length <= logWidth)
		PUTSTR str
		return true

	if notdefined(itemPrefix)
		itemPrefix = prefix + "\t"

	[type, subtype] = jsType(value)
	switch type
		when 'string'
			if (subtype == 'empty')
				PUTSTR "#{prefix}#{label} = ''"
			else
				str = "#{prefix}#{label} = #{quoted(value, 'escape')}"
				if (str.length <= logWidth)
					PUTSTR str
				else
					# --- escape, but not newlines
					escaped = escapeStr(value, hEscNoNL)
					PUTSTR """
						#{prefix}#{label} = \"\"\"
						#{prefixBlock(escaped, itemPrefix)}
						#{prefixBlock('"""', itemPrefix)}
						"""

		when 'hash', 'array'
			str = toTAML(value, {sortKeys: true})
			PUTSTR "#{prefix}#{label} ="
			for str in blockToArray(str)
				PUTSTR "#{itemPrefix}#{str}"

		when 'regexp'
			PUTSTR "#{prefix}#{label} = <regexp>"

		when 'function'
			PUTSTR "#{prefix}#{label} = <function>"

		when 'object'
			if isObject(value, '&toLogString')
				str = value.toLogString()
			else
				str = toTAML(value)

			if hasChar(str, "\n")
				PUTSTR "#{prefix}#{label} ="
				if notdefined(itemPrefix)
					itemPrefix = prefix
				for line in blockToArray(str)
					PUTSTR "#{itemPrefix}#{line}"
			else
				PUTSTR "#{prefix}#{label} = #{str}"
	return true

# ---------------------------------------------------------------------------

handleSimpleCase = (label, value, prefix) =>
	# --- Returns true if handled, else false

	# --- Handle some simple cases
	if (value == undef)
		PUTSTR "#{prefix}#{label} = undef"
		return true
	else if (value == null)
		PUTSTR "#{prefix}#{label} = null"
		return true
	else if isBoolean(value)
		if value
			PUTSTR "#{prefix}#{label} = true"
		else
			PUTSTR "#{prefix}#{label} = false"
		return true
	else if isNumber(value)
		PUTSTR "#{prefix}#{label} = #{value}"
		return true
	else
		return false

# ---------------------------------------------------------------------------
# simple redirect to an array - useful in unit tests

lUTLog = undef

export utReset = () =>
	lUTLog = []
	setLogger (str) => lUTLog.push(str)
	return

export utGetLog = () =>
	result = arrayToBlock(lUTLog)
	lUTLog = undef
	resetLogger()
	return result

# ---------------------------------------------------------------------------

if ! loaded
	setStringifier orderedStringify
	resetLogger()
loaded = true
