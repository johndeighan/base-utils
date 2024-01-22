# taml.coffee

import {parse, stringify} from 'yaml'

import {
	undef, defined, notdefined, OL, hasChar, getOptions,
	isEmpty, isString, isFunction, isBoolean, isArray,
	blockToArray, arrayToBlock, escapeStr, rtrim,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'

# ---------------------------------------------------------------------------
#   isTAML - is the string valid TAML?

export isTAML = (text) =>

	return isString(text) && text.match(/^---$/m)

# ---------------------------------------------------------------------------
#   fromTAML - convert valid TAML string to a JavaScript value

export fromTAML = (text) =>

	assert defined(text), "text is undef"
	assert isTAML(text), "string #{OL(text)} isn't TAML"

	# --- TAML uses TAB characters for indentation
	#     convert to 2 spaces per TAB
	lLines = ['---']
	for line,i in blockToArray(text)
		if (i == 0)
			assert (line == '---'), "Invalid TAML marker"
			continue
		[_, ws, str] = line.match(/^(\s*)(.*)$/)
		assert ! hasChar(ws, ' '), "space char in prefix: #{OL(line)}"
		str = str.trim()

		# --- Convert each TAB char to 2 spaces
		lLines.push '  '.repeat(ws.length) + tamlFix(str)

	block = arrayToBlock(lLines)
	try
		result = parse(block, {skipInvalid: true})
	catch err
		console.log '---------------------------------------'
		console.log "ERROR in TAML:"
		console.log text
		console.log "BLOCK:"
		console.log block
		console.log '---------------------------------------'
	return result

# ---------------------------------------------------------------------------

export llSplit = (str) =>
	# --- Returns ["<key>: ", <rest>]
	#        OR   ["- ", <rest>]
	#        OR   undef

	if lMatches = str.match(///^
			([A-Za-z_][A-Za-z0-9_]*)    # the key
			\s*
			:
			\s+
			(.*)
			$///)
		[_, key, rest] = lMatches
		result = ["#{key}: ", rest]
	else if lMatches = str.match(///^
			\-
			\s+
			(.*)
			$///)
		[_, rest] = lMatches
		result = ['- ', rest]
	else
		result = undef
	return result

# ---------------------------------------------------------------------------

export splitTaml = (str) =>
	# --- returns [ ("<key>: " || "- "), ..., <val> ] - <val> may be ''

	lParts = []
	while lResult = llSplit(str)
		lParts.push lResult[0]
		str = lResult[1]
	lParts.push fixValStr(str)
	return lParts

# ---------------------------------------------------------------------------

export tamlFix = (str) =>
	# --- str has been trimmed

	if (str == '-') || str.match(/^[A-Za-z0-9_]+:$/)
		return str
	lParts = splitTaml(str)
	result = lParts.join('')
	return result

# ---------------------------------------------------------------------------

export fixValStr = (valStr) =>

	if isEmpty(valStr) \
			|| (valStr == '[]') \
			|| (valStr == '{}') \
			|| valStr.match(/^\d+(?:\.\d*)?$/) \   # a number
			|| valStr.match(/^\".*\"$/) \          # " quoted string
			|| valStr.match(/^\'.*\'$/) \          # ' quoted string
			|| (valStr == 'true') || (valStr == 'false')
		result = valStr
	else
		result = "'" + valStr.replace(/'/g, "''") + "'"
	return result

# ---------------------------------------------------------------------------
# --- a replacer is (key, value) -> newvalue

myReplacer = (name, value) =>

	if (value == undef)
		# --- We need this, otherwise js-yaml will convert undef to null
		result = "<UNDEFINED_VALUE>"
	else if isString(value)
		result = escapeStr(value)
	else if isFunction(value)
		result = "[Function: #{value.name}]"
	else
		result = value
	return result

# ---------------------------------------------------------------------------

export toTAML = (obj, hOptions={}) =>

	hDefaults = {
		useTabs: true
		sortKeys: true
		}
	{useTabs, sortKeys, escape, replacer
		} = getOptions(hOptions, hDefaults)

	if (obj == undef)
		return "---\nundef"

	if (obj == null)
		return "---\nnull"

	if notdefined(replacer)
		replacer = myReplacer

	if isArray(sortKeys)
		h = {}
		for key,i in sortKeys
			h[key] = i+1
		sortKeys = (a, b) ->
			if defined(h[a])
				if defined(h[b])
					return compareFunc(h[a], h[b])
				else
					return -1
			else
				if defined(h[b])
					return 1
				else
					# --- compare keys alphabetically
					return compareFunc(a, b)
	assert isBoolean(sortKeys) || isFunction(sortKeys),
		"option sortKeys must be boolean, array or function"

	hStrOptions = {sortMapEntries: true}
	str = stringify(obj, myReplacer, hStrOptions)
	str = str.replace(/<UNDEFINED_VALUE>/g, 'undef')
	if useTabs
		str = str.replace(/  /g, "\t")
	return "---\n" + rtrim(str)

# ---------------------------------------------------------------------------

compareFunc = (a, b) =>

	if (a < b)
		return -1
	else if (a > b)
		return 1
	else
		return 0

# ---------------------------------------------------------------------------

squote = (text) =>

	return "'" + text.replace(/'/g, "''") + "'"
