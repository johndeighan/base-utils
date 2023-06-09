# machine.test.coffee

import {
	undef, defined, notdefined, pass, escapeStr,
	} from '@jdeighan/base-utils'
import {utest} from '@jdeighan/base-utils/utest'
import {Machine} from '@jdeighan/base-utils/machine'

# ---------------------------------------------------------------------------

(() ->
	mach = new Machine('init')

	utest.truthy 16, mach.inState('init')
	utest.falsy  17, mach.inState('not')
	utest.equal  18, mach.state, 'init'
	)()

# ---------------------------------------------------------------------------
# A very simple machine with states and transitions:
#
#    init --FIRST--> middle --SECOND--> final

(() ->
	class SimpleMachine extends Machine

		constructor: () ->
			super 'init'

		FIRST: () ->
			@expectState 'init'
			@setState 'middle'

		SECOND: () ->
			@expectState 'middle'
			@setState 'final'

	mach1 = new SimpleMachine()

	mach2 = new SimpleMachine()
	mach2.FIRST()

	mach3 = new SimpleMachine()
	mach3.FIRST()
	mach3.SECOND()

	utest.truthy 47, mach1.inState('init')
	utest.truthy 48, mach2.inState('middle')
	utest.truthy 49, mach3.inState('final')

	utest.fails 51, () => mach1.SECOND()
	utest.succeeds 52, () => mach1.FIRST()
	)()
