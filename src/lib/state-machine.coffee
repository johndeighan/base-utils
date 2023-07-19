# state-machine.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, OL,
	isString, isHash, isNonEmptyString,
	} from '@jdeighan/base-utils'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'

# ---------------------------------------------------------------------------
# You should override this class, adding methods (uppercase by convention)
#    that expect one or more states and assign a new state
# then only use those methods, not setState() directly

export class StateMachine

	constructor: (@state, @hData={}) ->

		dbgEnter 'StateMachine', @state, @hData
		assert isNonEmptyString(@state), "not a non-empty string"
		assert isHash(@hData), "data not a hash"
		dbgReturn 'StateMachine', this

	# ..........................................................

	inState: (x) ->

		return (@state == x)

	# ..........................................................

	setState: (newState, hNewData={}) ->

		assert isHash(hNewData), "new data not a hash"
		for own key,val of hNewData
			if defined(val)
				@hData[key] = val
			else
				delete @hData[key]
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

	getVar: (varname) ->

		@expectDefined varname
		return @hData[varname]

	# ..........................................................

	setVar: (varname, value) ->

		@hData[varname] = value
		return
