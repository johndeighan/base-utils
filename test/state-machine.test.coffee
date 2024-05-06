# state-machine.test.coffee

import {
	undef, defined, notdefined, pass, escapeStr, OL, isArray,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'
import * as lib from '@jdeighan/base-utils/utest'
Object.assign(global, lib)
import * as lib2 from '@jdeighan/base-utils/state-machine'
Object.assign(global, lib2)

# ---------------------------------------------------------------------------

(() ->
	mach = new StateMachine()

	truthy mach.inState('start')
	equal  mach.state, 'start'
	falsy  mach.inState('not')
	succeeds () => mach.expectState('start','not')
	fails () => mach.expectState('xxx','not')
	falsy mach.allDefined('flag','str')
	)()

# ---------------------------------------------------------------------------

(() ->
	mach = new StateMachine('init', {flag: true, str: 'a string'})

	truthy mach.inState('init')
	falsy  mach.inState('not')
	equal  mach.state, 'init'
	succeeds () => mach.expectState('init','not')
	fails () => mach.expectState('xxx','not')
	truthy mach.allDefined('flag','str')
	falsy mach.allDefined('flag','str','notdef')
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
			@state = 'middle'

		SECOND: () ->
			@expectState 'middle'
			@state = 'final'

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

# ---------------------------------------------------------------------------
# A more comples machine that simulates parsing CoffeeScript

(() ->
	class CoffeeStateMachine extends StateMachine

		constructor: () ->
			super()
			@setVar 'lLines', []

		START_IMPORT: () ->
			@expectState 'start'
			@setState 'importing', {lIdents: []}
			return this

		IDENT: (name) ->
			@expectState 'importing'
			@appendVar 'lIdents', name
			return this

		END_IMPORT: (source) ->
			@expectState 'importing'
			lIdents = @getVar 'lIdents'
			assert isArray(lIdents), "Not an array: #{OL(lIdents)}"
			identStr = lIdents.join(',')
			@appendVar 'lLines', "import {#{identStr}} from '#{source}';"
			@setState 'start', {lIdents: undef}
			return this

		ASSIGN: (name, num) ->
			@expectState 'start'
			@appendVar 'lLines', "#{name} = #{num};"

		getCode: () ->
			return @getVar('lLines').join("\n")

	mach = new CoffeeStateMachine()
	mach.START_IMPORT()
	mach.IDENT('x')
	mach.IDENT('y')
	mach.END_IMPORT('@jdeighan/base-utils')
	mach.ASSIGN('x', 42)
	mach.ASSIGN('y', 13)

	truthy mach.inState('start')
	equal mach.getCode(), """
		import {x,y} from '@jdeighan/base-utils';
		x = 42;
		y = 13;
		"""
	)()
