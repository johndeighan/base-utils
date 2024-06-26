# coffee.test.coffee

import {undef} from '@jdeighan/base-utils'
import * as lib from '@jdeighan/base-utils/coffee'
Object.assign(global, lib)
import {succeeds, fails} from '@jdeighan/base-utils/utest'

# ---------------------------------------------------------------------------

succeeds () => brew('v = 5')
fails    () => brew('let v = 5')

succeeds () => toAST('v = 5')
fails    () => toAST('let v = 5')

