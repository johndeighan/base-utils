# prefix.test.coffee

import {
	undef, defined, notdefined, pass, escapeStr,
	} from '@jdeighan/base-utils'
import * as lib from '@jdeighan/base-utils/prefix'
Object.assign(global, lib)
import {equal} from '@jdeighan/base-utils/utest'

un = (str) =>

	return escapeStr(str, {
	'▼': "\n"
	'→': "\t"
	'˳': " "
	})

# ---------------------------------------------------------------------------

equal getPrefix(2),               un('˳˳˳˳˳˳˳˳')
equal getPrefix(2, 'plain'),      un('│˳˳˳│˳˳˳')
equal getPrefix(2, 'withArrow'),  un('│˳˳˳└─>˳')
equal getPrefix(2, 'noLastVbar'), un('│˳˳˳˳˳˳˳')
equal getPrefix(2),               un('˳˳˳˳˳˳˳˳')
