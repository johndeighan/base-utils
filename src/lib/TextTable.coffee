# --- TextTable.coffee

import {sprintf} from 'sprintf-js'
import {
	undef, defined, notdefined, getOptions, words, OL, range,
	pad, toBlock, LOG, nonEmpty,
	jsType, isString, isNumber, isArray,
	} from '@jdeighan/base-utils'
import {
	assert, croak,
	} from '@jdeighan/base-utils/exceptions'
import {
	dbgEnter, dbgReturn, dbg,
	} from '@jdeighan/base-utils/debug'

hAlignCodes = {
	l: 'left'
	c: 'center'
	r: 'right'
	}

# ---------------------------------------------------------------------------

export class TextTable

	constructor: (formatStr, hOptions={}) ->
		# --- currently no options

		dbgEnter 'TextTable', formatStr, hOptions
		assert defined(formatStr), "missing format string"
		@lColFormats = words(formatStr).map (str) =>
			if (lMatches = str.match(/^(l|c|r)(\%.*)?$/))
				[_, align, fmt] = lMatches
				return [hAlignCodes[align], fmt]
			else
				croak "Bad format string: #{OL(formatStr)}"
		dbg 'lColFormats', @lColFormats

		@numCols = @lColFormats.length
		dbg 'numCols', @numCols

		# --- Items in @lRows can be:
		#        an Array of labels
		#        an Array of values
		#        a string of length 1 (separator line)
		#        the word 'total'
		@lRows = []
		@lLabelRows = []      # --- [<index>, ...]
		@lFormattedRows = []  # --- copy of @lRows with
		                      #     formats applied, but not aligned
		@lColWidths = []
		@closed = false

	# ..........................................................

	isLabelRow: (rowNum) ->

		return @lLabelRows.includes(rowNum)

	# ..........................................................

	dumpInternals: () ->

		LOG 'lColFormats:', @lColFormats
		LOG 'numCols:', @numCols
		if nonEmpty(@lRows)
			LOG 'lRows:', @lRows
		if nonEmpty(@lLabelRows)
			LOG 'lLabelRows:', @lLabelRows
		if nonEmpty(@lFormattedRows)
			LOG 'lFormattedRows:', @lFormattedRows
		if nonEmpty(@lColWidths)
			LOG 'lColWidths:', @lColWidths
		return

	# ..........................................................

	addLabels: (lRow) ->

		dbgEnter 'addLabels'
		assert ! @closed, "table is closed"
		assert (lRow.length == @numCols), "lRow = #{OL(lRow)}"
		dbg 'lRow', lRow
		@lLabelRows.push @lRows.length
		@lRows.push lRow
		dbgReturn 'addLabels'
		return

	# ..........................................................

	addSep: (ch='-') ->

		dbgEnter 'addSep'
		assert ! @closed, "table is closed"
		assert (ch.length == 1), "Non-char arg"
		@lRows.push ch
		dbgReturn 'addSep'
		return

	# ..........................................................

	addData: (lRow) ->

		dbgEnter 'addData'
		assert ! @closed, "table is closed"
		assert (lRow.length == @numCols), "lRow = #{OL(lRow)}"
		dbg 'lRow', lRow
		@lRows.push lRow
		dbgReturn 'addData'
		return

	# ..........................................................

	addTotals: () ->

		dbgEnter 'addTotals'
		assert ! @closed, "table is closed"
		@lRows.push 'total'
		dbgReturn 'addTotals'
		return

	# ..........................................................
	# --- Create @lFormattedRows from @lRows
	#     Calculate @lColWidths

	close: () ->

		dbgEnter 'close'

		# --- Allow multiple calls to close()
		if @closed
			dbgReturn 'close'
			return

		# --- Calculate column widths as max of all values in col
		#     Keep running totals for each column, which
		#        may affect column widths
		@lColWidths = @lColFormats.map (x) => 0
		@lColTotals = @lColFormats.map (x) => 0
		for row,rowNum in @lRows
			if (row == 'total')
				lFormattedItems = for colNum in range(@numCols)
					total = @lColTotals[colNum]
					if defined(total)
						[align, fmt] = @lColFormats[colNum]
						formatted = sprintf(fmt, total)
						if (formatted.length > @lColWidths[colNum])
							@lColWidths[colNum] = formatted.length
						formatted
					else
						''
				@lFormattedRows.push lFormattedItems
			else if isString(row)
				@lFormattedRows.push row
			else if isArray(row)
				if @isLabelRow(rowNum)
					@lFormattedRows.push row
				else
					lFormattedItems = row.map (item, colNum) =>
						if isNumber(item)
							@lColTotals[colNum] += item
						[align, fmt] = @lColFormats[colNum]
						# LOG "format = '#{fmt}'"
						# LOG "item = #{OL(item)}"
						if defined(fmt)
							formatted = sprintf(fmt, item)
						else
							formatted = item
						if (formatted.length > @lColWidths[colNum])
							@lColWidths[colNum] = formatted.length
						return formatted
					@lFormattedRows.push lFormattedItems
			else
				@lFormattedRows.push row

		# --- Now that we have all column widths, we can
		#     expand separator rows

		for row, rowNum in @lFormattedRows
			if isString(row)
				@lFormattedRows[rowNum] = range(@numCols).map((colNum) =>
					row.repeat(@lColWidths[colNum])
					)

		@closed = true
		dbgReturn 'close'
		return

	# ..........................................................

	asString: () ->

		dbgEnter 'asString'
		@close()

		# --- Map each item in @lFormattedRows to a string
		lLines = @lFormattedRows.map (row, rowNum) =>
			assert isArray(row), "lFormattedRows contains #{OL(row)}"
			if @isLabelRow(rowNum)
				return row.map((item, colNum) =>
					assert isString(item), "item not a string"
					pad(item, @lColWidths[colNum], 'justify=center')
					).join(' ')
			else
				return row.map((item, colNum) =>
					assert isString(item), "item not a string"
					align = @lColFormats[colNum][0]
					pad(item, @lColWidths[colNum], "justify=#{align}")
					).join(' ')

		table = toBlock(lLines)
		dbgReturn 'asString', table
		return table
