# base-utils.coffee

import {execSync} from 'child_process'
import assertLib from 'node:assert'

# --- ABSOLUTELY NO IMPORTS FROM OUR LIBS !!!!!

`export const undef = void 0`

# ---------------------------------------------------------------------------

export LOG = (lItems...) =>

	lSimpleItems = []
	for item in lItems
		if isHash(item) || isArray(item)
			if (lSimpleItems.length > 0)
				console.log lSimpleItems...
				lSimpleItems = []
			console.dir item, {depth: null}
		else
			lSimpleItems.push item
	if (lSimpleItems.length > 0)
		console.log lSimpleItems...
	return

# ---------------------------------------------------------------------------
# low-level version of assert()

export assert = (cond, msg) =>

	if !cond
		throw new Error(msg)
	return true

# ---------------------------------------------------------------------------
# low-level version of croak()

export croak = (msg) =>

	throw new Error(msg)
	return true

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

export alldefined = (lObj...) =>

	for obj in lObj
		if (obj == undef) || (obj == null)
			return false
	return true

# ---------------------------------------------------------------------------

export chomp = (str) =>
	# --- Remove trailing \n if present

	len = str.length
	if (str[len-1] == '\n')
		if (str[len-2] == '\r')
			return str.substring(0, len-2)
		else
			return str.substring(0, len-1)
	else
		return str

# ---------------------------------------------------------------------------
#   isEmpty
#      - string is whitespace, array has no elements, hash has no keys

export isEmpty = (x) =>

	if (x == undef) || (x == null)
		return true
	if (typeof x == 'string')
		return x.match(/^\s*$/)
	if Array.isArray(x)
		return (x.length == 0)
	if (typeof x == 'object')
		return Object.keys(x).length == 0
	else
		return false

# ---------------------------------------------------------------------------
#   nonEmpty
#      - string has non-whitespace, array has elements, hash has keys

export nonEmpty = (x) =>

	return ! isEmpty(x)

# ---------------------------------------------------------------------------
#   deepCopy - deep copy an array or object

export deepCopy = (obj) =>

	if (obj == undef)
		return undef
	objStr = JSON.stringify(obj)
	try
		newObj = JSON.parse(objStr)
	catch err
		throw new Error("ERROR: err.message")

	return newObj

# ---------------------------------------------------------------------------

export add_s = (n) =>

	if (n == 1)
		return ''
	else
		return 's'

# ---------------------------------------------------------------------------

export keys = (lHashes...) =>

	lKeys = []
	for h in lHashes
		for key in Object.keys(h)
			if ! lKeys.includes(key)
				lKeys.push key
	return lKeys

# ---------------------------------------------------------------------------

export hasKey = (obj, key) =>

	return obj.hasOwnProperty(key)

# ---------------------------------------------------------------------------
# --- Removes key, but returns associated value

export extractKey = (h, key) =>

	assert isHash(h), "not a hash"
	assert isString(key), "key not a string"
	val = h[key]     # might be undef
	delete h[key]
	return val

# ---------------------------------------------------------------------------

export hasAllKeys = (obj, lKeys...) =>

	for key in lKeys
		if ! hasKey(obj, key)
			return false
	return true

# ---------------------------------------------------------------------------

export hasAnyKey = (obj, lKeys...) =>

	for key in lKeys
		if hasKey(obj, key)
			return true
	return false

# ---------------------------------------------------------------------------

export addNewKey = (h, key, value) ->

	assert !hasKey(h, key), "hash has key #{key}"
	h[key] = value
	return h

# ---------------------------------------------------------------------------

export subkeys = (obj) =>

	lSubKeys = []
	for key in keys(obj)
		h = obj[key]
		for subkey in keys(h)
			if !lSubKeys.includes(subkey)
				lSubKeys.push subkey
	return lSubKeys

# ---------------------------------------------------------------------------

export samelist = (lItems1, lItems2) =>

	assert isArray(lItems1), "arg 1 not an array"
	assert isArray(lItems2), "arg 2 not an array"
	if (lItems1.length != lItems2.length)
		return false
	for item in lItems1
		if ! lItems2.includes item
			return false
	for item in lItems2
		if ! lItems1.includes item
			return false
	return true


# ---------------------------------------------------------------------------

export fromJSON = (strJson) =>
	# --- string to data structure

	return JSON.parse(strJson)

# ---------------------------------------------------------------------------

export toJSON = (hJson, hOptions={}) =>
	# --- data structure to string

	{useTabs, replacer} = getOptions hOptions, {
		useTabs: true
		replacer: undef
		}
	if useTabs
		return JSON.stringify(hJson, replacer, "\t")
	else
		return JSON.stringify(hJson, replacer, 3)

# ---------------------------------------------------------------------------

export runCmd = (cmd) =>

	result = execSync cmd, {
		stdio: 'pipe'
		windowsHide: true
		encoding: 'utf8'
		}
	return result || "<STDOUT>"

# ---------------------------------------------------------------------------

export deepEqual = (a, b) =>

	try
		assertLib.deepEqual(a, b)
	catch error
		if (error.name == "AssertionError")
			return false
		throw error
	return true

# ---------------------------------------------------------------------------

export isHashComment = (line) =>
	# --- true if:
	#        - 1st non-ws char is a '#'
	#        - '#' is either followed by a ws char or by nothing

	lMatches = line.match(///^
			(\s*)
			\#
			(\s*)
			(.*)
			$///)
	if defined(lMatches)
		[_, prefix, ws, text] = lMatches
		if (text.length == 0)
			return {prefix, ws, text: ''}
		else if (ws.length > 0)
			return {prefix, ws, text: text.trim()}
		else
			return undef
	else
		return undef

# ---------------------------------------------------------------------------

export spaces = (n) =>

	return " ".repeat(n)

# ---------------------------------------------------------------------------

export tabs = (n) =>

	return "\t".repeat(n)

# ---------------------------------------------------------------------------

export centeredText = (text, width) =>

	totSpaces = width - text.length
	if (totSpaces <= 0)
		return text
	numLeft = Math.floor(totSpaces / 2)
	numRight = totSpaces - numLeft
	return spaces(numLeft) + text + spaces(numRight)

# ---------------------------------------------------------------------------
#   rtrunc - strip nChars chars from right of a string

export rtrunc = (str, nChars) =>

	return str.substring(0, str.length - nChars)

# ---------------------------------------------------------------------------
#   ltrunc - strip nChars chars from left of a string

export ltrunc = (str, nChars) =>

	return str.substring(nChars)

# ---------------------------------------------------------------------------

export CWS = (str) =>

	assert isString(str), "CWS(): parameter not a string"
	return str.trim().replace(/\s+/sg, ' ')

# ---------------------------------------------------------------------------

export splitPrefix = (line) =>

	assert isString(line), "non-string #{OL(line)}"
	line = rtrim(line)
	lMatches = line.match(/^(\s*)(.*)$/)
	return [lMatches[1], lMatches[2]]

# ---------------------------------------------------------------------------

export hasPrefix = (line) =>

	assert isString(line), "non-string #{OL(line)}"
	lMatches = line.match(/^(\s*)/)
	return (lMatches[1].length > 0)

# ---------------------------------------------------------------------------
#    tabify - convert leading spaces to TAB characters
#             if numSpaces is not defined, then the first line
#             that contains at least one space sets it
# --- Works on both blocks and arrays - returns same kind of item

export tabify = (item, numSpaces=undef) =>

	lLines = []
	for str in toArray(item)
		[prefix, theRest] = splitPrefix(str)
		prefixLen = prefix.length
		if prefixLen == 0
			lLines.push theRest
		else
			assert (prefix.indexOf('\t') == -1), "found TAB"
			if numSpaces == undef
				numSpaces = prefixLen
			assert (prefixLen % numSpaces == 0), "Bad prefix"
			level = prefixLen / numSpaces
			lLines.push '\t'.repeat(level) + theRest
	if isArray(item)
		result = item
	else
		result = toBlock(lLines)
	return result

# ---------------------------------------------------------------------------

export untabify = (str, numSpaces=3) =>

	return str.replace(/\t/g, ' '.repeat(numSpaces))

# ---------------------------------------------------------------------------

export forEachLine = (item, func) =>
	# --- callback to func() gets arguments:
	#        line - each line
	#        hInfo - with keys lineNum and nextLine
	# Return value should be:
	#    true - to stop prematurely
	#    false - to continue

	lInput = toArray(item)
	for line,i in lInput
		result = func(line, {
			lineNum: i+1
			nextLine: lInput[i+1]
			})
		assert isBoolean(result), "result must be a boolean, got #{OL(result)}"
		if result   # return of true causes premature exit
			return
	return

# ---------------------------------------------------------------------------

export mapEachLine = (item, func) =>
	# --- callback to func() gets arguments:
	#        line - each line
	#        hInfo - with keys lineNum and nextLine
	#     callback return value should be:
	#        undef - to skip this line
	#        else value to include

	lLines = []    # return value
	lInput = toArray(item)
	for line,i in lInput
		result = func(line, {
			lineNum: i+1
			nextLine: lInput[i+1]
			})
		if defined(result)
			lLines.push result
	if isArray(item)
		return lLines
	else
		return toBlock(lLines)

# ---------------------------------------------------------------------------
# --- a replacer is (key, value) -> newvalue

myReplacer = (name, value) =>

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

export OL = (obj) =>

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

export OLS = (lObjects, sep=',') =>

	assert isArray(lObjects), "not an array"
	lParts = []
	for obj in lObjects
		lParts.push OL(obj)
	return lParts.join(sep)

# ---------------------------------------------------------------------------

export qStr = (x) =>
	# --- x must be string or undef
	#     puts quotes around a string

	if notdefined(x)
		return 'undef'
	else if isString(x)
		return "'#{x}'"
	else
		throw new Error("quoteStr(): Not a string or undef")

# ---------------------------------------------------------------------------

export quoted = (str, escape=undef) =>

	assert isString(str), "not a string: #{str}"
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
#   escapeStr - escape newlines, carriage return, TAB chars, etc.

export hEsc = {
	"\r": '◄'
	"\n": '▼'
	"\t": '→'
	" ": '˳'
	}
export hEscNoNL = {
	"\t": '→'
	" ": '˳'
	}

export escapeStr = (str, hReplace=hEsc) =>
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

export oneof = (word, lWords...) =>

	return (lWords.indexOf(word) >= 0)

# ---------------------------------------------------------------------------
# see: https://stackoverflow.com/questions/40922531/how-to-check-if-a-javascript-function-is-a-constructor

myHandler = {
	construct: () ->
		return myHandler
	} # Must return ANY object, so reuse one

export isConstructor = (x) =>
	if (typeof x != 'function')
		return false
	try
		return !!(new (new Proxy(x, myHandler))())
	catch e
		return false

# ---------------------------------------------------------------------------

export jsType = (x) =>
	# --- return [type, subtype]

	if (x == null)
		return [undef, 'null']
	else if (x == undef)
		return [undef, undef]

	switch (typeof x)
		when 'number'
			if Number.isNaN(x)
				return ['number', 'NaN']
			else if Number.isInteger(x)
				return ['number', 'integer']
			else
				return ['number', undef]
		when 'string'
			if x.match(/^\s*$/)
				return ['string', 'empty']
			else
				return ['string', undef]
		when 'boolean'
			return ['boolean', undef]
		when 'bigint'
			return ['number', 'integer']
		when 'function'
			if x.prototype && (x.prototype.constructor == x)
				return ['class', undef]
			else
				return ['function', x.name || undef]
		when 'object'
			if (x instanceof String)
				if x.match(/^\s*$/)
					return ['string', 'empty']
				else
					return ['string', undef]
			if (x instanceof Number)
				if Number.isInteger(x)
					return ['number', 'integer']
				else
					return ['number', undef]
			if (x instanceof Boolean)
				return ['boolean', undef]
			if Array.isArray(x)
				if (x.length == 0)
					return ['array', 'empty']
				else
					return ['array', undef]
			if (x instanceof RegExp)
				return ['regexp', undef]
			if (x instanceof Function)
				if x.prototype && (x.prototype.constructor == x)
					return ['class', undef]
				else
					return ['function', x.name || undef]
			if defined(x.constructor.name) \
					&& (typeof x.constructor.name == 'string') \
					&& (x.constructor.name == 'Object')
				lKeys = keys(x)
				if (lKeys.length == 0)
					return ['hash', 'empty']
				else
					return ['hash', undef]
			else
				return ['object', undef]
		else
			throw new Error ("Unknown jsType: #{x}")

# ---------------------------------------------------------------------------

export isString = (x) =>

	return (jsType(x)[0] == 'string')

# ---------------------------------------------------------------------------

export isNonEmptyString = (x) =>

	return isString(x) && ! x.match(/^\s*$/)

# ---------------------------------------------------------------------------

export isNonEmptyArray = (x) =>

	return isArray(x) && (x.length > 0)

# ---------------------------------------------------------------------------

export isNonEmptyHash = (x) =>

	return isHash(x) && (keys(x).length > 0)

# ---------------------------------------------------------------------------

export isIdentifier = (x) =>

	if ! isString(x)
		return false
	return x.match(///^
			[A-Za-z_]
			[A-Za-z0-9_]*
			$///)

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

export isNumber = (x, hOptions=undef) =>

	if (jsType(x)[0] != 'number')
		return false
	if defined(hOptions)
		assert isHash(hOptions), "2nd arg not a hash: #{OL(hOptions)}"
		{min, max} = hOptions
		if defined(min) && (x < min)
			return false
		if defined(max) && (x > max)
			return false
	return true

# ---------------------------------------------------------------------------

export isInteger = (x, hOptions={}) =>

	if (typeof x == 'number')
		result = Number.isInteger(x)
	else if (x instanceof Number)
		result = Number.isInteger(x.valueOf())
	else
		return false

	if result
		if defined(hOptions.min) && (x < hOptions.min)
			result = false
		if defined(hOptions.max) && (x > hOptions.max)
			result = false
	return result

# ---------------------------------------------------------------------------

export isArray = (x) =>

	return (jsType(x)[0] == 'array')

# ---------------------------------------------------------------------------

export isArrayOfArrays = (lItems, size=undef) =>
	# --- undefined items are allowed

	if ! isArray(lItems)
		return false
	for item in lItems
		if defined(item)
			if ! isArray(item)
				return false
			if defined(size) && (item.length != size)
				return false
	return true

# ---------------------------------------------------------------------------

export isArrayOfHashes = (lItems) =>
	# --- undefined items are allowed

	if ! isArray(lItems)
		return false
	for item in lItems
		if defined(item) && ! isHash(item)
			return false
	return true

# ---------------------------------------------------------------------------

export isArrayOfStrings = (lItems) =>
	# --- undefined items are allowed

	if ! isArray(lItems)
		return false
	for item in lItems
		if defined(item) && ! isString(item)
			return false
	return true

# ---------------------------------------------------------------------------

export words = (lStrings...) =>

	lWords = []
	for str in lStrings
		str = str.trim()
		if (str != '')
			for word in str.split(/\s+/)
				lWords.push word
	return lWords

# ---------------------------------------------------------------------------

export isBoolean = (x) =>

	return (jsType(x)[0] == 'boolean')

# ---------------------------------------------------------------------------

export isFunction = (x) =>

	mtype = jsType(x)[0]
	return (mtype == 'function') || (mtype == 'class')

# ---------------------------------------------------------------------------

export isIterable = (obj) =>

	if (obj == undef) || (obj == null)
		return false
	return (typeof obj[Symbol.iterator] == 'function')

# ---------------------------------------------------------------------------

export isRegExp = (x) =>

	return (jsType(x)[0] == 'regexp')

# ---------------------------------------------------------------------------

export isHash = (x, lKeys) =>

	if (jsType(x)[0] != 'hash')
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

export removeKeys = (item, lKeys) =>

	assert isArray(lKeys), "not an array"
	[type, subtype] = jsType(item)
	switch type
		when 'array'
			for subitem in item
				removeKeys subitem, lKeys
		when 'hash', 'object'
			for key in lKeys
				if item.hasOwnProperty(key)
					delete item[key]
			for prop,value of item
				removeKeys value, lKeys
	return item

# ---------------------------------------------------------------------------

export isObject = (x, lReqKeys=undef) =>

	if (jsType(x)[0] != 'object')
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

export isClass = (x) =>

	return (jsType(x)[0] == 'class')

# ---------------------------------------------------------------------------

export className = (item) =>
	# --- item can be a class or an object

	if isClass(item)
		if lMatches = item.toString().match(/class\s+(\w+)/)
			return lMatches[1]
		else
			throw new Error("className(): Bad input class")
	else if isObject(item)
		return item.constructor.name
	else
		return undef

# ---------------------------------------------------------------------------

export isScalar = (x) =>

	return isNumber(x) || isString(x) || isBoolean(x)

# ---------------------------------------------------------------------------
#   blockToArray - split a block into lines

export blockToArray = (block) =>

	if (block == undef) || (block == '')
		return []
	else
		assert isString(block), "block is #{OL(block)}"
		lLines = block.split(/\r?\n/)
		return lLines

# ---------------------------------------------------------------------------
#   arrayToBlock - block and lines in block will have no trailing whitespace

export arrayToBlock = (lLines, hEsc=undef) =>

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

export toBlock = (item) =>

	if isString(item)
		return item
	else
		return arrayToBlock(item)

# ---------------------------------------------------------------------------

export toArray = (item) =>

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

export prefixBlock = (block, prefix) =>

	lLines = for line in toArray(block)
		"#{prefix}#{line}"
	return toBlock(lLines)

# ---------------------------------------------------------------------------
#   rtrim - strip trailing whitespace

export rtrim = (line) =>

	assert isString(line), "rtrim(): line is not a string"
	lMatches = line.match(/\s+$/)
	if defined(lMatches)
		n = lMatches[0].length   # num chars to remove
		return line.substring(0, line.length - n)
	else
		return line

# ---------------------------------------------------------------------------

export hashFromString = (str) =>

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

				# --- check if str is a valid number
				num = parseFloat(str)
				if Number.isNaN(num)
					# --- TO DO: interpret backslash escapes
					h[ident] = str
				else
					h[ident] = num
			else if neg
				h[ident] = false
			else
				h[ident] = true
		else
			throw new Error("Invalid word #{OL(word)}")
	return h

# ---------------------------------------------------------------------------

export getOptions = (options=undef, hDefault={}) =>

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

export range = (n) =>

	return [0..n-1]

# ---------------------------------------------------------------------------

export rev_range = (n) =>

	return [0..n-1].reverse()

# ---------------------------------------------------------------------------

export warn = (msg) =>

	console.log "WARNING: #{msg}"
	return

# ---------------------------------------------------------------------------

export uniq = (lItems) =>

	return [...new Set(lItems)]

# ---------------------------------------------------------------------------
#   say - print to the console (for now)
#         later, on a web page, call alert(str)

export say = (x) =>

	if isHash(x)
		LOG JSON.stringify(x, Object.keys(h).sort(), 3)
	else
		LOG x
	return

# ---------------------------------------------------------------------------

export extractMatches = (line, regexp, convertFunc=undef) =>

	lStrings = [...line.matchAll(regexp)]
	lStrings = for str in lStrings
		str[0]
	if defined(convertFunc)
		lConverted = for str in lStrings
			convertFunc(str)
		return lConverted
	else
		return lStrings

# ---------------------------------------------------------------------------

export getTimeStr = (date=undef) =>

	if date == undef
		date = new Date()
	return date.toLocaleTimeString('en-US')

# ---------------------------------------------------------------------------

export getDateStr = (date=undef) =>

	if date == undef
		date = new Date()
	return date.toLocaleDateString('en-US')

# ---------------------------------------------------------------------------

export timestamp = (dateStr=undef, locale='en-US') =>

	if defined(dateStr)
		date = new Date(dateStr)
	else
		date = new Date()
	str1 = date.toLocaleDateString(locale)
	str2 = date.toLocaleTimeString(locale)
	return "#{str1} #{str2}"

# ---------------------------------------------------------------------------

export msSinceEpoch = (dateStr=undef) =>

	if defined(dateStr)
		date = new Date(dateStr)
	else
		date = new Date()
	return date.getTime()

# ---------------------------------------------------------------------------

export formatDate = (dateStr=undef, dateStyle='medium', locale='en-US') =>

	if defined(dateStr)
		date = new Date(dateStr)
	else
		date = new Date()
	return new Intl.DateTimeFormat(locale, {dateStyle}).format(date)

# ---------------------------------------------------------------------------

export getDumpStr = (label, str, hOptions={}) =>
	# --- Valid options:
	#        escape - escape space & TAB chars
	#        width

	lLines = []
	{escape, width} = getOptions(hOptions, {
		escape: false
		width: 42
		})

	if isString(str)
		stringified = false
	else if defined(str)
		str = JSON.stringify(str, undef, 3)
		stringified = true
	else
		str = 'undef'
		stringified = true

	lLines.push '='.repeat(width)
	lLines.push centeredText(label, width)

	if stringified
		lLines.push '-'.repeat(width)
	else
		lLines.push '='.repeat(width)

	if escape
		lLines.push escapeStr(str, hEscNoNL)
	else
		lLines.push str.replace(/\t/g, "   ")
	lLines.push '='.repeat(width)
	return lLines.join("\n")

# ---------------------------------------------------------------------------

export eachCharInString = (str, func) =>

	for ch in Array.from(str)
		if !func(ch)
			return false
	return true

# ---------------------------------------------------------------------------

export DUMP = (label, obj, hOptions={}) =>

	assert isString(label), "no label"
	console.log getDumpStr(label, obj, hOptions)
	return

# ---------------------------------------------------------------------------
# in callback set():
#    - return undef to NOT set
#    - return value (possibly changed) to set
# in callback get():
#    - return (possibly changed) value
# ---------------------------------------------------------------------------

export getProxy = (obj, hCallbacks) =>
	# --- Keys in hFuncs can be: 'get','set'

	hHandlers = {}
	if hCallbacks.hasOwnProperty('set')
		hHandlers.set = (obj, prop, value) ->
			newval = hCallbacks.set(obj, prop, value)
			if defined(newval)   # don't set if callback returns false
				Reflect.set(obj, prop, newval)
			return true

	if hCallbacks.hasOwnProperty('get')
		hHandlers.get = (obj, prop) ->
			value = Reflect.get(obj, prop)
			return hCallbacks.get(obj, prop, value)

	if isEmpty(hHandlers)
		return obj
	else
		return new Proxy(obj, hHandlers)

# ---------------------------------------------------------------------------

export sleep = (secs) =>

	return new Promise((r) => setTimeout(r, 1000 * secs))

# ---------------------------------------------------------------------------

hTimers = {}    # { <id> => <timer>, ... }

export schedule = (secs, keyVal, func, lArgs...) =>

	assert isFunction(func), "not a function: #{OL(func)}"

	# --- if there's currently a timer with the same keyVal, kill it
	if defined(timer = hTimers[keyVal])
		clearTimeout timer
	hTimers[keyVal] = setTimeout(func, 1000 * secs, lArgs...)
	return

# ---------------------------------------------------------------------------

export hit = (pct) ->

	return Math.random() * 100 < pct

# ---------------------------------------------------------------------------

export choose = (lItems) ->

	return lItems[Math.floor(Math.random()*lItems.length)]

# ---------------------------------------------------------------------------
# --- shuffle an array in place, return ref to shuffled array

export shuffle = (lItems) ->

	i = lItems.length

	# --- While there remain elements to shuffle.
	while (i > 0)

		# --- Pick a remaining element.
		i2 = Math.floor(Math.random() * i)
		i -= 1

		# --- And swap it with the current element.
		[lItems[i], lItems[i2]] = [lItems[i2], lItems[i]];

	return lItems

# ---------------------------------------------------------------------------

export pad = (x, width, hOptions={}) =>
	# --- hOptions.justify can be 'left','center','right'

	{decPlaces, justify, truncate} = getOptions hOptions, {
		decPlaces: undef
		justify: undef
		truncate: false
		}
	[type, subtype] = jsType(x)
	switch type
		when undef
			str = 'undef'
			if notdefined(justify)
				justify = 'left'
		when 'string'
			str = x
			if notdefined(justify)
				justify = 'left'
		when 'boolean'
			if x
				str = 'true'
			else
				str = 'false'
			if notdefined(justify)
				justify = 'center'
		when 'number'
			if defined(decPlaces)
				str = x.toFixed(decPlaces)
			else if (subtype == 'integer')
				str = x.toString()
			else
				str = x.toFixed(2)
			if notdefined(justify)
				justify = 'right'
		when 'object'
			str = '[Object]'
			if notdefined(justify)
				justify = 'left'
		else
			croak "Invalid value: #{OL(x)}"

	toAdd = width - str.length
	if (toAdd == 0)
		return str
	else if (toAdd < 0)
		if truncate
			return str.substring(0, width)
		else
			return str

	switch justify
		when 'left'
			return str + ' '.repeat(toAdd)
		when 'center'
			lPad = Math.floor(toAdd / 2)
			rPad = toAdd - lPad
			return "#{' '.repeat(lPad)}#{str}#{' '.repeat(rPad)}"
		when 'right'
			return ' '.repeat(toAdd) + str
		else
			croak "Invalid value for justify: #{justify}"

# ---------------------------------------------------------------------------

export forEachItem = (iter, func, hContext={}) =>
	# --- func() gets (item, hContext)
	#        hContext includes key _index
	#     return value from func() is added to
	#        returned array if defined
	#     if func() throws
	#        thrown strings are interpreted as
	#           "stop" - stop the iteration
	#           any other string - an error
	#           non-string - is rethrown

	assert isIterable(iter), "not an iterable"
	lItems = []
	index = 0
	for item from iter
		hContext._index = index
		index += 1
		try
			result = func(item, hContext)
			if defined(result)
				lItems.push result
		catch err
			if isString(err)
				if (err == 'stop')
					return lItems
				else
					throw new Error("forEachItem: Bad throw '#{err}'")
			else
				throw err    # rethrow the error
	return lItems

# ---------------------------------------------------------------------------

export addToHash = (obj, lIndexes, value) =>

	# --- Allow passing a simple string or integer
	if isString(lIndexes) || isInteger(lIndexes)
		lIndexes = [lIndexes]
	else
		assert isArray(lIndexes), "Bad indexes: #{OL(lIndexes)}"

	assert nonEmpty(lIndexes), "empty lIndexes"
	key = lIndexes.pop()

	subobj = obj
	for index in lIndexes
		if defined(obj[index])
			subobj = subobj[index]
		else if isNumber(index) || isString(index)
			subobj[index] = {}
			subobj = subobj[index]
		else
			croak "Bad index: #{OL(index)}"
	subobj[key] = value
	return obj

# ---------------------------------------------------------------------------

export flattenToHash = (x) =>

	if isHash(x)
		return x
	else if isArray(x)
		hResult = {}
		for item in x
			if isHash(item)
				for own key,value of item
					hResult[key] = value
			else if isArray(item)
				for subitem in item
					for own key,value of flattenToHash(subitem)
						hResult[key] = value
			else
				croak "not a hash or array: #{OL(item)}"
	return hResult
