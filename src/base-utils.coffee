# base-utils.coffee

import assert from 'node:assert/strict'

`export const undef = void 0`

# ---------------------------------------------------------------------------

export isHashComment = (line) ->

	return line.match(/^\s*\#($|\s)/)

# ---------------------------------------------------------------------------
#   pass - do nothing

export pass = () =>

	return true

# ---------------------------------------------------------------------------

export defined = (obj) =>

	return (obj != undef) && (obj != null)

# ---------------------------------------------------------------------------

export notdefined = (obj) =>

	return (obj == undef) || (obj == null)

# ---------------------------------------------------------------------------

export spaces = (n) =>

	return " ".repeat(n)

# ---------------------------------------------------------------------------

export tabs = (n) =>

	return "\t".repeat(n)

# ---------------------------------------------------------------------------

export untabify = (str, numSpaces=3) =>

	return str.replace(/\t/g, ' '.repeat(numSpaces))

# ---------------------------------------------------------------------------

export oneof = (word, lWords...) ->

	return (lWords.indexOf(word) >= 0)

# ---------------------------------------------------------------------------

export prefixBlock = (block, prefix) =>

	lLines = for line in blockToArray(block)
		"#{prefix}#{line}"
	return arrayToBlock(lLines)

# ---------------------------------------------------------------------------
#   deepCopy - deep copy an array or object

export deepCopy = (obj) ->

	if (obj == undef)
		return undef
	objStr = JSON.stringify(obj)
	try
		newObj = JSON.parse(objStr)
	catch err
		throw new Error("ERROR: err.message")

	return newObj

# ---------------------------------------------------------------------------
# --- a replacer is (key, value) -> newvalue

myReplacer = (name, value) ->

	if (value == undef)
		return undef
	else if (value == null)
		return null
	else if isString(value)
		return escapeStr(value)
	else if (typeof value == 'function')
		return "[Function: #{value.name}]"
	else
		return value

# ---------------------------------------------------------------------------

export OL = (obj) ->

	if defined(obj)
		if isString(obj)
			return quoted(obj, 'escape')
		else
			return JSON.stringify(obj, myReplacer)
	else if (obj == null)
		return 'null'
	else
		return 'undef'

# ---------------------------------------------------------------------------

export OLS = (lObjects, sep=',') ->

	assert isArray(lObjects), "not an array"
	lParts = []
	for obj in lObjects
		lParts.push OL(obj)
	return lParts.join(sep)

# ---------------------------------------------------------------------------

export quoted = (str, escape=undef) =>

	assert isString(str), "not a string"
	switch escape
		when 'escape'
			str = escapeStr(str)
		when 'escapeNoNL'
			str = escapeStr(str, hEscNoNL)
		else
			pass

	if ! hasChar(str, "'")
		return "'" + str + "'"
	if ! hasChar(str, '"')
		return '"' + str + '"'
	return '<' + str + '>'

# ---------------------------------------------------------------------------
#   escapeStr - escape newlines, TAB chars, etc.

export hEsc = {
	"\n": '®'
	"\t": '→'
	" ": '˳'
	}
export hEscNoNL = {
	"\t": '→'
	" ": '˳'
	}

export escapeStr = (str, hReplace=hEsc) ->
	# --- hReplace can also be a string:
	#        'esc'     - escape space, newline, tab
	#        'escNoNL' - escape space, tab

	if isString(hReplace)
		switch hReplace
			when 'esc'
				hReplace = hEsc
			when 'escNoNL'
				hReplace = hExcNoNL
			else
				throw new Error("Invalid hReplace string value")

	assert isString(str), "escapeStr(): not a string"
	lParts = for ch in str.split('')
		if defined(hReplace[ch]) then hReplace[ch] else ch
	return lParts.join('')

# ---------------------------------------------------------------------------

export hasChar = (str, ch) =>

	return (str.indexOf(ch) >= 0)

# ---------------------------------------------------------------------------
#   unescapeStr - unescape newlines, TAB chars, etc.

export hUnesc = {
	'®': "\n"
	'→': "\t"
	'˳': " "
	}

export unescapeStr = (str, hReplace=hUnesc) ->

	return escapeStr(str, hReplace)

# ---------------------------------------------------------------------------

export inList = (item, lStrings...) =>

	return (lStrings.indexOf(item) >= 0)

# ---------------------------------------------------------------------------

export isString = (x) =>

	return (typeof x == 'string') || (x instanceof String)

# ---------------------------------------------------------------------------

export isNonEmptyString = (x) =>

	return isString(x) && ! x.match(/^\s*$/)

# ---------------------------------------------------------------------------

export isIdentifier = (x) =>

	return !! (isString(x) && x.match(///^
			[A-Za-z_]
			[A-Za-z0-9_]*
			$///))

# ---------------------------------------------------------------------------

export isFunctionName = (x) =>

	if isString(x) && lMatches = x.match(///^
			( [A-Za-z_] [A-Za-z0-9_]* )
			(?:
				\.             # allow class method names
				( [A-Za-z_] [A-Za-z0-9_]* )
				)?
			$///)
		[_, first, second] = lMatches
		if nonEmpty(second)
			return [first, second]
		else
			return [first]
	else
		return undef

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
		if isString(lKeys)
			lKeys = words(lKeys)
		else if ! isArray(lKeys)
			throw new Error("lKeys not an array: #{OL(lKeys)}")
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

	return (typeof f == 'function') \
		&& !!f.prototype \
		&& (f.prototype.constructor == f)

# ---------------------------------------------------------------------------

export isFunction = (x) ->

	return typeof x == 'function'

# ---------------------------------------------------------------------------

export isIterable = (obj) ->

	if (obj == undef) || (obj == null)
		return false
	return (typeof obj[Symbol.iterator] == 'function')

# ---------------------------------------------------------------------------

export isRegExp = (x) ->

	return x instanceof RegExp

# ---------------------------------------------------------------------------

export isObject = (x, lReqKeys=undef) ->

	if (typeof x != 'object') \
			|| isString(x) \
			|| isArray(x) \
			|| isHash(x) \
			|| isNumber(x)
		return false

	if defined(lReqKeys)
		if isString(lReqKeys)
			lReqKeys = words(lReqKeys)
		assert isArray(lReqKeys), "lReqKeys not an array: #{OL(lReqKeys)}"
		for key in lReqKeys
			type = undef
			if lMatches = key.match(///^ (\&) (.*) $///)
				[_, type, key] = lMatches
			if notdefined(x[key])
				return false
			if (type == '&') && (typeof x[key] != 'function')
				return false
	return true

# ---------------------------------------------------------------------------

export isScalar = (x) ->

	return isNumber(x) || isString(x) || isBoolean(x)

# ---------------------------------------------------------------------------

export jsType = (x) ->

	if (x == null)
		return [undef, 'null']
	else if (x == undef)
		return [undef, 'undef']
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
		if x
			return ['boolean', 'true']
		else
			return ['boolean', 'false']
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

	if notdefined(x)
		return false
	if isString(x)
		return ! x.match(/^\s*$/)
	if isArray(x)
		return x.length > 0
	if isHash(x)
		return Object.keys(x).length > 0
	else
		return defined(x)

# ---------------------------------------------------------------------------
#   blockToArray - split a block into lines

export blockToArray = (block) ->

	if (block == undef) || (block == '')
		return []
	else
		assert isString(block), "block is #{OL(block)}"
		lLines = block.split(/\r?\n/)
		return lLines

# ---------------------------------------------------------------------------

export toArray = (item) ->

	if isArray(item)
		# --- We need to split any strings containing a \n
		lLines = []
		for line in item
			if hasChar(line, "\n")
				for str in line.split(/\r?\n/)
					lLines.push str
			else
				lLines.push line
		return lLines
	else
		return blockToArray(item)

# ---------------------------------------------------------------------------
#   arrayToBlock - block and lines in block will have no trailing whitespace

export arrayToBlock = (lLines, hEsc=undef) ->

	if (lLines == undef)
		return ''
	assert isArray(lLines), "lLines is not an array"
	lResult = []
	for line in lLines
		if defined(line)
			lResult.push rtrim(line)
	if lResult.length == 0
		return ''
	else
		result = lResult.join("\n")
		if defined(hEsc)
			result = escapeStr(result, hEsc)
		return result

# ---------------------------------------------------------------------------

export toBlock = (item) ->

	if isString(item)
		return item
	else
		return arrayToBlock(item)

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
	if defined(lMatches)
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

export words = (lStrings...) ->

	lWords = []
	for str in lStrings
		str = str.trim()
		if (str != '')
			for word in str.split(/\s+/)
				lWords.push word
	return lWords

# ---------------------------------------------------------------------------

export firstWord = (str) =>

	pos = str.indexOf(' ')
	if (pos == -1)
		return str
	else
		return str.substring(0, pos)

# ---------------------------------------------------------------------------

export getOptions = (options=undef, hDefault={}) ->

	[type, subtype] = jsType(options)
	switch type
		when undef
			hOptions = {}
		when 'hash'
			hOptions = options
		when 'string'
			hOptions = hashFromString(options)
		else
			throw new Error("options not hash or string: #{OL(options)}")

	# --- Fill in defaults for missing values
	for own key,value of hDefault
		if ! hOptions.hasOwnProperty(key)
			hOptions[key] = value

	return hOptions

# ---------------------------------------------------------------------------

export hashFromString = (str) ->

	assert isString(str), "not a string: #{OL(str)}"
	h = {}
	for word in words(str)
		if lMatches = word.match(///^
				(\!)?                    # negate value
				([A-Za-z][A-Za-z_0-9]*)  # identifier
				(?:
					(=)
					(.*)
					)?
				$///)
			[_, neg, ident, eq, str] = lMatches
			if nonEmpty(eq)
				assert isEmpty(neg), "negation with string value"

				# --- TO DO: interpret backslash escapes
				h[ident] = str
			else if neg
				h[ident] = false
			else
				h[ident] = true
		else
			throw new Error("Invalid word #{OL(word)}")
	return h

# ---------------------------------------------------------------------------

export range = (n) ->

	return [0..n-1]

# ---------------------------------------------------------------------------

export warn = (msg) =>

	console.log "WARNING: #{msg}"
	return
