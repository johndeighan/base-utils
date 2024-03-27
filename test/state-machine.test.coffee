# state-machine.test.coffee

import {
	undef, defined, notdefined, pass, escapeStr,
	} from '@jdeighan/base-utils'
import {suppressExceptionLogging} from '@jdeighan/base-utils/exceptions'
import {
	UnitTester,
	equal, like, notequal, truthy, falsy, fails, succeeds,
	} from '@jdeighan/base-utils/utest'
import * as lib from '@jdeighan/base-utils/state-machine'
Object.assign(global, lib)

suppressExceptionLogging()

# ---------------------------------------------------------------------------

(() ->
	mach = new StateMachine('init', {flag: true, str: 'a string'})

	truthy mach.inState('init')
	falsy  mach.inState('not')
	equal  mach.state, 'init'
	succeeds () => mach.expectState('init','not')
	fails () => mach.expectState('xxx','not')
	succeeds () => mach.expectDefined('flag','str')
	fails () => mach.expectDefined('flag','str','notdef')
	equal mach.getVar('flag'), true
	equal mach.getVar('str'), 'a string'
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

	truthy mach1.inState('init')
	truthy mach2.inState('middle')
	truthy mach3.inState('final')

	fails () => mach1.SECOND()
	succeeds () => mach1.FIRST()
	fails () => mach1.setState('some state')
	)()
