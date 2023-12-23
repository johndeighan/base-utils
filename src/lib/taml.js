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
//   fromTAML - convert valid TAML string to a JavaScript value
export var fromTAML = (text) => {
  var _, block, err, i, j, lLines, len, line, prefix, ref, result, str;
  assert(defined(text), "text is undef");
  assert(isTAML(text), `string ${OL(text)} isn't TAML`);
  // --- TAML uses TAB characters for indentation
  //     convert to 2 spaces per TAB
  lLines = ['---'];
  ref = blockToArray(text);
  for (i = j = 0, len = ref.length; j < len; i = ++j) {
    line = ref[i];
    if (i === 0) {
      assert(line === '---', "Invalid TAML marker");
      continue;
    }
    [_, prefix, str] = line.match(/^(\s*)(.*)$/);
    assert(!hasChar(prefix, ' '), `space char in prefix: ${OL(line)}`);
    str = str.trim();
    // --- Convert each TAB char to 2 spaces
    lLines.push('  '.repeat(prefix.length) + tamlFix(str));
  }
  block = arrayToBlock(lLines);
  try {
    result = parse(block, {
      skipInvalid: true
    });
  } catch (error) {
    err = error;
    console.log('---------------------------------------');
    console.log("ERROR in TAML:");
    console.log(text);
    console.log("BLOCK:");
    console.log(block);
    console.log('---------------------------------------');
  }
  return result;
};

// ---------------------------------------------------------------------------
export var llSplit = (str) => {
  var _, key, lMatches, rest, result;
  // --- Returns ["<key>: ", <rest>]
  //        OR   ["- ", <rest>]
  //        OR   undef
  if (lMatches = str.match(/^([A-Za-z_][A-Za-z0-9_]*)\s*:\s+(.*)$/)) { // the key
    [_, key, rest] = lMatches;
    result = [`${key}: `, rest];
  } else if (lMatches = str.match(/^\-\s+(.*)$/)) {
    [_, rest] = lMatches;
    result = ['- ', rest];
  } else {
    result = undef;
  }
  return result;
};

// ---------------------------------------------------------------------------
export var splitTaml = (str) => {
  var lParts, lResult;
  // --- returns [ ("<key>: " || "- "), ..., <val> ] - <val> may be ''
  lParts = [];
  while (lResult = llSplit(str)) {
    lParts.push(lResult[0]);
    str = lResult[1];
  }
  lParts.push(fixValStr(str));
  return lParts;
};

// ---------------------------------------------------------------------------
export var tamlFix = (str) => {
  var lParts, result;
  // --- str has been trimmed
  lParts = splitTaml(str);
  result = lParts.join('');
  return result;
};

// ---------------------------------------------------------------------------
export var fixValStr = (valStr) => {
  var result;
  if (isEmpty(valStr) || (valStr === '[]') || (valStr === '{}') || valStr.match(/^\d+(?:\.\d*)?$/) || valStr.match(/^\".*\"$/) || valStr.match(/^\'.*\'$/) || (valStr === 'true') || (valStr === 'false')) { // a number // " quoted string // ' quoted string
    result = valStr;
  } else {
    result = "'" + valStr.replace(/'/g, "''") + "'";
  }
  return result;
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
    sortMapEntries: true
  };
  str = stringify(obj, myReplacer, hStrOptions);
  str = str.replace(/<UNDEFINED_VALUE>/g, 'undef');
  if (useTabs) {
    str = str.replace(/  /g, "\t");
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

//# sourceMappingURL=taml.js.map
