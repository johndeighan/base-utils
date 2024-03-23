# peggy.coffee

import peggy from 'peggy'
{generate} = peggy

import {
	undef, defined, notdefined, pass, OL, getOptions, hasKey,
	isString, isFunction, isArray, isHash, isEmpty, nonEmpty,
	toArray, toBlock, isArrayOfStrings, removeEmptyLines,
	isNonEmptyString, untabify,
	} from '@jdeighan/base-utils'
import {LOG} from '@jdeighan/base-utils/log'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'
import {
	isIndented, undented, splitLine, indentLevel, indented,
	} from '@jdeighan/base-utils/indent'
import {
	isFile, slurp, barf, withExt, readTextFile,
	} from '@jdeighan/base-utils/fs'
import {brew} from '@jdeighan/base-utils/coffee'

hPreProcessors = {
	coffee: (lLines) =>
		[jsCode, _] = brew lLines
		return jsCode
	}

# ---------------------------------------------------------------------------

export addPreProcessor = (name, func) =>

	assert isNonEmptyString(name), "Bad name: #{OL(name)}"
	assert ! hasKey(hPreProcessors, name), "Exists: #{OL(name)}"
	assert isFunction(func), "Not a function: #{OL(func)}"
	hPreProcessors[name] = func
	return

# ---------------------------------------------------------------------------
# --- peggyCode can be a string or array of strings

export peggify = (peggyCode, source=undef, hMetaData) =>

	dbgEnter 'peggify', peggyCode, source, hMetaData

	assert isHash(hMetaData), "Not a hash: #{OL(hMetaData)}"

	# --- preprocess peggyCode if required
	#        - ensure peggyCode is a string

	type = hMetaData.type
	dbg "type = #{OL(type)}"
	if isNonEmptyString(type)
		peggyCode = convertToJS(peggyCode, hMetaData)
	else if isArray(peggyCode)
		peggyCode = toBlock(peggyCode)
	try
		if defined(source)
			assert isFile(source), "Not a file: #{OL(source)}"
			srcNode = generate(peggyCode, {
				grammarSource: source
				allowedStartRules: ['*']
				format: 'es'
				output: 'source-and-map'
				trace: true   # compile w/tracing capability
				})
			h = srcNode.toStringWithSourceMap()
			result = [h.code, h.map.toString()]
		else
			jsCode = generate(peggyCode, {
				allowedStartRules: ['*']
				format: 'es'
				output: 'source'
				trace: true   # compile w/tracing capability
				})
			result = [jsCode, undef]

	catch err
		console.log '-'.repeat(32) + "  FAILED  " + '-'.repeat(32)
		console.log untabify(peggyCode)
		console.log '-'.repeat(74)
		throw err

	dbgReturn 'peggify', result
	return result

# ---------------------------------------------------------------------------

export peggifyFile = (filePath) =>

	{hMetaData, lLines} = readTextFile(filePath)
	[jsCode, sourceMap] = peggify lLines, filePath, hMetaData
	barf jsCode, withExt(filePath, '.js')
	if defined(sourceMap)
		barf sourceMap, withExt(filePath, '.js.map')
	return

# ---------------------------------------------------------------------------
# --- input may be a string or array of strings
# --- returns a block of JavaScript code

export convertToJS = (input, hMetaData={}) =>

	dbgEnter 'convertToJS', input, hMetaData

	# --- convert input to array of lines
	if isString(input)
		dbg "convert string to array"
		lLines = toArray(input)
	else
		dbg "already an array"
		lLines = input
	lLines = removeEmptyLines(lLines)

	assert isArrayOfStrings(lLines),
			"not an array of strings: #{OL(lLines)}"

	# --- NOTE: There are NO empty lines in lLines !!!
	#     We will remove lines from lLines as they're processed

	assert isHash(hMetaData), "Not a hash: #{OL(hMetaData)}"
	type = hMetaData.type
	preProcessor = hPreProcessors[type]
	assert isFunction(preProcessor), "Unknown type: #{OL(type)}"

	# --- Define some utility functions ----------

	# --- are there more lines to process?
	more = () =>
		return (lLines.length > 0)

	# --- what is the next line?
	next = () =>
		return lLines[0]

	# --- what is the level of the next line?
	nextLevel = () =>
		if (next() == undef)
			return 0
		return indentLevel(lLines[0])

	# --- get the next line, removing it from lLines
	get = () =>
		return lLines.shift()

	# --- remove the next line without returning it
	skip = () =>
		lLines.shift()
		return

	# --- get a block of code, as an array, undented
	getCodeLines = (minLevel) =>
		dbgEnter 'getCodeLines', minLevel
		lCodeLines = []
		while (nextLevel() >= minLevel)
			lCodeLines.push get()
		result = undented(lCodeLines)
		dbgReturn 'getCodeLines', result
		return result

	# --------------------------------------------

	lPeggy = []   # --- shift lines from lLines as processed

	if (next() == 'INITIALIZATION')
		skip()
		dbg "Found INITIALIZATION section"
		lCoffee = getCodeLines(1)
		dbg "   - #{lCoffee.length} lines of coffee code"
		lPeggy.push "{{"
		lPeggy.push preProcessor(lCoffee)
		lPeggy.push "}}"

	if (next() == 'EACH_PARSE')
		skip()
		dbg "Found EACH_PARSE section"
		lCoffee = getCodeLines(1)
		dbg "   - #{lCoffee.length} lines of coffee code"
		lPeggy.push "{"
		lPeggy.push preProcessor(lCoffee)
		lPeggy.push "}"

	hRules = {}
	while more()

		# --- Get rule name - must be left aligned, no whitespace
		name = get()
		lPeggy.push name
		dbg "RULE #{OL(name)}"
		assert !name.match(/\s/), "whitespace in rule name #{OL(name)}"
		assert !hasKey(hRules, name), "duplicate rule #{name}"
		hRules[name] = 0   # number of options

		while more() && (nextLevel() == 1)
			# --- Get match expression - 1 indent level, may be multi-line
			lExprLines = []
			while (nextLevel() == 1)
				lExprLines.push get().trim()
			assert (lExprLines.length > 0), "Bad rule #{name}"
			matchExpr = lExprLines.join(' ')

			ch = if (hRules[name] == 0) then '=' else '/'
			headerLine = "#{ch} #{matchExpr}"
			dbg ""
			dbg "OPTION #{hRules[name]}", headerLine
			lPeggy.push "  #{headerLine}"
			hRules[name] += 1

			lCoffee = getCodeLines(2)
			dbg 'lCoffee', lCoffee

			if (lCoffee.length > 0)
				lPeggy.push "    {"
				lPeggy.push indented(preProcessor(lCoffee), 2, "  ")
				lPeggy.push "    }"
				lPeggy.push ""

	result = toBlock(lPeggy)
	dbgReturn 'convertToJS', result
	return result

# ---------------------------------------------------------------------------

# --- Tracer object does not log

class Tracer

	trace: ({type, rule, location}) ->
		pass()

class MyTracer extends Tracer

	constructor: () ->
		super()
		@level = 0

	prefix: () ->
		return "|  ".repeat(@level)

	trace: ({type, rule, location, match}) ->
		switch type
			when 'rule.enter'
				console.log "#{@prefix()}? #{rule}"
				@level += 1
			when 'rule.fail'
				@level -= 1;
				console.log "#{@prefix()}NO"
			when 'rule.match'
				@level -= 1
				if defined(match)
					console.log "#{@prefix()}YES - #{OL(match)}"
				else
					console.log "#{@prefix()}YES"
			else
				console.log "UNKNOWN type: #{type}"
		return

# ---------------------------------------------------------------------------

export peggyParse = (parseFunc, inputStr, hOptions={}) =>

	{start, tracer} = getOptions hOptions, {
		start: undef     #     name of start rule
		tracer: 'none'   # --- can be 'none'/'peggy'/'default'/a function
		}

	hParseOptions = {}
	if defined(start)
		hParseOptions.startRule = start
	switch tracer
		when 'none'
			hParseOptions.tracer = new Tracer()
		when 'peggy'
			pass()
		when 'default'
			hParseOptions.tracer = new MyTracer()
		else
			assert isFunction(tracer), "tracer not a function"
			hParseOptions.tracer = tracer

	return parseFunc(inputStr, hParseOptions)

# ---------------------------------------------------------------------------

