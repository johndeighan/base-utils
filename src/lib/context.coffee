# context.coffee

import {
	undef, deepCopy, words, OL, isString,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG} from '@jdeighan/base-utils/log'
import {
	dbg, dbgEnter, dbgReturn,
	} from '@jdeighan/base-utils/debug'

import {Scope} from '@jdeighan/base-utils/scope'

lBuiltins = words "parseInt process JSON import console",
                  "Function String Number Boolean Object Set",
                  "Math Date"

# ---------------------------------------------------------------------------

export class Context

	constructor: () ->

		@globalScope = new Scope('global', lBuiltins)
		@lScopes = [ @globalScope ]
		@currentScope = @globalScope

	# ..........................................................

	atGlobalLevel: () ->

		result = (@currentScope == @globalScope)
		if result
			assert (@lScopes.length == 1), "more than one scope"
			return true
		else
			return false

	# ..........................................................

	add: (lSymbols...) ->

		dbgEnter "Context.add", lSymbols
		for symbol in lSymbols
			assert isString(symbol), "Not a string: #{symbol}"
			@currentScope.add(symbol)
		dbgReturn "Context.add"
		return

	# ..........................................................

	addGlobal: (symbol) ->

		dbgEnter "Context.addGlobal", symbol
		@globalScope.add(symbol)
		dbgReturn "Context.addGlobal"
		return

	# ..........................................................

	has: (symbol) ->

		for scope in @lScopes
			if scope.has(symbol)
				return true
		return false

	# ..........................................................

	beginScope: (name=undef, lSymbols=[]) ->

		dbgEnter "beginScope", name, lSymbols
		newScope = new Scope(name, lSymbols)
		@lScopes.unshift newScope
		@currentScope = newScope
		dbgReturn "beginScope"
		return

	# ..........................................................

	endScope: () ->

		dbgEnter "endScope"
		@lScopes.shift()    # remove ended scope
		@currentScope = @lScopes[0]
		dbgReturn "endScope"
		return

	# ..........................................................

	dump: () ->

		for scope in @lScopes
			LOG "   SCOPE:"
			scope.dump()
		return
