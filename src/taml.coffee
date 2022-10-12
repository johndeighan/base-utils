# taml.coffee

import yaml from 'js-yaml'

import {assert, croak} from '@jdeighan/exceptions'
import {
	defined, notdefined, isEmpty, isString, isObject,
	blockToArray, arrayToBlock,
	hasChar, escapeStr, chomp, OL,
	} from '@jdeighan/exceptions/utils'

# ---------------------------------------------------------------------------
#   isTAML - is the string valid TAML?

export isTAML = (text) ->

	return isString(text) && text.match(/^---$/m)

# ---------------------------------------------------------------------------
#   taml - convert valid TAML string to a JavaScript value

export fromTAML = (text) ->

	assert defined(text), "text is undef"
	assert isTAML(text), "string #{OL(text)} isn't TAML"

	lLines = for line in blockToArray(text)
		[_, prefix, str] = line.match(/^(\s*)(.*)$/)
		assert ! hasChar(prefix, ' '), "space char in prefix: #{OL(line)}"
		level = prefix.length
		newPrefix = ' '.repeat(level)
		if lMatches = line.match(///^
				([A-Za-z_][A-Za-z0-9_]*)    # the key
				\s*
				:
				\s*
				(.*)
				$///)
			[_, key, text] = lMatches
			if isEmpty(text) || text.match(/\d+(?:\.\d*)$/)
				newPrefix + str
			else
				newPrefix + key + ':' + ' ' + squote(text)
		else
			newPrefix + str

	return yaml.load(arrayToBlock(lLines), {skipInvalid: true})

# ---------------------------------------------------------------------------
# --- a replacer is (key, value) -> newvalue

myReplacer = (name, value) ->

	if isString(value)
		return escapeStr(value)
	else if isObject(value, ['tamlReplacer'])
		return value.tamlReplacer()
	else
		return value

# ---------------------------------------------------------------------------

export toTAML = (obj, hOptions={}) ->

	{useTabs, sortKeys, escape, replacer} = hOptions
	if notdefined(replacer)
		replacer = myReplacer
	str = yaml.dump(obj, {
		skipInvalid: true
		indent: 3
		sortKeys: !!sortKeys
		lineWidth: -1
		replacer
		})
	if useTabs
		str = str.replace(/   /g, "\t")
	return "---\n" + chomp(str)

# ---------------------------------------------------------------------------

squote = (text) ->

	return "'" + text.replace(/'/g, "''") + "'"
