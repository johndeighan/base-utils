# bin-utils.coffee

import {sprintf} from 'sprintf-js'
import {undef, OL, isString} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'

# ---------------------------------------------------------------------------

export fmt = (n1, n2, n3, desc) =>

	return sprintf("%3d %3d %3d", n1, n2, n3) + ' - ' + desc

# ---------------------------------------------------------------------------
# --- get project name from its directory path

export proj = (dir) =>

	lMatches = dir.match(/\/([^\/]+)$/)
	if lMatches
		return lMatches[1]
	else
		return dir
