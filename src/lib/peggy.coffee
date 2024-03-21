# peggy.coffee

import peggy from 'peggy'
{generate} = peggy

import {
	undef, defined, notdefined, pass, OL, toBlock, getOptions,
	isString, isEmpty, isFunction,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	isFile, slurp, barf, withExt, readTextFile,
	} from '@jdeighan/base-utils/fs'

hPeggyOptions = {
	allowedStartRules: ['*']
	format: 'es'
	output: 'source-and-map'
	trace: true
	}

# ---------------------------------------------------------------------------

export peggify = (peggyCode, source) =>

	assert isFile(source), "Not a file: #{OL(source)}"
	try
		hPeggyOptions.grammarSource = source
		srcNode = generate(peggyCode, hPeggyOptions)
		h = srcNode.toStringWithSourceMap()
		return [h.code, h.map.toString()]
	catch err
		console.log "ERROR: #{err.message}"
		return [undef, undef]

# ---------------------------------------------------------------------------

export peggifyFile = (filePath) =>

	{metadata, lLines} = readTextFile(filePath)
	[jsCode, sourceMap] = peggify toBlock(lLines), filePath
	barf jsCode, withExt(filePath, '.js')
	barf sourceMap, withExt(filePath, '.js.map')
	return

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

export pparse = (parseFunc, inputStr, hOptions={}) =>

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

