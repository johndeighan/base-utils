// Generated by CoffeeScript 2.7.0
// taml.coffee
var myReplacer, squote;

import yaml from 'js-yaml';

import {
  strict as assert
} from 'node:assert';

import {
  undef,
  defined,
  notdefined,
  isEmpty,
  isString,
  isObject,
  blockToArray,
  arrayToBlock,
  hasChar,
  escapeStr,
  chomp,
  OL
} from '@jdeighan/exceptions/utils';

// ---------------------------------------------------------------------------
//   isTAML - is the string valid TAML?
export var isTAML = function(text) {
  return isString(text) && text.match(/^---$/m);
};

// ---------------------------------------------------------------------------
//   taml - convert valid TAML string to a JavaScript value
export var fromTAML = function(text) {
  var _, key, lLines, lMatches, level, line, newPrefix, prefix, str;
  assert(defined(text), "text is undef");
  assert(isTAML(text), `string ${OL(text)} isn't TAML`);
  lLines = (function() {
    var i, len, ref, results;
    ref = blockToArray(text);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      line = ref[i];
      [_, prefix, str] = line.match(/^(\s*)(.*)$/);
      assert(!hasChar(prefix, ' '), `space char in prefix: ${OL(line)}`);
      level = prefix.length;
      newPrefix = ' '.repeat(level);
      if (lMatches = line.match(/^([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.*)$/)) { // the key
        [_, key, text] = lMatches;
        if (isEmpty(text) || text.match(/\d+(?:\.\d*)$/)) {
          results.push(newPrefix + str);
        } else {
          results.push(newPrefix + key + ':' + ' ' + squote(text));
        }
      } else {
        results.push(newPrefix + str);
      }
    }
    return results;
  })();
  return yaml.load(arrayToBlock(lLines), {
    skipInvalid: true
  });
};

// ---------------------------------------------------------------------------
// --- a replacer is (key, value) -> newvalue
myReplacer = function(name, value) {
  if (value === undef) {
    // --- We need this, otherwise js-yaml will convert undef to null
    return "<UNDEFINED_VALUE>";
  }
  if (isString(value)) {
    return escapeStr(value);
  } else {
    //	else if isObject(value, ['tamlReplacer'])
    //		return value.tamlReplacer()
    return value;
  }
};

// ---------------------------------------------------------------------------
export var toTAML = function(obj, hOptions = {}) {
  var escape, replacer, sortKeys, str, useTabs;
  if (obj === undef) {
    return "---\nundef";
  }
  if (obj === null) {
    return "---\nnull";
  }
  ({useTabs, sortKeys, escape, replacer} = hOptions);
  if (notdefined(replacer)) {
    replacer = myReplacer;
  }
  str = yaml.dump(obj, {
    skipInvalid: true,
    indent: 3,
    sortKeys: !!sortKeys,
    lineWidth: -1,
    replacer
  });
  str = str.replace(/<UNDEFINED_VALUE>/g, 'undef');
  if (useTabs) {
    str = str.replace(/   /g, "\t");
  }
  return "---\n" + chomp(str);
};

// ---------------------------------------------------------------------------
squote = function(text) {
  return "'" + text.replace(/'/g, "''") + "'";
};
