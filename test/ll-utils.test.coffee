# ll-utils.test.coffee

import test from 'ava'

import {
	undef, mydir, pass, assert, defined, notdefined, alldefined,
	isEmpty, nonEmpty, getFullPath, deepCopy,
	} from '@jdeighan/base-utils/ll-utils'
import {getStack, getCaller} from './templib.js'

dir = mydir(import.meta.url)
fullPath = getFullPath('.')

# ---------------------------------------------------------------------------

test "line 16", (t) => t.is(undef, undefined)
test "line 17", (t) => t.truthy(dir.match(/\/base\-utils\/test$/))
test "line 18", (t) => t.truthy(pass())
test "line 19", (t) => t.truthy(defined(1))
test "line 20", (t) => t.falsy(defined(undefined))
test "line 21", (t) => t.truthy(notdefined(undefined))
test "line 22", (t) => t.falsy(notdefined(12))
test "line 23", (t) => t.notThrows(() => pass())
test "line 24", (t) => t.notThrows(() => assert(12==12, "BAD"))

# ---------------------------------------------------------------------------

test "line 28", (t) => t.truthy(isEmpty(''))
test "line 29", (t) => t.truthy(isEmpty('  \t\t'))
test "line 30", (t) => t.truthy(isEmpty([]))
test "line 31", (t) => t.truthy(isEmpty({}))

test "line 33", (t) => t.truthy(nonEmpty('a'))
test "line 34", (t) => t.truthy(nonEmpty('.'))
test "line 35", (t) => t.truthy(nonEmpty([2]))
test "line 36", (t) => t.truthy(nonEmpty({width: 2}))

test "line 38", (t) => t.is(fullPath, "C:/Users/johnd/base-utils")

# ---------------------------------------------------------------------------

a = undef
b = null
c = 42
d = 'dog'
e = {a: 42}

test "line 48", (t) => t.truthy(alldefined(c,d,e))
test "line 49", (t) => t.falsy(alldefined(a,b,c,d,e))
test "line 50", (t) => t.falsy(alldefined(a,c,d,e))
test "line 51", (t) => t.falsy(alldefined(b,c,d,e))

test "line 53", (t) => t.deepEqual(deepCopy(e), {a: 42})
