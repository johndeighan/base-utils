# metadata.coffee

import {
	undef, defined, notdefined, OL,
	isHash, isString, isArray, isNonEmptyString, isFunction,
	toArray, toBlock,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG} from '@jdeighan/base-utils/log'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'
import {fromTAML} from '@jdeighan/base-utils/taml'
import {fromNICE} from '@jdeighan/base-utils/nice'

# --- { <start>: <converter>, ... }
hMetaDataTypes = {
	'---': (block) => return fromTAML("---\n#{block}")
	'!!!': (block) => fromNICE(block)
	}

# ---------------------------------------------------------------------------

export addMetaDataType = (start, converter) =>

	assert isString(start), "Missing start"
	assert (start.length == 3), "Bad 'start' key: #{OL(start)}"
	assert (start[1] == start[0]) && (start[2] == start[0]),
		"Bad 'start' key: #{OL(start)}"

	assert isFunction(converter), "Non-function converter"
	hMetaDataTypes[start] = converter
	return

# ---------------------------------------------------------------------------

export isMetaDataStart = (str) =>

	return defined(hMetaDataTypes[str])

# ---------------------------------------------------------------------------
# --- input can be a string or array of strings
# --- input will include start line, but not end line

export convertMetaData = (input) =>

	dbgEnter 'convertMetaData', input

	# --- convert input to a block, set var start
	if isArray(input)
		assert (input.length > 0), "Empty array"
		start = input.shift()
		block = toBlock(input)
	else if isString(input)
		arr = toArray(input)
		assert (arr.length > 0), "Empty block"
		start = arr.shift()
		block = toBlock(arr)
	else
		croak "Bad parameter to convertMetaData()"

	dbg 'block', block

	assert defined(hMetaDataTypes[start]),
		"Bad metadata start: #{OL(start)}"

	# --- NOTE: block should not include the start line
	result = hMetaDataTypes[start](block)
	dbgReturn 'convertMetaData', result
	return result
