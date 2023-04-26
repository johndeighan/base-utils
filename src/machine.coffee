# machine.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, defined, notdefined, OL,
	isString, isNonEmptyString,
	} from '@jdeighan/base-utils'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'

# ---------------------------------------------------------------------------

export class Machine

	constructor: (initialState) ->

		dbgEnter 'Machine', initialState
		assert isNonEmptyString(initialState), "not a non-empty string"
		@curState = initialState
		@hTransitions = {}    # <state> -> <event> -> {nextState, callback}
		@anyCallback = undef
		@addState(initialState)
		dbgReturn 'Machine', this

	# ..........................................................

	on: (state, event, nextState, callback=undef) ->

		assert @isState(state), "not a state: #{state}"
		@addState nextState

		if defined(@hTransitions[state][event])
			croak "transition for (#{state},#{event} already defined"
		else
			@hTransitions[state][event] = {
				nextState
				callback
				}
		return

	# ..........................................................

	onAny: (callback) ->

		assert isFunction(callback), "callback not a function"
		@anyCallback = callback
		return

	# ..........................................................

	addState: (state) ->

		assert isNonEmptyString(state), "not a non-empty string"
		if notdefined(@hTransitions[state])
			@hTransitions[state] = {}
		return

	# ..........................................................

	isState: (state) ->

		return defined(@hTransitions[state])

	# ..........................................................

	emit: (event) ->

		hTrans = @hTransitions[@curState][event]
		assert defined(hTrans), "bad event #{event} in state #{@curState}"
		@curState = hTrans.nextState
		if defined(hTrans.callback)
			hTrans.callback(@curState, event)
		if defined(@anyCallback)
			@anyCallback(@curState, event)
		return
