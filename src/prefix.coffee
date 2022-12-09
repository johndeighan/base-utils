# prefix.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {undef, OL, setCharsAt} from '@jdeighan/base-utils/utils'

# --- We use spaces here because Windows Terminal handles TAB chars badly

export vbar = '│'       # unicode 2502
export hbar = '─'       # unicode 2500
export corner = '└'     # unicode 2514
export tee = '├'        # unicode 251C
export arrowhead = '>'
export space = ' '
export dot = '.'

export fourSpaces  = space  + space + space     + space
export oneIndent   = vbar   + space + space     + space
export arrow       = corner + hbar  + arrowhead + space
export flat        = tee    + hbar  + hbar      + space
export dotIndent   = dot    + space + space     + space

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
		when 'withFlat'
			if (level == 0)
				return flat
			else
				return oneIndent.repeat(level-1) + flat
		when 'noLastVbar'
			assert (level >= 1),
				"getPrefix(), noLastVbar but level=#{OL(level)}"
			return oneIndent.repeat(level-1) + fourSpaces
		when 'dotLast2Vbars'
			assert (level >= 2),
				"getPrefix(), dotLast2Vbars but level=#{OL(level)}"
			return oneIndent.repeat(level-2) + dotIndent + fourSpaces
		else
			return fourSpaces.repeat(level)

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
