# peggy.test.coffee

import {
	undef, defined, notdefined, toArray, CWSALL,
	} from '@jdeighan/base-utils'
import {setDebugging} from '@jdeighan/base-utils/debug'
import {assert} from '@jdeighan/base-utils/exceptions'
import * as lib from '@jdeighan/base-utils/peggy'
Object.assign(global, lib)
import {
	u, equal, succeeds, fails,
	} from '@jdeighan/base-utils/utest'

u.transformValue = (peggyCode) ->
	try
		jsCode = convertToJS peggyCode, {type: 'coffee'}
		assert defined(jsCode), "empty jsCode"
		return CWSALL(jsCode)
	catch err
		console.log "ERROR: #{err.message}"
		return "ERROR: #{err.message}"

u.transformExpected = (jsCode) ->
	return CWSALL(jsCode.replaceAll("\t", "  "))

# ---------------------------------------------------------------------------

equal """
	INITIALIZATION
		import {undef} from '@jdeighan/base-utils'

	""", """
	{{
	import {
	  undef
	} from '@jdeighan/base-utils';
	}}
	"""

# ---------------------------------------------------------------------------

equal """
	primitive
		".undef."
			return undef

		".null."
			return null
	""", """
	primitive
	  = ".undef."
		{
		return undef;
		}

	  / ".null."
		{
		return null;
		}
	"""

# ---------------------------------------------------------------------------

equal """
	bare_str
		lChars:[^\\n]+
			return CWS(mkword(lChars))

	""", """
	bare_str
	  = lChars:[^\\n]+
		{
		return CWS(mkword(lChars));
		}
	"""

# ---------------------------------------------------------------------------

equal """
	bare_str
		lChars:[^\\n]+
		ws
			return CWS(mkword(lChars))

	""", """
	bare_str
	  = lChars:[^\\n]+ ws
		{
		return CWS(mkword(lChars));
		}
	"""

# ---------------------------------------------------------------------------

equal """
	primitive
		".undef."
			return undef

		".null."
			return null

	bare_str
		lChars:[^\\n]+
			return CWS(mkword(lChars))

	""", """
	primitive
	  = ".undef."
		{
		return undef;
		}

	  / ".null."
		{
		return null;
		}

	bare_str
	  = lChars:[^\\n]+
		{
		return CWS(mkword(lChars));
		}
	"""

# ---------------------------------------------------------------------------

equal """
	INITIALIZATION

		import {undef} from '@jdeighan/base-utils'

	primitive

		".undef."
			return undef

		".null."
			return null
	""", """
	{{
	import {
	  undef
	} from '@jdeighan/base-utils';
	}}
	primitive
	  = ".undef."
		{
		return undef;
		}

	  / ".null."
		{
		return null;
		}
	"""

# ---------------------------------------------------------------------------

equal """
	INITIALIZATION
		import {undef, defined} from '@jdeighan/base-utils'
		import {LOG, LOGVALUE} from '@jdeighan/base-utils/log'

	EACH_PARSE
		# --- add terminating newline
		if notdefined(options.startRule)
			input += newline
	""", """
	{{
	import {
	  undef,
	  defined
	} from '@jdeighan/base-utils';

	import {
	  LOG,
	  LOGVALUE
	} from '@jdeighan/base-utils/log';
	}}
	{
	// --- add terminating newline
	if (notdefined(options.startRule)) {
	  input += newline;
	}
	}
	"""
