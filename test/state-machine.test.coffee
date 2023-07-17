# state-machine.test.coffee

import {
	undef, defined, notdefined, pass, escapeStr,
	} from '@jdeighan/base-utils'
import {suppressExceptionLogging} from '@jdeighan/base-utils/exceptions'
import {utest} from '@jdeighan/base-utils/utest'
import {StateMachine} from '@jdeighan/base-utils/state-machine'

suppressExceptionLogging()

# ---------------------------------------------------------------------------

(() ->
	mach = new StateMachine('init', {flag: true, str: 'a string'})

	utest.truthy 17, mach.inState('init')
	utest.falsy  18, mach.inState('not')
	utest.equal  19, mach.state, 'init'
	utest.succeeds 20, () => mach.expectState('init','not')
	utest.fails 21, () => mach.expectState('xxx','not')
	utest.succeeds 22, () => mach.expectDefined('flag','str')
	utest.fails 23, () => mach.expectDefined('flag','str','notdef')
	utest.equal 24, mach.getVar('flag'), true
	utest.equal 25, mach.getVar('str'), 'a string'
	)()

# ---------------------------------------------------------------------------
# A very simple machine with states and transitions:
#
#    init --FIRST--> middle --SECOND--> final

(() ->
	class SimpleStateMachine extends StateMachine

		constructor: () ->
			super 'init'

		setState: () ->
			croak "Don't call this class's setState() method"

		FIRST: () ->
			@expectState 'init'
			super.setState 'middle'

		SECOND: () ->
			@expectState 'middle'
			super.setState 'final'

	mach1 = new SimpleStateMachine()

	mach2 = new SimpleStateMachine()
	mach2.FIRST()

	mach3 = new SimpleStateMachine()
	mach3.FIRST()
	mach3.SECOND()

	utest.truthy 56, mach1.inState('init')
	utest.truthy 57, mach2.inState('middle')
	utest.truthy 58, mach3.inState('final')

	utest.fails 60, () => mach1.SECOND()
	utest.succeeds 61, () => mach1.FIRST()
	utest.fails 65, () => mach1.setState('some state')
	)()
