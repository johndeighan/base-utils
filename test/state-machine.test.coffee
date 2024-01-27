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

	utest.truthy mach.inState('init')
	utest.falsy  mach.inState('not')
	utest.equal  mach.state, 'init'
	utest.succeeds () => mach.expectState('init','not')
	utest.throws () => mach.expectState('xxx','not')
	utest.succeeds () => mach.expectDefined('flag','str')
	utest.throws () => mach.expectDefined('flag','str','notdef')
	utest.equal mach.getVar('flag'), true
	utest.equal mach.getVar('str'), 'a string'
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

	utest.truthy mach1.inState('init')
	utest.truthy mach2.inState('middle')
	utest.truthy mach3.inState('final')

	utest.throws () => mach1.SECOND()
	utest.succeeds () => mach1.FIRST()
	utest.throws () => mach1.setState('some state')
	)()
