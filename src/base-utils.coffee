# base-utils.coffee

import {
	undef, pass, defined, notdefined,
	} from '@jdeighan/base-utils/utils'
import {
	LOG, LOGVALUE, LOGTAML, sep_dash, sep_eq,
	} from '@jdeighan/base-utils/log'
import {
	setDebugging, setCustomDebugLogger,
	} from '@jdeighan/base-utils/debug'
import {isTAML, fromTAML, toTAML} from '@jdeighan/base-utils/taml'
import {
	haltOnError, assert, croak,
	} from '@jdeighan/base-utils/exceptions'

export {
	undef, pass, defined, notdefined,
	LOG, LOGVALUE, LOGTAML, sep_dash, sep_eq,
	setDebugging, setCustomDebugLogger,
	isTAML, fromTAML, toTAML,
	haltOnError, assert, croak,
	}

