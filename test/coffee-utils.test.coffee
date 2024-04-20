# coffee-utils.test.coffee

import * as lib1 from '@jdeighan/base-utils/utest'
Object.assign(global, lib1)
import * as lib2 from '@jdeighan/base-utils/coffee-utils'
Object.assign(global, lib2)

# ---------------------------------------------------------------------------

equal 2+2, 4
