# simple.test.coffee

import {utest} from '@jdeighan/base-utils/utest'
import {deepEqual} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

utest.truthy 8, deepEqual({a:1, b:2}, {a:1, b:2})
utest.falsy  9, deepEqual({a:1, b:2}, {a:1, b:3})
