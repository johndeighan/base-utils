  // nice.coffee
import {
  undef,
  defined,
  notdefined,
  escapeStr,
  getOptions,
  jsType,
  toBlock
} from '@jdeighan/base-utils';

import {
  indented
} from '@jdeighan/base-utils/indent';

import {
  dbgEnter,
  dbgReturn,
  dbg
} from '@jdeighan/base-utils/debug';

import {
  parse
} from '@jdeighan/base-utils/object';

import {
  peggyParse
} from '@jdeighan/base-utils/peggy';

// ---------------------------------------------------------------------------
// --- There are 3 types of quotes:
//        " - double quotes
//        ' - single quotes (i.e. apostrophe)
//        « (ALT+0171) » (ALT+0187)
export var formatString = (str) => {
  var hEsc;
  hEsc = {
    " ": '˳',
    "\t": '→',
    "\r": '◄',
    "\n": '▼'
  };
  if (str.includes("'")) {
    if (str.includes('"')) {
      hEsc["«"] = "\\«";
      hEsc["»"] = "\\»";
      return "«" + escapeStr(str, hEsc) + "»";
    } else {
      return '"' + escapeStr(str, hEsc) + '"';
    }
  } else {
    return "'" + escapeStr(str, hEsc) + "'";
  }
};

// ---------------------------------------------------------------------------
export var shouldSplit = (type) => {
  return ['hash', 'array', 'class', 'object'].includes(type);
};

// ---------------------------------------------------------------------------
export var toNICE = (obj, hOptions = {}) => {
  var block, i, item, key, lLines, len, result, subtype, type, untabify, val;
  dbgEnter('toNICE', obj, hOptions);
  ({untabify} = getOptions(hOptions, {
    untabify: false
  }));
  [type, subtype] = jsType(obj);
  switch (type) {
    case undef:
      if (subtype === 'null') {
        result = 'null';
      } else {
        result = 'undef';
      }
      break;
    case 'number':
    case 'bigint':
      if (subtype === 'NaN') {
        result = 'NaN';
      } else {
        result = obj.toString();
      }
      break;
    case 'string':
      result = formatString(obj);
      break;
    case 'boolean':
      if (obj) {
        result = 'true';
      } else {
        result = 'false';
      }
      break;
    case 'function':
      if (defined(subtype)) {
        result = `[Function ${subtype}]`;
      } else {
        result = "[Function]";
      }
      break;
    case 'array':
      lLines = [];
      for (i = 0, len = obj.length; i < len; i++) {
        item = obj[i];
        block = toNICE(item);
        if (shouldSplit(jsType(item)[0])) {
          lLines.push('-');
          lLines.push(indented(block));
        } else {
          lLines.push(`- ${block}`);
        }
      }
      result = toBlock(lLines);
      break;
    case 'hash':
      lLines = [];
      for (key in obj) {
        val = obj[key];
        block = toNICE(val);
        if (shouldSplit(jsType(val)[0])) {
          lLines.push(`${key}:`);
          lLines.push(indented(block));
        } else {
          lLines.push(`${key}: ${block}`);
        }
      }
      result = toBlock(lLines);
      break;
    case 'object':
      result = "[Object]";
  }
  dbgReturn('toNICE', result);
  return result;
};

// ---------------------------------------------------------------------------
export var fromNICE = (block) => {
  var result;
  dbgEnter('fromNICE', block);
  result = peggyParse(parse, block);
  dbgReturn('fromNICE', result);
  return result;
};

//# sourceMappingURL=nice.js.map
