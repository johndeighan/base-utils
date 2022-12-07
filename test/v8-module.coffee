# v8-module.coffee

import {
	getMyDirectCaller, getMyOutsideCaller,
	} from '@jdeighan/base-utils/v8-stack'

# ---------------------------------------------------------------------------

export getCallers = () ->

	return secondFunc()

# ---------------------------------------------------------------------------

secondFunc = () ->

	return thirdFunc()

# ---------------------------------------------------------------------------

thirdFunc = () ->

	# --- direct caller should be 'secondFunc'
	#     outside caller should be the function that called getCaller()
	return [getMyDirectCaller(), getMyOutsideCaller()]
