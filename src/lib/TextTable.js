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
  isArray,
  isArrayOfStrings
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
    // --- Valid options:
    //        decPlaces - used for numbers with no % style format
    //                    default: 2
    //        parseNumbers - string data that looks like a number
    //                       is treated as a number
    dbgEnter('TextTable', formatStr, hOptions);
    assert(defined(formatStr), "missing format string");
    this.hOptions = getOptions(hOptions, {
      decPlaces: 2,
      parseNumbers: false
    });
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
    //        formats applied, but not aligned
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
    assert(isArrayOfStrings(lRow), "non-strings in label row");
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
    if (this.hOptions.parseNumbers) {
      lRow = lRow.map((item) => {
        if (isString(item)) {
          if (item.match(/^\d+(\.\d*)?([Ee]\d+)?$/)) { // one or more digits
            // optional decimal part
            // optional exponent
            return parseFloat(item);
          } else {
            return item;
          }
        } else {
          return item;
        }
      });
    }
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
  formatItem(item, fmt) {
    if (defined(fmt)) {
      return sprintf(fmt, item);
    } else if (isString(item)) {
      return item;
    } else if (isNumber(item)) {
      return item.toFixed(this.hOptions.decPlaces);
    } else {
      return OL(item);
    }
  }

  // ..........................................................
  // --- Create @lFormattedRows from @lRows
  //     Calculate @lColWidths
  close() {
    var align, colNum, fmt, formatted, i, j, k, l, lFormattedItems, len, len1, len2, len3, ref, ref1, ref2, row, rowNum, total;
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
    this.lColTotals = this.lColFormats.map((x) => {
      return undef;
    });
    ref = this.lRows;
    for (rowNum = i = 0, len = ref.length; i < len; rowNum = ++i) {
      row = ref[rowNum];
      if (row === 'total') {
        dbg('TOTALS row');
        dbg('lColTotals', this.lColTotals);
        lFormattedItems = (function() {
          var j, len1, ref1, results;
          ref1 = range(this.numCols);
          results = [];
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            colNum = ref1[j];
            total = this.lColTotals[colNum];
            if (notdefined(total)) {
              results.push('');
            } else {
              [align, fmt] = this.lColFormats[colNum];
              results.push(this.formatItem(total, fmt));
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
              if (defined(this.lColTotals[colNum])) {
                this.lColTotals[colNum] += item;
              } else {
                this.lColTotals[colNum] = item;
              }
            }
            [align, fmt] = this.lColFormats[colNum];
            return this.formatItem(item, fmt);
          });
          this.lFormattedRows.push(lFormattedItems);
        }
      } else {
        this.lFormattedRows.push(row);
      }
    }
    dbg("Calculate column widths");
    this.lColWidths = this.lColFormats.map((x) => {
      return 0;
    });
    ref1 = this.lFormattedRows;
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      row = ref1[j];
      if (!isString(row)) {
        assert(isArrayOfStrings(row), `Bad formatted row: ${OL(row)}`);
        for (colNum = k = 0, len2 = row.length; k < len2; colNum = ++k) {
          formatted = row[colNum];
          if (formatted.length > this.lColWidths[colNum]) {
            this.lColWidths[colNum] = formatted.length;
          }
        }
      }
    }
    // --- Now that we have all column widths, we can
    //     expand separator rows
    dbg("Expand separator rows");
    ref2 = this.lFormattedRows;
    for (rowNum = l = 0, len3 = ref2.length; l < len3; rowNum = ++l) {
      row = ref2[rowNum];
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
          assert(isString(item), `item not a string: ${OL(item)}`);
          return pad(item, this.lColWidths[colNum], 'justify=center');
        }).join(' ');
      } else {
        return row.map((item, colNum) => {
          var align;
          assert(isString(item), `item not a string: ${OL(item)}`);
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
