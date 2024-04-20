# context.test.coffee

import * as ulib from '@jdeighan/base-utils/utest'
Object.assign(global, ulib)
import {Context} from '@jdeighan/base-utils/context'

context = new Context()
context.add 'main', 'func'

context.beginScope()
context.add 'func2', 'func3'

truthy context.has('main')
truthy context.has('func')
truthy context.has('func3')
falsy  context.has('notthere')

context.endScope()

truthy context.has('main')
truthy context.has('func')
falsy  context.has('func3')
falsy  context.has('notthere')
