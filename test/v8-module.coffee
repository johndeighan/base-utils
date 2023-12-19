# v8-module.coffee

import {
	getMyDirectCaller, getMyOutsideCaller,
	} from '@jdeighan/base-utils/ll-v8-stack'

# ---------------------------------------------------------------------------

export getBoth = () ->

	return secondFunc('both')

# ---------------------------------------------------------------------------

export getDirect = () ->

	return secondFunc('direct')

# ---------------------------------------------------------------------------

export getOutside = () ->

	return secondFunc('outside')

# ---------------------------------------------------------------------------

secondFunc = (type) ->

	return thirdFunc(type)

# ---------------------------------------------------------------------------

thirdFunc = (type) ->

	# --- direct caller should be 'secondFunc'
	#     outside caller should be the function that called getCaller()
	switch type
		when 'both'
			return [getMyDirectCaller(), getMyOutsideCaller()]
		when 'direct'
			return getMyDirectCaller()
		when 'outside'
			return getMyOutsideCaller()
		else
			croak "Unknown type: #{type}"
