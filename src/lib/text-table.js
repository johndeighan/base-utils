  // --- text-table.coffee
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
  pad,
  toBlock,
  isEmpty,
  nonEmpty,
  isNonEmptyString,
  jsType,
  isString,
  isNumber,
  isInteger,
  isArray,
  isFunction,
  range,
  hasKey,
  untabify,
  isArrayOfStrings
} from '@jdeighan/base-utils';

import {
  assert,
  isType,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  LOG,
  LOGVALUE
} from '@jdeighan/base-utils/log';

import {
  toNICE
} from '@jdeighan/base-utils/to-nice';

import {
  dbgEnter,
  dbgReturn,
  dbg,
  dbgCall
} from '@jdeighan/base-utils/debug';

// ---------------------------------------------------------------------------
export var TextTable = class TextTable {
  constructor(formatStr, hOptions = {}) {
    // --- Valid options:
    //        decPlaces - used for numbers with no % style format
    //                    default: 2
    //        parseNumbers - string data that looks like a number
    //                       is treated as a number, default: false
    dbgEnter('TextTable', formatStr, hOptions);
    this.hOptions = getOptions(hOptions, {
      decPlaces: 2,
      parseNumbers: false
    });
    // --- sets @numCols, @lColAligns, @lColFormats
    this.parseFormatString(formatStr, hOptions);
    dbg('numCols', this.numCols);
    dbg('lColFormats', this.lColFormats);
    dbg('lColAligns', this.lColAligns);
    // --- Items in @lRows must be a hash w/key 'opcode'
    this.lRows = [];
    this.lColWidths = new Array(this.numCols).fill(0);
    this.totalWidth = undef;
    this.closed = false;
    // --- Accumulate totals and subtotals
    //     When a subtotal row is added, subtotals are reset to 0
    this.lColTotals = new Array(this.numCols).fill(undef);
    this.lColSubTotals = new Array(this.numCols).fill(undef);
  }

  // ..........................................................
  parseFormatString(formatStr, hOptions) {
    var _, align, alignWord, colNum, fmt, j, lMatches, lWords, len, word;
    assert(defined(formatStr), "missing format string");
    lWords = words(formatStr);
    this.numCols = lWords.length;
    this.lColAligns = new Array(this.numCols);
    this.lColFormats = new Array(this.numCols);
    for (colNum = j = 0, len = lWords.length; j < len; colNum = ++j) {
      word = lWords[colNum];
      if ((lMatches = word.match(/^(l|c|r)(\%\S+)?$/))) {
        [_, align, fmt] = lMatches;
        alignWord = (function() {
          switch (align) {
            case 'l':
              return 'left';
            case 'c':
              return 'center';
            case 'r':
              return 'right';
            default:
              return undef;
          }
        })();
        assert(defined(alignWord), `Bad format string: ${OL(formatStr)}`);
        this.lColAligns[colNum] = alignWord;
        this.lColFormats[colNum] = fmt; // may be undef
      } else {
        croak(`Bad format string: ${OL(formatStr)}`);
      }
    }
  }

  // ..........................................................
  resetSubTotals() {
    this.lColSubTotals.fill(undef);
  }

  // ..........................................................
  alignItem(item, colNum) {
    var align, width;
    assert(this.closed, "table not closed");
    isType('string', 'item', item);
    if (item.length === width) {
      return item;
    }
    align = this.lColAligns[colNum];
    assert(['left', 'center', 'right'].includes(align), `Bad align parm: ${OL(align)}`);
    width = this.lColWidths[colNum];
    return pad(item, width, `justify=${align}`);
  }

  // ..........................................................
  formatItem(item, colNum) {
    var fmt;
    if (notdefined(item)) {
      return '';
    }
    fmt = this.lColFormats[colNum];
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
  dumpInternals() {
    LOGVALUE('totalWidth', this.totalWidth);
    LOGVALUE('numCols:', this.numCols);
    LOGVALUE('lColWidths:', this.lColWidths);
    LOGVALUE('lColAligns', this.lColAligns);
    LOGVALUE('lColFormats:', this.lColFormats);
    if (nonEmpty(this.lColTotals)) {
      LOGVALUE('lColTotals:', this.lColTotals);
    }
    if (nonEmpty(this.lColSubTotals)) {
      LOGVALUE('lColSubTotals:', this.lColSubTotals);
    }
    if (nonEmpty(this.lRows)) {
      LOGVALUE('lRows:', this.lRows);
    }
  }

  // ..........................................................
  // --- adjust column to width at least minWidth
  adjust(colNum, minWidth) {
    if (minWidth > this.lColWidths[colNum]) {
      this.lColWidths[colNum] = minWidth;
    }
  }

  // ..........................................................
  adjustColWidths(lRow) {
    var colNum, item, j, k, len, len1, str;
    for (colNum = j = 0, len = lRow.length; j < len; colNum = ++j) {
      item = lRow[colNum];
      if (isString(item)) {
        this.adjust(colNum, item.length);
      } else if (isArray(item)) {
        for (k = 0, len1 = item.length; k < len1; k++) {
          str = item[k];
          this.adjust(colNum, str.length);
        }
      }
    }
  }

  // ..........................................................
  accum(num, colNum) {
    isType('number', 'num', num);
    if (defined(this.lColTotals[colNum])) {
      this.lColTotals[colNum] += num;
    } else {
      this.lColTotals[colNum] = num;
    }
    if (defined(this.lColSubTotals[colNum])) {
      this.lColSubTotals[colNum] += num;
    } else {
      this.lColSubTotals[colNum] = num;
    }
  }

  // ..........................................................
  labels(lRow) {
    var hRow;
    dbgEnter('labels', lRow);
    assert(!this.closed, "table is closed");
    isType('array', 'lRow', lRow);
    assert(lRow.length === this.numCols, `bad length: lRow = ${OL(lRow)}`);
    this.adjustColWidths(lRow);
    hRow = {
      opcode: 'labels',
      lRow
    };
    this.lRows.push(hRow);
    dbgReturn('labels', hRow);
  }

  // ..........................................................
  data(lRow) {
    dbgEnter('data', lRow);
    assert(!this.closed, "table is closed");
    isType('array', 'lRow', lRow);
    assert(lRow.length === this.numCols, `lRow = ${OL(lRow)}`);
    lRow = lRow.map((item, colNum) => {
      var formatted, num;
      switch (jsType(item)[0]) {
        case undef:
          dbg("item is undef");
          return '';
        case 'string':
          dbg("item is a string");
          if (this.hOptions.parseNumbers && item.match(/^\d+(\.\d*)?([Ee]\d+)?$/)) { // one or more digits
            // optional decimal part
            // optional exponent
            dbg(`checking if '${item}' is a number`);
            num = parseFloat(item);
            dbg('num', num);
            this.accum(num, colNum);
            formatted = this.formatItem(num, colNum);
            dbg('formatted', formatted);
            return formatted;
          } else {
            return item;
          }
          break;
        case 'number':
          dbg("item is a number");
          this.accum(item, colNum);
          formatted = this.formatItem(item, colNum);
          dbg('formatted', formatted);
          return formatted;
        default:
          dbg("item is not a number or string");
          formatted = this.formatItem(num, colNum);
          dbg('formatted', formatted);
          return formatted;
      }
    });
    this.adjustColWidths(lRow);
    this.lRows.push({
      opcode: 'data',
      lRow
    });
    dbgReturn('data');
  }

  // ..........................................................
  sep(ch = '-') {
    dbgEnter('sep');
    assert(!this.closed, "table is closed");
    assert(ch.length === 1, "Non-char arg");
    this.lRows.push({
      opcode: 'sep',
      ch
    });
    dbgReturn('sep');
  }

  // ..........................................................
  fullsep(ch = '-') {
    dbgEnter('fullsep');
    assert(!this.closed, "table is closed");
    assert(ch.length === 1, "Non-char arg");
    this.lRows.push({
      opcode: 'fullsep',
      ch
    });
    dbgReturn('fullsep');
  }

  // ..........................................................
  title(title, align = 'center') {
    dbgEnter('title');
    assert(!this.closed, "table is closed");
    assert(isNonEmptyString(title), "Bad title: '@{title}'");
    assert(['left', 'center', 'right'].includes(align), `Bad align: ${OL(align)}`);
    this.lRows.push({
      opcode: 'title',
      title,
      align
    });
    dbgReturn('title');
  }

  // ..........................................................
  totals() {
    var lRow;
    dbgEnter('totals');
    assert(!this.closed, "table is closed");
    lRow = this.lColTotals.map((item, colNum) => {
      return this.formatItem(item, colNum);
    });
    this.adjustColWidths(lRow);
    this.lRows.push({
      opcode: 'totals',
      lRow
    });
    dbgReturn('totals');
  }

  // ..........................................................
  subtotals() {
    var lRow;
    dbgEnter('subtotals');
    assert(!this.closed, "table is closed");
    lRow = this.lColSubTotals.map((item, colNum) => {
      return this.formatItem(item, colNum);
    });
    this.resetSubTotals();
    this.adjustColWidths(lRow);
    this.lRows.push({
      opcode: 'subtotals',
      lRow
    });
    dbgReturn('subtotals');
  }

  // ..........................................................
  close() {
    var h, j, len, ref;
    dbgEnter('close');
    // --- Allow multiple calls to close()
    if (this.closed) {
      dbg("already closed, returning");
      dbgCall(() => {
        return this.dumpInternals();
      });
      dbgReturn('close');
      return;
    }
    // --- We can now compute some other stuff
    this.totalWidth = this.lColWidths.reduce((acc, n) => {
      return acc + n;
    }, 0) + (this.numCols - 1);
    ref = this.lRows;
    // --- Go through @lRows, updating 'sep' entries
    for (j = 0, len = ref.length; j < len; j++) {
      h = ref[j];
      if (h.opcode === 'sep') {
        h.lRow = this.lColWidths.map((w) => {
          return h.ch.repeat(w);
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
  asString(hOptions = {}) {
    var hide, i, j, lHide, lLines, len, ref, table, w, width;
    dbgEnter('asString');
    this.close();
    ({hide} = getOptions(hOptions, {
      hide: ''
    }));
    if (isEmpty(hide)) {
      width = this.totalWidth;
      lHide = [];
    } else {
      if (isInteger(hide)) {
        lHide = [hide];
      } else {
        lHide = hide.split(',').map((s) => {
          return parseInt(s);
        });
      }
      // --- We have to compute width
      width = 0;
      ref = this.lColWidths;
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        w = ref[i];
        if (!lHide.includes(i)) {
          width += w + 1;
        }
      }
      width -= 1;
    }
    dbg('lHide', lHide);
    dbg('width', width);
    // --- Map each item in @lRows to a string
    lLines = this.lRows.map((hRow) => {
      var align, ch, hColAlign, hColWidth, lRow, numCols, opcode, title;
      ({opcode, title, lRow, ch, align} = hRow);
      if (defined(lRow)) {
        numCols = 0;
        hColWidth = {};
        hColAlign = {};
        lRow = lRow.filter((elem, index) => {
          if (lHide.includes(index)) {
            return false;
          } else {
            hColWidth[numCols] = this.lColWidths[index];
            hColAlign[numCols] = this.lColAligns[index];
            ++numCols;
            return true;
          }
        });
      }
      switch (opcode) {
        case 'title':
          return pad(title, width, `justify=${align}`);
        case 'sep':
          return lRow.join(' ');
        case 'fullsep':
          return ch.repeat(width);
        case 'labels':
          // --- labels are always center aligned
          return lRow.map((item, colNum) => {
            var a;
            w = hColWidth[colNum];
            a = hColAlign[colNum];
            return pad(item, w, "justify=center");
          }).join(' ');
        case 'data':
        case 'totals':
        case 'subtotals':
          return lRow.map((item, colNum) => {
            var a;
            w = hColWidth[colNum];
            a = hColAlign[colNum];
            return pad(item, w, `justify=${a}`);
          }).join(' ');
      }
    });
    table = toBlock(lLines);
    dbgReturn('asString', table);
    return table;
  }

};
