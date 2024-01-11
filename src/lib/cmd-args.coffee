# cmd-args.coffee

import parseArgs from 'minimist'
import {
	undef, defined, notdefined, isString, isHash, isArray,
	} from '@jdeighan/base-utils'
import {LOG} from '@jdeighan/base-utils/log'
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
	if hOptions.hasOwnProperty('debug')
		debug = hOptions.debug
		delete hOptions.debug
	if hOptions.hasOwnProperty('number')
		lNumbers = hOptions.number
		if hOptions.hasOwnProperty('string')
			hOptions.string = [hOptions.string..., lNumbers]
		else
			hOptions.string = lNumbers
		delete hOptions.number
	if isString(lArgs)
		lArgs = lArgs.trim().split(/\s+/)
		if debug
			LOG lArgs
	else
		assert isArray(lArgs), "lArgs must be an array"

	# --- If no 'unknown' key in hOptions, add a default one
	if notdefined(hOptions.unknown)
		hOptions.unknown = (opt) =>
			if opt.startsWith('-')
				displayHelpText helpText
				croak "Unknown option '#{opt}'"
			return
	hArgs = parseArgs(lArgs, hOptions)
	if defined(lNumbers)
		for key in lNumbers
			hArgs[key] = parseFloat(hArgs[key])
	if hArgs.h
		displayHelpText helpText
	return hArgs
