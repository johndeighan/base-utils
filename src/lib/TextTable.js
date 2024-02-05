// --- TextTable.coffee
var hAlignCodes;

import {
  sprintf
} from 'sprintf-js';

import {
  undef,
  defined,
  notdefined,
  getOptions,
  words,
  OL,
  range,
  pad,
  toBlock,
  LOG,
  nonEmpty,
  jsType,
  isString,
  isNumber,
  isArray
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  dbgEnter,
  dbgReturn,
  dbg,
  dbgCall
} from '@jdeighan/base-utils/debug';

hAlignCodes = {
  l: 'left',
  c: 'center',
  r: 'right'
};

// ---------------------------------------------------------------------------
export var TextTable = class TextTable {
  constructor(formatStr, hOptions = {}) {
    // --- currently no options
    dbgEnter('TextTable', formatStr, hOptions);
    assert(defined(formatStr), "missing format string");
    this.lColFormats = words(formatStr).map((str) => {
      var _, align, fmt, lMatches;
      if ((lMatches = str.match(/^(l|c|r)(\%.*)?$/))) {
        [_, align, fmt] = lMatches;
        return [hAlignCodes[align], fmt];
      } else {
        return croak(`Bad format string: ${OL(formatStr)}`);
      }
    });
    dbg('lColFormats', this.lColFormats);
    this.numCols = this.lColFormats.length;
    dbg('numCols', this.numCols);
    // --- Items in @lRows can be:
    //        an Array of labels
    //        an Array of values
    //        a string of length 1 (separator line)
    //        the word 'total'
    this.lRows = [];
    this.lLabelRows = []; // --- [<index>, ...]
    this.lFormattedRows = []; // --- copy of @lRows with
    //     formats applied, but not aligned
    this.lColWidths = [];
    this.closed = false;
  }

  // ..........................................................
  isLabelRow(rowNum) {
    return this.lLabelRows.includes(rowNum);
  }

  // ..........................................................
  dumpInternals() {
    LOG('lColFormats:', this.lColFormats);
    LOG('numCols:', this.numCols);
    if (nonEmpty(this.lRows)) {
      LOG('lRows:', this.lRows);
    }
    if (nonEmpty(this.lLabelRows)) {
      LOG('lLabelRows:', this.lLabelRows);
    }
    if (nonEmpty(this.lFormattedRows)) {
      LOG('lFormattedRows:', this.lFormattedRows);
    }
    if (nonEmpty(this.lColWidths)) {
      LOG('lColWidths:', this.lColWidths);
    }
  }

  // ..........................................................
  addLabels(lRow) {
    dbgEnter('addLabels');
    assert(!this.closed, "table is closed");
    assert(lRow.length === this.numCols, `lRow = ${OL(lRow)}`);
    dbg('lRow', lRow);
    this.lLabelRows.push(this.lRows.length);
    this.lRows.push(lRow);
    dbgReturn('addLabels');
  }

  // ..........................................................
  addSep(ch = '-') {
    dbgEnter('addSep');
    assert(!this.closed, "table is closed");
    assert(ch.length === 1, "Non-char arg");
    this.lRows.push(ch);
    dbgReturn('addSep');
  }

  // ..........................................................
  addData(lRow) {
    dbgEnter('addData');
    assert(!this.closed, "table is closed");
    assert(lRow.length === this.numCols, `lRow = ${OL(lRow)}`);
    dbg('lRow', lRow);
    this.lRows.push(lRow);
    dbgReturn('addData');
  }

  // ..........................................................
  addTotals() {
    dbgEnter('addTotals');
    assert(!this.closed, "table is closed");
    this.lRows.push('total');
    dbgReturn('addTotals');
  }

  // ..........................................................
  // --- Create @lFormattedRows from @lRows
  //     Calculate @lColWidths
  close() {
    var align, colNum, fmt, formatted, i, j, lFormattedItems, len, len1, ref, ref1, row, rowNum, total;
    dbgEnter('close');
    // --- Allow multiple calls to close()
    if (this.closed) {
      dbg("already closed, returning");
      dbgReturn('close');
      return;
    }
    // --- Calculate column widths as max of all values in col
    //     Keep running totals for each column, which
    //        may affect column widths
    dbg("Calculate column widths, build lFormattedRows");
    this.lColWidths = this.lColFormats.map((x) => {
      return 0;
    });
    this.lColTotals = this.lColFormats.map((x) => {
      return 0;
    });
    ref = this.lRows;
    for (rowNum = i = 0, len = ref.length; i < len; rowNum = ++i) {
      row = ref[rowNum];
      if (row === 'total') {
        lFormattedItems = (function() {
          var j, len1, ref1, results;
          ref1 = range(this.numCols);
          results = [];
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            colNum = ref1[j];
            total = this.lColTotals[colNum];
            if (defined(total)) {
              [align, fmt] = this.lColFormats[colNum];
              formatted = sprintf(fmt, total);
              if (formatted.length > this.lColWidths[colNum]) {
                this.lColWidths[colNum] = formatted.length;
              }
              results.push(formatted);
            } else {
              results.push('');
            }
          }
          return results;
        }).call(this);
        this.lFormattedRows.push(lFormattedItems);
      } else if (isString(row)) {
        this.lFormattedRows.push(row);
      } else if (isArray(row)) {
        if (this.isLabelRow(rowNum)) {
          this.lFormattedRows.push(row);
        } else {
          lFormattedItems = row.map((item, colNum) => {
            if (notdefined(item)) {
              return '';
            }
            if (isNumber(item)) {
              this.lColTotals[colNum] += item;
            }
            [align, fmt] = this.lColFormats[colNum];
            // LOG "format = '#{fmt}'"
            // LOG "item = #{OL(item)}"
            if (defined(fmt)) {
              formatted = sprintf(fmt, item);
            } else {
              formatted = item;
            }
            if (formatted.length > this.lColWidths[colNum]) {
              this.lColWidths[colNum] = formatted.length;
            }
            return formatted;
          });
          this.lFormattedRows.push(lFormattedItems);
        }
      } else {
        this.lFormattedRows.push(row);
      }
    }
    // --- Now that we have all column widths, we can
    //     expand separator rows
    dbg("Expand separator rows");
    ref1 = this.lFormattedRows;
    for (rowNum = j = 0, len1 = ref1.length; j < len1; rowNum = ++j) {
      row = ref1[rowNum];
      if (isString(row)) {
        this.lFormattedRows[rowNum] = range(this.numCols).map((colNum) => {
          return row.repeat(this.lColWidths[colNum]);
        });
      }
    }
    this.closed = true;
    dbgCall(() => {
      return this.dumpInternals();
    });
    dbgReturn('close');
  }

  // ..........................................................
  asString() {
    var lLines, table;
    dbgEnter('asString');
    this.close();
    // --- Map each item in @lFormattedRows to a string
    lLines = this.lFormattedRows.map((row, rowNum) => {
      assert(isArray(row), `lFormattedRows contains ${OL(row)}`);
      if (this.isLabelRow(rowNum)) {
        return row.map((item, colNum) => {
          if (notdefined(item)) {
            return '';
          } else {
            assert(isString(item), `item not a string: ${OL(item)}`);
            return pad(item, this.lColWidths[colNum], 'justify=center');
          }
        }).join(' ');
      } else {
        return row.map((item, colNum) => {
          var align;
          assert(isString(item), "item not a string");
          align = this.lColFormats[colNum][0];
          return pad(item, this.lColWidths[colNum], `justify=${align}`);
        }).join(' ');
      }
    });
    table = toBlock(lLines);
    dbgReturn('asString', table);
    return table;
  }

};

//# sourceMappingURL=TextTable.js.map
