# prefix.test.coffee

import test from 'ava'

import {
	undef, defined, notdefined, pass, unescapeStr,
	} from '@jdeighan/base-utils/utils'
import {
	getPrefix,
	} from '@jdeighan/base-utils/prefix'

un = unescapeStr

# ---------------------------------------------------------------------------

test "line 16", (t) => t.is(getPrefix(2),                  un('˳˳˳˳˳˳˳˳'))
test "line 17", (t) => t.is(getPrefix(2, 'plain'),         un('│˳˳˳│˳˳˳'))
test "line 18", (t) => t.is(getPrefix(2, 'withArrow'),     un('│˳˳˳└─>˳'))
test "line 19", (t) => t.is(getPrefix(2, 'noLastVbar'),    un('│˳˳˳˳˳˳˳'))
test "line 20", (t) => t.is(getPrefix(2, 'dotLast2Vbars'), un('.˳˳˳˳˳˳˳'))
test "line 21", (t) => t.is(getPrefix(2),                  un('˳˳˳˳˳˳˳˳'))
