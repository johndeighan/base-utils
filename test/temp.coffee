# temp.coffee = from utils.test.coffee

import {undef, pass} from '@jdeighan/base-utils/utils'

# ----------------------------------------------------

class NewClass

	constructor: () ->
		@name = 'bob'
		@doIt = pass

	meth: (x) ->
		return 2 * x

o = new NewClass()

console.log o
