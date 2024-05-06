# state-machine.coffee

import {
	undef, defined, notdefined, OL,
	isString, isHash, isArray, isNonEmptyString,
	} from '@jdeighan/base-utils'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'

# ---------------------------------------------------------------------------
# You should override this class,
#    adding methods (uppercase by convention)
#    that expect one or more states and assign a new state
# then only use those methods, not setState() directly

export class StateMachine

	constructor: (@state='start', @hData={}) ->

		dbgEnter 'StateMachine', @state, @hData
		assert isNonEmptyString(@state),
				"not a non-empty string: #{OL(@state)}"
		assert isHash(@hData), "data not a hash"
		dbgReturn 'StateMachine'

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

	defined: (name) ->

		return defined(@hData[name])

	# ..........................................................

	allDefined: (lNames...) ->

		for name in lNames
			if notdefined(@hData[name])
				return false
		return true

	# ..........................................................

	anyDefined: (lNames...) ->

		for name in lNames
			if defined(@hData[name])
				return true
		return false

	# ..........................................................

	setVar: (name, value) ->

		@hData[name] = value
		return

	# ..........................................................

	appendVar: (name, value) ->

		assert @defined(name), "#{name} not defined"
		lItems = @hData[name]
		assert isArray(lItems), "Not an array: #{OL(lItems)}"
		lItems.push value
		return

	# ..........................................................

	getVar: (name) ->

		assert @allDefined(name), "#{name} is not defined"
		return @hData[name]
