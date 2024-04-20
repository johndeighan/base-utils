# utils.coffee

import {
	undef, defined, notdefined, getOptions, CWS,
	shuffle, keys, hasKey,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {LOG} from '@jdeighan/base-utils/log'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'
import {
	mkpath, isFile,
	} from '@jdeighan/base-utils/fs'
import {FileProcessor} from '@jdeighan/base-utils/file-processor'

# ---------------------------------------------------------------------------

export splitEn = (enStr) =>

	dbgEnter 'splitEn', enStr
	lWords = []
	for str in enStr.split(',')
		lWords.push CWS(str)
	dbgReturn 'splitEn', lWords
	return lWords

# ---------------------------------------------------------------------------
# e.g. splits "打扰 dǎ rǎo, 麻烦 má fan"
# into [
#    {zh: '打扰', pinyin: 'dǎ rǎo'}
#    {zh: '麻烦', pinyin: 'má fan'}
#    ]

export splitZh = (zhStr) =>

	lWords = []
	for str in zhStr.split(',')
		if lParts = str.match(///^
				\s*
				([A-Z\u4E00-\u9FFF]+)  # Chinese characters
				(?:
					\s*
					[\!\?]
					)?
				\s+
				([A-Za-z\s'āáǎàēéěèīíǐìōóǒòūúǔùǖüǘǚǜ]+)
				(?:
					\s*
					[\!\?]
					)?
				\s*
				$///)
			[_, zh, pinyin] = lParts
			lWords.push {
				zh: CWS(zh)
				pinyin: CWS(pinyin)
				}
		else
			croak "splitZh('#{zhStr}') - bad zh string"
	return lWords

# ---------------------------------------------------------------------------
# --- Should handle lines in:
#        test.zh
#        keepers.zh
#        nouns.zh, etc.

export line2hWord = (line) ->

	dbgEnter 'line2hWord', line
	if notdefined(line) || (line.length == 0)
		dbgReturn 'line2hWord', undef
		return undef
	else if lMatches = line.match(///^
			\s*
			(?:
				([0-9]+) # one or more digits
				\s*
				)?
			(?:
				(\*+)    # some number of * chars
				\s*
				)?
			(?:         # optional empty checkbox
				□
				\s*
				)?
			\s*         # skip white space
			(.*)        # the rest
			$///)
		[_, numStr, astStr, rest] = lMatches
		dbg "rest = '#{rest}'"

		# --- get number of correct tests
		num = 0
		if defined(numStr)
			num = parseInt(numStr, 10)
		if defined(astStr)
			num += astStr.length

		pos = rest.indexOf('-')
		dbg "pos = #{pos}"

		zhStr = rest.substring(0, pos)
		enStr = rest.substring(pos+1)
		dbg "zhStr = '#{zhStr}'"
		dbg "enStr = '#{enStr}'"

		hWord = {
			num
			zh:     splitZh(zhStr)
			en:     splitEn(enStr)
			}
		addKey hWord
		dbgReturn 'line2hWord', hWord
		return hWord
	else
		croak "Bad line: '#{line}'"

# ---------------------------------------------------------------------------

export zh_pinyin = (h) ->

	return "#{h.zh} #{h.pinyin}"

# ---------------------------------------------------------------------------

export zhStr = (hWord) ->

	lParts = for h in hWord.zh
		zh_pinyin(h)
	return lParts.join(', ')

# ---------------------------------------------------------------------------

export enStr = (hWord) ->

	return hWord.en.join(', ')

# ---------------------------------------------------------------------------

export hWord2line = (hWord, hOptions={}) ->

	{box, number} = getOptions hOptions, {
		box: false
		number: true
		}
	str = ""
	if number
		str += "#{hWord.num} "
	if box
		str += "□ "
	str += "#{zhStr(hWord)} - #{enStr(hWord)}\n"
	return str

# ---------------------------------------------------------------------------

export addKey = (hWord) ->

	lParts = [hWord.en.join('/')]
	for h in hWord.zh
		lParts.push h.zh
		lParts.push h.pinyin
	key = lParts.join '/'
	hWord.key = key
	return

# ---------------------------------------------------------------------------

export getWords = (hOptions={}) ->
	# --- path can be a file or a directory
	#     words are ordered by hWord.num, but
	#        scrambled for words w/same num

	dbgEnter 'getWords', hOptions
	{path, debug, limit, filter, lExclude
			} = getOptions hOptions, {
		path: './words'
		debug: false
		filter: (h) -> return (h.ext == '.zh')
		lExclude: []
		}

	# --- { <num>: [hWord, ...] }
	hWords = {}

	addWord = (h) =>
		num = h.num
		if hasKey(hWords, num)
			hWords[num].push h
		else
			hWords[num] = [h]

	fp = new FileProcessor(path, {debug})
	fp.filter = filter
	fp.handleLine = (line, lineNum, hFileInfo) ->
		hWord = line2hWord(line)
		if lExclude.includes hWord.key
			return
		hWord.filePath = hFileInfo.filePath
		hWord.lineNum = lineNum
		addWord hWord
	fp.go()

	lWords = []
	for num in keys(hWords)
		shuffle hWords[num]
		lWords.push ...hWords[num]

	# --- lWords is an array of all words, ordered by
	#     num, but scrambled within a num

	if defined(limit)
		lWords = lWords.slice(0, limit)
	dbgReturn 'getWords', lWords
	return lWords

# ---------------------------------------------------------------------------

export getTestWords = (hOptions={}) ->

	lTestWords = getWords getOptions(hOptions, {
		path: './test.zh'
		})
	totalCount = 0
	for hWord in lTestWords
		totalCount += hWord.num
	assert (totalCount > 5), "Bad test file"
	return lTestWords
