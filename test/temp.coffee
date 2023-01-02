# temp.coffee

import {
	isClass, isConstructor, OL, jsType,
	} from '@jdeighan/base-utils'

func = (x) ->
	return 42

for x in [func, 42, 'abc', {a: 13}]
	console.log()
	console.log "x = #{OL(x)}"

	type = jsType(x)
	console.log "jsType() returned #{OL(type)}"

	result = isClass(func)
	console.log "isClass() returned #{result}"

	result = isConstructor(func)
	console.log "isConstructor() returned #{result}"

