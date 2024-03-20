// --- TextTable.coffee
var hAlignWords, lOpCodes;

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
  hasKey,
  pad,
  toBlock,
  isEmpty,
  nonEmpty,
  isNonEmptyString,
  jsType,
  isString,
  isNumber,
  isArray,
  isArrayOfStrings,
  isFunction
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  LOG
} from '@jdeighan/base-utils/log';

import {
  dbgEnter,
  dbgReturn,
  dbg,
  dbgCall
} from '@jdeighan/base-utils/debug';

hAlignWords = {
  l: 'left',
  c: 'center',
  r: 'right'
};

lOpCodes = words('labels data sep fullsep total subtotal literal');

// ---------------------------------------------------------------------------
export var TextTable = class TextTable {
  constructor(formatStr, hOptions = {}) {
    var _, align, alignWord, colNum, fmt, i, lMatches, lWords, len, word;
    // --- Valid options:
    //        decPlaces - used for numbers with no % style format
    //                    default: 2
    //        parseNumbers - string data that looks like a number
    //                       is treated as a number, default: false
    dbgEnter('TextTable', formatStr, hOptions);
    assert(defined(formatStr), "missing format string");
    this.hOptions = getOptions(hOptions, {
      decPlaces: 2,
      parseNumbers: false
    });
    lWords = words(formatStr);
    this.numCols = lWords.length;
    dbg('numCols', this.numCols);
    this.lColAligns = new Array(this.numCols);
    this.lColFormats = new Array(this.numCols);
    for (colNum = i = 0, len = lWords.length; i < len; colNum = ++i) {
      word = lWords[colNum];
      if ((lMatches = word.match(/^(l|c|r)(\%\S+)?$/))) {
        [_, align, fmt] = lMatches;
        alignWord = hAlignWords[align];
        assert(defined(alignWord), `Bad format string: ${OL(formatStr)}`);
        this.lColAligns[colNum] = alignWord;
        this.lColFormats[colNum] = fmt; // may be undef
      } else {
        croak(`Bad format string: ${OL(formatStr)}`);
      }
    }
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
  resetSubTotals() {
    this.lColSubTotals.fill(undef);
  }

  // ..........................................................
  alignItem(item, colNum) {
    var align, width;
    assert(this.closed, "table not closed");
    assert(isString(item), `Not a string: ${OL(item)}`);
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
    LOG('lColAligns', this.lColAligns);
    LOG('lColFormats:', this.lColFormats);
    LOG('numCols:', this.numCols);
    if (nonEmpty(this.lRows)) {
      LOG('lRows:', this.lRows);
    }
    if (nonEmpty(this.lColWidths)) {
      LOG('lColWidths:', this.lColWidths);
    }
    if (defined(this.totalWidth)) {
      LOG('totalWidth', this.totalWidth);
    }
    if (nonEmpty(this.lColTotals)) {
      LOG('lColTotals:', this.lColTotals);
    }
    if (nonEmpty(this.lColSubTotals)) {
      LOG('lColSubTotals:', this.lColSubTotals);
    }
  }

  // ..........................................................
  adjustColWidths(lFormatted) {
    var colNum, i, len, str;
    for (colNum = i = 0, len = lFormatted.length; i < len; colNum = ++i) {
      str = lFormatted[colNum];
      assert(isString(str), `Not a string: ${OL(str)}`);
      if (str.length > this.lColWidths[colNum]) {
        this.lColWidths[colNum] = str.length;
      }
    }
  }

  // ..........................................................
  accum(num, colNum) {
    assert(isNumber(num), `Not a number: ${OL(num)}`);
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
  flatten(lRow) {
    if ((lRow.length === 1) && isArray(lRow[0])) {
      return lRow[0];
    }
    return lRow;
  }

  // ..........................................................
  labels(...lRow) {
    lRow = this.flatten(lRow);
    dbgEnter('labels', lRow);
    assert(!this.closed, "table is closed");
    assert(isArray(lRow), `Not an array: ${OL(lRow)}`);
    assert(lRow.length === this.numCols, `lRow = ${OL(lRow)}`);
    this.adjustColWidths(lRow);
    this.lRows.push({
      opcode: 'labels',
      lFormatted: lRow
    });
    dbgReturn('labels');
  }

  // ..........................................................
  data(...lRow) {
    var lFormatted;
    lRow = this.flatten(lRow);
    dbgEnter('data', lRow);
    assert(!this.closed, "table is closed");
    assert(lRow.length === this.numCols, `lRow = ${OL(lRow)}`);
    lFormatted = lRow.map((item, colNum) => {
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
    this.adjustColWidths(lFormatted);
    this.lRows.push({
      opcode: 'data',
      lFormatted
    });
    dbgReturn('data');
  }

  // ..........................................................
  literal(str) {
    assert(isString(str), `Not a string: ${OL(str)}`);
    this.lRows.push({
      opcode: 'literal',
      literal: str
    });
  }

  // ..........................................................
  callback(func) {
    assert(isFunction(func), `Not a function: ${OL(func)}`);
    this.lRows.push({
      opcode: 'callback',
      callback: func
    });
  }

  // ..........................................................
  sep(ch = '-') {
    dbgEnter('addSep');
    assert(!this.closed, "table is closed");
    assert(ch.length === 1, "Non-char arg");
    this.lRows.push({
      opcode: 'sep',
      sep: ch
    });
    dbgReturn('addSep');
  }

  // ..........................................................
  fullsep(ch = '-') {
    dbgEnter('fullsep');
    assert(!this.closed, "table is closed");
    assert(ch.length === 1, "Non-char arg");
    this.lRows.push({
      opcode: 'fullsep',
      fullsep: ch
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
    var lFormatted;
    dbgEnter('totals');
    assert(!this.closed, "table is closed");
    lFormatted = this.lColTotals.map((item, colNum) => {
      return this.formatItem(item, colNum);
    });
    this.adjustColWidths(lFormatted);
    this.lRows.push({
      opcode: 'totals',
      lFormatted
    });
    dbgReturn('totals');
  }

  // ..........................................................
  subtotals() {
    var lFormatted;
    dbgEnter('subtotals');
    assert(!this.closed, "table is closed");
    lFormatted = this.lColSubTotals.map((item, colNum) => {
      return this.formatItem(item, colNum);
    });
    this.resetSubTotals();
    this.adjustColWidths(lFormatted);
    this.lRows.push({
      opcode: 'subtotals',
      lFormatted
    });
    dbgReturn('subtotals');
  }

  // ..........................................................
  close() {
    var align, hRow, i, len, ref, title;
    dbgEnter('close');
    // --- Allow multiple calls to close()
    if (this.closed) {
      dbg("already closed, returning");
      dbgReturn('close');
      return;
    }
    // --- We can now compute some other stuff
    this.totalWidth = this.lColWidths.reduce((acc, n) => {
      return acc + n;
    }, 0) + (this.numCols - 1);
    ref = this.lRows;
    // --- Go through @lRows, updating some items
    for (i = 0, len = ref.length; i < len; i++) {
      hRow = ref[i];
      switch (hRow.opcode) {
        case 'sep':
          hRow.lFormatted = this.lColWidths.map((w) => {
            return hRow.sep.repeat(w);
          });
          break;
        case 'fullsep':
          hRow.literal = hRow.fullsep.repeat(this.totalWidth);
          break;
        case 'title':
          ({title, align} = hRow);
          hRow.literal = pad(title, this.totalWidth, `justify=${align}`);
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
    // --- Map each item in @lRows to a string
    lLines = this.lRows.map((hRow) => {
      var lFormatted, literal, opcode;
      ({opcode, literal, lFormatted} = hRow);
      if (opcode === 'sep') {
        return lFormatted.join(' ');
      } else if (defined(literal)) {
        return literal;
      } else if (defined(lFormatted)) {
        return lFormatted.map((item, colNum) => {
          var a, w;
          w = this.lColWidths[colNum];
          a = this.lColAligns[colNum];
          return pad(item, w, `justify=${a}`);
        }).join(' ');
      }
    });
    table = toBlock(lLines);
    dbgReturn('asString', table);
    return table;
  }

};

//# sourceMappingURL=TextTable.js.map
