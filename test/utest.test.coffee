# utest.test.coffee

import {isString, OL} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'
import {utest, UnitTester} from '@jdeighan/base-utils/utest'

utest.truthy 9, 42
utest.equal 10, 2+2, 4
utest.falsy 11, false
utest.like 12, {a:1, b:2, c:3}, {a:1, c:3}
utest.throws 13, () => throw new Error("bad")
utest.succeeds 14, () => return 'me'

utest.truthy 42
utest.equal 2+2, 4
utest.falsy false
utest.like {a:1, b:2, c:3}, {a:1, c:3}
utest.throws () => throw new Error("bad")
utest.succeeds () => return 'me'

# ---------------------------------------------------------------------------

(() =>
	utest2 = new UnitTester()
	utest2.transformValue = (val) =>
		assert isString(val), "val is #{val}"
		return val.toUpperCase()

	utest2.equal 'abc', 'ABC'
	)()
