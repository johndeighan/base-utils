# tamlFix.test.coffee

import test from 'ava'

import {assert, croak} from '@jdeighan/base-utils'
import {undef} from '@jdeighan/base-utils/utils'
import {LOG} from '@jdeighan/base-utils/log'
import {tamlFix, fixValStr} from '@jdeighan/base-utils/taml'

# ---------------------------------------------------------------------------

test "line 12", (t) =>
	t.is fixValStr(""), ""

test "line 15", (t) =>
	t.is fixValStr("5"), "5"

test "line 18", (t) =>
	t.is fixValStr("'abc'"), "'abc'"

test "line 21", (t) =>
	t.is fixValStr('"5"'), '"5"'

test "line 24", (t) =>
	t.is fixValStr('abc'), "'abc'"

test "line 27", (t) =>
	t.is fixValStr("ab'cd"), "'ab''cd'"
