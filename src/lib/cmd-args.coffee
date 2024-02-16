# cmd-args.coffee

import parseArgs from 'minimist'

import {
	undef, defined, notdefined, isString, isHash, LOG,
	isArray, isArrayOfStrings,
	hasKey, extractKey, OL,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'

# ---------------------------------------------------------------------------

displayHelpText = (helpText) =>

	if defined(helpText)
		LOG helpText
	else
		LOG "No help available"
	return

# ---------------------------------------------------------------------------
# --- By default, throws error if unexpected args are seen

export getArgs = (hOptions, lArgs=process.argv.slice(2), helpText=undef) =>
	# --- hOptions should include keys for types of args
	#        with value being an array of option keys, e.g.
	#
	#        {
	#           boolean: ['a','b','c','h']
	#           string: ['name','count']
	#           default: {
	#              a: true
	#              }
	#           unknown: (opt) =>
	#              LOG "Unknown option '#{opt}'"
	#           }
	#
	#     when invoked with:
	#        <script> -c --name=abc --count=5 def ghi`
	#     will return:
	#        {
	#           c: true,          # explicitly on cmd line
	#           a: true,          # default value
	#           name: 'abc',
	#           count: 5          # returned as a number
	#           _: ['def','ghi']  # non-options
	#           }
	#
	#     if lArgs is a string, it's split on whitespace
	#     hArgs._ contains and array of all non-options

	assert isHash(hOptions), "hOptions must be a hash"

	if hOptions.debug
		LOG 'org hOptions:', hOptions

	# --- some keys are unexpected by parseArgs() so we extract them
	debug = extractKey(hOptions, 'debug')
	minNonOptions = extractKey(hOptions, 'minNonOptions')
	maxNonOptions = extractKey(hOptions, 'maxNonOptions')
	lNumbers = extractKey(hOptions, 'number')

	# --- Unspecified default values will be added w/value undef
	if defined(hOptions.default)
		assert isHash(hOptions.default), "key 'default' must be a hash"
		hDefaultVals = hOptions.default
	else
		hOptions.default = hDefaultVals = {}

	if isString(lArgs)
		lArgs = lArgs.trim().split(/\s+/)
		if debug
			LOG lArgs
	else
		assert isArray(lArgs), "lArgs must be an array"

	# --- Non-standard key 'numbers' is list of names
	#     where numbers are expected
	if defined(lNumbers)
		assert isArrayOfStrings(lNumbers),
			"key 'number' must be an array of strings"
		if defined(hOptions.string)
			assert isArrayOfStrings(hOptions.string),
				"key 'string' must be an array"
			hOptions.string = [hOptions.string..., lNumbers...]
		else
			hOptions.string = lNumbers

	if defined(hOptions.string)
		assert isArrayOfStrings(hOptions.string),
			"key 'string' must be an array of strings"
		for str in hOptions.string
			if ! hasKey(hDefaultVals, str)
				hDefaultVals[str] = undef

	if defined(hOptions.boolean)
		assert isArrayOfStrings(hOptions.string),
			"key 'string' must be an array of strings"
		for str in hOptions.boolean
			if ! hasKey(hDefaultVals, str)
				hDefaultVals[str] = undef

	# --- If no 'unknown' key in hOptions, add a default one
	if ! hasKey(hOptions, 'unknown')
		hOptions.unknown = (opt) =>
			if opt.startsWith('-')
				displayHelpText helpText
				croak "Unknown option '#{opt}'"
			return

	hOptions.default = hDefaultVals
	if debug
		LOG 'final hOptions', hOptions

	hArgs = parseArgs(lArgs, hOptions)
	if defined(lNumbers)
		for key in lNumbers
			hArgs[key] = parseFloat(hArgs[key])
	if hArgs.h
		displayHelpText helpText
	return hArgs
