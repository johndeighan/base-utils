# taml.coffee

import {parse, stringify} from 'yaml'

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, OL, hasChar, getOptions,
	isEmpty, isString, isFunction, isBoolean, isArray,
	blockToArray, arrayToBlock, escapeStr, rtrim,
	} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------
#   isTAML - is the string valid TAML?

export isTAML = (text) =>

	return isString(text) && text.match(/^---$/m)

# ---------------------------------------------------------------------------
#   taml - convert valid TAML string to a JavaScript value

export fromTAML = (text) =>

	assert defined(text), "text is undef"
	assert isTAML(text), "string #{OL(text)} isn't TAML"

	# --- TAML uses TAB characters for indentation
	lLines = ['---']
	for line,i in blockToArray(text)
		if (i == 0)
			continue
		[_, prefix, str] = line.match(/^(\s*)(.*)$/)
		str = str.trim()
		assert ! hasChar(prefix, ' '), "space char in prefix: #{OL(line)}"
		lLines.push ' '.repeat(prefix.length) + tamlFix(str)

	return parse(arrayToBlock(lLines), {skipInvalid: true})

# ---------------------------------------------------------------------------

export tamlFix = (str) =>

	if lMatches = str.match(///^
			([A-Za-z_][A-Za-z0-9_]*)    # the key
			\s*
			:
			\s*
			(.*)
			$///)
		[_, key, valStr] = lMatches
		if isEmpty(valStr)
			return "#{key}:"
		else
			return "#{key}: #{fixValStr(valStr)}"
	else
		return str

# ---------------------------------------------------------------------------

export fixValStr = (valStr) =>

	if isEmpty(valStr) \
			|| valStr.match(/^\d+(?:\.\d*)?$/) \   # a number
			|| valStr.match(/^\".*\"$/) \          # " quoted string
			|| valStr.match(/^\'.*\'$/) \          # ' quoted string
			|| (valStr == 'true') || (valStr == 'false')
		return valStr
	else
		return "'" + valStr.replace(/'/g, "''") + "'"

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

	{useTabs, sortKeys, escape, replacer} = getOptions(hOptions, {useTabs: true, sortKeys: true})

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
