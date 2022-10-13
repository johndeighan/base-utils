# taml.coffee

import yaml from 'js-yaml'
import {strict as assert} from 'node:assert'

import {
	undef, defined, notdefined, isEmpty, isString, isObject,
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

	if (value == undef)
		# --- We need this, otherwise js-yaml will convert undef to null
		return "<UNDEFINED_VALUE>"
	if isString(value)
		return escapeStr(value)
#	else if isObject(value, ['tamlReplacer'])
#		return value.tamlReplacer()
	else
		return value

# ---------------------------------------------------------------------------

export toTAML = (obj, hOptions={}) ->

	if (obj == undef)
		return "---\nundef"
	if (obj == null)
		return "---\nnull"
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
	str = str.replace(/<UNDEFINED_VALUE>/g, 'undef')
	if useTabs
		str = str.replace(/   /g, "\t")
	return "---\n" + chomp(str)

# ---------------------------------------------------------------------------

squote = (text) ->

	return "'" + text.replace(/'/g, "''") + "'"
