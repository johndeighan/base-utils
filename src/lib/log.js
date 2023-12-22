// log.coffee
var handleSimpleCase, internalDebugging, logs, putstr, threeSpaces;

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
} from '@jdeighan/base-utils/ll-v8-stack';

import {
  NamedLogs
} from '@jdeighan/base-utils/named-logs';

export var logWidth = 42;

export var sep_dash = '-'.repeat(logWidth);

export var sep_eq = '='.repeat(logWidth);

export var stringify = undef;

internalDebugging = false;

threeSpaces = '   ';

// --- This logger only ever gets passed a single string argument
//     ONLY called directly in PUTSTR, set in setLogger()
putstr = undef;

logs = new NamedLogs({
  doEcho: true
});

// ---------------------------------------------------------------------------
export var echoLogsByDefault = (flag = true) => {
  logs.hDefaultKeys.doEcho = flag;
};

// ---------------------------------------------------------------------------
export var debugLogging = (flag = true) => {
  internalDebugging = flag;
  if (internalDebugging) {
    console.log(`internalDebugging = ${flag}`);
  }
};

// ---------------------------------------------------------------------------
export var echoMyLogs = (flag = true) => {
  var filePath;
  // --- NOTE: hFrame can be undef - NamedLogs handles that OK
  filePath = getMyOutsideCaller().filePath;
  logs.setKey(filePath, 'doEcho', flag);
};

// ---------------------------------------------------------------------------
export var clearMyLogs = () => {
  var filePath;
  filePath = getMyOutsideCaller().filePath;
  logs.clear(filePath);
};

// ---------------------------------------------------------------------------
export var clearAllLogs = () => {
  logs.clearAllLogs();
};

// ---------------------------------------------------------------------------
export var getMyLogs = () => {
  var filePath;
  filePath = getMyOutsideCaller().filePath;
  return logs.getLogs(filePath);
};

// ---------------------------------------------------------------------------
export var getAllLogs = () => {
  return logs.getAllLogs();
};

// ---------------------------------------------------------------------------
export var PUTSTR = (str) => {
  var doEcho, filePath;
  if (internalDebugging) {
    console.log(`CALL PUTSTR(${OL(str)})`);
    if (defined(putstr) && (putstr !== console.log)) {
      console.log("   - use custom logger");
    }
  }
  str = rtrim(str);
  filePath = getMyOutsideCaller().filePath;
  doEcho = logs.getKey(filePath, 'doEcho');
  if (internalDebugging) {
    console.log(`   filePath = ${OL(filePath)}, doEcho = ${OL(doEcho)}`);
  }
  logs.log(filePath, str);
  if (doEcho) {
    if (defined(putstr) && (putstr !== console.log)) {
      putstr(str);
    } else {
      // --- console doesn't handle TABs correctly, so...
      console.log(untabify(str));
    }
  }
};

// ---------------------------------------------------------------------------
export var LOG = (str = "", prefix = "") => {
  if (internalDebugging) {
    console.log(`CALL LOG(${OL(str)}), prefix=${OL(prefix)}`);
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
export var prefixed = (prefix, ...lStrings) => {
  var i, lLines, len, result, str;
  lLines = [];
  for (i = 0, len = lStrings.length; i < len; i++) {
    str = lStrings[i];
    lLines = lLines.concat(blockToArray(str));
  }
  result = arrayToBlock(lLines.map((x) => {
    return `${prefix}${x}`;
  }));
  return result;
};

// ---------------------------------------------------------------------------
export var LOGTAML = (label, value, prefix = "", itemPrefix = undef) => {
  var desc, str1, str2, str3;
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
  desc = toTAML(value, {
    sortKeys: true
  });
  PUTSTR(prefixed(prefix, `${prefix}${label} = <<<`, prefixed('   ', desc)));
  return true;
};

// ---------------------------------------------------------------------------
export var LOGJSON = (label, value, prefix = "") => {
  var desc, str1, str2, str3;
  if (internalDebugging) {
    str1 = OL(label);
    str2 = OL(value);
    str3 = OL(prefix);
    console.log(`CALL LOGJSON(${str1}, ${str2}), prefix=${str3}`);
  }
  assert(nonEmpty(label), "label is empty");
  desc = JSON.stringify(value, null, 3);
  PUTSTR(prefixed(prefix, `${prefix}${label} =`, desc));
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

//# sourceMappingURL=log.js.map
