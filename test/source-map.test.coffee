# source-map.test.coffee

import test from 'ava'

import {parsePath} from '@jdeighan/base-utils/ll-utils'
import {
	getRawMap, mapSourcePos,
	} from '@jdeighan/base-utils/source-map'

rawMap = getRawMap("./test/source.js.map")
hFrame = parsePath("./test/source.js")  # no line or column yet
hFrame.line = 9
hFrame.column = 0

hMapped = mapSourcePos(hFrame)

test "line 17", (t) => t.truthy(rawMap.indexOf('func1') > 0)
test "line 18", (t) => t.truthy(rawMap.indexOf('func2') > 0)
test "line 19", (t) => t.falsy(rawMap.indexOf('func3') > 0)

# ---------------------------------------------------------------------------

(() =>
	test "line 24", (t) => t.is(hMapped.line, 9)
	)()
