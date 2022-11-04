// Generated by CoffeeScript 2.7.0
// log.coffee
var doDebugLogging, handleSimpleCase, lUTLog, loaded, putstr, threeSpaces;

import {
  strict as assert
} from 'node:assert';

import {
  pass,
  undef,
  defined,
  notdefined,
  deepCopy,
  hEsc,
  escapeStr,
  OL,
  hasMethod,
  untabify,
  blockToArray,
  arrayToBlock,
  prefixBlock,
  isNumber,
  isInteger,
  isString,
  isHash,
  isFunction,
  isBoolean,
  nonEmpty,
  hEscNoNL,
  jsType,
  hasChar,
  quoted
} from '@jdeighan/base-utils/utils';

import {
  toTAML
} from '@jdeighan/base-utils/taml';

import {
  getPrefix
} from '@jdeighan/base-utils/prefix';

export var logWidth = 42;

export var sep_dash = '-'.repeat(logWidth);

export var sep_eq = '='.repeat(logWidth);

export var stringify = undef;

doDebugLogging = false;

threeSpaces = '   ';

// --- This logger only ever gets passed a single string argument
//     ONLY called directly in PUTSTR
putstr = undef;

// ---------------------------------------------------------------------------
export var PUTSTR = function(str) {
  if ((putstr === console.log) || notdefined(putstr)) {
    console.log(untabify(str));
  } else {
    putstr(str);
  }
};

// ---------------------------------------------------------------------------
export var setLogWidth = (w) => {
  logWidth = w;
  sep_dash = '-'.repeat(logWidth);
  sep_eq = '='.repeat(logWidth);
};

// ---------------------------------------------------------------------------
export var resetLogWidth = () => {
  setLogWidth(42);
};

// ---------------------------------------------------------------------------
export var debugLogging = (flag = true) => {
  doDebugLogging = flag;
  if (doDebugLogging) {
    console.log(`doDebugLogging = ${flag}`);
  }
};

// ---------------------------------------------------------------------------
export var setStringifier = (func) => {
  var orgStringifier;
  orgStringifier = stringify;
  assert(isFunction(func), "setStringifier() arg is not a function");
  stringify = func;
  return orgStringifier;
};

// ---------------------------------------------------------------------------
export var resetStringifier = () => {
  return setStringifier(orderedStringify);
};

// ---------------------------------------------------------------------------
export var setLogger = (func) => {
  var orgLogger;
  assert(isFunction(func), "setLogger() arg is not a function");
  orgLogger = putstr;
  putstr = func;
  return orgLogger;
};

// ---------------------------------------------------------------------------
export var resetLogger = () => {
  return setLogger(console.log);
};

// ---------------------------------------------------------------------------
export var tamlStringify = (obj, escape = false) => {
  return toTAML(obj, {
    useTabs: false,
    sortKeys: false,
    escape
  });
};

// ---------------------------------------------------------------------------
export var orderedStringify = (obj, escape = false) => {
  return toTAML(obj, {
    useTabs: false,
    sortKeys: true,
    escape
  });
};

// ---------------------------------------------------------------------------
export var LOG = (str = "", prefix = "") => {
  if (doDebugLogging) {
    console.log(`CALL LOG(${OL(str)}), prefix=${OL(prefix)}`);
    if (defined(putstr) && (putstr !== console.log)) {
      console.log("   - use custom logger");
    }
  }
  PUTSTR(`${prefix}${str}`);
  return true; // to allow use in boolean expressions
};


// ---------------------------------------------------------------------------
export var LOGTAML = (label, value, prefix = "", itemPrefix = undef) => {
  var i, len, ref, str, str1, str2, str3;
  if (doDebugLogging) {
    str1 = OL(label);
    str2 = OL(value);
    str3 = OL(prefix);
    console.log(`CALL LOGTAML(${str1}, ${str2}), prefix=${str3}`);
  }
  assert(nonEmpty(label), "label is empty");
  if (notdefined(itemPrefix)) {
    itemPrefix = prefix + "\t";
  }
  if (handleSimpleCase(label, value, prefix)) {
    return true;
  }
  PUTSTR(`${prefix}${label} =`);
  ref = blockToArray(toTAML(value, {
    sortKeys: true
  }));
  for (i = 0, len = ref.length; i < len; i++) {
    str = ref[i];
    PUTSTR(`${itemPrefix}${str}`);
  }
  return true;
};

// ---------------------------------------------------------------------------
export var LOGVALUE = (label, value, prefix = "", itemPrefix = undef) => {
  var escaped, i, j, len, len1, line, ref, ref1, str, str1, str2, str3, subtype, type;
  if (doDebugLogging) {
    str1 = OL(label);
    str2 = OL(value);
    str3 = OL(prefix);
    console.log(`CALL LOGVALUE(${str1}, ${str2}), prefix=${str3}`);
  }
  assert(nonEmpty(label), "label is empty");
  if (handleSimpleCase(label, value, prefix)) {
    return true;
  }
  // --- Try OL() - if it's short enough, use that
  str = `${prefix}${label} = ${OL(value)}`;
  if (doDebugLogging) {
    console.log(`Using OL(), strlen = ${str.length}, logWidth = ${logWidth}`);
  }
  if (str.length <= logWidth) {
    PUTSTR(str);
    return true;
  }
  if (notdefined(itemPrefix)) {
    itemPrefix = prefix + "\t";
  }
  [type, subtype] = jsType(value);
  switch (type) {
    case 'string':
      if (subtype === 'empty') {
        PUTSTR(`${prefix}${label} = ''`);
      } else {
        str = `${prefix}${label} = ${quoted(value, 'escape')}`;
        if (str.length <= logWidth) {
          PUTSTR(str);
        } else {
          // --- escape, but not newlines
          escaped = escapeStr(value, hEscNoNL);
          PUTSTR(`${prefix}${label} = \"\"\"
${prefixBlock(escaped, itemPrefix)}
${prefixBlock('"""', itemPrefix)}`);
        }
      }
      break;
    case 'hash':
    case 'array':
      str = toTAML(value, {
        sortKeys: true
      });
      PUTSTR(`${prefix}${label} =`);
      ref = blockToArray(str);
      for (i = 0, len = ref.length; i < len; i++) {
        str = ref[i];
        PUTSTR(`${itemPrefix}${str}`);
      }
      break;
    case 'regexp':
      PUTSTR(`${prefix}${label} = <regexp>`);
      break;
    case 'function':
      PUTSTR(`${prefix}${label} = <function>`);
      break;
    case 'object':
      if (hasMethod(value, 'toLogString')) {
        str = value.toLogString();
      } else {
        str = toTAML(value);
      }
      if (hasChar(str, "\n")) {
        PUTSTR(`${prefix}${label} =`);
        if (notdefined(itemPrefix)) {
          itemPrefix = prefix;
        }
        ref1 = blockToArray(str);
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          line = ref1[j];
          PUTSTR(`${itemPrefix}${line}`);
        }
      } else {
        PUTSTR(`${prefix}${label} = ${str}`);
      }
  }
  return true;
};

// ---------------------------------------------------------------------------
handleSimpleCase = (label, value, prefix) => {
  // --- Returns true if handled, else false

  // --- Handle some simple cases
  if (value === undef) {
    PUTSTR(`${prefix}${label} = undef`);
    return true;
  } else if (value === null) {
    PUTSTR(`${prefix}${label} = null`);
    return true;
  } else if (isBoolean(value)) {
    if (value) {
      PUTSTR(`${prefix}${label} = true`);
    } else {
      PUTSTR(`${prefix}${label} = false`);
    }
    return true;
  } else if (isNumber(value)) {
    PUTSTR(`${prefix}${label} = ${value}`);
    return true;
  } else {
    return false;
  }
};

// ---------------------------------------------------------------------------
// simple redirect to an array - useful in unit tests
lUTLog = undef;

export var utReset = () => {
  lUTLog = [];
  setLogger((str) => {
    return lUTLog.push(str);
  });
};

export var utGetLog = () => {
  var result;
  result = arrayToBlock(lUTLog);
  lUTLog = undef;
  resetLogger();
  return result;
};

if (!loaded) {
  setStringifier(orderedStringify);
  resetLogger();
}

loaded = true;
