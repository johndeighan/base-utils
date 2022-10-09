# utils.coffee

import yaml from 'js-yaml'

import {assert, croak} from '@jdeighan/exceptions'

`export const undef = undefined`
export sep_dash = '-'.repeat(42)
export sep_eq = '='.repeat(42)

# ---------------------------------------------------------------------------
#   pass - do nothing

export pass = () ->

# ---------------------------------------------------------------------------

export defined = (obj) =>

	return (obj != undef) && (obj != null)

# ---------------------------------------------------------------------------

export notdefined = (obj) =>

	return (obj == undef) || (obj == null)

# ---------------------------------------------------------------------------

export untabify = (str) =>

	return str.replace(/\t/g, ' '.repeat(3))

# ---------------------------------------------------------------------------
# --- a replacer is (key, value) -> newvalue

myReplacer = (name, value) ->

	if isString(value)
		return escapeStr(value)
	else if isObject(value, ['tamlReplacer'])
		return value.tamlReplacer()
	else
		return value

# ---------------------------------------------------------------------------
# --- export only to allow unit tests

export toTAML = (obj, hOptions={}) ->

	{useTabs, sortKeys, escape, replacer} = hOptions
	if notdefined(replacer)
		replacer = myReplacer
	str = yaml.dump(obj, {
		skipInvalid: true
		indent: 3
		sortKeys: !!sortKeys
		lineWidth: -1
		replacer
		})
	if useTabs
		str = str.replace(/   /g, "\t")
	return "---\n" + chomp(str)

# ---------------------------------------------------------------------------
#   escapeStr - escape newlines, TAB chars, etc.

export hDefEsc = {
	"\n": '®'
	"\t": '→'
	" ": '˳'
	}

export escapeStr = (str, hEscape=hDefEsc) ->

	assert isString(str), "escapeStr(): not a string"
	lParts = for ch in str.split('')
		if hEscape[ch]? then hEscape[ch] else ch
	return lParts.join('')

# ---------------------------------------------------------------------------

export OL = (obj) ->

	if defined(obj)
		if isString(obj)
			return "'#{escapeStr(obj)}'"
		else
			return JSON.stringify(obj)
	else
		return 'undef'

# ---------------------------------------------------------------------------

export jsType = (x) ->

	if notdefined(x)
		return [undef, undef]
	else if isString(x)
		if x.match(/^\s*$/)
			return ['string', 'empty']
		else
			return ['string', undef]
	else if isNumber(x)
		if Number.isInteger(x)
			return ['number', 'integer']
		else
			return ['number', undef]
	else if isBoolean(x)
		return ['boolean', undef]
	else if isHash(x)
		lKeys = Object.keys(x);
		if (lKeys.length == 0)
			return ['hash', 'empty']
		else
			return ['hash', undef]
	else if isArray(x)
		if (x.length == 0)
			return ['array', 'empty']
		else
			return ['array', undef]
	else if isRegExp(x)
		return ['regexp', undef]
	else if isConstructor(x)
		return ['function', 'constructor']
	else if isFunction(x)
		return ['function', undef]
	else if isObject(x)
		return ['object', undef]
	else
		throw new Error("Unknown type: #{OL(x)}")

# ---------------------------------------------------------------------------

export isString = (x) =>

	return (typeof x == 'string') || (x instanceof String)

# ---------------------------------------------------------------------------

export isNumber = (x, hOptions=undef) ->

	result = (typeof x == 'number') || (x instanceof Number)
	if result && defined(hOptions)
		if ! isHash(hOptions)
			LOG "2nd arg not a hash: #{OL(hOptions)}"
			process.exit()
		{min, max} = hOptions
		if defined(min) && (x < min)
			result = false
		if defined(max) && (x > max)
			result = false
	return result

# ---------------------------------------------------------------------------

export isInteger = (x, hOptions={}) ->

	if (typeof x == 'number')
		result = Number.isInteger(x)
	else if (x instanceof Number)
		result = Number.isInteger(x.valueOf())
	else
		result = false

	if result
		if defined(hOptions.min) && (x < hOptions.min)
			result = false
		if defined(hOptions.max) && (x > hOptions.max)
			result = false
	return result

# ---------------------------------------------------------------------------

export getClassName = (obj) ->

	if (typeof obj != 'object')
		return undef
	return obj.constructor.name

# ---------------------------------------------------------------------------

export isHash = (x, lKeys) ->

	if ! x || (getClassName(x) != 'Object')
		return false
	if defined(lKeys)
		if ! isArray(lKeys)
			LOG "isHash(): lKeys not an array"
			process.exit()
		for key in lKeys
			if ! x.hasOwnProperty(key)
				return false
	return true

# ---------------------------------------------------------------------------

export isArray = (x) ->

	return Array.isArray(x)

# ---------------------------------------------------------------------------

export isBoolean = (x) ->

	return typeof x == 'boolean'

# ---------------------------------------------------------------------------

export isConstructor = (f) ->

	try
		new f()
	catch err
		if (err.message.indexOf('is not a constructor') >= 0)
			return false
	return true

# ---------------------------------------------------------------------------

export isFunction = (x) ->

	return typeof x == 'function'

# ---------------------------------------------------------------------------

export isRegExp = (x) ->

	return x instanceof RegExp

# ---------------------------------------------------------------------------

export isObject = (x, lReqKeys=undef) ->

	result = (typeof x == 'object') \
			&& ! isString(x) \
			&& ! isArray(x) \
			&& ! isHash(x) \
			&& ! isNumber(x)
	if result
		if defined(lReqKeys)
			if ! isArray(lReqKeys)
				LOG "lReqKeys is not an array"
				process.exit()
			for key in lReqKeys
				if ! x.hasOwnProperty(key)
					return false
		return true
	else
		return false

# ---------------------------------------------------------------------------
# This is useful for debugging

export LOG = (lArgs...) ->

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
#   isEmpty
#      - string is whitespace, array has no elements, hash has no keys

export isEmpty = (x) ->

	if (x == undef) || (x == null)
		return true
	if isString(x)
		return x.match(/^\s*$/)
	if isArray(x)
		return x.length == 0
	if isHash(x)
		return Object.keys(x).length == 0
	else
		return false

# ---------------------------------------------------------------------------
#   nonEmpty
#      - string has non-whitespace, array has elements, hash has keys

export nonEmpty = (x) ->

	if ! x?
		return false
	if isString(x)
		return ! x.match(/^\s*$/)
	if isArray(x)
		return x.length > 0
	if isHash(x)
		return Object.keys(x).length > 0
	else
		croak "isEmpty(): Invalid parameter"

# ---------------------------------------------------------------------------
#   blockToArray - split a block into lines

export blockToArray = (block) ->

	if (block == undef) || (block == '')
		return []
	else
		lLines = block.split(/\r?\n/)

		# --- remove trailing empty lines
		len = lLines.length
		while (len > 0) && isEmpty(lLines[len-1])
			lLines.pop()
			len -= 1
		return lLines

# ---------------------------------------------------------------------------
#   arrayToBlock - block and lines in block will have no trailing whitespace

export arrayToBlock = (lLines) ->

	if (lLines == undef)
		return undef
	assert isArray(lLines), "lLines is not an array"
	lLines = lLines.filter((line) => defined(line));
	if lLines.length == 0
		return undef
	else
		return rtrim(lLines.join('\n'))

# ---------------------------------------------------------------------------

export chomp = (str) ->

	len = str.length
	if (len == 0)
		return ''
	else if (len == 1)
		if (str == "\r") || (str == "\n")
			return ''
		else
			return str
	else
		# --- check the last 2 characters
		tail = str.substring(len-2)
		if (tail == "\r\n")
			return str.substring(0, len-2)
		else
			tail = str.substring(len-1)
			if (tail == "\n")
				return str.substring(0, len-1)
			else
				return str

# ---------------------------------------------------------------------------
#   rtrim - strip trailing whitespace

export rtrim = (line) ->

	assert isString(line), "rtrim(): line is not a string"
	lMatches = line.match(/\s+$/)
	if lMatches?
		n = lMatches[0].length   # num chars to remove
		return line.substring(0, line.length - n)
	else
		return line

# ---------------------------------------------------------------------------

export setCharsAt = (str, pos, str2) ->

	assert (pos >= 0), "negative pos #{pos} not allowed"
	assert (pos < str.length), "pos #{pos} not in #{OL(str)}"
	if (pos + str2.length >= str.length)
		return str.substring(0, pos) + str2
	else
		return str.substring(0, pos) + str2 + str.substring(pos + str2.length)

# ---------------------------------------------------------------------------

export words = (str) ->

	str = str.trim()
	if (str == '')
		return []
	return str.split(/\s+/)
