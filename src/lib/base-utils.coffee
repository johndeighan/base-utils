# base-utils.coffee

import fs from 'node:fs'
import {exec as execCB, execSync} from 'node:child_process'
import {promisify} from 'node:util'
exec = promisify(execCB)
import assertLib from 'node:assert'

# --- ABSOLUTELY NO IMPORTS FROM OUR LIBS !!!!!

`export const undef = void 0`
LOG = console.log   # used internally, not exported

# ---------------------------------------------------------------------------
# low-level version of assert()

export assert = (cond, msg) =>

	assertLib.ok cond, msg
	return true

# ---------------------------------------------------------------------------
# low-level version of croak()

export croak = (msg) =>

	throw new Error(msg)
	return true

# ---------------------------------------------------------------------------

export fileExt = (filePath) =>

	if lMatches = filePath.match(/\.[^\.]+$/)
		return lMatches[0]
	else
		return ''

# ---------------------------------------------------------------------------

export withExt = (filePath, newExt) =>

	if newExt.indexOf('.') != 0
		newExt = '.' + newExt

	if lMatches = filePath.match(/^(.*)\.[^\.]+$/)
		[_, pre] = lMatches
		return pre + newExt
	throw new Error("Bad path: '#{filePath}'")

# ---------------------------------------------------------------------------

export newerDestFilesExist = (srcPath, lDestPaths...) =>

	for destPath in lDestPaths
		if ! fs.existsSync(destPath)
			return false
		srcModTime = fs.statSync(srcPath).mtimeMs
		destModTime = fs.statSync(destPath).mtimeMs
		if (destModTime < srcModTime)
			return false
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

export truncateStr = (str, maxLen) =>

	assert isString(str), "not a string: #{typeof str}"
	assert isInteger(maxLen), "not an integer: #{maxLen}"
	len = str.length
	if (len <= maxLen)
		return str
	else
		return str.substring(0, maxLen-1) + '…'

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

	assert isString(str), "not a string: #{typeof str}"
	if isString(hReplace)
		switch hReplace
			when 'esc'
				hReplace = hEsc
			when 'escNoNL'
				hReplace = hExcNoNL
			else
				return str
	assert isHash(hReplace), "not a hash"
	if isEmpty(hReplace)
		return str

	result = ''
	for ch from str
		if defined(hReplace[ch])
			result += hReplace[ch]
		else
			result += ch
	return result

# ---------------------------------------------------------------------------

export userSetQuoteChars = false
export lQuoteChars = ['«', '»']

export quoted = (str, escape=undef) =>

	assert isString(str), "not a string: #{str}"

	# --- Escape chars if specified
	switch escape
		when 'escape'
			str = escapeStr(str, hEsc)  # escape sp, tab, nl
		when 'escapeNoNL'
			str = escapeStr(str, hEscNoNL)

	# --- Surround with quote marks

	if !userSetQuoteChars
		# --- Prefer using "
		if ! hasChar(str, '"')
			result = '"' + str + '"'
			return result

		if ! hasChar(str, "'")
			result = "'" + str + "'"
			return result

	[lq, rq] = lQuoteChars
	hMyEsc = {
		[lq]: "\\" + lq
		[rq]: "\\" + rq
		}
	result = lq + escapeStr(str, hMyEsc) + rq
	return result

# ---------------------------------------------------------------------------

export setQuoteChars = (start='«', end='»') =>
	# --- returns original quote chars

	lQuoteChars[0] = start
	lQuoteChars[1] = end || start
	userSetQuoteChars = true
	return

export resetQuoteChars = () =>

	userSetQuoteChars = false
	lQuoteChars = ['«', '»']
	return

# ---------------------------------------------------------------------------

export OL = (obj, hOptions={}) =>

	{debug, short} = getOptions hOptions, {
		debug: false
		short: false
		}

	if (obj == undef)
		return 'undef'
	if (obj == null)
		return 'null'

	if short
		if isHash(obj) then return 'HASH'
		if isArray(obj) then return 'ARRAY'
		if isFunction(obj) then return 'FUNCTION'
		if isObject(obj) then return 'OBJECT'

	myReplacer = (key, x) =>
		type = typeof x
		switch type
			when 'bigint'
				return "«BigInt #{x.toString()}»"
			when 'function'
				if x.toString().startsWith('class')
					tag = 'Class'
				else
					tag = 'Function'
				if defined(x.name)
					return "«#{tag} #{x.name}»"
				else
					return "«#{tag}»"
			when 'string'
				# --- NOTE: JSON.stringify will add quote chars
				return escapeStr(x)
			when 'object'
				if x instanceof RegExp
					return "«RegExp #{x.toString()}»"
				if defined(x) && (typeof x.then == 'function')
					return "«Promise»"
				else
					return x
			else
				return x

	result = JSON.stringify(obj, myReplacer)

	# --- Because JSON.stringify adds quote marks,
	#     we remove them when using « and »
	finalResult = result \
		.replaceAll('"«','«').replaceAll('»"','»')
	return finalResult

# ---------------------------------------------------------------------------

export OLS = (lObjects, hOptions={}) =>

	{sep, short} = getOptions hOptions, {
		sep: ','
		short: false
		}

	assert isArray(lObjects), "not an array"
	lParts = []
	for obj in lObjects
		lParts.push OL(obj, {short})
	return lParts.join(sep)

# ---------------------------------------------------------------------------

export jsType = (x) =>
	# --- return [type, subtype]

	switch x
		when undef
			return [undef, undef]
		when null
			return [undef, 'null']
		when true
			return ['boolean', 'true']
		when false
			return ['boolean', 'false']

	switch (typeof x)
		when 'number'
			if Number.isNaN(x)
				return ['number', 'NaN']
			else if Number.isInteger(x)
				return ['number', 'integer']
			else
				return ['number', undef]
		when 'bigint'
			return ['number', 'integer']
		when 'string'
			if x.match(/^\s*$/)
				return ['string', 'empty']
			else
				return ['string', undef]
		when 'boolean'
			return ['boolean', undef]
		when 'function'
			str = x.toString()
			if str.startsWith('class')
				return ['class', x.name || undef]
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
			else if (typeof x.then == 'function')
				return ['promise', undef]
			else
				return ['object', undef]
		else
			throw new Error ("Unknown jsType: #{x}")

# ---------------------------------------------------------------------------

export isString   = (x) => (jsType(x)[0] == 'string')
export isArray    = (x) => (jsType(x)[0] == 'array')
export isBoolean  = (x) => (jsType(x)[0] == 'boolean')
export isFunction = (x) => (jsType(x)[0] == 'function')
export isRegExp   = (x) => (jsType(x)[0] == 'regexp')
export isPromise  = (x) => (jsType(x)[0] == 'promise')

# ---------------------------------------------------------------------------

export isHash = (x, lKeys=undef) =>

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

export execCmd = (cmd, lParts...) =>
	# --- may throw an exception

	cmdLine = buildCmdLine(cmd, lParts...)
	try
		result = execSync cmdLine, {
			encoding: 'utf8'
			windowsHide: true
			}

		assert isString(result), "result = #{OL(result)}"
		return result
	catch err
		console.log "ERROR: #{OL(err)}"

# ---------------------------------------------------------------------------

export npmLogLevel = () =>

	result = execCmd('npm config get loglevel')
	return chomp(result)

# ---------------------------------------------------------------------------

export execCmdAsync = (cmd, lParts...) =>
	# --- may throw an exception

	cmdLine = buildCmdLine(cmd, lParts...)
	return await exec cmdLine, {
		encoding: 'utf8'
		windowsHide: true
		}

# ---------------------------------------------------------------------------
# --- lParts may contain hashes (options) or arrays (non-options)

export buildCmdLine = (cmd, lParts...) =>

	lOptions = []
	lFlags = []      # array of letters
	lNonOptions = []

	for obj in lParts
		if isHash(obj)
			for own key,value of obj
				switch jsType(value)[0]
					when 'string'
						if value.includes(' ')
							lOptions.push "-#{key}=\"#{value}\""
						else
							lOptions.push "-#{key}=#{value}"
					when 'boolean'
						if value
							if (key.length == 1)
								lFlags.push key
							else
								lOptions.push "-#{key}=true"
						else
							lOptions.push "-#{key}=false"
					when 'number'
						lOptions.push "-#{key}=#{value}"
					else
						croak "Bad option: #{OL(value)}"

		else if isArray(obj)
			for item in obj
				if item.includes(' ')
					lNonOptions.push "\"#{item}\""
				else
					lNonOptions.push item
		else
			croak "arg not an array or hash"

	if (lFlags.length > 0)
		lOptions.push "-#{lFlags.join('')}"

	# --- join the parts
	lAllParts = [cmd, lOptions..., lNonOptions...]
	return lAllParts.join(' ');

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

export hslice = (h, lKeys) =>

	hResult = {}
	for key in lKeys
		hResult[key] = h[key]
	return hResult

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
# --- valid options:
#        char - char to use on left and right
#        buffer - num spaces around text when char <> ' '

export centeredText = (text, width, hOptions={}) =>

	{char, numBuffer} = getOptions hOptions, {
		char: ' '
		numBuffer: 2
		}
	assert isInteger(width), "width = #{OL(width)}"
	totSpaces = width - text.length
	if (totSpaces <= 0)
		return text
	numLeft = Math.floor(totSpaces / 2)
	numRight = totSpaces - numLeft
	if (char == ' ')
		return spaces(numLeft) + text + spaces(numRight)
	else
		buf = ' '.repeat(numBuffer)
		left = char.repeat(numLeft - numBuffer)
		right = char.repeat(numRight - numBuffer)
		numLeft -= numBuffer
		numRight -= numBuffer
		return left + buf + text + buf + right

# ---------------------------------------------------------------------------

export delimitBlock = (block, hOptions={}) =>

	{width, label} = getOptions hOptions, {
		width: 40
		label: undef
		}
	str = '-'.repeat(width)
	if defined(label)
		header = centeredText(label, width, {char: '-'})
	else
		header = str
	if (block == '')
		return [header, str].join("\n")
	else
		return [header, block, str].join("\n")

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

export trimArray = (lLines) =>

	# --- lLines is modified in place, but we still return a ref
	while (lLines.length > 0) && isEmpty(lLines[0])
		lLines.shift()
	while (lLines.length > 0) && isEmpty(lLines[lLines.length-1])
		lLines.pop()
	return lLines

# ---------------------------------------------------------------------------

export removeEmptyLines = (lLines) =>

	assert isArrayOfStrings(lLines), "Not an array of strings: #{OL(lLines)}"
	return lLines.filter (line) => nonEmpty(line)

# ---------------------------------------------------------------------------

export CWSALL = (blockOrArray) =>

	if isArrayOfStrings(blockOrArray)
		lNewArray = for line in blockOrArray
			CWS(line)
		return trimArray(lNewArray)
	else if isString(blockOrArray)
		lNewArray = for line in toArray(blockOrArray)
			CWS(line)
		return toBlock(trimArray(lNewArray))
	else
		throw new Error("Bad param: #{OL(blockOrArray)}")

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

export hasChar = (str, ch) =>

	assert isString(str), "Not a string: #{str}"
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

export sortArrayOfHashes = (lHashes, key) =>

	assert isArrayOfHashes(lHashes), "Not an array of hashes"

	# --- NOTE: works whether values are strings or numbers
	compareFunc = (a, b) =>
		if a[key] < b[key]
			return -1
		else if a[key] > b[key]
			return 1
		else
			return 0
	lHashes.sort(compareFunc)

	# --- NOTE: array is sorted in place, but sometimes
	#           it's useful if we return a ref to it anyway
	return lHashes

# ---------------------------------------------------------------------------

export sortedArrayOfHashes = (lHashes, key) =>

	assert isArrayOfHashes(lHashes), "Not an array of hashes"

	# --- NOTE: works whether values are strings or numbers
	compareFunc = (a, b) =>
		if a[key] < b[key]
			return -1
		else if a[key] > b[key]
			return 1
		else
			return 0
	return lHashes.toSorted(compareFunc)

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
# --- e.g. mkword([null, ['4','2'], null) returns '42'

export mkword = (lStuff...) =>

	lParts = []
	for thing in lStuff
		if isString(thing)
			lParts.push thing
		else if isArray(thing)
			result = mkword(thing...)
			if nonEmpty(result)
				lParts.push result
	return lParts.join('')

# ---------------------------------------------------------------------------

export isIterable = (obj) =>

	if (obj == undef) || (obj == null)
		return false
	return (typeof obj[Symbol.iterator] == 'function')

# ---------------------------------------------------------------------------
# --- always return hash with the same set of keys!
#     values should be a string, true, false or undef

export analyzeObj = (obj, hOptions={}) =>

	{maxStrLen} = getOptions hOptions, {
		maxStrLen: 22
		}

	type = typeof obj
	lType = jsType(obj)
	if defined(lType[1])
		jst = lType.join('/')
	else
		jst = lType[0]
	h = {
		jsType: jst
		type
		isArr: Array.isArray(obj)
		isIter: isIterable(obj)
		objType: ''
		objName: ''
		conName: ''
		str: ''
		}

	if notdefined(obj)
		return h

	if defined(obj.constructor)
		h.conName = obj.constructor.name

	if defined(obj.toString)
		str = truncateStr(CWS(obj.toString()), maxStrLen)
		if lMatches = str.match(///^
				\[ object \s+
				([A-Za-z]+)
				\]
				///)
			[_, objType] = lMatches
			if (objType == 'Generator')
				h.objType = 'iterator'
			else
				h.objType = objType.toLowerCase()
		else if lMatches = str.match(///^
				class \s*
				(?:
					([A-Za-z_][A-Za-z0-9_]*)
					\s*
					)?
				\{
				///)
			h.objType = 'class'
			h.objName = lMatches[1] || ''
		else if lMatches = str.match(///^
				\s*
				function \s* (\*)?
				\s*
				(?:
					([A-Za-z_][A-Za-z0-9_]*)
					\s*
					)?
				\(
				///)
			[_, star, name] = lMatches
			h.objType = if (star == '*') then 'generator' else 'function'
			h.objName = lMatches[1] || ''
		h.str = str
	return h

# ---------------------------------------------------------------------------

export hasClassConstructor = (obj) =>

	con = obj?.constructor
	if notdefined(con) || notdefined(con.toString)
		return false
	return con.toString().startsWith('class')

# ---------------------------------------------------------------------------

export isClass = (obj) =>

	return (typeof obj == 'function') && obj.toString().startsWith('class')

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

	assert isString(line), "not a string: #{OL(line)}"
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
		if ! hOptions.hasOwnProperty(key) && defined(value)
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
