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

	# --- TAML uses TAB characters for indentation
	lLines = ['---']
	for line,i in blockToArray(text)
		if (i == 0)
			continue
		[_, prefix, str] = line.match(/^(\s*)(.*)$/)
		str = str.trim()
		assert ! hasChar(prefix, ' '), "space char in prefix: #{OL(line)}"
		lLines.push ' '.repeat(prefix.length) + tamlFix(str)

	return yaml.load(arrayToBlock(lLines), {skipInvalid: true})

# ---------------------------------------------------------------------------

export tamlFix = (str) =>

	if lMatches = str.match(///^
			([A-Za-z_][A-Za-z0-9_]*)    # the key
			\s*
			:
			\s*
			(.*)
			$///)
		[_, key, valStr] = lMatches
		if isEmpty(valStr)
			return "#{key}:"
		else
			return "#{key}: #{fixValStr(valStr)}"
	else
		return str

# ---------------------------------------------------------------------------

export fixValStr = (valStr) =>

	if isEmpty(valStr) \
			|| valStr.match(/^\d+(?:\.\d*)?$/) \
			|| valStr.match(/^\".*\"$/) \
			|| valStr.match(/^\'.*\'$/)
		return valStr
	else
		return "'" + valStr.replace(/'/g, "''") + "'"

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

export toTAML = (obj, hOptions={sortKeys: true}) ->

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
