# stringify.test.coffee

import test from 'ava'

import {undef, escapeStr} from '@jdeighan/base-utils/utils'
import {
	stringify, tamlStringify, orderedStringify,
	} from '@jdeighan/base-utils/log'

test "line 10", (t) =>
	t.deepEqual orderedStringify(['a', 42, [1,2]]), """
		---
		- a
		- 42
		-
		   - 1
		   - 2
		"""
