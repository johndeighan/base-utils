  // to-nice.coffee
import {
  undef,
  defined,
  notdefined,
  escapeStr,
  getOptions,
  jsType,
  toArray,
  toBlock,
  untabify,
  isInteger,
  OL,
  isArray,
  isBoolean,
  isFunction,
  delimitBlock
} from '@jdeighan/base-utils';

// ---------------------------------------------------------------------------
export var needsQuotes = (str) => {
  // --- if it looks like an array item, it needs quotes
  if (str.match(/^\s*-/)) {
    return true;
  }
  // --- if it looks like a hash key, it needs quotes
  if (str.match(/^\s*\S+\s*:/)) {
    return true;
  }
  // --- if it looks like a number, it needs quotes
  if (str.match(/^\s*\d+(?:\.\d*)?/)) {
    return true;
  }
  return false;
};

// ---------------------------------------------------------------------------
// --- There is only one type of quote:
//        « (ALT+0171) » (ALT+0187)
export var formatString = (str) => {
  var fstr;
  fstr = escapeStr(str, {
    ' ': '˳',
    "\t": '→  ',
    "\r": '◄',
    "\n": '▼',
    '«': "\\«",
    '»': "\\»"
  });
  if (needsQuotes(str)) {
    return "«" + fstr + "»";
  } else {
    return fstr;
  }
};

// ---------------------------------------------------------------------------
export var shouldSplit = (type) => {
  return ['hash', 'array', 'class', 'object'].includes(type);
};

// ---------------------------------------------------------------------------
export var baseCompare = (a, b) => {
  if (a < b) {
    return -1;
  } else if (a > b) {
    return 1;
  } else {
    return 0;
  }
};

// ---------------------------------------------------------------------------
export var indentBlock = (block, level, oneIndent) => {
  var lLines, lNewLines, line;
  lLines = toArray(block);
  lNewLines = (function() {
    var j, len, results;
    results = [];
    for (j = 0, len = lLines.length; j < len; j++) {
      line = lLines[j];
      results.push(oneIndent.repeat(level) + line);
    }
    return results;
  })();
  return toBlock(lNewLines);
};

// ---------------------------------------------------------------------------
export var toNICE = (obj, hOptions = {}) => {
  var block, delimit, h, i, indent, item, j, k, key, l, lKeys, lLines, label, len, len1, len2, oneIndent, result, sortKeys, subtype, type, val, width;
  ({sortKeys, indent, oneIndent, label, delimit, width} = getOptions(hOptions, {
    sortKeys: false, // --- can be boolean/array/function
    indent: 0, // --- integer number of levels
    oneIndent: "\t",
    label: undef,
    delimit: false,
    width: 40
  }));
  if (isArray(sortKeys)) {
    // --- Convert to a function
    h = {};
    for (i = j = 0, len = sortKeys.length; j < len; i = ++j) {
      key = sortKeys[i];
      h[key] = i + 1;
    }
    sortKeys = function(aKey, bKey) {
      var aVal, bVal;
      aVal = h[aKey];
      bVal = h[bKey];
      if (defined(aVal)) {
        if (defined(bVal)) {
          // --- compare numerically
          return baseCompare(aVal, bVal);
        } else {
          return -1;
        }
      } else {
        if (defined(bVal)) {
          return 1;
        } else {
          // --- compare keys alphabetically
          return baseCompare(aKey, bKey);
        }
      }
    };
  } else {
    type = typeof sortKeys;
    if ((type !== 'boolean') && (type !== 'function')) {
      throw new Error("sortKeys not boolean or function");
    }
  }
  [type, subtype] = jsType(obj);
  switch (type) {
    case 'function':
      if (defined(subtype)) {
        result = `[Function ${subtype}]`;
      } else {
        result = "[Function]";
      }
      break;
    case 'class':
      if (defined(subtype)) {
        result = `[Class ${subtype}]`;
      } else {
        result = "[Class]";
      }
      break;
    case undef:
      if (subtype === 'null') {
        result = '.null.';
      } else {
        result = '.undef.';
      }
      break;
    case 'number':
    case 'bigint':
      if (subtype === 'NaN') {
        result = '.NaN.';
      } else {
        result = obj.toString();
      }
      break;
    case 'string':
      result = formatString(obj);
      break;
    case 'boolean':
      if (obj) {
        result = '.true.';
      } else {
        result = '.false.';
      }
      break;
    case 'array':
      lLines = [];
      for (k = 0, len1 = obj.length; k < len1; k++) {
        item = obj[k];
        block = toNICE(item);
        if (shouldSplit(jsType(item)[0])) {
          lLines.push('-');
          lLines.push(indentBlock(block, 1, oneIndent));
        } else {
          lLines.push(`- ${block}`);
        }
      }
      result = toBlock(lLines);
      break;
    case 'hash':
    case 'object':
      lLines = [];
      lKeys = Object.keys(obj);
      if (sortKeys === true) {
        lKeys.sort();
      } else if (isFunction(sortKeys)) {
        lKeys.sort(sortKeys);
      }
      for (l = 0, len2 = lKeys.length; l < len2; l++) {
        key = lKeys[l];
        val = obj[key];
        block = toNICE(val);
        if (shouldSplit(jsType(val)[0])) {
          lLines.push(`${key}:`);
          lLines.push(indentBlock(block, 1, oneIndent));
        } else {
          lLines.push(`${key}: ${block}`);
        }
      }
      result = toBlock(lLines);
  }
  if (delimit) {
    result = delimitBlock(result, {label, width});
  } else if (label) {
    result = `${label}\n${result}`;
  }
  if (indent !== 0) {
    if (!Number.isInteger(indent)) {
      throw new Error(`Bad indent: ${indent}`);
    }
    result = indentBlock(result, indent, oneIndent);
  }
  return result;
};
