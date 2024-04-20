# ast-walker.test.coffee

import {
	defined, nonEmpty, toBlock, OL, words, keys, hasKey,
	} from '@jdeighan/base-utils'
import {
	LOG, LOGVALUE, clearMyLogs, getMyLogs,
	} from '@jdeighan/base-utils/log'
import {
	setDebugging, getDebugLog,
	} from '@jdeighan/base-utils/debug'
import * as ulib from '@jdeighan/base-utils/utest'
Object.assign(global, ulib)
import {mkpath, slurp} from '@jdeighan/base-utils/fs'
import {indented} from '@jdeighan/base-utils/indent'

import {ASTWalker} from '@jdeighan/base-utils/ast-walker'

lKeys = words('lImported lExported lUsed lMissing lNotNeeded')

u.transformValue = (coffeeCode) ->
	walker = new ASTWalker(coffeeCode)
	return walker.walk()

u.transformExpected = (h) ->
	# --- All unspecified keys should be empty arrays
	for key in lKeys
		if ! hasKey(h, key)
			h[key] = []
	return h

# ---------------------------------------------------------------------------
# Test keeping track of imported symbols

equal """
	LOG someSymbol
	""",
	{
		lUsed: words('LOG someSymbol')
		lMissing: words('LOG someSymbol')
		}

equal """
	import {toArray, toBlock} from '@jdeighan/coffee-utils'
	import {LOG} from '@jdeighan/coffee-utils/log'
	LOG someSymbol
	""",
	{
		lImported: words('LOG toArray toBlock')
		lUsed: words('LOG someSymbol')
		lNotNeeded: words('toArray toBlock')
		lMissing: ['someSymbol']
		}

equal """
	import {toArray, toBlock} from '@jdeighan/coffee-utils'
	import {arrayToBlock} from '@jdeighan/coffee-utils/block'
	export {toArray, arrayToBlock}
	""",
	{
		lImported: words('arrayToBlock toArray toBlock')
		lExported: words('arrayToBlock toArray')
		lNotNeeded: ['toBlock']
		}

equal """
	import {toArray, toBlock} from '@jdeighan/coffee-utils'
	import {arrayToBlock} from '@jdeighan/coffee-utils/block'
	export class ASTWalker
		constructor: (from) ->
			debug "enter ASTWalker()"
	""",
	{
		lImported: words('arrayToBlock toArray toBlock')
		lExported: words('ASTWalker')
		lUsed: ['debug']
		lMissing: words('debug')
		lNotNeeded: words('arrayToBlock toArray toBlock')
		}

equal """
	export toBlock = (lItems) ->
		return lItems.join("\n")
	""",
	{
		lExported: ['toBlock']
		lUsed: ['lItems']
		}

equal """
	export meaning = 42
	""",
	{
		lExported: ['meaning']
		}

equal """
	import {undef} from '@jdeighan/coffee-utils'
	x = undef
	""",
	{
		lImported: ['undef']
		lUsed: ['undef']
		}

equal """
	import {undef} from '@jdeighan/coffee-utils'
	x = undef
	y = x
	""",
	{
		lImported: ['undef']
		lUsed: ['undef','x']
		}

equal """
	x = undef
	""",
	{
		lUsed: ['undef']
		lMissing: ['undef']
		}

equal """
	func = () ->
		return undef
	x = func()
	""",
	{
		lUsed: ['func','undef']
		lMissing: ['undef']
		}

equal """
	x = toArray("abc")
	""",
	{
		lUsed: ['toArray']
		lMissing: ['toArray']
		}

equal """
	import {undef, toArray} from '@jdeighan/coffee-utils'
	x = toArray("abc")
	""",
	{
		lUsed: ['toArray']
		lImported: words('toArray undef')
		lNotNeeded: ['undef']
		}

equal """
	import {undef, toArray} from '@jdeighan/coffee-utils'
	x = str + toArray("abc")
	""",
	{
		lImported: words('toArray undef')
		lMissing: ['str']
		lNotNeeded: ['undef']
		lUsed: words('str toArray')
		}

equal """
	func = (x,y) ->
		z = x+y
		return z
	w = func(1,2)
	""",
	{
		lUsed: words('func x y z')
		}

equal """
	func = (x,y) ->
		z = sum(x+y)
		return z
	""", {
		lUsed: words('sum x y z')
		lMissing: ['sum']
		}

equal """
	func = (x,y) ->
		z = sum(x+y)
		return z
	""",
	{
		lMissing: ['sum']
		lUsed: words('sum x y z')
		}

equal """
	export isHashComment = (line) =>
		return defined(line)
	""",
	{
		lExported: ['isHashComment']
		lMissing: ['defined']
		lUsed: words('defined line')
		}

equal """
	export isHashComment = (line) ->
		return defined(line)
	""",
	{
		lExported: ['isHashComment']
		lMissing: ['defined']
		lUsed: words('defined line')
		}

equal """
	export isSubclassOf = (subClass, superClass) ->

		return (subClass == superClass) \
			|| (subClass.prototype instanceof superClass)
	""",
	{
		lExported: ['isSubclassOf']
		lUsed: words('subClass superClass')
		}

equal """
	export patchStr = (bigstr, pos, str) ->

		endpos = pos + str.length
		if (endpos < bigstr.length)
			return bigstr.substring(0, pos) + str + bigstr.substring(endpos)
		else
			return bigstr.substring(0, pos) + str
	""",
	{
		lExported: ['patchStr']
		lUsed: words('bigstr endpos pos str')
		}

equal """
	delete h[key]
	""",
	{
		lMissing: words('h key')
		lUsed: words('h key')
		}

equal """
	export removeKeys = (h, lKeys) =>

		for key in lKeys
			delete h[key]
		for own key,value of h
			if defined(value)
				if isArray(value)
					for item in value
						if isHash(item)
							removeKeys(item, lKeys)
				else if (typeof value == 'object')
					removeKeys value, lKeys
		return
	""",
	{
		lExported: ['removeKeys']
		lMissing: words('defined isArray isHash')
		lUsed: words('defined h isArray isHash item key lKeys removeKeys value')
		}
