# scope.test.coffee

import * as ulib from '@jdeighan/base-utils/utest'
Object.assign(global, ulib)
import {Scope} from '@jdeighan/base-utils/scope'

scope = new Scope('global', ['main'])
scope.add('func')

truthy scope.has('main')
truthy scope.has('func')
falsy  scope.has('notthere')

