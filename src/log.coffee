# log.coffee

import {strict as assert} from 'node:assert'

import {
	pass, undef, defined, notdefined, deepCopy,
	hEsc, escapeStr, OL,
	blockToArray, arrayToBlock,
	isNumber, isInteger, isString, isHash, isFunction,
	nonEmpty, hEscNoNL, jsType, hasChar, quoted,
	} from '@jdeighan/exceptions/utils'
import {toTAML} from '@jdeighan/exceptions/taml'
import {getPrefix} from '@jdeighan/exceptions/prefix'

# --- This logger only ever gets passed a single string argument
putstr = undef

export logWidth = 42
export sep_dash = '-'.repeat(logWidth)
export sep_eq = '='.repeat(logWidth)

export stringify = undef
doDebugLogging = false
threeSpaces  = '   '

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

	doDebugLogging = flag
	if doDebugLogging
		console.log "doDebugLogging = #{flag}"
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

	if doDebugLogging
		console.log "CALL LOG(#{OL(str)}), prefix=#{OL(prefix)}"
		if (putstr != console.log)
			console.log "   - use custom logger"

	putstr "#{prefix}#{str}"
	return true   # to allow use in boolean expressions

# ---------------------------------------------------------------------------

export LOGVALUE = (label, value, prefix="", itemPrefix=undef) =>

	assert nonEmpty(label), "label is empty"
	if notdefined(itemPrefix)
		itemPrefix = prefix

	if doDebugLogging
		str1 = OL(label)
		str2 = OL(value)
		str3 = OL(prefix)
		console.log "CALL LOGITEM(#{str1}, #{str2}), prefix=#{str3}"

	[type, subtype] = jsType(value)
	baselen = prefix.length + label.length
	switch type
		when undef
			putstr "#{prefix}#{label} = #{subtype}"

		when 'string'
			if (subtype == 'empty')
				putstr "#{prefix}#{label} = ''"
			else
				str = quoted(value, 'escape')
				if (baselen + str.length + 3 <= logWidth)
					putstr "#{prefix}#{label} = #{str}"
				else
					# --- escape, but not newlines
					str = quoted(value, 'escapeNoNL')
					putstr "#{prefix}#{label} = #{str}"

		when 'number'
			putstr "#{prefix}#{label} = #{value}"

		when 'boolean'
			putstr "#{prefix}#{label} = #{subtype}"

		when 'hash', 'array'
			str = toTAML(value, {sortKeys: true})
			putstr "#{prefix}#{label} ="
			for str in blockToArray(str)
				putstr "#{itemPrefix}#{str}"

		when 'regexp'
			putstr "#{prefix}#{label} = <regexp>"

		when 'function'
			putstr "#{prefix}#{label} = <function>"

		when 'object'
			putstr "#{prefix}#{label} = <object>"

	return true

# ---------------------------------------------------------------------------
# simple redirect to an array - useful in unit tests

lUTLog = []

export utReset = () =>
	lUTLog = []
	setLogger (str) => lUTLog.push(str)

export utGetLog = () =>
	return arrayToBlock(lUTLog)

# ---------------------------------------------------------------------------

if ! loaded
	setStringifier orderedStringify
	resetLogger()
loaded = true
