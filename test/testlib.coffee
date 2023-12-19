# testlib.coffee

import {undef} from '@jdeighan/base-utils'
import {
	getMyOutsideCaller,
	} from '@jdeighan/base-utils/ll-v8-stack'

# ---------------------------------------------------------------------------

export getMyCaller = () =>

	func1()
	return func2()

# ---------------------------------------------------------------------------

func1 = () ->

	return

# ---------------------------------------------------------------------------

func2 = () ->
	hNode = getMyOutsideCaller()
	return hNode
