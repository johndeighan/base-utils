// Generated by CoffeeScript 2.7.0
  // base-utils.coffee
var hashFromString, myHandler, myReplacer,
  hasProp = {}.hasOwnProperty;

import assert from 'node:assert/strict';

export const undef = void 0;

// ---------------------------------------------------------------------------
export var isHashComment = (line) => {
  var _, lMatches, prefix, text, ws;
  // --- true if:
  //        - 1st non-ws char is a '#'
  //        - '#' is either followed by a ws char or by nothing
  lMatches = line.match(/^(\s*)\#(\s*)(.*)$/);
  if (defined(lMatches)) {
    [_, prefix, ws, text] = lMatches;
    if (text.length === 0) {
      return {
        prefix,
        ws,
        text: ''
      };
    } else if (ws.length > 0) {
      return {
        prefix,
        ws,
        text: text.trim()
      };
    } else {
      return undef;
    }
  } else {
    return undef;
  }
};

// ---------------------------------------------------------------------------
export var splitPrefix = (line) => {
  var lMatches;
  assert(isString(line), `non-string ${OL(line)}`);
  line = rtrim(line);
  lMatches = line.match(/^(\s*)(.*)$/);
  return [lMatches[1], lMatches[2]];
};

// ---------------------------------------------------------------------------
//   pass - do nothing
export var pass = () => {
  return true;
};

// ---------------------------------------------------------------------------
export var defined = (obj) => {
  return (obj !== undef) && (obj !== null);
};

// ---------------------------------------------------------------------------
export var notdefined = (obj) => {
  return (obj === undef) || (obj === null);
};

// ---------------------------------------------------------------------------
export var spaces = (n) => {
  return " ".repeat(n);
};

// ---------------------------------------------------------------------------
export var tabs = (n) => {
  return "\t".repeat(n);
};

// ---------------------------------------------------------------------------
export var centeredText = (text, width) => {
  var numLeft, numRight, totSpaces;
  totSpaces = width - text.length;
  numLeft = Math.floor(totSpaces / 2);
  numRight = totSpaces = numLeft;
  return spaces(numLeft) + text + spaces(numRight);
};

// ---------------------------------------------------------------------------
//   rtrunc - strip nChars chars from right of a string
export var rtrunc = (str, nChars) => {
  return str.substring(0, str.length - nChars);
};

// ---------------------------------------------------------------------------
//   ltrunc - strip nChars chars from left of a string
export var ltrunc = (str, nChars) => {
  return str.substring(nChars);
};

// ---------------------------------------------------------------------------
export var CWS = (str) => {
  assert(isString(str), "CWS(): parameter not a string");
  return str.trim().replace(/\s+/sg, ' ');
};

// ---------------------------------------------------------------------------
//    tabify - convert leading spaces to TAB characters
//             if numSpaces is not defined, then the first line
//             that contains at least one space sets it
export var tabify = function(str, numSpaces = undef) {
  var _, i, lLines, len, level, prefix, prefixLen, ref, result, theRest;
  lLines = [];
  ref = toArray(str);
  for (i = 0, len = ref.length; i < len; i++) {
    str = ref[i];
    [_, prefix, theRest] = str.match(/^(\s*)(.*)$/);
    prefixLen = prefix.length;
    if (prefixLen === 0) {
      lLines.push(theRest);
    } else {
      assert(prefix.indexOf('\t') === -1, "found TAB");
      if (numSpaces === undef) {
        numSpaces = prefixLen;
      }
      assert(prefixLen % numSpaces === 0, "Bad prefix");
      level = prefixLen / numSpaces;
      lLines.push('\t'.repeat(level) + theRest);
    }
  }
  result = toBlock(lLines);
  return result;
};

// ---------------------------------------------------------------------------
export var untabify = (str, numSpaces = 3) => {
  return str.replace(/\t/g, ' '.repeat(numSpaces));
};

// ---------------------------------------------------------------------------
export var oneof = (word, ...lWords) => {
  return lWords.indexOf(word) >= 0;
};

// ---------------------------------------------------------------------------
//   deepCopy - deep copy an array or object
export var deepCopy = (obj) => {
  var err, newObj, objStr;
  if (obj === undef) {
    return undef;
  }
  objStr = JSON.stringify(obj);
  try {
    newObj = JSON.parse(objStr);
  } catch (error) {
    err = error;
    throw new Error("ERROR: err.message");
  }
  return newObj;
};

// ---------------------------------------------------------------------------
// --- a replacer is (key, value) -> newvalue
myReplacer = (name, value) => {
  if (value === undef) {
    return undef;
  } else if (value === null) {
    return null;
  } else if (isString(value)) {
    return escapeStr(value);
  } else if (typeof value === 'function') {
    return `[Function: ${value.name}]`;
  } else {
    return value;
  }
};

// ---------------------------------------------------------------------------
export var OL = (obj) => {
  if (defined(obj)) {
    if (isString(obj)) {
      return quoted(obj, 'escape');
    } else {
      return JSON.stringify(obj, myReplacer);
    }
  } else if (obj === null) {
    return 'null';
  } else {
    return 'undef';
  }
};

// ---------------------------------------------------------------------------
export var OLS = (lObjects, sep = ',') => {
  var i, lParts, len, obj;
  assert(isArray(lObjects), "not an array");
  lParts = [];
  for (i = 0, len = lObjects.length; i < len; i++) {
    obj = lObjects[i];
    lParts.push(OL(obj));
  }
  return lParts.join(sep);
};

// ---------------------------------------------------------------------------
export var quoted = (str, escape = undef) => {
  assert(isString(str), `not a string: ${str}`);
  switch (escape) {
    case 'escape':
      str = escapeStr(str);
      break;
    case 'escapeNoNL':
      str = escapeStr(str, hEscNoNL);
      break;
    default:
      pass;
  }
  if (!hasChar(str, "'")) {
    return "'" + str + "'";
  }
  if (!hasChar(str, '"')) {
    return '"' + str + '"';
  }
  return '<' + str + '>';
};

// ---------------------------------------------------------------------------
//   escapeStr - escape newlines, TAB chars, etc.
export var hEsc = {
  "\n": '®',
  "\t": '→',
  " ": '˳'
};

export var hEscNoNL = {
  "\t": '→',
  " ": '˳'
};

export var escapeStr = function(str, hReplace = hEsc) {
  var ch, lParts;
  // --- hReplace can also be a string:
  //        'esc'     - escape space, newline, tab
  //        'escNoNL' - escape space, tab
  if (isString(hReplace)) {
    switch (hReplace) {
      case 'esc':
        hReplace = hEsc;
        break;
      case 'escNoNL':
        hReplace = hExcNoNL;
        break;
      default:
        throw new Error("Invalid hReplace string value");
    }
  }
  assert(isString(str), "escapeStr(): not a string");
  lParts = (function() {
    var i, len, ref, results;
    ref = str.split('');
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      ch = ref[i];
      if (defined(hReplace[ch])) {
        results.push(hReplace[ch]);
      } else {
        results.push(ch);
      }
    }
    return results;
  })();
  return lParts.join('');
};

// ---------------------------------------------------------------------------
export var hasChar = (str, ch) => {
  return str.indexOf(ch) >= 0;
};

// ---------------------------------------------------------------------------
export var inList = (item, ...lStrings) => {
  return lStrings.indexOf(item) >= 0;
};

// ---------------------------------------------------------------------------
// see: https://stackoverflow.com/questions/40922531/how-to-check-if-a-javascript-function-is-a-constructor
myHandler = {
  construct: function() {
    return myHandler; // Must return ANY object, so reuse one
  }
};

export var isConstructor = (x) => {
  var e;
  if (typeof x !== 'function') {
    return false;
  }
  try {
    return !!(new (new Proxy(x, myHandler))());
  } catch (error) {
    e = error;
    return false;
  }
};

// ---------------------------------------------------------------------------
export var jsType = (x) => {
  var lKeys;
  // --- return [type, subtype]
  if (x === null) {
    return [undef, 'null'];
  } else if (x === undef) {
    return [undef, 'undef'];
  }
  switch (typeof x) {
    case 'number':
      if (Number.isInteger(x)) {
        return ['number', 'integer'];
      } else {
        return ['number', undef];
      }
      break;
    case 'string':
      if (x.match(/^\s*$/)) {
        return ['string', 'empty'];
      } else {
        return ['string', undef];
      }
      break;
    case 'boolean':
      return ['boolean', undef];
    case 'bigint':
      return ['number', 'integer'];
    case 'function':
      if (x.prototype && (x.prototype.constructor === x)) {
        return ['class', undef];
      }
      return ['function', undef];
    case 'object':
      if (x instanceof String) {
        if (x.match(/^\s*$/)) {
          return ['string', 'empty'];
        } else {
          return ['string', undef];
        }
      }
      if (x instanceof Number) {
        if (Number.isInteger(x)) {
          return ['number', 'integer'];
        } else {
          return ['number', undef];
        }
      }
      if (x instanceof Boolean) {
        return ['boolean', undef];
      }
      if (Array.isArray(x)) {
        if (x.length === 0) {
          return ['array', 'empty'];
        } else {
          return ['array', undef];
        }
      }
      if (x instanceof RegExp) {
        return ['regexp', undef];
      }
      if (x instanceof Function) {
        if (x.prototype && (x.prototype.constructor === x)) {
          return ['class', undef];
        } else {
          return ['function', undef];
        }
      }
      if (defined(x.constructor.name) && (typeof x.constructor.name === 'string') && (x.constructor.name === 'Object')) {
        lKeys = Object.keys(x);
        if (lKeys.length === 0) {
          return ['hash', 'empty'];
        } else {
          return ['hash', undef];
        }
      } else {
        return ['object', undef];
      }
      break;
    default:
      throw new Error(`Unknown jsType: ${x}`);
  }
};

// ---------------------------------------------------------------------------
export var isString = (x) => {
  return jsType(x)[0] === 'string';
};

// ---------------------------------------------------------------------------
export var isNonEmptyString = (x) => {
  return isString(x) && !x.match(/^\s*$/);
};

// ---------------------------------------------------------------------------
export var isNonEmptyArray = (x) => {
  return isArray(x) && (x.length > 0);
};

// ---------------------------------------------------------------------------
export var isNonEmptyHash = (x) => {
  return isHash(x) && (Object.keys(x).length > 0);
};

// ---------------------------------------------------------------------------
export var isIdentifier = (x) => {
  if (!isString(x)) {
    return false;
  }
  return x.match(/^[A-Za-z_][A-Za-z0-9_]*$/);
};

// ---------------------------------------------------------------------------
export var isFunctionName = (x) => {
  var _, first, lMatches, second;
  if (isString(x) && (lMatches = x.match(/^([A-Za-z_][A-Za-z0-9_]*)(?:\.([A-Za-z_][A-Za-z0-9_]*))?$/))) { // allow class method names
    [_, first, second] = lMatches;
    if (nonEmpty(second)) {
      return [first, second];
    } else {
      return [first];
    }
  } else {
    return undef;
  }
};

// ---------------------------------------------------------------------------
export var isNumber = (x, hOptions = undef) => {
  var max, min;
  if (jsType(x)[0] !== 'number') {
    return false;
  }
  if (defined(hOptions)) {
    assert(isHash(hOptions), `2nd arg not a hash: ${OL(hOptions)}`);
    ({min, max} = hOptions);
    if (defined(min) && (x < min)) {
      return false;
    }
    if (defined(max) && (x > max)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isInteger = (x, hOptions = {}) => {
  var result;
  if (typeof x === 'number') {
    result = Number.isInteger(x);
  } else if (x instanceof Number) {
    result = Number.isInteger(x.valueOf());
  } else {
    return false;
  }
  if (result) {
    if (defined(hOptions.min) && (x < hOptions.min)) {
      result = false;
    }
    if (defined(hOptions.max) && (x > hOptions.max)) {
      result = false;
    }
  }
  return result;
};

// ---------------------------------------------------------------------------
export var isArray = (x) => {
  return jsType(x)[0] === 'array';
};

// ---------------------------------------------------------------------------
export var isArrayOfHashes = (lItems) => {
  var i, item, len;
  if (!isArray(lItems)) {
    return false;
  }
  for (i = 0, len = lItems.length; i < len; i++) {
    item = lItems[i];
    if (defined(item) && !isHash(item)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isArrayOfStrings = (lItems) => {
  var i, item, len;
  if (!isArray(lItems)) {
    return false;
  }
  for (i = 0, len = lItems.length; i < len; i++) {
    item = lItems[i];
    if (defined(item) && !isString(item)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var words = (...lStrings) => {
  var i, j, lWords, len, len1, ref, str, word;
  lWords = [];
  for (i = 0, len = lStrings.length; i < len; i++) {
    str = lStrings[i];
    str = str.trim();
    if (str !== '') {
      ref = str.split(/\s+/);
      for (j = 0, len1 = ref.length; j < len1; j++) {
        word = ref[j];
        lWords.push(word);
      }
    }
  }
  return lWords;
};

// ---------------------------------------------------------------------------
export var isBoolean = (x) => {
  return jsType(x)[0] === 'boolean';
};

// ---------------------------------------------------------------------------
export var isFunction = (x) => {
  var mtype;
  mtype = jsType(x)[0];
  return (mtype === 'function') || (mtype === 'class');
};

// ---------------------------------------------------------------------------
export var isIterable = (obj) => {
  if ((obj === undef) || (obj === null)) {
    return false;
  }
  return typeof obj[Symbol.iterator] === 'function';
};

// ---------------------------------------------------------------------------
export var isRegExp = (x) => {
  return jsType(x)[0] === 'regexp';
};

// ---------------------------------------------------------------------------
export var isHash = (x, lKeys) => {
  var i, key, len;
  if (jsType(x)[0] !== 'hash') {
    return false;
  }
  if (defined(lKeys)) {
    if (isString(lKeys)) {
      lKeys = words(lKeys);
    } else if (!isArray(lKeys)) {
      throw new Error(`lKeys not an array: ${OL(lKeys)}`);
    }
    for (i = 0, len = lKeys.length; i < len; i++) {
      key = lKeys[i];
      if (!x.hasOwnProperty(key)) {
        return false;
      }
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isObject = (x, lReqKeys = undef) => {
  var _, i, key, lMatches, len, type;
  if (jsType(x)[0] !== 'object') {
    return false;
  }
  if (defined(lReqKeys)) {
    if (isString(lReqKeys)) {
      lReqKeys = words(lReqKeys);
    }
    assert(isArray(lReqKeys), `lReqKeys not an array: ${OL(lReqKeys)}`);
    for (i = 0, len = lReqKeys.length; i < len; i++) {
      key = lReqKeys[i];
      type = undef;
      if (lMatches = key.match(/^(\&)(.*)$/)) {
        [_, type, key] = lMatches;
      }
      if (notdefined(x[key])) {
        return false;
      }
      if ((type === '&') && (typeof x[key] !== 'function')) {
        return false;
      }
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isClass = (x) => {
  return jsType(x)[0] === 'class';
};

// ---------------------------------------------------------------------------
export var className = (item) => {
  var lMatches;
  // --- item can be a class or an object
  if (isClass(item)) {
    if (lMatches = item.toString().match(/class\s+(\w+)/)) {
      return lMatches[1];
    } else {
      throw new Error("className(): Bad input class");
    }
  } else if (isObject(item)) {
    return item.constructor.name;
  } else {
    return undef;
  }
};

// ---------------------------------------------------------------------------
export var isScalar = (x) => {
  return isNumber(x) || isString(x) || isBoolean(x);
};

// ---------------------------------------------------------------------------
//   isEmpty
//      - string is whitespace, array has no elements, hash has no keys
export var isEmpty = (x) => {
  if ((x === undef) || (x === null)) {
    return true;
  }
  if (isString(x)) {
    return x.match(/^\s*$/);
  }
  if (isArray(x)) {
    return x.length === 0;
  }
  if (isHash(x)) {
    return Object.keys(x).length === 0;
  } else {
    return false;
  }
};

// ---------------------------------------------------------------------------
//   nonEmpty
//      - string has non-whitespace, array has elements, hash has keys
export var nonEmpty = (x) => {
  return !isEmpty(x);
};

// ---------------------------------------------------------------------------
//   blockToArray - split a block into lines
export var blockToArray = (block) => {
  var lLines;
  if ((block === undef) || (block === '')) {
    return [];
  } else {
    assert(isString(block), `block is ${OL(block)}`);
    lLines = block.split(/\r?\n/);
    return lLines;
  }
};

// ---------------------------------------------------------------------------
//   arrayToBlock - block and lines in block will have no trailing whitespace
export var arrayToBlock = (lLines, hEsc = undef) => {
  var i, lResult, len, line, result;
  if (lLines === undef) {
    return '';
  }
  assert(isArray(lLines), "lLines is not an array");
  lResult = [];
  for (i = 0, len = lLines.length; i < len; i++) {
    line = lLines[i];
    if (defined(line)) {
      lResult.push(rtrim(line));
    }
  }
  if (lResult.length === 0) {
    return '';
  } else {
    result = lResult.join("\n");
    if (defined(hEsc)) {
      result = escapeStr(result, hEsc);
    }
    return result;
  }
};

// ---------------------------------------------------------------------------
export var toBlock = (item) => {
  if (isString(item)) {
    return item;
  } else {
    return arrayToBlock(item);
  }
};

// ---------------------------------------------------------------------------
export var toArray = (item) => {
  var i, j, lLines, len, len1, line, ref, str;
  if (isArray(item)) {
    // --- We need to split any strings containing a \n
    lLines = [];
    for (i = 0, len = item.length; i < len; i++) {
      line = item[i];
      if (hasChar(line, "\n")) {
        ref = line.split(/\r?\n/);
        for (j = 0, len1 = ref.length; j < len1; j++) {
          str = ref[j];
          lLines.push(str);
        }
      } else {
        lLines.push(line);
      }
    }
    return lLines;
  } else {
    return blockToArray(item);
  }
};

// ---------------------------------------------------------------------------
export var prefixBlock = (block, prefix) => {
  var lLines, line;
  lLines = (function() {
    var i, len, ref, results;
    ref = toArray(block);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      line = ref[i];
      results.push(`${prefix}${line}`);
    }
    return results;
  })();
  return toBlock(lLines);
};

// ---------------------------------------------------------------------------
//   rtrim - strip trailing whitespace
export var rtrim = (line) => {
  var lMatches, n;
  assert(isString(line), "rtrim(): line is not a string");
  lMatches = line.match(/\s+$/);
  if (defined(lMatches)) {
    n = lMatches[0].length; // num chars to remove
    return line.substring(0, line.length - n);
  } else {
    return line;
  }
};

// ---------------------------------------------------------------------------
hashFromString = (str) => {
  var _, eq, h, i, ident, lMatches, len, neg, ref, word;
  assert(isString(str), `not a string: ${OL(str)}`);
  h = {};
  ref = words(str);
  for (i = 0, len = ref.length; i < len; i++) {
    word = ref[i];
    if (lMatches = word.match(/^(\!)?([A-Za-z][A-Za-z_0-9]*)(?:(=)(.*))?$/)) { // negate value
      // identifier
      [_, neg, ident, eq, str] = lMatches;
      if (nonEmpty(eq)) {
        assert(isEmpty(neg), "negation with string value");
        // --- TO DO: interpret backslash escapes
        h[ident] = str;
      } else if (neg) {
        h[ident] = false;
      } else {
        h[ident] = true;
      }
    } else {
      throw new Error(`Invalid word ${OL(word)}`);
    }
  }
  return h;
};

// ---------------------------------------------------------------------------
export var getOptions = (options = undef, hDefault = {}) => {
  var hOptions, key, subtype, type, value;
  [type, subtype] = jsType(options);
  switch (type) {
    case undef:
      hOptions = {};
      break;
    case 'hash':
      hOptions = options;
      break;
    case 'string':
      hOptions = hashFromString(options);
      break;
    default:
      throw new Error(`options not hash or string: ${OL(options)}`);
  }
  for (key in hDefault) {
    if (!hasProp.call(hDefault, key)) continue;
    value = hDefault[key];
    if (!hOptions.hasOwnProperty(key)) {
      hOptions[key] = value;
    }
  }
  return hOptions;
};

// ---------------------------------------------------------------------------
export var range = (n) => {
  var ref;
  return (function() {
    var results = [];
    for (var i = 0, ref = n - 1; 0 <= ref ? i <= ref : i >= ref; 0 <= ref ? i++ : i--){ results.push(i); }
    return results;
  }).apply(this);
};

// ---------------------------------------------------------------------------
export var warn = (msg) => {
  console.log(`WARNING: ${msg}`);
};

// ---------------------------------------------------------------------------
export var uniq = (lItems) => {
  return [...new Set(lItems)];
};

// ---------------------------------------------------------------------------
//   say - print to the console (for now)
//         later, on a web page, call alert(str)
export var say = (x) => {
  if (isHash(x)) {
    LOG(JSON.stringify(x, Object.keys(h).sort(), 3));
  } else {
    LOG(x);
  }
};

// ---------------------------------------------------------------------------
export var extractMatches = (line, regexp, convertFunc = undef) => {
  var lConverted, lStrings, str;
  lStrings = [...line.matchAll(regexp)];
  lStrings = (function() {
    var i, len, results;
    results = [];
    for (i = 0, len = lStrings.length; i < len; i++) {
      str = lStrings[i];
      results.push(str[0]);
    }
    return results;
  })();
  if (defined(convertFunc)) {
    lConverted = (function() {
      var i, len, results;
      results = [];
      for (i = 0, len = lStrings.length; i < len; i++) {
        str = lStrings[i];
        results.push(convertFunc(str));
      }
      return results;
    })();
    return lConverted;
  } else {
    return lStrings;
  }
};

// ---------------------------------------------------------------------------
export var getTimeStr = (date = undef) => {
  if (date === undef) {
    date = new Date();
  }
  return date.toLocaleTimeString('en-US');
};

// ---------------------------------------------------------------------------
export var getDateStr = (date = undef) => {
  if (date === undef) {
    date = new Date();
  }
  return date.toLocaleDateString('en-US');
};

// ---------------------------------------------------------------------------
export var timestamp = () => {
  return new Date().toLocaleTimeString("en-US");
};

// ---------------------------------------------------------------------------
export var getDumpStr = (label, str, hOptions = {}) => {
  var escape, lLines, stringified, width;
  // --- Valid options:
  //        escape - escape space & TAB chars
  //        width
  lLines = [];
  ({escape, width} = getOptions(hOptions, {
    escape: false,
    width: 42
  }));
  if (isString(str)) {
    stringified = false;
  } else if (defined(str)) {
    str = JSON.stringify(str, undef, 3);
    stringified = true;
  } else {
    str = 'undef';
    stringified = true;
  }
  lLines.push('='.repeat(width));
  lLines.push(centeredText(label, width));
  if (stringified) {
    lLines.push('-'.repeat(width));
  } else {
    lLines.push('='.repeat(width));
  }
  if (escape) {
    lLines.push(escapeStr(str, hEscNoNL));
  } else {
    lLines.push(str.replace(/\t/g, "   "));
  }
  lLines.push('='.repeat(width));
  return lLines.join("\n");
};

// ---------------------------------------------------------------------------
export var DUMP = (label, obj, hOptions = {}) => {
  console.log(getDumpStr(label, obj, hOptions));
};
