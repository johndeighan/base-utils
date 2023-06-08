// log.coffee
var hEchoLogs, handleSimpleCase, internalDebugging, lNamedLogs, putstr, threeSpaces;

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  pass,
  undef,
  defined,
  notdefined,
  deepCopy,
  getOptions,
  hEsc,
  escapeStr,
  OL,
  untabify,
  isObject,
  rtrim,
  DUMP,
  blockToArray,
  arrayToBlock,
  prefixBlock,
  centeredText,
  isNumber,
  isInteger,
  isString,
  isHash,
  isFunction,
  isBoolean,
  isEmpty,
  nonEmpty,
  hEscNoNL,
  jsType,
  hasChar,
  quoted
} from '@jdeighan/base-utils';

import {
  toTAML
} from '@jdeighan/base-utils/taml';

import {
  getPrefix
} from '@jdeighan/base-utils/prefix';

import {
  getMyOutsideCaller
} from '@jdeighan/base-utils/v8-stack';

export var logWidth = 42;

export var sep_dash = '-'.repeat(logWidth);

export var sep_eq = '='.repeat(logWidth);

export var stringify = undef;

internalDebugging = false;

threeSpaces = '   ';

// --- This logger only ever gets passed a single string argument
//     ONLY called directly in PUTSTR, set in setLogger()
putstr = undef;

lNamedLogs = []; // array of {caller, str}

hEchoLogs = {}; // { <source> => true }


// ---------------------------------------------------------------------------
export var echoMyLogs = (flag = true) => {
  var caller;
  caller = getMyOutsideCaller();
  if (notdefined(caller) || !caller.source) {
    return;
  }
  if (flag) {
    hEchoLogs[caller.source] = true;
  } else {
    delete hEchoLogs[caller.source];
  }
};

// ---------------------------------------------------------------------------
export var clearMyLogs = () => {
  var caller, h, i, lNewLogs, len;
  caller = getMyOutsideCaller();
  if (notdefined(caller) || !caller.source) {
    return;
  }
  lNewLogs = [];
  for (i = 0, len = lNamedLogs.length; i < len; i++) {
    h = lNamedLogs[i];
    if (h.caller !== caller.source) {
      lNewLogs.push(h);
    }
  }
  lNamedLogs = lNewLogs;
};

// ---------------------------------------------------------------------------
export var clearAllLogs = () => {
  lNamedLogs = [];
};

// ---------------------------------------------------------------------------
export var getMyLog = () => {
  var caller, h, i, lLines, len, result;
  caller = getMyOutsideCaller();
  if (notdefined(caller) || !caller.source) {
    return undef;
  }
  lLines = [];
  for (i = 0, len = lNamedLogs.length; i < len; i++) {
    h = lNamedLogs[i];
    if (h.caller === caller.source) {
      lLines.push(h.str);
    }
  }
  result = lLines.join("\n");
  if (isEmpty(result)) {
    return undef;
  } else {
    return result;
  }
};

// ---------------------------------------------------------------------------
export var getAllLogs = () => {
  var h, i, lLines, len;
  lLines = [];
  for (i = 0, len = lNamedLogs.length; i < len; i++) {
    h = lNamedLogs[i];
    lLines.push(h.str);
  }
  return lLines.join("\n");
};

// ---------------------------------------------------------------------------
export var dumpLog = (label, theLog, hOptions = {}) => {
  DUMP(label, theLog, hOptions);
};

// ---------------------------------------------------------------------------
export var PUTSTR = (str) => {
  var caller;
  str = rtrim(str);
  caller = getMyOutsideCaller();
  if (notdefined(caller) || !caller.source) {
    return undef;
  }
  lNamedLogs.push({
    caller: caller.source,
    str
  });
  if (defined(hEchoLogs[caller.source])) {
    if ((putstr === console.log) || notdefined(putstr)) {
      console.log(untabify(str));
    } else {
      putstr(str);
    }
  }
};

// ---------------------------------------------------------------------------
export var LOG = (str = "", prefix = "") => {
  if (internalDebugging) {
    console.log(`CALL LOG(${OL(str)}), prefix=${OL(prefix)}`);
    if (defined(putstr) && (putstr !== console.log)) {
      console.log("   - use custom logger");
    }
  }
  PUTSTR(`${prefix}${str}`);
  return true; // to allow use in boolean expressions
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
  internalDebugging = flag;
  if (internalDebugging) {
    console.log(`internalDebugging = ${flag}`);
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
export var LOGTAML = (label, value, prefix = "", itemPrefix = undef) => {
  var i, len, ref, str, str1, str2, str3;
  if (internalDebugging) {
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
export var stringFits = (str) => {
  return str.length <= logWidth;
};

// ---------------------------------------------------------------------------
export var LOGVALUE = (label, value, prefix = "", itemPrefix = undef) => {
  var escaped, i, j, labelStr, len, len1, line, ref, ref1, str, str1, str2, str3, subtype, type;
  // --- Allow label to be empty, i.e. undef
  if (internalDebugging) {
    str1 = OL(label);
    str2 = OL(value);
    str3 = OL(prefix);
    console.log(`CALL LOGVALUE(${str1}, ${str2}), prefix=${str3}`);
  }
  // --- Handles undef, null, boolean, number
  if (handleSimpleCase(label, value, prefix)) {
    return true;
  }
  if (defined(label)) {
    labelStr = `${label} = `;
  } else {
    labelStr = "";
  }
  // --- Try OL() - if it's short enough, use that
  str = `${prefix}${labelStr}${OL(value)}`;
  if (stringFits(str)) {
    if (internalDebugging) {
      console.log(`Using OL(), ${str.length} <= ${logWidth}`);
    }
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
        // --- empty string
        PUTSTR(`${prefix}${labelStr}''`);
      } else {
        // --- non empty string
        str = `${prefix}${labelStr}${quoted(value, 'escape')}`;
        if (stringFits(str)) {
          PUTSTR(str);
        } else {
          // --- escape, but not newlines
          escaped = escapeStr(value, hEscNoNL);
          PUTSTR(`${prefix}${labelStr}\"\"\"
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
      if (labelStr) {
        PUTSTR(`${prefix}${labelStr}`);
      }
      ref = blockToArray(str);
      for (i = 0, len = ref.length; i < len; i++) {
        str = ref[i];
        PUTSTR(`${itemPrefix}${str}`);
      }
      break;
    case 'regexp':
      PUTSTR(`${prefix}${labelStr}<regexp>`);
      break;
    case 'function':
      PUTSTR(`${prefix}${labelStr}<function>`);
      break;
    case 'object':
      if (isObject(value, '&toLogString')) {
        str = value.toLogString();
      } else {
        str = toTAML(value);
      }
      if (hasChar(str, "\n")) {
        if (labelStr) {
          PUTSTR(`${prefix}${labelStr}`);
        }
        if (notdefined(itemPrefix)) {
          itemPrefix = prefix;
        }
        ref1 = blockToArray(str);
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          line = ref1[j];
          PUTSTR(`${itemPrefix}${line}`);
        }
      } else {
        PUTSTR(`${prefix}${labelStr}${str}`);
      }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var LOGSTRING = (label, value, prefix = "") => {
  var itemPrefix, str, str1, str2, str3;
  if (internalDebugging) {
    str1 = OL(label);
    str2 = OL(value);
    str3 = OL(prefix);
    console.log(`CALL LOGSTRING(${str1}, ${str2}), prefix=${str3}`);
  }
  assert(nonEmpty(label), "label is empty");
  assert(isString(value), "value not a string");
  // --- if it's short enough, put on one line
  str = `${prefix}${label} = ${quoted(value)}`;
  if (stringFits(str)) {
    if (internalDebugging) {
      console.log(`Put on one line, ${str.length} <= ${logWidth}`);
    }
    PUTSTR(str);
    return true;
  }
  itemPrefix = prefix + "\t";
  str = `${prefix}${label} = ${quoted(value, 'escape')}`;
  if (stringFits(str)) {
    PUTSTR(str);
  } else {
    // --- escape, but not newlines
    PUTSTR(`${prefix}${label} = \"\"\"
${prefixBlock(value, itemPrefix)}
${prefixBlock('"""', itemPrefix)}`);
  }
  return true;
};

// ---------------------------------------------------------------------------
handleSimpleCase = (label, value, prefix) => {
  var labelStr;
  // --- Returns true if handled, else false
  if (defined(label)) {
    labelStr = `${label} = `;
  } else {
    labelStr = "";
  }
  // --- Handle some simple cases
  if (value === undef) {
    PUTSTR(`${prefix}${labelStr}undef`);
    return true;
  } else if (value === null) {
    PUTSTR(`${prefix}${labelStr}null`);
    return true;
  } else if (isBoolean(value)) {
    if (value) {
      PUTSTR(`${prefix}${labelStr}true`);
    } else {
      PUTSTR(`${prefix}${labelStr}false`);
    }
    return true;
  } else if (isNumber(value)) {
    PUTSTR(`${prefix}${labelStr}${value}`);
    return true;
  } else {
    return false;
  }
};

// ---------------------------------------------------------------------------
setStringifier(orderedStringify);

resetLogger();