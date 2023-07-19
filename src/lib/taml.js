// taml.coffee
var compareFunc, myReplacer, squote;

import {
  parse,
  stringify
} from 'yaml';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  undef,
  defined,
  notdefined,
  OL,
  hasChar,
  getOptions,
  isEmpty,
  isString,
  isFunction,
  isBoolean,
  isArray,
  blockToArray,
  arrayToBlock,
  escapeStr,
  rtrim
} from '@jdeighan/base-utils';

// ---------------------------------------------------------------------------
//   isTAML - is the string valid TAML?
export var isTAML = (text) => {
  return isString(text) && text.match(/^---$/m);
};

// ---------------------------------------------------------------------------
//   taml - convert valid TAML string to a JavaScript value
export var fromTAML = (text) => {
  var _, i, j, lLines, len, line, prefix, ref, str;
  assert(defined(text), "text is undef");
  assert(isTAML(text), `string ${OL(text)} isn't TAML`);
  // --- TAML uses TAB characters for indentation
  lLines = ['---'];
  ref = blockToArray(text);
  for (i = j = 0, len = ref.length; j < len; i = ++j) {
    line = ref[i];
    if (i === 0) {
      continue;
    }
    [_, prefix, str] = line.match(/^(\s*)(.*)$/);
    str = str.trim();
    assert(!hasChar(prefix, ' '), `space char in prefix: ${OL(line)}`);
    lLines.push(' '.repeat(prefix.length) + tamlFix(str));
  }
  return parse(arrayToBlock(lLines), {
    skipInvalid: true
  });
};

// ---------------------------------------------------------------------------
export var tamlFix = (str) => {
  var _, key, lMatches, valStr;
  if (lMatches = str.match(/^([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.*)$/)) { // the key
    [_, key, valStr] = lMatches;
    if (isEmpty(valStr)) {
      return `${key}:`;
    } else {
      return `${key}: ${fixValStr(valStr)}`;
    }
  } else {
    return str;
  }
};

// ---------------------------------------------------------------------------
export var fixValStr = (valStr) => {
  if (isEmpty(valStr) || valStr.match(/^\d+(?:\.\d*)?$/) || valStr.match(/^\".*\"$/) || valStr.match(/^\'.*\'$/) || (valStr === 'true') || (valStr === 'false')) { // a number // " quoted string // ' quoted string
    return valStr;
  } else {
    return "'" + valStr.replace(/'/g, "''") + "'";
  }
};

// ---------------------------------------------------------------------------
// --- a replacer is (key, value) -> newvalue
myReplacer = (name, value) => {
  var result;
  if (value === undef) {
    // --- We need this, otherwise js-yaml will convert undef to null
    result = "<UNDEFINED_VALUE>";
  } else if (isString(value)) {
    result = escapeStr(value);
  } else if (isFunction(value)) {
    result = `[Function: ${value.name}]`;
  } else {
    result = value;
  }
  return result;
};

// ---------------------------------------------------------------------------
export var toTAML = (obj, hOptions = {}) => {
  var escape, h, hStrOptions, i, j, key, len, replacer, sortKeys, str, useTabs;
  ({useTabs, sortKeys, escape, replacer} = getOptions(hOptions, {
    useTabs: true,
    sortKeys: true
  }));
  if (obj === undef) {
    return "---\nundef";
  }
  if (obj === null) {
    return "---\nnull";
  }
  if (notdefined(replacer)) {
    replacer = myReplacer;
  }
  if (isArray(sortKeys)) {
    h = {};
    for (i = j = 0, len = sortKeys.length; j < len; i = ++j) {
      key = sortKeys[i];
      h[key] = i + 1;
    }
    sortKeys = function(a, b) {
      if (defined(h[a])) {
        if (defined(h[b])) {
          return compareFunc(h[a], h[b]);
        } else {
          return -1;
        }
      } else {
        if (defined(h[b])) {
          return 1;
        } else {
          // --- compare keys alphabetically
          return compareFunc(a, b);
        }
      }
    };
  }
  assert(isBoolean(sortKeys) || isFunction(sortKeys), "option sortKeys must be boolean, array or function");
  hStrOptions = {
    sortMapEntries: true,
    indent: 3
  };
  str = stringify(obj, myReplacer, hStrOptions);
  str = str.replace(/<UNDEFINED_VALUE>/g, 'undef');
  if (useTabs) {
    str = str.replace(/   /g, "\t");
  }
  return "---\n" + rtrim(str);
};

// ---------------------------------------------------------------------------
compareFunc = (a, b) => {
  if (a < b) {
    return -1;
  } else if (a > b) {
    return 1;
  } else {
    return 0;
  }
};

// ---------------------------------------------------------------------------
squote = (text) => {
  return "'" + text.replace(/'/g, "''") + "'";
};
