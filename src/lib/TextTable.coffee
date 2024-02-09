# --- TextTable.coffee

import {sprintf} from 'sprintf-js'
import {
	undef, defined, notdefined, getOptions, words, OL, range, hasKey,
	pad, toBlock, LOG, isEmpty, nonEmpty, isNonEmptyString,
	jsType, isString, isNumber, isArray, isArrayOfStrings,
	isFunction,
	} from '@jdeighan/base-utils'
import {
	assert, croak,
	} from '@jdeighan/base-utils/exceptions'
import {
	dbgEnter, dbgReturn, dbg, dbgCall,
	} from '@jdeighan/base-utils/debug'

hAlignWords = {
	l: 'left'
	c: 'center'
	r: 'right'
	}

lOpCodes = words('labels data sep fullsep total subtotal literal')

# ---------------------------------------------------------------------------

export class TextTable

	constructor: (formatStr, hOptions={}) ->
		# --- Valid options:
		#        decPlaces - used for numbers with no % style format
		#                    default: 2
		#        parseNumbers - string data that looks like a number
		#                       is treated as a number, default: false

		dbgEnter 'TextTable', formatStr, hOptions
		assert defined(formatStr), "missing format string"
		@hOptions = getOptions hOptions, {
			decPlaces: 2
			parseNumbers: false
			}

		lWords = words(formatStr)
		@numCols = lWords.length
		dbg 'numCols', @numCols

		@lColAligns  = new Array(@numCols)
		@lColFormats = new Array(@numCols)

		for word,colNum in lWords
			if (lMatches = word.match(/^(l|c|r)(\%\S+)?$/))
				[_, align, fmt] = lMatches
				alignWord = hAlignWords[align]
				assert defined(alignWord), "Bad format string: #{OL(formatStr)}"
				@lColAligns[colNum] = alignWord
				@lColFormats[colNum] = fmt       # may be undef
			else
				croak "Bad format string: #{OL(formatStr)}"

		dbg 'lColFormats', @lColFormats
		dbg 'lColAligns', @lColAligns

		# --- Items in @lRows must be a hash w/key 'opcode'
		@lRows = []
		@lColWidths = new Array(@numCols).fill(0)
		@totalWidth = undef
		@closed = false

		# --- Accumulate totals and subtotals
		#     When a subtotal row is added, subtotals are reset to 0
		@lColTotals    = new Array(@numCols).fill(undef)
		@lColSubTotals = new Array(@numCols).fill(undef)

	# ..........................................................

	resetSubTotals: () ->

		@lColSubTotals.fill(undef)
		return

	# ..........................................................

	alignItem: (item, colNum) ->

		assert @closed, "table not closed"
		assert isString(item), "Not a string: #{OL(item)}"
		if (item.length == width)
			return item
		align = @lColAligns[colNum]
		assert ['left','center','right'].includes(align), \
				"Bad align parm: #{OL(align)}"
		width = @lColWidths[colNum]
		return pad(item, width, "justify=#{align}")

	# ..........................................................

	formatItem: (item, colNum) ->

		if notdefined(item)
			return ''
		fmt = @lColFormats[colNum]
		if defined(fmt)
			return sprintf(fmt, item)
		else if isString(item)
			return item
		else if isNumber(item)
			return item.toFixed(@hOptions.decPlaces)
		else
			return OL(item)

	# ..........................................................

	dumpInternals: () ->

		LOG 'lColAligns', @lColAligns
		LOG 'lColFormats:', @lColFormats
		LOG 'numCols:', @numCols
		if nonEmpty(@lRows)
			LOG 'lRows:', @lRows
		if nonEmpty(@lColWidths)
			LOG 'lColWidths:', @lColWidths
		if defined(@totalWidth)
			LOG 'totalWidth', @totalWidth
		if nonEmpty(@lColTotals)
			LOG 'lColTotals:', @lColTotals
		if nonEmpty(@lColSubTotals)
			LOG 'lColSubTotals:', @lColSubTotals
		return

	# ..........................................................

	adjustColWidths: (lFormatted) ->

		for str,colNum in lFormatted
			assert isString(str), "Not a string: #{OL(str)}"
			if (str.length > @lColWidths[colNum])
				@lColWidths[colNum] = str.length
		return

	# ..........................................................

	accum: (num, colNum) ->

		assert isNumber(num), "Not a number: #{OL(num)}"

		if defined(@lColTotals[colNum])
			@lColTotals[colNum] += num
		else
			@lColTotals[colNum] = num

		if defined(@lColSubTotals[colNum])
			@lColSubTotals[colNum] += num
		else
			@lColSubTotals[colNum] = num

		return

	# ..........................................................

	flatten: (lRow) ->

		if (lRow.length == 1) && isArray(lRow[0])
			return lRow[0]
		return lRow

	# ..........................................................

	labels: (lRow...) ->

		lRow = @flatten(lRow)
		dbgEnter 'labels', lRow
		assert ! @closed, "table is closed"
		assert isArray(lRow), "Not an array: #{OL(lRow)}"
		assert (lRow.length == @numCols), "lRow = #{OL(lRow)}"
		@adjustColWidths lRow
		@lRows.push {
			opcode: 'labels'
			lFormatted: lRow
			}
		dbgReturn 'labels'
		return

	# ..........................................................

	data: (lRow...) ->

		lRow = @flatten(lRow)
		dbgEnter 'data', lRow
		assert ! @closed, "table is closed"
		assert (lRow.length == @numCols), "lRow = #{OL(lRow)}"
		lFormatted = lRow.map (item, colNum) =>
			switch jsType(item)[0]
				when undef
					dbg "item is undef"
					return ''
				when 'string'
					dbg "item is a string"
					if @hOptions.parseNumbers && item.match(///^
							\d+         # one or more digits
							(\.\d*)?    # optional decimal part
							([Ee]\d+)?  # optional exponent
							$///)
						dbg "checking if '#{item}' is a number"
						num = parseFloat(item)
						dbg 'num', num
						@accum num, colNum
						formatted = @formatItem(num, colNum)
						dbg 'formatted', formatted
						return formatted
					else
						return item
				when 'number'
					dbg "item is a number"
					@accum item, colNum
					formatted = @formatItem(item, colNum)
					dbg 'formatted', formatted
					return formatted
				else
					dbg "item is not a number or string"
					formatted = @formatItem(num, colNum)
					dbg 'formatted', formatted
					return formatted
		@adjustColWidths lFormatted
		@lRows.push {
			opcode: 'data'
			lFormatted
			}
		dbgReturn 'data'
		return

	# ..........................................................

	literal: (str) ->

		assert isString(str), "Not a string: #{OL(str)}"
		@lRows.push {
			opcode: 'literal'
			literal: str
			}
		return

	# ..........................................................

	callback: (func) ->

		assert isFunction(func), "Not a function: #{OL(func)}"
		@lRows.push {
			opcode: 'callback'
			callback: func
			}
		return

	# ..........................................................

	sep: (ch='-') ->

		dbgEnter 'addSep'
		assert ! @closed, "table is closed"
		assert (ch.length == 1), "Non-char arg"
		@lRows.push {
			opcode: 'sep'
			sep: ch
			}
		dbgReturn 'addSep'
		return

	# ..........................................................

	fullsep: (ch='-') ->

		dbgEnter 'fullsep'
		assert ! @closed, "table is closed"
		assert (ch.length == 1), "Non-char arg"
		@lRows.push {
			opcode: 'fullsep'
			fullsep: ch
			}
		dbgReturn 'fullsep'
		return

	# ..........................................................

	title: (title, align='center') ->

		dbgEnter 'title'
		assert ! @closed, "table is closed"
		assert isNonEmptyString(title), "Bad title: '@{title}'"
		assert ['left','center','right'].includes(align),
			"Bad align: #{OL(align)}"
		@lRows.push {
			opcode: 'title'
			title
			align
			}
		dbgReturn 'title'
		return

	# ..........................................................

	totals: () ->

		dbgEnter 'totals'
		assert ! @closed, "table is closed"
		lFormatted = @lColTotals.map (item, colNum) =>
			return @formatItem(item, colNum)
		@adjustColWidths lFormatted
		@lRows.push {
			opcode: 'totals'
			lFormatted
			}
		dbgReturn 'totals'
		return

	# ..........................................................

	subtotals: () ->

		dbgEnter 'subtotals'
		assert ! @closed, "table is closed"
		lFormatted = @lColSubTotals.map (item, colNum) =>
			return @formatItem(item, colNum)
		@resetSubTotals()
		@adjustColWidths lFormatted
		@lRows.push {
			opcode: 'subtotals'
			lFormatted
			}
		dbgReturn 'subtotals'
		return

	# ..........................................................

	close: () ->

		dbgEnter 'close'

		# --- Allow multiple calls to close()
		if @closed
			dbg "already closed, returning"
			dbgReturn 'close'
			return

		# --- We can now compute some other stuff
		@totalWidth = @lColWidths.reduce(
			(acc, n) => acc+n,
			0) + (@numCols - 1)

		# --- Go through @lRows, updating some items
		for hRow in @lRows
			switch hRow.opcode
				when 'sep'
					hRow.lFormatted = @lColWidths.map((w) =>
						hRow.sep.repeat(w))
				when 'fullsep'
					hRow.literal = hRow.fullsep.repeat(@totalWidth)
				when 'title'
					{title, align} = hRow
					hRow.literal = pad(title, @totalWidth, "justify=#{align}")

		@closed = true
		dbgCall () => @dumpInternals()
		dbgReturn 'close'
		return

	# ..........................................................

	asString: () ->

		dbgEnter 'asString'
		@close()

		# --- Map each item in @lRows to a string
		lLines = @lRows.map (hRow) =>
			{opcode, literal, lFormatted} = hRow
			if (opcode == 'sep')
				return lFormatted.join(' ')
			else if defined(literal)
				return literal
			else if defined(lFormatted)
				return lFormatted.map((item, colNum) =>
					w = @lColWidths[colNum]
					a = @lColAligns[colNum]
					return pad(item, w, "justify=#{a}")
			).join(' ')

		table = toBlock(lLines)
		dbgReturn 'asString', table
		return table
