# nice.coffee

import {
	undef, defined, notdefined, escapeStr, getOptions,
	jsType, toBlock, untabify, isInteger, OL,
	isArray, isBoolean, isFunction,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {indented} from '@jdeighan/base-utils/indent'
import {
	dbgEnter, dbgReturn, dbg,
	} from '@jdeighan/base-utils/debug'
import {parse} from '@jdeighan/base-utils/object'
import {pparse} from '@jdeighan/base-utils/peggy'

# ---------------------------------------------------------------------------

export needsQuotes = (str) =>

	dbgEnter 'needsQuotes', str

	# --- if it looks like an array item, it needs quotes
	if str.match(/^\s*-/)
		dbg "looks like array item"
		dbgReturn 'needsQuotes', true
		return true

	# --- if it looks like a hash key, it needs quotes
	if str.match(/^\s*\S+\s*:/)
		dbg "looks like hash key"
		dbgReturn 'needsQuotes', true
		return true

	# --- if it looks like a number, it needs quotes
	if str.match(/^\s*\d+(?:\.\d*)?/)
		dbg "looks like a number"
		dbgReturn 'needsQuotes', true
		return true

	dbgReturn 'needsQuotes', false
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

export toNICE = (obj, hOptions={}) =>

	dbgEnter 'toNICE', obj, hOptions
	{sortKeys, indent, oneIndent} = getOptions hOptions, {
		sortKeys: false    # --- can be boolean/array/function
		indent: 0          # --- integer number of levels
		oneIndent: "\t"
		}

	if isArray(sortKeys)
		# --- Convert to a function
		dbg "sortKeys is an array - convert to function"

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
		assert isBoolean(sortKeys) || isFunction(sortKeys),
				"sortKeys = #{OL(sortKeys)}"

	[type, subtype] = jsType(obj)
	dbg "type = #{OL(type)}, subtype = #{OL(subtype)}"
	switch type
		when 'function'
			if defined(subtype)
				result = "[Function #{subtype}]"
			else
				result = "[Function]"
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
					lLines.push indented(block, 1, oneIndent)
				else
					lLines.push "- #{block}"
			result = toBlock(lLines)
		when 'hash'
			lLines = []
			lKeys = Object.keys(obj)
			if (sortKeys == true)
				lKeys.sort()
			else if isFunction(sortKeys)
				lKeys.sort(sortKeys)
			dbg "SORTED: #{OL(lKeys)}"
			for key in lKeys
				val = obj[key]
				block = toNICE(val)
				if shouldSplit(jsType(val)[0])
					lLines.push "#{key}:"
					lLines.push indented(block, 1, oneIndent)
				else
					lLines.push "#{key}: #{block}"
			result = toBlock(lLines)
		when 'object'
			if defined(subtype)
				result = "[Object #{subtype}]"
			else
				result = "[Object]"

	if (indent != 0)
		assert isInteger(indent, {min: 1}),
			"Bad indent option: #{OL(indent)}"
		result = indented(result, indent, oneIndent)
	dbgReturn 'toNICE', result
	return result

# ---------------------------------------------------------------------------

export fromNICE = (block) =>

	dbgEnter 'fromNICE', block
	result = pparse(parse, block)
	dbgReturn 'fromNICE', result
	return result
