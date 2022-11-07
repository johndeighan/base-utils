# temp.test.coffee = from utils.test.coffee

import test from 'ava'

import {
	undef, pass, defined, notdefined, untabify, prefixBlock,
	escapeStr, unescapeStr, OL, inList,
	isString, isNumber, isInteger, isHash, isArray, isBoolean,
	isConstructor, isFunction, isRegExp, isObject, jsType,
	isEmpty, nonEmpty,
	blockToArray, arrayToBlock,

	chomp, rtrim, setCharsAt, words, firstWord,
	hasChar, quoted, getOptions,
	} from '@jdeighan/base-utils/utils'

# ---------------------------------------------------------------------------

class NewClass

	constructor: (@name = 'bob') ->
		@doIt = pass

	meth: (x) ->
		return 2 * x

o = new NewClass()

test "line 204", (t) => t.truthy(isObject(o, "name doIt meth"))


