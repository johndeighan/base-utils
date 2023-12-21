# ll-utils.test.coffee

import test from 'ava'

import {
	undef, pass, assert, defined, notdefined, alldefined,
	isEmpty, nonEmpty, deepCopy,
	} from '@jdeighan/base-utils/ll-utils'
import {getStack, getCaller} from './templib.js'

# ---------------------------------------------------------------------------

test "line 13", (t) => t.is(undef, undefined)
test "line 14", (t) => t.truthy(pass())
test "line 15", (t) => t.truthy(defined(1))
test "line 16", (t) => t.falsy(defined(undefined))
test "line 17", (t) => t.truthy(notdefined(undefined))
test "line 18", (t) => t.falsy(notdefined(12))
test "line 19", (t) => t.notThrows(() => pass())
test "line 20", (t) => t.notThrows(() => assert(12==12, "BAD"))

# ---------------------------------------------------------------------------

test "line 24", (t) => t.truthy(isEmpty(''))
test "line 25", (t) => t.truthy(isEmpty('  \t\t'))
test "line 26", (t) => t.truthy(isEmpty([]))
test "line 27", (t) => t.truthy(isEmpty({}))

test "line 29", (t) => t.truthy(nonEmpty('a'))
test "line 30", (t) => t.truthy(nonEmpty('.'))
test "line 31", (t) => t.truthy(nonEmpty([2]))
test "line 32", (t) => t.truthy(nonEmpty({width: 2}))

# ---------------------------------------------------------------------------

a = undef
b = null
c = 42
d = 'dog'
e = {a: 42}

test "line 42", (t) => t.truthy(alldefined(c,d,e))
test "line 43", (t) => t.falsy(alldefined(a,b,c,d,e))
test "line 44", (t) => t.falsy(alldefined(a,c,d,e))
test "line 45", (t) => t.falsy(alldefined(b,c,d,e))

test "line 47", (t) => t.deepEqual(deepCopy(e), {a: 42})
