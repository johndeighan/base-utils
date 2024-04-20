# parse-cmd-args.coffee

import {
	undef, defined, notdefined, getOptions,
	OL, hasKey, words,
	isHash, isArray, isNumber, isInteger, isRegExp,
	isString, isBoolean,
	} from '@jdeighan/base-utils'
import {LOG} from '@jdeighan/base-utils/log'
import {
	dbgEnter, dbgReturn, dbg, debugDebug,
	} from '@jdeighan/base-utils/debug'
import {
	assert, croak,
	} from '@jdeighan/base-utils/exceptions'
import {parse} from '@jdeighan/base-utils/cmd-args'
import {pparse} from '@jdeighan/base-utils/peggy'

lTypes = words('boolean string number integer json')

# ---------------------------------------------------------------------------

export argStrFromArgv = () =>

	dbgEnter 'argStrFromArgv'
	lTrueArgs = process.argv.slice(2)
	dbg 'lTrueArgs', lTrueArgs
	lQuoted = lTrueArgs.map((str) =>
		if str.match(/\s/)
			if lMatches=str.match(///^
					\-
					([A-Za-z_][A-Za-z0-9_]+)
					\=
					(.*)
					$///)
				[_, name, value] = lMatches
				return "-#{name}=\"#{value}\""
			else
				return '"' + str + '"'
		else
			return str
		)
	dbg 'lQuoted', lQuoted
	result = lQuoted.join(' ')
	dbgReturn 'argStrFromArgv', result
	return result

# ---------------------------------------------------------------------------
# --- option 'expect' should be a hash, like:
#        {
#           <name>: <type>
#           _: [<int>, <int>]  # min, max
#           }
#        <type> can be:
#           a regular expression # --- implies value is a string
#           'boolean'
#           'string'
#           'number'
#           'integer'
#           'json'

export parseCmdArgs = (hOptions={}) =>

	dbgEnter 'parseCmdArgs', hOptions
	{argStr, hExpect} = getOptions hOptions, {
		argStr: undef
		hExpect: undef
		}

	# --- Check if hExpect option is valid
	minNonOptions = 0
	maxNonOptions = Infinity
	if defined(hExpect)
		assert isHash(hExpect), "hExpect is not a hash"
		for own key,value of hExpect
			if (key == '_')
				assert isArray(value), "key '_', value = #{OL(value)}"
				assert (value.length == 2), "Bad '_' key"
				[min, max] = value
				if defined(min)
					assert isInteger(min, {min:0}), "Bad '_' key, min = #{OL(min)}"
					minNonOptions = min
				if defined(max)
					assert isInteger(max, {min:0}), "Bad '_' key, max = #{OL(max)}"
					maxNonOptions = max
					if defined(min)
						assert (min <= max), "min = #{OL(min)}, max = #{OL(max)}"
			else
				assert lTypes.includes(value) || isRegExp(value),
						"Bad type for #{key}: #{OL(value)}"

	if notdefined(argStr)
		argStr = argStrFromArgv()
	dbg "arg str = '#{argStr}'"

	hResult = pparse(parse, argStr)
	dbg 'hResult', hResult
	assert isHash(hResult), "hResult = #{OL(hResult)}"

	if hasKey(hResult, '_')
		numNonOptions = hResult._.length
	else
		numNonOptions = 0

	assert numNonOptions >= minNonOptions,
			"#{numNonOptions} non options < min #{min}",
			hResult, 'hResult'
	assert numNonOptions <= maxNonOptions,
			"#{numNonOptions} non options > max #{max}",
			hResult, 'hResult'

	for own name,value of hResult
		dbg "FOUND #{name} = #{OL(value)}"
		if (name == '_')
			continue
		else if isBoolean(value)
			if defined(hExpect)
				assert (hExpect[name] == 'boolean'),
						"boolean #{name} not expected"
		else
			assert isString(value), "value = #{OL(value)}"
			if defined(hExpect)
				type = hExpect[name]
				assert defined(type), "Unexpected option: #{OL(name)}"
				if isRegExp(type)
					assert value.match(type),
							"Bad value for option -#{name}: #{OL(value)}"
					hResult[name] = value
				else
					hResult[name] = getVal(name, type, value)

	dbgReturn 'parseCmdArgs', hResult
	return hResult

# ---------------------------------------------------------------------------

export getVal = (name, type, value) =>

	switch type
		when 'boolean'
			if isBoolean(value)
				return value
			else if (value == 'true')
				return true
			else if (value == 'false')
				return false
			else
				croak "#{name} should be 'true' or 'false' (#{OL(value)})"
		when 'string'
			return value
		when 'number'
			if value.match(/^\d+(\.\d*)$/)
				return Number(value)
			else
				croak "option #{name} not a number"
		when 'integer'
			if value.match(/^\d+$/)
				return parseInt(value)
			else
				croak "option #{name} not an integer"
		when 'json'
			return JSON.parse(value)
	return
