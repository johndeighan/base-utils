# to-nice.coffee

import {
	undef, defined, notdefined, escapeStr, getOptions,
	jsType, toArray, toBlock, untabify, isInteger, OL,
	isArray, isBoolean, isFunction, delimitBlock,
	} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

export needsQuotes = (str) =>

	# --- if it looks like an array item, it needs quotes
	if str.match(/^\s*-/)
		return true

	# --- if it looks like a hash key, it needs quotes
	if str.match(/^\s*\S+\s*:/)
		return true

	# --- if it looks like a number, it needs quotes
	if str.match(/^\s*\d+(?:\.\d*)?/)
		return true

	return false

# ---------------------------------------------------------------------------
# --- There is only one type of quote:
#        « (ALT+0171) » (ALT+0187)

export formatString = (str) =>

	fstr = escapeStr(str, {
		' ': '˳'
		"\t": '→  '
		"\r": '◄'
		"\n": '▼'
		'«': "\\«"
		'»': "\\»"
		})
	if needsQuotes(str)
		return "«" + fstr + "»"
	else
		return fstr

# ---------------------------------------------------------------------------

export shouldSplit = (type) =>

	return ['hash','array','class','object'].includes(type)

# ---------------------------------------------------------------------------

export baseCompare = (a, b) =>

	if (a < b)
		return -1
	else if (a > b)
		return 1
	else
		return 0

# ---------------------------------------------------------------------------

export indentBlock = (block, level, oneIndent) =>

	lLines = toArray(block)
	lNewLines = for line in lLines
		oneIndent.repeat(level) + line
	return toBlock(lNewLines)

# ---------------------------------------------------------------------------

export toNICE = (obj, hOptions={}) =>

	{sortKeys, indent, oneIndent, label, delimit, width,
		} = getOptions hOptions, {
		sortKeys: false    # --- can be boolean/array/function
		indent: 0          # --- integer number of levels
		oneIndent: "\t"
		label: undef
		delimit: false
		width: 40
		}

	if isArray(sortKeys)
		# --- Convert to a function
		h = {}
		for key,i in sortKeys
			h[key] = i+1

		sortKeys = (aKey, bKey) ->
			aVal = h[aKey]
			bVal = h[bKey]

			if defined(aVal)
				if defined(bVal)
					# --- compare numerically
					return baseCompare(aVal, bVal)
				else
					return -1
			else
				if defined(bVal)
					return 1
				else
					# --- compare keys alphabetically
					return baseCompare(aKey, bKey)
	else
		type = typeof sortKeys
		if (type != 'boolean') && (type != 'function')
			throw new Error("sortKeys not boolean or function")

	[type, subtype] = jsType(obj)
	switch type
		when 'function'
			if defined(subtype)
				result = "[Function #{subtype}]"
			else
				result = "[Function]"
		when 'class'
			if defined(subtype)
				result = "[Class #{subtype}]"
			else
				result = "[Class]"
		when undef
			if (subtype == 'null')
				result = '.null.'
			else
				result = '.undef.'
		when 'number', 'bigint'
			if (subtype == 'NaN')
				result = '.NaN.'
			else
				result = obj.toString()
		when 'string'
			result = formatString(obj)
		when 'boolean'
			if obj
				result = '.true.'
			else
				result = '.false.'
		when 'array'
			lLines = []
			for item in obj
				block = toNICE(item)
				if shouldSplit(jsType(item)[0])
					lLines.push '-'
					lLines.push indentBlock(block, 1, oneIndent)
				else
					lLines.push "- #{block}"
			result = toBlock(lLines)
		when 'hash','object'
			lLines = []
			lKeys = Object.keys(obj)
			if (sortKeys == true)
				lKeys.sort()
			else if isFunction(sortKeys)
				lKeys.sort(sortKeys)
			for key in lKeys
				val = obj[key]
				block = toNICE(val)
				if shouldSplit(jsType(val)[0])
					lLines.push "#{key}:"
					lLines.push indentBlock(block, 1, oneIndent)
				else
					lLines.push "#{key}: #{block}"
			result = toBlock(lLines)

	if delimit
		result = delimitBlock(result, {label, width})
	else if label
		result = "#{label}\n#{result}"

	if (indent != 0)
		if !Number.isInteger(indent)
			throw new Error("Bad indent: #{indent}")
		result = indentBlock(result, indent, oneIndent)
	return result
