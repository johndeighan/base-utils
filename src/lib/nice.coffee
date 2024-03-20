# nice.coffee

import {
	undef, defined, notdefined, escapeStr, getOptions,
	jsType, toBlock,
	} from '@jdeighan/base-utils'
import {indented} from '@jdeighan/base-utils/indent'
import {
	dbgEnter, dbgReturn, dbg,
	} from '@jdeighan/base-utils/debug'
import {parse} from '@jdeighan/base-utils/object'

# ---------------------------------------------------------------------------
# --- There are 3 types of quotes:
#        " - double quotes
#        ' - single quotes (i.e. apostrophe)
#        « (ALT+0171) » (ALT+0187)

export formatString = (str) =>

	hEsc = {
		" ": '˳'
		"\t": '→'
		"\r": '◄'
		"\n": '▼'
		}
	if str.includes("'")
		if str.includes('"')
			hEsc["«"] = "\\«"
			hEsc["»"] = "\\»"
			return "«" + escapeStr(str, hEsc) + "»"
		else
			return '"' + escapeStr(str, hEsc) + '"'
	else
		return "'" + escapeStr(str, hEsc) + "'"

# ---------------------------------------------------------------------------

export shouldSplit = (type) =>

	return ['hash','array','class','object'].includes(type)

# ---------------------------------------------------------------------------

export toNICE = (obj, hOptions={}) =>

	dbgEnter 'toNICE', obj, hOptions
	{untabify} = getOptions hOptions, {
		untabify: false
		}

	[type, subtype] = jsType(obj)
	switch type
		when undef
			if (subtype == 'null')
				result = 'null'
			else
				result = 'undef'
		when 'number', 'bigint'
			if (subtype == 'NaN')
				result = 'NaN'
			else
				result = obj.toString()
		when 'string'
			result = formatString(obj)
		when 'boolean'
			if obj
				result = 'true'
			else
				result = 'false'
		when 'function'
			if defined(subtype)
				result = "[Function #{subtype}]"
			else
				result = "[Function]"
		when 'array'
			lLines = []
			for item in obj
				block = toNICE(item)
				if shouldSplit(jsType(item)[0])
					lLines.push '-'
					lLines.push indented(block)
				else
					lLines.push "- #{block}"
			result = toBlock(lLines)
		when 'hash'
			lLines = []
			for key,val of obj
				block = toNICE(val)
				if shouldSplit(jsType(val)[0])
					lLines.push "#{key}:"
					lLines.push indented(block)
				else
					lLines.push "#{key}: #{block}"
			result = toBlock(lLines)
		when 'object'
			result = "[Object]"

	dbgReturn 'toNICE', result
	return result

# ---------------------------------------------------------------------------

export fromNICE = (block) =>

	dbgEnter 'fromNICE', block
	result = parse(block)
	dbgReturn 'fromNice', result
	return result
