# machine.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, OL,
	isString, isHash, isNonEmptyString,
	} from '@jdeighan/base-utils'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'

# ---------------------------------------------------------------------------

export class Machine

	constructor: (initialState) ->

		dbgEnter 'Machine', initialState
		assert isNonEmptyString(initialState), "not a non-empty string"
		@state = initialState
		@hData = {}
		dbgReturn 'Machine', this

	# ..........................................................

	inState: (x) ->

		return (@state == x)

	# ..........................................................

	setState: (newState, hNewData={}) ->

		assert isHash(hNewData), "new data not a hash"
		Object.assign @hData, hNewData
		@state = newState
		return

	# ..........................................................

	expectState: (lStates...) ->

		if ! lStates.includes(@state)
			if lStates.length == 1
				croak "state is '#{@state}', expected #{lStates[0]}"
			else
				croak "state is '#{@state}', expected one of #{OL(lStates)}"
		return

	# ..........................................................

	expectDefined: (lVarNames...) ->

		for varname in lVarNames
			assert defined(@hData[varname]), "#{varname} should be defined"
		return

	# ..........................................................

	var: (varname) ->

		return @hData[varname]
