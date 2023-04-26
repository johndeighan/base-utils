# machine.test.coffee

import test from 'ava'
import {utest} from '@jdeighan/base-utils/utest'

import {
	undef, defined, notdefined, pass, escapeStr,
	} from '@jdeighan/base-utils'
import {Machine} from '@jdeighan/base-utils/machine'

# ---------------------------------------------------------------------------

(() ->
	mach = new Machine('init')

	utest.truthy 16, mach.isState('init')
	utest.falsy  17, mach.isState('not')
	utest.equal  18, mach.curState, 'init'
	)()

# ---------------------------------------------------------------------------

(() ->
	mach = new Machine('init')
	mach.on 'init', 'loaded', 'loaded'
	mach.emit 'loaded'

	utest.truthy 28, mach.isState('init')
	utest.truthy 29, mach.isState('loaded')
	utest.falsy  30, mach.isState('not')
	utest.equal  31, mach.curState, 'loaded'
	)()
