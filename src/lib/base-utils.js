  // base-utils.coffee
var LOG, exec, hTimers, myHandler,
  hasProp = {}.hasOwnProperty;

import fs from 'node:fs';

import {
  exec as execCB,
  execSync
} from 'node:child_process';

import {
  promisify
} from 'node:util';

exec = promisify(execCB);

import assertLib from 'node:assert';

// --- ABSOLUTELY NO IMPORTS FROM OUR LIBS !!!!!
export const undef = void 0;

LOG = console.log; // used internally, not exported


// ---------------------------------------------------------------------------
// low-level version of assert()
export var assert = (cond, msg) => {
  assertLib.ok(cond, msg);
  return true;
};

// ---------------------------------------------------------------------------
// low-level version of croak()
export var croak = (msg) => {
  throw new Error(msg);
  return true;
};

// ---------------------------------------------------------------------------
export var fileExt = (filePath) => {
  var lMatches;
  if (lMatches = filePath.match(/\.[^\.]+$/)) {
    return lMatches[0];
  } else {
    return '';
  }
};

// ---------------------------------------------------------------------------
export var withExt = (filePath, newExt) => {
  var _, lMatches, pre;
  if (newExt.indexOf('.') !== 0) {
    newExt = '.' + newExt;
  }
  if (lMatches = filePath.match(/^(.*)\.[^\.]+$/)) {
    [_, pre] = lMatches;
    return pre + newExt;
  }
  throw new Error(`Bad path: '${filePath}'`);
};

// ---------------------------------------------------------------------------
export var newerDestFilesExist = (srcPath, ...lDestPaths) => {
  var destModTime, destPath, j, len1, srcModTime;
  for (j = 0, len1 = lDestPaths.length; j < len1; j++) {
    destPath = lDestPaths[j];
    if (!fs.existsSync(destPath)) {
      return false;
    }
    srcModTime = fs.statSync(srcPath).mtimeMs;
    destModTime = fs.statSync(destPath).mtimeMs;
    if (destModTime < srcModTime) {
      return false;
    }
  }
  return true;
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
export var alldefined = (...lObj) => {
  var j, len1, obj;
  for (j = 0, len1 = lObj.length; j < len1; j++) {
    obj = lObj[j];
    if ((obj === undef) || (obj === null)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var truncateStr = (str, maxLen) => {
  var len;
  assert(isString(str), `not a string: ${typeof str}`);
  assert(isInteger(maxLen), `not an integer: ${maxLen}`);
  len = str.length;
  if (len <= maxLen) {
    return str;
  } else {
    return str.substring(0, maxLen - 1) + '…';
  }
};

// ---------------------------------------------------------------------------
//   escapeStr - escape newlines, carriage return, TAB chars, etc.
export var hEsc = {
  "\r": '◄',
  "\n": '▼',
  "\t": '→',
  " ": '˳'
};

export var hEscNoNL = {
  "\t": '→',
  " ": '˳'
};

export var escapeStr = (str, hReplace = hEsc) => {
  var ch, result;
  // --- hReplace can also be a string:
  //        'esc'     - escape space, newline, tab
  //        'escNoNL' - escape space, tab
  assert(isString(str), `not a string: ${typeof str}`);
  if (isString(hReplace)) {
    switch (hReplace) {
      case 'esc':
        hReplace = hEsc;
        break;
      case 'escNoNL':
        hReplace = hExcNoNL;
        break;
      default:
        return str;
    }
  }
  assert(isHash(hReplace), "not a hash");
  if (isEmpty(hReplace)) {
    return str;
  }
  result = '';
  for (ch of str) {
    if (defined(hReplace[ch])) {
      result += hReplace[ch];
    } else {
      result += ch;
    }
  }
  return result;
};

// ---------------------------------------------------------------------------
export var userSetQuoteChars = false;

export var lQuoteChars = ['«', '»'];

export var quoted = (str, escape = undef) => {
  var hMyEsc, lq, result, rq;
  assert(isString(str), `not a string: ${str}`);
  // --- Escape chars if specified
  switch (escape) {
    case 'escape':
      str = escapeStr(str, hEsc); // escape sp, tab, nl
      break;
    case 'escapeNoNL':
      str = escapeStr(str, hEscNoNL);
  }
  if (!userSetQuoteChars) {
    if (!hasChar(str, '"')) {
      result = '"' + str + '"';
      return result;
    }
    if (!hasChar(str, "'")) {
      result = "'" + str + "'";
      return result;
    }
  }
  [lq, rq] = lQuoteChars;
  hMyEsc = {
    [lq]: "\\" + lq,
    [rq]: "\\" + rq
  };
  result = lq + escapeStr(str, hMyEsc) + rq;
  return result;
};

// ---------------------------------------------------------------------------
export var setQuoteChars = (start = '«', end = '»') => {
  // --- returns original quote chars
  lQuoteChars[0] = start;
  lQuoteChars[1] = end || start;
  userSetQuoteChars = true;
};

export var resetQuoteChars = () => {
  userSetQuoteChars = false;
  lQuoteChars = ['«', '»'];
};

// ---------------------------------------------------------------------------
export var OL = (obj, debug = false) => {
  var finalResult, myReplacer, result;
  if (obj === undef) {
    return 'undef';
  }
  if (obj === null) {
    return 'null';
  }
  myReplacer = (key, x) => {
    var tag, type;
    type = typeof x;
    switch (type) {
      case 'bigint':
        return `«BigInt ${x.toString()}»`;
      case 'function':
        if (x.toString().startsWith('class')) {
          tag = 'Class';
        } else {
          tag = 'Function';
        }
        if (defined(x.name)) {
          return `«${tag} ${x.name}»`;
        } else {
          return `«${tag}»`;
        }
        break;
      case 'string':
        // --- NOTE: JSON.stringify will add quote chars
        return escapeStr(x);
      case 'object':
        if (x instanceof RegExp) {
          return `«RegExp ${x.toString()}»`;
        }
        if (defined(x) && (typeof x.then === 'function')) {
          return "«Promise»";
        } else {
          return x;
        }
        break;
      default:
        return x;
    }
  };
  result = JSON.stringify(obj, myReplacer);
  // --- Because JSON.stringify adds quote marks,
  //     we remove them when using « and »
  finalResult = result.replaceAll('"«', '«').replaceAll('»"', '»');
  return finalResult;
};

// ---------------------------------------------------------------------------
export var OLS = (lObjects, sep = ',') => {
  var j, lParts, len1, obj;
  assert(isArray(lObjects), "not an array");
  lParts = [];
  for (j = 0, len1 = lObjects.length; j < len1; j++) {
    obj = lObjects[j];
    lParts.push(OL(obj));
  }
  return lParts.join(sep);
};

// ---------------------------------------------------------------------------
export var jsType = (x) => {
  var lKeys, str;
  // --- return [type, subtype]
  switch (x) {
    case undef:
      return [undef, undef];
    case null:
      return [undef, 'null'];
    case true:
    case false:
      return ['boolean', undef];
  }
  switch (typeof x) {
    case 'number':
      if (Number.isNaN(x)) {
        return ['number', 'NaN'];
      } else if (Number.isInteger(x)) {
        return ['number', 'integer'];
      } else {
        return ['number', undef];
      }
      break;
    case 'bigint':
      return ['number', 'integer'];
    case 'string':
      if (x.match(/^\s*$/)) {
        return ['string', 'empty'];
      } else {
        return ['string', undef];
      }
      break;
    case 'boolean':
      return ['boolean', undef];
    case 'function':
      str = x.toString();
      if (str.startsWith('class')) {
        return ['class', x.name || undef];
      } else {
        return ['function', x.name || undef];
      }
      break;
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
          return ['function', x.name || undef];
        }
      }
      if (defined(x.constructor.name) && (typeof x.constructor.name === 'string') && (x.constructor.name === 'Object')) {
        lKeys = keys(x);
        if (lKeys.length === 0) {
          return ['hash', 'empty'];
        } else {
          return ['hash', undef];
        }
      } else if (typeof x.then === 'function') {
        return ['promise', undef];
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

export var isArray = (x) => {
  return jsType(x)[0] === 'array';
};

export var isBoolean = (x) => {
  return jsType(x)[0] === 'boolean';
};

export var isFunction = (x) => {
  return jsType(x)[0] === 'function';
};

export var isRegExp = (x) => {
  return jsType(x)[0] === 'regexp';
};

export var isPromise = (x) => {
  return jsType(x)[0] === 'promise';
};

// ---------------------------------------------------------------------------
export var isHash = (x, lKeys = undef) => {
  var j, key, len1;
  if (jsType(x)[0] !== 'hash') {
    return false;
  }
  if (defined(lKeys)) {
    if (isString(lKeys)) {
      lKeys = words(lKeys);
    } else if (!isArray(lKeys)) {
      throw new Error(`lKeys not an array: ${OL(lKeys)}`);
    }
    for (j = 0, len1 = lKeys.length; j < len1; j++) {
      key = lKeys[j];
      if (!x.hasOwnProperty(key)) {
        return false;
      }
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isObject = (x, lReqKeys = undef) => {
  var _, j, key, lMatches, len1, type;
  if (jsType(x)[0] !== 'object') {
    return false;
  }
  if (defined(lReqKeys)) {
    if (isString(lReqKeys)) {
      lReqKeys = words(lReqKeys);
    }
    assert(isArray(lReqKeys), `lReqKeys not an array: ${OL(lReqKeys)}`);
    for (j = 0, len1 = lReqKeys.length; j < len1; j++) {
      key = lReqKeys[j];
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
export var execCmd = (cmd, ...lParts) => {
  var cmdLine, err, result;
  // --- may throw an exception
  cmdLine = buildCmdLine(cmd, ...lParts);
  try {
    result = execSync(cmdLine, {
      encoding: 'utf8',
      windowsHide: true
    });
    assert(isString(result), `result = ${OL(result)}`);
    return result;
  } catch (error1) {
    err = error1;
    return console.log(`ERROR: ${OL(err)}`);
  }
};

// ---------------------------------------------------------------------------
export var npmLogLevel = () => {
  var result;
  result = execCmd('npm config get loglevel');
  return chomp(result);
};

// ---------------------------------------------------------------------------
export var execCmdAsync = async(cmd, ...lParts) => {
  var cmdLine;
  // --- may throw an exception
  cmdLine = buildCmdLine(cmd, ...lParts);
  return (await exec(cmdLine, {
    encoding: 'utf8',
    windowsHide: true
  }));
};

// ---------------------------------------------------------------------------
// --- lParts may contain hashes (options) or arrays (non-options)
export var buildCmdLine = (cmd, ...lParts) => {
  var item, j, k, key, lAllParts, lFlags, lNonOptions, lOptions, len1, len2, obj, value;
  lOptions = [];
  lFlags = []; // array of letters
  lNonOptions = [];
  for (j = 0, len1 = lParts.length; j < len1; j++) {
    obj = lParts[j];
    if (isHash(obj)) {
      for (key in obj) {
        if (!hasProp.call(obj, key)) continue;
        value = obj[key];
        switch (jsType(value)[0]) {
          case 'string':
            if (value.includes(' ')) {
              lOptions.push(`-${key}=\"${value}\"`);
            } else {
              lOptions.push(`-${key}=${value}`);
            }
            break;
          case 'boolean':
            if (value) {
              if (key.length === 1) {
                lFlags.push(key);
              } else {
                lOptions.push(`-${key}=true`);
              }
            } else {
              lOptions.push(`-${key}=false`);
            }
            break;
          case 'number':
            lOptions.push(`-${key}=${value}`);
            break;
          default:
            croak(`Bad option: ${OL(value)}`);
        }
      }
    } else if (isArray(obj)) {
      for (k = 0, len2 = obj.length; k < len2; k++) {
        item = obj[k];
        if (item.includes(' ')) {
          lNonOptions.push(`\"${item}\"`);
        } else {
          lNonOptions.push(item);
        }
      }
    } else {
      croak("arg not an array or hash");
    }
  }
  if (lFlags.length > 0) {
    lOptions.push(`-${lFlags.join('')}`);
  }
  // --- join the parts
  lAllParts = [cmd, ...lOptions, ...lNonOptions];
  return lAllParts.join(' ');
};

// ---------------------------------------------------------------------------
export var chomp = (str) => {
  var len;
  // --- Remove trailing \n if present
  len = str.length;
  if (str[len - 1] === '\n') {
    if (str[len - 2] === '\r') {
      return str.substring(0, len - 2);
    } else {
      return str.substring(0, len - 1);
    }
  } else {
    return str;
  }
};

// ---------------------------------------------------------------------------
//   isEmpty
//      - string is whitespace, array has no elements, hash has no keys
export var isEmpty = (x) => {
  if ((x === undef) || (x === null)) {
    return true;
  }
  if (typeof x === 'string') {
    return x.match(/^\s*$/);
  }
  if (Array.isArray(x)) {
    return x.length === 0;
  }
  if (typeof x === 'object') {
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
//   deepCopy - deep copy an array or object
export var deepCopy = (obj) => {
  var err, newObj, objStr;
  if (obj === undef) {
    return undef;
  }
  objStr = JSON.stringify(obj);
  try {
    newObj = JSON.parse(objStr);
  } catch (error1) {
    err = error1;
    throw new Error("ERROR: err.message");
  }
  return newObj;
};

// ---------------------------------------------------------------------------
export var add_s = (n) => {
  if (n === 1) {
    return '';
  } else {
    return 's';
  }
};

// ---------------------------------------------------------------------------
export var keys = (...lHashes) => {
  var h, j, k, key, lKeys, len1, len2, ref;
  lKeys = [];
  for (j = 0, len1 = lHashes.length; j < len1; j++) {
    h = lHashes[j];
    ref = Object.keys(h);
    for (k = 0, len2 = ref.length; k < len2; k++) {
      key = ref[k];
      if (!lKeys.includes(key)) {
        lKeys.push(key);
      }
    }
  }
  return lKeys;
};

// ---------------------------------------------------------------------------
export var hasKey = (obj, key) => {
  return obj.hasOwnProperty(key);
};

// ---------------------------------------------------------------------------
// --- Removes key, but returns associated value
export var extractKey = (h, key) => {
  var val;
  assert(isHash(h), "not a hash");
  assert(isString(key), "key not a string");
  val = h[key];
  delete h[key];
  return val;
};

// ---------------------------------------------------------------------------
export var removeKeys = (item, lKeys) => {
  var j, k, key, len1, len2, prop, subitem, subtype, type, value;
  assert(isArray(lKeys), "not an array");
  [type, subtype] = jsType(item);
  switch (type) {
    case 'array':
      for (j = 0, len1 = item.length; j < len1; j++) {
        subitem = item[j];
        removeKeys(subitem, lKeys);
      }
      break;
    case 'hash':
    case 'object':
      for (k = 0, len2 = lKeys.length; k < len2; k++) {
        key = lKeys[k];
        if (item.hasOwnProperty(key)) {
          delete item[key];
        }
      }
      for (prop in item) {
        value = item[prop];
        removeKeys(value, lKeys);
      }
  }
  return item;
};

// ---------------------------------------------------------------------------
export var hasAllKeys = (obj, ...lKeys) => {
  var j, key, len1;
  for (j = 0, len1 = lKeys.length; j < len1; j++) {
    key = lKeys[j];
    if (!hasKey(obj, key)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var hasAnyKey = (obj, ...lKeys) => {
  var j, key, len1;
  for (j = 0, len1 = lKeys.length; j < len1; j++) {
    key = lKeys[j];
    if (hasKey(obj, key)) {
      return true;
    }
  }
  return false;
};

// ---------------------------------------------------------------------------
export var addNewKey = function(h, key, value) {
  assert(!hasKey(h, key), `hash has key ${key}`);
  h[key] = value;
  return h;
};

// ---------------------------------------------------------------------------
export var subkeys = (obj) => {
  var h, j, k, key, lSubKeys, len1, len2, ref, ref1, subkey;
  lSubKeys = [];
  ref = keys(obj);
  for (j = 0, len1 = ref.length; j < len1; j++) {
    key = ref[j];
    h = obj[key];
    ref1 = keys(h);
    for (k = 0, len2 = ref1.length; k < len2; k++) {
      subkey = ref1[k];
      if (!lSubKeys.includes(subkey)) {
        lSubKeys.push(subkey);
      }
    }
  }
  return lSubKeys;
};

// ---------------------------------------------------------------------------
export var hslice = (h, lKeys) => {
  var hResult, j, key, len1;
  hResult = {};
  for (j = 0, len1 = lKeys.length; j < len1; j++) {
    key = lKeys[j];
    hResult[key] = h[key];
  }
  return hResult;
};

// ---------------------------------------------------------------------------
export var samelist = (lItems1, lItems2) => {
  var item, j, k, len1, len2;
  assert(isArray(lItems1), "arg 1 not an array");
  assert(isArray(lItems2), "arg 2 not an array");
  if (lItems1.length !== lItems2.length) {
    return false;
  }
  for (j = 0, len1 = lItems1.length; j < len1; j++) {
    item = lItems1[j];
    if (!lItems2.includes(item)) {
      return false;
    }
  }
  for (k = 0, len2 = lItems2.length; k < len2; k++) {
    item = lItems2[k];
    if (!lItems1.includes(item)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var fromJSON = (strJson) => {
  // --- string to data structure
  return JSON.parse(strJson);
};

// ---------------------------------------------------------------------------
export var toJSON = (hJson, hOptions = {}) => {
  var replacer, useTabs;
  // --- data structure to string
  ({useTabs, replacer} = getOptions(hOptions, {
    useTabs: true,
    replacer: undef
  }));
  if (useTabs) {
    return JSON.stringify(hJson, replacer, "\t");
  } else {
    return JSON.stringify(hJson, replacer, 3);
  }
};

// ---------------------------------------------------------------------------
export var deepEqual = (a, b) => {
  var error;
  try {
    assertLib.deepEqual(a, b);
  } catch (error1) {
    error = error1;
    if (error.name === "AssertionError") {
      return false;
    }
    throw error;
  }
  return true;
};

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
export var spaces = (n) => {
  return " ".repeat(n);
};

// ---------------------------------------------------------------------------
export var tabs = (n) => {
  return "\t".repeat(n);
};

// ---------------------------------------------------------------------------
// --- valid options:
//        char - char to use on left and right
//        buffer - num spaces around text when char <> ' '
export var centeredText = (text, width, hOptions = {}) => {
  var buf, char, left, numBuffer, numLeft, numRight, right, totSpaces;
  ({char, numBuffer} = getOptions(hOptions, {
    char: ' ',
    numBuffer: 2
  }));
  assert(isInteger(width), `width = ${OL(width)}`);
  totSpaces = width - text.length;
  if (totSpaces <= 0) {
    return text;
  }
  numLeft = Math.floor(totSpaces / 2);
  numRight = totSpaces - numLeft;
  if (char === ' ') {
    return spaces(numLeft) + text + spaces(numRight);
  } else {
    buf = ' '.repeat(numBuffer);
    left = char.repeat(numLeft - numBuffer);
    right = char.repeat(numRight - numBuffer);
    numLeft -= numBuffer;
    numRight -= numBuffer;
    return left + buf + text + buf + right;
  }
};

// ---------------------------------------------------------------------------
export var delimitBlock = (block, hOptions = {}) => {
  var header, label, str, width;
  ({width, label} = getOptions(hOptions, {
    width: 40,
    label: undef
  }));
  str = '-'.repeat(width);
  if (defined(label)) {
    header = centeredText(label, width, {
      char: '-'
    });
  } else {
    header = str;
  }
  if (block === '') {
    return [header, str].join("\n");
  } else {
    return [header, block, str].join("\n");
  }
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
export var trimArray = (lLines) => {
  // --- lLines is modified in place, but we still return a ref
  while ((lLines.length > 0) && isEmpty(lLines[0])) {
    lLines.shift();
  }
  while ((lLines.length > 0) && isEmpty(lLines[lLines.length - 1])) {
    lLines.pop();
  }
  return lLines;
};

// ---------------------------------------------------------------------------
export var removeEmptyLines = (lLines) => {
  assert(isArrayOfStrings(lLines), `Not an array of strings: ${OL(lLines)}`);
  return lLines.filter((line) => {
    return nonEmpty(line);
  });
};

// ---------------------------------------------------------------------------
export var CWSALL = (blockOrArray) => {
  var lNewArray, line;
  if (isArrayOfStrings(blockOrArray)) {
    lNewArray = (function() {
      var j, len1, results;
      results = [];
      for (j = 0, len1 = blockOrArray.length; j < len1; j++) {
        line = blockOrArray[j];
        results.push(CWS(line));
      }
      return results;
    })();
    return trimArray(lNewArray);
  } else if (isString(blockOrArray)) {
    lNewArray = (function() {
      var j, len1, ref, results;
      ref = toArray(blockOrArray);
      results = [];
      for (j = 0, len1 = ref.length; j < len1; j++) {
        line = ref[j];
        results.push(CWS(line));
      }
      return results;
    })();
    return toBlock(trimArray(lNewArray));
  } else {
    throw new Error(`Bad param: ${OL(blockOrArray)}`);
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
export var hasPrefix = (line) => {
  var lMatches;
  assert(isString(line), `non-string ${OL(line)}`);
  lMatches = line.match(/^(\s*)/);
  return lMatches[1].length > 0;
};

// ---------------------------------------------------------------------------
//    tabify - convert leading spaces to TAB characters
//             if numSpaces is not defined, then the first line
//             that contains at least one space sets it
// --- Works on both blocks and arrays - returns same kind of item
export var tabify = (item, numSpaces = undef) => {
  var j, lLines, len1, level, prefix, prefixLen, ref, result, str, theRest;
  lLines = [];
  ref = toArray(item);
  for (j = 0, len1 = ref.length; j < len1; j++) {
    str = ref[j];
    [prefix, theRest] = splitPrefix(str);
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
  if (isArray(item)) {
    result = item;
  } else {
    result = toBlock(lLines);
  }
  return result;
};

// ---------------------------------------------------------------------------
export var untabify = (str, numSpaces = 3) => {
  return str.replace(/\t/g, ' '.repeat(numSpaces));
};

// ---------------------------------------------------------------------------
export var forEachLine = (item, func) => {
  var i, j, lInput, len1, line, result;
  // --- callback to func() gets arguments:
  //        line - each line
  //        hInfo - with keys lineNum and nextLine
  // Return value should be:
  //    true - to stop prematurely
  //    false - to continue
  lInput = toArray(item);
  for (i = j = 0, len1 = lInput.length; j < len1; i = ++j) {
    line = lInput[i];
    result = func(line, {
      lineNum: i + 1,
      nextLine: lInput[i + 1]
    });
    assert(isBoolean(result), `result must be a boolean, got ${OL(result)}`);
    if (result) { // return of true causes premature exit
      return;
    }
  }
};

// ---------------------------------------------------------------------------
export var mapEachLine = (item, func) => {
  var i, j, lInput, lLines, len1, line, result;
  // --- callback to func() gets arguments:
  //        line - each line
  //        hInfo - with keys lineNum and nextLine
  //     callback return value should be:
  //        undef - to skip this line
  //        else value to include
  lLines = []; // return value
  lInput = toArray(item);
  for (i = j = 0, len1 = lInput.length; j < len1; i = ++j) {
    line = lInput[i];
    result = func(line, {
      lineNum: i + 1,
      nextLine: lInput[i + 1]
    });
    if (defined(result)) {
      lLines.push(result);
    }
  }
  if (isArray(item)) {
    return lLines;
  } else {
    return toBlock(lLines);
  }
};

// ---------------------------------------------------------------------------
export var qStr = (x) => {
  // --- x must be string or undef
  //     puts quotes around a string
  if (notdefined(x)) {
    return 'undef';
  } else if (isString(x)) {
    return `'${x}'`;
  } else {
    throw new Error("quoteStr(): Not a string or undef");
  }
};

// ---------------------------------------------------------------------------
export var hasChar = (str, ch) => {
  assert(isString(str), `Not a string: ${str}`);
  return str.indexOf(ch) >= 0;
};

// ---------------------------------------------------------------------------
export var oneof = (word, ...lWords) => {
  return lWords.indexOf(word) >= 0;
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
  } catch (error1) {
    e = error1;
    return false;
  }
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
  return isHash(x) && (keys(x).length > 0);
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
export var isArrayOfArrays = (lItems, size = undef) => {
  var item, j, len1;
  if (!isArray(lItems)) {
    return false;
  }
  for (j = 0, len1 = lItems.length; j < len1; j++) {
    item = lItems[j];
    if (defined(item)) {
      if (!isArray(item)) {
        return false;
      }
      if (defined(size) && (item.length !== size)) {
        return false;
      }
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var isArrayOfHashes = (lItems) => {
  var item, j, len1;
  if (!isArray(lItems)) {
    return false;
  }
  for (j = 0, len1 = lItems.length; j < len1; j++) {
    item = lItems[j];
    if (defined(item) && !isHash(item)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var sortArrayOfHashes = (lHashes, key) => {
  var compareFunc;
  assert(isArrayOfHashes(lHashes), "Not an array of hashes");
  // --- NOTE: works whether values are strings or numbers
  compareFunc = (a, b) => {
    if (a[key] < b[key]) {
      return -1;
    } else if (a[key] > b[key]) {
      return 1;
    } else {
      return 0;
    }
  };
  lHashes.sort(compareFunc);
  // --- NOTE: array is sorted in place, but sometimes
  //           it's useful if we return a ref to it anyway
  return lHashes;
};

// ---------------------------------------------------------------------------
export var sortedArrayOfHashes = (lHashes, key) => {
  var compareFunc;
  assert(isArrayOfHashes(lHashes), "Not an array of hashes");
  // --- NOTE: works whether values are strings or numbers
  compareFunc = (a, b) => {
    if (a[key] < b[key]) {
      return -1;
    } else if (a[key] > b[key]) {
      return 1;
    } else {
      return 0;
    }
  };
  return lHashes.toSorted(compareFunc);
};

// ---------------------------------------------------------------------------
export var isArrayOfStrings = (lItems) => {
  var item, j, len1;
  if (!isArray(lItems)) {
    return false;
  }
  for (j = 0, len1 = lItems.length; j < len1; j++) {
    item = lItems[j];
    if (defined(item) && !isString(item)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var words = (...lStrings) => {
  var j, k, lWords, len1, len2, ref, str, word;
  lWords = [];
  for (j = 0, len1 = lStrings.length; j < len1; j++) {
    str = lStrings[j];
    str = str.trim();
    if (str !== '') {
      ref = str.split(/\s+/);
      for (k = 0, len2 = ref.length; k < len2; k++) {
        word = ref[k];
        lWords.push(word);
      }
    }
  }
  return lWords;
};

// ---------------------------------------------------------------------------
// --- e.g. mkword([null, ['4','2'], null) returns '42'
export var mkword = (...lStuff) => {
  var j, lParts, len1, result, thing;
  lParts = [];
  for (j = 0, len1 = lStuff.length; j < len1; j++) {
    thing = lStuff[j];
    if (isString(thing)) {
      lParts.push(thing);
    } else if (isArray(thing)) {
      result = mkword(...thing);
      if (nonEmpty(result)) {
        lParts.push(result);
      }
    }
  }
  return lParts.join('');
};

// ---------------------------------------------------------------------------
export var isIterable = (obj) => {
  if ((obj === undef) || (obj === null)) {
    return false;
  }
  return typeof obj[Symbol.iterator] === 'function';
};

// ---------------------------------------------------------------------------
// --- always return hash with the same set of keys!
//     values should be a string, true, false or undef
export var analyzeObj = (obj, hOptions = {}) => {
  var _, h, jst, lMatches, lType, maxStrLen, name, objType, star, str, type;
  ({maxStrLen} = getOptions(hOptions, {
    maxStrLen: 22
  }));
  type = typeof obj;
  lType = jsType(obj);
  if (defined(lType[1])) {
    jst = lType.join('/');
  } else {
    jst = lType[0];
  }
  h = {
    jsType: jst,
    type,
    isArr: Array.isArray(obj),
    isIter: isIterable(obj),
    objType: '',
    objName: '',
    conName: '',
    str: ''
  };
  if (notdefined(obj)) {
    return h;
  }
  if (defined(obj.constructor)) {
    h.conName = obj.constructor.name;
  }
  if (defined(obj.toString)) {
    str = truncateStr(CWS(obj.toString()), maxStrLen);
    if (lMatches = str.match(/^\[object\s+([A-Za-z]+)\]/)) {
      [_, objType] = lMatches;
      if (objType === 'Generator') {
        h.objType = 'iterator';
      } else {
        h.objType = objType.toLowerCase();
      }
    } else if (lMatches = str.match(/^class\s*(?:([A-Za-z_][A-Za-z0-9_]*)\s*)?\{/)) {
      h.objType = 'class';
      h.objName = lMatches[1] || '';
    } else if (lMatches = str.match(/^\s*function\s*(\*)?\s*(?:([A-Za-z_][A-Za-z0-9_]*)\s*)?\(/)) {
      [_, star, name] = lMatches;
      h.objType = star === '*' ? 'generator' : 'function';
      h.objName = lMatches[1] || '';
    }
    h.str = str;
  }
  return h;
};

// ---------------------------------------------------------------------------
export var hasClassConstructor = (obj) => {
  var con;
  con = obj != null ? obj.constructor : void 0;
  if (notdefined(con) || notdefined(con.toString)) {
    return false;
  }
  return con.toString().startsWith('class');
};

// ---------------------------------------------------------------------------
export var isClass = (obj) => {
  return (typeof obj === 'function') && obj.toString().startsWith('class');
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
  var j, lResult, len1, line, result;
  if (lLines === undef) {
    return '';
  }
  assert(isArray(lLines), "lLines is not an array");
  lResult = [];
  for (j = 0, len1 = lLines.length; j < len1; j++) {
    line = lLines[j];
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
  var j, k, lLines, len1, len2, line, ref, str;
  if (isArray(item)) {
    // --- We need to split any strings containing a \n
    lLines = [];
    for (j = 0, len1 = item.length; j < len1; j++) {
      line = item[j];
      if (hasChar(line, "\n")) {
        ref = line.split(/\r?\n/);
        for (k = 0, len2 = ref.length; k < len2; k++) {
          str = ref[k];
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
    var j, len1, ref, results;
    ref = toArray(block);
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      line = ref[j];
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
  assert(isString(line), `not a string: ${OL(line)}`);
  lMatches = line.match(/\s+$/);
  if (defined(lMatches)) {
    n = lMatches[0].length; // num chars to remove
    return line.substring(0, line.length - n);
  } else {
    return line;
  }
};

// ---------------------------------------------------------------------------
export var hashFromString = (str) => {
  var _, eq, h, ident, j, lMatches, len1, neg, num, ref, word;
  assert(isString(str), `not a string: ${OL(str)}`);
  h = {};
  ref = words(str);
  for (j = 0, len1 = ref.length; j < len1; j++) {
    word = ref[j];
    if (lMatches = word.match(/^(\!)?([A-Za-z][A-Za-z_0-9]*)(?:(=)(.*))?$/)) { // negate value
      // identifier
      [_, neg, ident, eq, str] = lMatches;
      if (nonEmpty(eq)) {
        assert(isEmpty(neg), "negation with string value");
        // --- check if str is a valid number
        num = parseFloat(str);
        if (Number.isNaN(num)) {
          // --- TO DO: interpret backslash escapes
          h[ident] = str;
        } else {
          h[ident] = num;
        }
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
    if (!hOptions.hasOwnProperty(key) && defined(value)) {
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
    for (var j = 0, ref = n - 1; 0 <= ref ? j <= ref : j >= ref; 0 <= ref ? j++ : j--){ results.push(j); }
    return results;
  }).apply(this);
};

// ---------------------------------------------------------------------------
export var rev_range = (n) => {
  var ref;
  return (function() {
    var results = [];
    for (var j = 0, ref = n - 1; 0 <= ref ? j <= ref : j >= ref; 0 <= ref ? j++ : j--){ results.push(j); }
    return results;
  }).apply(this).reverse();
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
export var extractMatches = (line, regexp, convertFunc = undef) => {
  var lConverted, lStrings, str;
  lStrings = [...line.matchAll(regexp)];
  lStrings = (function() {
    var j, len1, results;
    results = [];
    for (j = 0, len1 = lStrings.length; j < len1; j++) {
      str = lStrings[j];
      results.push(str[0]);
    }
    return results;
  })();
  if (defined(convertFunc)) {
    lConverted = (function() {
      var j, len1, results;
      results = [];
      for (j = 0, len1 = lStrings.length; j < len1; j++) {
        str = lStrings[j];
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
export var timestamp = (dateStr = undef, locale = 'en-US') => {
  var date, str1, str2;
  if (defined(dateStr)) {
    date = new Date(dateStr);
  } else {
    date = new Date();
  }
  str1 = date.toLocaleDateString(locale);
  str2 = date.toLocaleTimeString(locale);
  return `${str1} ${str2}`;
};

// ---------------------------------------------------------------------------
export var msSinceEpoch = (dateStr = undef) => {
  var date;
  if (defined(dateStr)) {
    date = new Date(dateStr);
  } else {
    date = new Date();
  }
  return date.getTime();
};

// ---------------------------------------------------------------------------
export var formatDate = (dateStr = undef, dateStyle = 'medium', locale = 'en-US') => {
  var date;
  if (defined(dateStr)) {
    date = new Date(dateStr);
  } else {
    date = new Date();
  }
  return new Intl.DateTimeFormat(locale, {dateStyle}).format(date);
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
export var eachCharInString = (str, func) => {
  var ch, j, len1, ref;
  ref = Array.from(str);
  for (j = 0, len1 = ref.length; j < len1; j++) {
    ch = ref[j];
    if (!func(ch)) {
      return false;
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var DUMP = (label, obj, hOptions = {}) => {
  assert(isString(label), "no label");
  console.log(getDumpStr(label, obj, hOptions));
};

// ---------------------------------------------------------------------------
// in callback set():
//    - return undef to NOT set
//    - return value (possibly changed) to set
// in callback get():
//    - return (possibly changed) value
// ---------------------------------------------------------------------------
export var getProxy = (obj, hCallbacks) => {
  var hHandlers;
  // --- Keys in hFuncs can be: 'get','set'
  hHandlers = {};
  if (hCallbacks.hasOwnProperty('set')) {
    hHandlers.set = function(obj, prop, value) {
      var newval;
      newval = hCallbacks.set(obj, prop, value);
      if (defined(newval)) { // don't set if callback returns false
        Reflect.set(obj, prop, newval);
      }
      return true;
    };
  }
  if (hCallbacks.hasOwnProperty('get')) {
    hHandlers.get = function(obj, prop) {
      var value;
      value = Reflect.get(obj, prop);
      return hCallbacks.get(obj, prop, value);
    };
  }
  if (isEmpty(hHandlers)) {
    return obj;
  } else {
    return new Proxy(obj, hHandlers);
  }
};

// ---------------------------------------------------------------------------
export var sleep = (secs) => {
  return new Promise((r) => {
    return setTimeout(r, 1000 * secs);
  });
};

// ---------------------------------------------------------------------------
hTimers = {}; // { <id> => <timer>, ... }

export var schedule = (secs, keyVal, func, ...lArgs) => {
  var timer;
  assert(isFunction(func), `not a function: ${OL(func)}`);
  // --- if there's currently a timer with the same keyVal, kill it
  if (defined(timer = hTimers[keyVal])) {
    clearTimeout(timer);
  }
  hTimers[keyVal] = setTimeout(func, 1000 * secs, ...lArgs);
};

// ---------------------------------------------------------------------------
export var hit = function(pct) {
  return Math.random() * 100 < pct;
};

// ---------------------------------------------------------------------------
export var choose = function(lItems) {
  return lItems[Math.floor(Math.random() * lItems.length)];
};

// ---------------------------------------------------------------------------
// --- shuffle an array in place, return ref to shuffled array
export var shuffle = function(lItems) {
  var i, i2;
  i = lItems.length;
  // --- While there remain elements to shuffle.
  while (i > 0) {
    // --- Pick a remaining element.
    i2 = Math.floor(Math.random() * i);
    i -= 1;
    // --- And swap it with the current element.
    [lItems[i], lItems[i2]] = [lItems[i2], lItems[i]];
  }
  return lItems;
};

// ---------------------------------------------------------------------------
export var pad = (x, width, hOptions = {}) => {
  var decPlaces, justify, lPad, rPad, str, subtype, toAdd, truncate, type;
  // --- hOptions.justify can be 'left','center','right'
  ({decPlaces, justify, truncate} = getOptions(hOptions, {
    decPlaces: undef,
    justify: undef,
    truncate: false
  }));
  [type, subtype] = jsType(x);
  switch (type) {
    case undef:
      str = 'undef';
      if (notdefined(justify)) {
        justify = 'left';
      }
      break;
    case 'string':
      str = x;
      if (notdefined(justify)) {
        justify = 'left';
      }
      break;
    case 'boolean':
      if (x) {
        str = 'true';
      } else {
        str = 'false';
      }
      if (notdefined(justify)) {
        justify = 'center';
      }
      break;
    case 'number':
      if (defined(decPlaces)) {
        str = x.toFixed(decPlaces);
      } else if (subtype === 'integer') {
        str = x.toString();
      } else {
        str = x.toFixed(2);
      }
      if (notdefined(justify)) {
        justify = 'right';
      }
      break;
    case 'object':
      str = '[Object]';
      if (notdefined(justify)) {
        justify = 'left';
      }
      break;
    default:
      croak(`Invalid value: ${OL(x)}`);
  }
  toAdd = width - str.length;
  if (toAdd === 0) {
    return str;
  } else if (toAdd < 0) {
    if (truncate) {
      return str.substring(0, width);
    } else {
      return str;
    }
  }
  switch (justify) {
    case 'left':
      return str + ' '.repeat(toAdd);
    case 'center':
      lPad = Math.floor(toAdd / 2);
      rPad = toAdd - lPad;
      return `${' '.repeat(lPad)}${str}${' '.repeat(rPad)}`;
    case 'right':
      return ' '.repeat(toAdd) + str;
    default:
      return croak(`Invalid value for justify: ${justify}`);
  }
};

// ---------------------------------------------------------------------------
export var forEachItem = (iter, func, hContext = {}) => {
  var err, index, item, lItems, result;
  // --- func() gets (item, hContext)
  //        hContext includes key _index
  //     return value from func() is added to
  //        returned array if defined
  //     if func() throws
  //        thrown strings are interpreted as
  //           "stop" - stop the iteration
  //           any other string - an error
  //           non-string - is rethrown
  assert(isIterable(iter), "not an iterable");
  lItems = [];
  index = 0;
  for (item of iter) {
    hContext._index = index;
    index += 1;
    try {
      result = func(item, hContext);
      if (defined(result)) {
        lItems.push(result);
      }
    } catch (error1) {
      err = error1;
      if (isString(err)) {
        if (err === 'stop') {
          return lItems;
        } else {
          throw new Error(`forEachItem: Bad throw '${err}'`);
        }
      } else {
        throw err; // rethrow the error
      }
    }
  }
  return lItems;
};

// ---------------------------------------------------------------------------
export var addToHash = (obj, lIndexes, value) => {
  var index, j, key, len1, subobj;
  // --- Allow passing a simple string or integer
  if (isString(lIndexes) || isInteger(lIndexes)) {
    lIndexes = [lIndexes];
  } else {
    assert(isArray(lIndexes), `Bad indexes: ${OL(lIndexes)}`);
  }
  assert(nonEmpty(lIndexes), "empty lIndexes");
  key = lIndexes.pop();
  subobj = obj;
  for (j = 0, len1 = lIndexes.length; j < len1; j++) {
    index = lIndexes[j];
    if (defined(obj[index])) {
      subobj = subobj[index];
    } else if (isNumber(index) || isString(index)) {
      subobj[index] = {};
      subobj = subobj[index];
    } else {
      croak(`Bad index: ${OL(index)}`);
    }
  }
  subobj[key] = value;
  return obj;
};

// ---------------------------------------------------------------------------
export var flattenToHash = (x) => {
  var hResult, item, j, k, key, len1, len2, ref, subitem, value;
  if (isHash(x)) {
    return x;
  } else if (isArray(x)) {
    hResult = {};
    for (j = 0, len1 = x.length; j < len1; j++) {
      item = x[j];
      if (isHash(item)) {
        for (key in item) {
          if (!hasProp.call(item, key)) continue;
          value = item[key];
          hResult[key] = value;
        }
      } else if (isArray(item)) {
        for (k = 0, len2 = item.length; k < len2; k++) {
          subitem = item[k];
          ref = flattenToHash(subitem);
          for (key in ref) {
            if (!hasProp.call(ref, key)) continue;
            value = ref[key];
            hResult[key] = value;
          }
        }
      } else {
        croak(`not a hash or array: ${OL(item)}`);
      }
    }
  }
  return hResult;
};
