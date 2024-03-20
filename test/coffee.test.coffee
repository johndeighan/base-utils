# coffee.test.coffee

import {undef} from '@jdeighan/base-utils'
import {brew} from '@jdeighan/base-utils/coffee'
import {succeeds, fails} from '@jdeighan/base-utils/utest'

# ---------------------------------------------------------------------------

succeeds () => brew('v = 5', undef, '!fileExists')
fails    () => brew('let v = 5', undef, '!fileExists')

