# log.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	pass, undef, defined, notdefined, deepCopy, getOptions,
	hEsc, escapeStr, OL, untabify, isObject, rtrim, DUMP,
	blockToArray, arrayToBlock, prefixBlock, centeredText,
	isNumber, isInteger, isString, isHash, isFunction, isBoolean,
	isEmpty, nonEmpty, hEscNoNL, jsType, hasChar, quoted,
	} from '@jdeighan/base-utils'
import {toTAML} from '@jdeighan/base-utils/ll-taml'
import {getPrefix} from '@jdeighan/base-utils/prefix'
import {getMyOutsideCaller} from '@jdeighan/base-utils/ll-v8-stack'
import {NamedLogs} from '@jdeighan/base-utils/named-logs'

export logWidth = 42
export sep_dash = '-'.repeat(logWidth)
export sep_eq = '='.repeat(logWidth)

export stringify = undef
internalDebugging = false
threeSpaces  = '   '

# --- This logger only ever gets passed a single string argument
#     ONLY called directly in PUTSTR, set in setLogger()
putstr = undef

logs = new NamedLogs({doEcho: true})

# ---------------------------------------------------------------------------

export echoLogsByDefault = (flag=true) =>

	logs.hDefaultKeys.doEcho = flag
	return

# ---------------------------------------------------------------------------

export debugLogging = (flag=true) =>

	internalDebugging = flag
	if internalDebugging
		console.log "internalDebugging = #{flag}"
	return

# ---------------------------------------------------------------------------

export echoMyLogs = (flag=true) =>

	# --- NOTE: hFrame can be undef - NamedLogs handles that OK
	filePath = getMyOutsideCaller().filePath
	logs.setKey filePath, 'doEcho', flag
	return

# ---------------------------------------------------------------------------

export clearMyLogs = () =>

	filePath = getMyOutsideCaller().filePath
	logs.clear filePath
	return

# ---------------------------------------------------------------------------

export clearAllLogs = () =>

	logs.clearAllLogs()
	return

# ---------------------------------------------------------------------------

export getMyLogs = () =>

	filePath = getMyOutsideCaller().filePath
	return logs.getLogs(filePath)

# ---------------------------------------------------------------------------

export getAllLogs = () =>

	return logs.getAllLogs()

# ---------------------------------------------------------------------------

export PUTSTR = (str) =>

	if internalDebugging
		console.log "CALL PUTSTR(#{OL(str)})"
		if defined(putstr) && (putstr != console.log)
			console.log "   - use custom logger"

	str = rtrim(str)

	filePath = getMyOutsideCaller().filePath
	doEcho = logs.getKey(filePath, 'doEcho')
	if internalDebugging
		console.log "   filePath = #{OL(filePath)}, doEcho = #{OL(doEcho)}"
	logs.log filePath, str
	if doEcho
		if defined(putstr) && (putstr != console.log)
			putstr str
		else
			# --- console doesn't handle TABs correctly, so...
			console.log untabify(str)
	return

# ---------------------------------------------------------------------------

export LOG = (str="", prefix="") =>

	if internalDebugging
		console.log "CALL LOG(#{OL(str)}), prefix=#{OL(prefix)}"

	PUTSTR "#{prefix}#{str}"
	return true   # to allow use in boolean expressions

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

export prefixed = (prefix, lStrings...) =>

	lLines = []
	for str in lStrings
		lLines = lLines.concat(blockToArray(str))
	result = arrayToBlock(lLines.map((x) => "#{prefix}#{x}"))
	return result

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

	desc = toTAML(value, {sortKeys: true})
	PUTSTR prefixed(prefix, "#{prefix}#{label} = <<<", prefixed('   ', desc))
	return true

# ---------------------------------------------------------------------------

export LOGJSON = (label, value, prefix="") =>

	if internalDebugging
		str1 = OL(label)
		str2 = OL(value)
		str3 = OL(prefix)
		console.log "CALL LOGJSON(#{str1}, #{str2}), prefix=#{str3}"
	assert nonEmpty(label), "label is empty"

	desc = JSON.stringify(value, null, 3)
	PUTSTR prefixed(prefix, "#{prefix}#{label} =", desc)
	return true

# ---------------------------------------------------------------------------

export stringFits = (str) =>

	return (str.length <= logWidth)

# ---------------------------------------------------------------------------

export LOGVALUE = (label, value, prefix="", itemPrefix=undef) =>
	# --- Allow label to be empty, i.e. undef

	if internalDebugging
		str1 = OL(label)
		str2 = OL(value)
		str3 = OL(prefix)
		console.log "CALL LOGVALUE(#{str1}, #{str2}), prefix=#{str3}"

	# --- Handles undef, null, boolean, number
	if handleSimpleCase(label, value, prefix)
		return true

	if defined(label)
		labelStr = "#{label} = "
	else
		labelStr = ""

	# --- Try OL() - if it's short enough, use that
	str = "#{prefix}#{labelStr}#{OL(value)}"

	if stringFits(str)
		if internalDebugging
			console.log "Using OL(), #{str.length} <= #{logWidth}"
		PUTSTR str
		return true

	if notdefined(itemPrefix)
		itemPrefix = prefix + "\t"

	[type, subtype] = jsType(value)
	switch type
		when 'string'
			if (subtype == 'empty')
				# --- empty string
				PUTSTR "#{prefix}#{labelStr}''"
			else
				# --- non empty string
				str = "#{prefix}#{labelStr}#{quoted(value, 'escape')}"
				if stringFits(str)
					PUTSTR str
				else
					# --- escape, but not newlines
					escaped = escapeStr(value, hEscNoNL)
					PUTSTR """
						#{prefix}#{labelStr}\"\"\"
						#{prefixBlock(escaped, itemPrefix)}
						#{prefixBlock('"""', itemPrefix)}
						"""

		when 'hash', 'array'
			str = toTAML(value, {sortKeys: true})
			if labelStr
				PUTSTR "#{prefix}#{labelStr}"
			for str in blockToArray(str)
				PUTSTR "#{itemPrefix}#{str}"

		when 'regexp'
			PUTSTR "#{prefix}#{labelStr}<regexp>"

		when 'function'
			PUTSTR "#{prefix}#{labelStr}<function>"

		when 'object'
			if isObject(value, '&toLogString')
				str = value.toLogString()
			else
				str = toTAML(value)

			if hasChar(str, "\n")
				if labelStr
					PUTSTR "#{prefix}#{labelStr}"
				if notdefined(itemPrefix)
					itemPrefix = prefix
				for line in blockToArray(str)
					PUTSTR "#{itemPrefix}#{line}"
			else
				PUTSTR "#{prefix}#{labelStr}#{str}"
	return true

# ---------------------------------------------------------------------------

export LOGSTRING = (label, value, prefix="") =>

	if internalDebugging
		str1 = OL(label)
		str2 = OL(value)
		str3 = OL(prefix)
		console.log "CALL LOGSTRING(#{str1}, #{str2}), prefix=#{str3}"
	assert nonEmpty(label), "label is empty"
	assert isString(value), "value not a string"

	# --- if it's short enough, put on one line
	str = "#{prefix}#{label} = #{quoted(value)}"
	if stringFits(str)
		if internalDebugging
			console.log "Put on one line, #{str.length} <= #{logWidth}"
		PUTSTR str
		return true

	itemPrefix = prefix + "\t"

	str = "#{prefix}#{label} = #{quoted(value, 'escape')}"
	if stringFits(str)
		PUTSTR str
	else
		# --- escape, but not newlines
		PUTSTR """
			#{prefix}#{label} = \"\"\"
			#{prefixBlock(value, itemPrefix)}
			#{prefixBlock('"""', itemPrefix)}
			"""

	return true

# ---------------------------------------------------------------------------

handleSimpleCase = (label, value, prefix) =>
	# --- Returns true if handled, else false

	if defined(label)
		labelStr = "#{label} = "
	else
		labelStr = ""

	# --- Handle some simple cases
	if (value == undef)
		PUTSTR "#{prefix}#{labelStr}undef"
		return true
	else if (value == null)
		PUTSTR "#{prefix}#{labelStr}null"
		return true
	else if isBoolean(value)
		if value
			PUTSTR "#{prefix}#{labelStr}true"
		else
			PUTSTR "#{prefix}#{labelStr}false"
		return true
	else if isNumber(value)
		PUTSTR "#{prefix}#{labelStr}#{value}"
		return true
	else
		return false

# ---------------------------------------------------------------------------

setStringifier orderedStringify
resetLogger()
