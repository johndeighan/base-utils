// taml.coffee
var myReplacer;

import YAML from 'yaml';

import {
  undef,
  defined,
  notdefined,
  OL,
  hasChar,
  getOptions,
  isEmpty,
  nonEmpty,
  isString,
  isFunction,
  isBoolean,
  isArray,
  isInteger,
  blockToArray,
  arrayToBlock,
  escapeStr,
  rtrim,
  spaces
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  indented
} from '@jdeighan/base-utils/indent';

// ---------------------------------------------------------------------------
//   isTAML - is the string valid TAML?
export var isTAML = (text) => {
  return isString(text) && text.match(/^---$/m);
};

// ---------------------------------------------------------------------------
//   fromTAML - convert valid TAML string to a JavaScript value
export var fromTAML = (text) => {
  var _, block, err, i, j, lLines, len, line, ref, result, str, ws;
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
    [_, ws, str] = line.match(/^(\s*)(.*)$/);
    assert(!hasChar(ws, ' '), `space char in prefix: ${OL(line)}`);
    str = str.trim();
    // --- Convert each TAB char to 2 spaces
    lLines.push('  '.repeat(ws.length) + tamlFix(str));
  }
  block = arrayToBlock(lLines);
  try {
    result = YAML.parse(block, {
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
  if ((str === '-') || str.match(/^[A-Za-z0-9_]+:$/)) {
    return str;
  }
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
    // --- We need this, otherwise js-yaml
    //     will convert undef to null
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
export var toTAML = (obj, hOptions = {}) => {
  var h, i, indent, j, key, len, oneIndent, pre, sortKeys, str, useDashes;
  ({useDashes, sortKeys, indent, oneIndent} = getOptions(hOptions, {
    useDashes: true,
    sortKeys: true, // --- can be boolean/array/function
    indent: 0, // --- integer number of levels
    oneIndent: "\t"
  }));
  assert(isInteger(indent), `indent = ${OL(indent)}`);
  assert(isString(oneIndent), `oneIndent = ${OL(oneIndent)}`);
  pre = useDashes ? "---\n" : "";
  switch (obj) {
    case undef:
      return `${pre}undef`;
    case null:
      return `${pre}null`;
    case true:
      return `${pre}true`;
    case false:
      return `${pre}false`;
  }
  if (isArray(sortKeys)) {
    h = {};
    for (i = j = 0, len = sortKeys.length; j < len; i = ++j) {
      key = sortKeys[i];
      h[key] = i + 1;
    }
    sortKeys = function(aVal, bVal) {
      var a, b;
      a = Object.entries(aVal)[0][1];
      b = Object.entries(bVal)[0][1];
      if (defined(h[a])) {
        if (defined(h[b])) {
          return baseCompare(h[a], h[b]);
        } else {
          return -1;
        }
      } else {
        if (defined(h[b])) {
          return 1;
        } else {
          // --- compare keys alphabetically
          return baseCompare(a, b);
        }
      }
    };
  } else {
    assert(isBoolean(sortKeys) || isFunction(sortKeys), `sortKeys = ${OL(sortKeys)}`);
  }
  str = YAML.stringify(obj, myReplacer, {
    sortMapEntries: sortKeys
  });
  str = str.replace(/<UNDEFINED_VALUE>/g, 'undef');
  str = rtrim(str);
  str = str.replaceAll("  ", oneIndent);
  str = pre + str;
  if (indent === 0) {
    return str;
  } else {
    return indented(str, indent, oneIndent);
  }
};

//# sourceMappingURL=taml.js.map
