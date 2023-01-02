# prefix.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {undef, OL} from '@jdeighan/base-utils'

# --- We use spaces here because Windows Terminal handles TAB chars badly

export vbar = '│'       # unicode 2502
export hbar = '─'       # unicode 2500
export corner = '└'     # unicode 2514
export tee = '├'        # unicode 251C
export arrowhead = '>'
export backarrow = '<'
export space = ' '
export dot = '.'

export fourSpaces  = space  + space     + space     + space
export oneIndent   = vbar   + space     + space     + space
export arrow       = corner + hbar      + arrowhead + space
export flat        = tee    + hbar      + hbar      + space
export resume      = tee    + hbar      + arrowhead + space
export yieldSym    = tee    + backarrow + hbar      + space

# ---------------------------------------------------------------------------

export getPrefix = (level, option='none') ->

	switch option
		when 'plain'
			return oneIndent.repeat(level)
		when 'withArrow'
			if (level == 0)
				return arrow
			else
				return oneIndent.repeat(level-1) + arrow
		when 'withResume'
			if (level == 0)
				return resume
			else
				return oneIndent.repeat(level-1) + resume
		when 'withFlat'
			if (level == 0)
				return flat
			else
				return oneIndent.repeat(level-1) + flat
		when 'withYield'
			if (level == 0)
				return yieldSym
			else
				return oneIndent.repeat(level-1) + yieldSym
		when 'noLastVbar'
			assert (level >= 1),
				"getPrefix(), noLastVbar but level=#{OL(level)}"
			return oneIndent.repeat(level-1) + fourSpaces
		else
			return fourSpaces.repeat(level)

# ---------------------------------------------------------------------------

setCharsAt = (str, pos, str2) =>

	assert (pos >= 0), "negative pos #{pos} not allowed"
	assert (pos < str.length), "pos #{pos} not in #{OL(str)}"
	if (pos + str2.length >= str.length)
		return str.substring(0, pos) + str2
	else
		return str.substring(0, pos) \
				+ str2 \
				+ str.substring(pos + str2.length)

# ---------------------------------------------------------------------------

export addArrow = (prefix) ->

	pos = prefix.lastIndexOf(vbar)
	if (pos == -1)
		result = prefix
	else
		result = setCharsAt(prefix, pos, arrow)
	return result

# ---------------------------------------------------------------------------

export removeLastVbar = (prefix) ->

	pos = prefix.lastIndexOf(vbar)
	if (pos == -1)
		result = prefix
	else
		result = setCharsAt(prefix, pos, ' ')
	return result
