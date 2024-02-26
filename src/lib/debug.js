// debug.coffee
var dbgReturnVal, dbgYieldFrom, internalDebugging, lFuncList, logAll, logEnter, logResume, logReturn, logString, logType, logValue, logYield, stdLogReturnVal;

import {
  pass,
  undef,
  defined,
  notdefined,
  OL,
  OLS,
  isIdentifier,
  isFunctionName,
  isArrayOfStrings,
  isString,
  isFunction,
  isArray,
  isHash,
  isBoolean,
  isInteger,
  isEmpty,
  nonEmpty,
  arrayToBlock,
  getOptions,
  words,
  oneof,
  jsType,
  blockToArray
} from '@jdeighan/base-utils';

import {
  parsePath
} from '@jdeighan/base-utils/ll-fs';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  getPrefix
} from '@jdeighan/base-utils/prefix';

import {
  LOG,
  LOGVALUE,
  stringFits,
  debugLogging,
  clearMyLogs,
  getMyLogs,
  echoMyLogs
} from '@jdeighan/base-utils/log';

import {
  toTAML
} from '@jdeighan/base-utils/taml';

import {
  CallStack
} from '@jdeighan/base-utils/stack';

export {
  debugLogging
};

export var debugStack = new CallStack();

// --- Comes from call to setDebugging()
lFuncList = []; // array of {funcName, plus}

logAll = false; // if true, always log

internalDebugging = false;

// --- Custom loggers, if defined
logEnter = undef;

logReturn = undef;

logYield = undef;

logResume = undef;

logString = undef;

logValue = undef;

export var doDbg = true; // overall flag - if false, no debugging


// ---------------------------------------------------------------------------
export var disableDbg = function() {
  doDbg = false;
};

// ---------------------------------------------------------------------------
export var clearDebugLog = () => {
  return clearMyLogs();
};

// ---------------------------------------------------------------------------
export var getDebugLog = () => {
  return getMyLogs();
};

// ---------------------------------------------------------------------------
export var debugDebug = (debugFlag = true) => {
  internalDebugging = debugFlag;
  if (debugFlag) {
    console.log("turn on internal debugging in debug.coffee");
  } else {
    console.log("turn off internal debugging in debug.coffee");
  }
};

// ---------------------------------------------------------------------------
export var dumpDebugLoggers = (label = undef) => {
  var lLines;
  lLines = [];
  if (nonEmpty(label)) {
    lLines.push(`LOGGERS (${label})`);
  } else {
    lLines.push("LOGGERS");
  }
  lLines.push(`   enter      - ${logType(logEnter, stdLogEnter)}`);
  lLines.push(`   return     - ${logType(logReturn, stdLogReturn)}`);
  lLines.push(`   yield      - ${logType(logYield, stdLogYield)}`);
  lLines.push(`   resume     - ${logType(logResume, stdLogResume)}`);
  lLines.push(`   string     - ${logType(logString, stdLogString)}`);
  lLines.push(`   value      - ${logType(logValue, stdLogValue)}`);
  return console.log(arrayToBlock(lLines));
};

// ---------------------------------------------------------------------------
logType = (cur, std) => {
  if (cur === std) {
    return 'std';
  } else if (defined(cur)) {
    return 'custom';
  } else {
    return 'undef';
  }
};

// ---------------------------------------------------------------------------
export var resetDebugging = () => {
  // --- reset everything
  debugStack.reset();
  lFuncList = [];
  logAll = false;
  logEnter = stdLogEnter;
  logReturn = stdLogReturn;
  logYield = stdLogYield;
  logResume = stdLogResume;
  logString = stdLogString;
  logValue = stdLogValue;
  clearMyLogs();
  echoMyLogs(false);
};

// ---------------------------------------------------------------------------
export var setDebugging = (debugWhat = undef, hOptions = {}) => {
  var customSet, j, key, len, ref, subtype, type;
  // --- debugWhat can be:
  //        1. a boolean (false=disable, true=debug all)
  //        2. a string
  //        3. an array of strings
  // --- Valid options:
  //        'noecho' - don't echo logs to console
  //        'enter', 'returnFrom',
  //           'yield', 'resume',
  //           'string', 'value'
  //         - to set custom loggers
  if (internalDebugging) {
    console.log(`setDebugging ${OL(debugWhat)}, ${OL(hOptions)}`);
  }
  assert(defined(debugWhat), "arg 1 must be defined");
  resetDebugging();
  customSet = false; // were any custom loggers set?
  
  // --- First, process any options
  hOptions = getOptions(hOptions);
  if (hOptions.noecho) {
    echoMyLogs(false);
    if (internalDebugging) {
      console.log("TURN OFF ECHO");
    }
  } else {
    echoMyLogs(true);
    if (internalDebugging) {
      console.log("TURN ON ECHO");
    }
  }
  ref = words('enter returnFrom yield resume string value');
  for (j = 0, len = ref.length; j < len; j++) {
    key = ref[j];
    if (defined(hOptions[key])) {
      setCustomDebugLogger(key, hOptions[key]);
      customSet = true;
    }
  }
  // --- process debugWhat if defined
  [type, subtype] = jsType(debugWhat);
  switch (type) {
    case undef:
      pass();
      break;
    case 'boolean':
      if (internalDebugging) {
        console.log(`set logAll to ${OL(debugWhat)}`);
      }
      logAll = debugWhat;
      break;
    case 'string':
    case 'array':
      if (internalDebugging) {
        console.log(`debugWhat is ${OL(debugWhat)}`);
      }
      lFuncList = getFuncList(debugWhat);
      break;
    default:
      croak(`Bad arg 1: ${OL(debugWhat)}`);
  }
  if (internalDebugging) {
    dumpFuncList();
    if (customSet) {
      dumpDebugLoggers();
    }
  }
};

// ---------------------------------------------------------------------------
export var dumpFuncList = () => {
  console.log('lFuncList: --------------------------------');
  console.log(toTAML(lFuncList));
  console.log('-------------------------------------------');
};

// ---------------------------------------------------------------------------
export var setCustomDebugLogger = (type, func) => {
  assert(isFunction(func), "Not a function");
  if (internalDebugging) {
    console.log(`set custom logger ${OL(type)}`);
  }
  switch (type) {
    case 'enter':
      logEnter = func;
      break;
    case 'returnFrom':
      logReturn = func;
      break;
    case 'yield':
      logYield = func;
      break;
    case 'resume':
      logResume = func;
      break;
    case 'string':
      logString = func;
      break;
    case 'value':
      logValue = func;
      break;
    default:
      throw new Error(`Unknown type: ${OL(type)}`);
  }
};

// ---------------------------------------------------------------------------
export var getFuncList = (funcs) => {
  var fullName, j, k, lFuncs, lItems, len, len1, modifier, ref, str, word;
  // --- funcs can be a string or an array of strings
  lFuncs = []; // return value
  
  // --- Allow passing in an array of strings
  if (isArray(funcs)) {
    assert(isArrayOfStrings(funcs), "not an array of strings");
    for (j = 0, len = funcs.length; j < len; j++) {
      str = funcs[j];
      lItems = getFuncList(str); // recursive call
      lFuncs.push(...lItems);
    }
    return lFuncs;
  }
  assert(isString(funcs), "not a string");
  ref = words(funcs);
  for (k = 0, len1 = ref.length; k < len1; k++) {
    word = ref[k];
    if (word === 'debug') {
      internalDebugging = true;
    }
    [fullName, modifier] = parseFunc(word);
    assert(defined(fullName), `Bad debug object: ${OL(word)}`);
    lFuncs.push({
      fullName,
      plus: modifier === '+'
    });
  }
  return lFuncs;
};

// ---------------------------------------------------------------------------
// Stack is only modified in these 8 functions (it is reset in setDebugging())
// ---------------------------------------------------------------------------
export var dbgEnter = (funcName, ...lValues) => {
  var doLog, level;
  doLog = doDebugFunc(funcName);
  if (internalDebugging) {
    if (lValues.length === 0) {
      console.log(`dbgEnter ${OL(funcName)}`);
    } else {
      console.log(`dbgEnter ${OL(funcName)}, ${OLS(lValues)}`);
    }
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    level = debugStack.logLevel;
    if (!logEnter(level, funcName, lValues)) {
      stdLogEnter(level, funcName, lValues);
    }
  }
  debugStack.enter(funcName, lValues, doLog);
  return true;
};

// ---------------------------------------------------------------------------
export var doDebugFunc = (funcName) => {
  return logAll || funcMatch(funcName);
};

// ---------------------------------------------------------------------------
export var funcMatch = (funcName) => {
  var h, j, k, lParts, len, len1, methodName;
  // --- funcName came from a call to dbgEnter()
  //     it might be of form <object>.<method>
  // --- We KNOW that funcName is active!
  if (internalDebugging) {
    console.log(`CHECK funcMatch(${OL(funcName)})`);
    console.log(lFuncList);
    debugStack.dump(1);
  }
  lParts = isFunctionName(funcName);
  assert(defined(lParts), `not a valid function name: ${OL(funcName)}`);
  for (j = 0, len = lFuncList.length; j < len; j++) {
    h = lFuncList[j];
    if (h.fullName === funcName) {
      if (internalDebugging) {
        console.log(`   - TRUE - ${OL(funcName)} is in lFuncList`);
      }
      return true;
    }
    if (h.plus && debugStack.isActive(h.fullName)) {
      if (internalDebugging) {
        console.log(`   - TRUE - ${OL(h.fullName)} is active`);
      }
      return true;
    }
  }
  if (lParts.length === 2) { // came from dbgEnter()
    methodName = lParts[1];
    for (k = 0, len1 = lFuncList.length; k < len1; k++) {
      h = lFuncList[k];
      if (h.fullName === methodName) {
        if (internalDebugging) {
          console.log(`   - TRUE - ${OL(methodName)} is in lFuncList`);
        }
        return true;
      }
    }
  }
  if (internalDebugging) {
    console.log("   - FALSE");
  }
  return false;
};

// ---------------------------------------------------------------------------
export var dbgReturn = (...lArgs) => {
  var doLog, funcName, level;
  if (lArgs.length > 1) {
    return dbgReturnVal(...lArgs);
  }
  funcName = lArgs[0];
  assert(isFunctionName(funcName), "not a valid function name");
  doLog = logAll || debugStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgReturn ${OL(funcName)}`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    level = debugStack.logLevel;
    if (!logReturn(level, funcName)) {
      stdLogReturn(level, funcName);
    }
  }
  debugStack.returnFrom(funcName);
  return true;
};

// ---------------------------------------------------------------------------
dbgReturnVal = (funcName, val) => {
  var doLog, level;
  assert(isFunctionName(funcName), "not a valid function name");
  doLog = logAll || debugStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgReturn ${OL(funcName)}, ${OL(val)}`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    level = debugStack.logLevel;
    if (!logReturn(level, funcName, val)) {
      stdLogReturn(level, funcName, val);
    }
  }
  debugStack.returnFrom(funcName, val);
  return true;
};

// ---------------------------------------------------------------------------
export var dbgYield = (...lArgs) => {
  var doLog, funcName, level, nArgs, val;
  nArgs = lArgs.length;
  assert((nArgs === 1) || (nArgs === 2), `Bad num args: ${nArgs}`);
  [funcName, val] = lArgs;
  if (nArgs === 1) {
    return dbgYieldFrom(funcName);
  }
  assert(isFunctionName(funcName), `not a function name: ${OL(funcName)}`);
  doLog = logAll || debugStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgYield ${OL(funcName)} ${OL(val)}`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    level = debugStack.logLevel;
    if (!logYield(level, funcName, val)) {
      stdLogYield(level, funcName, val);
    }
  }
  debugStack.yield(funcName, val);
  return true;
};

// ---------------------------------------------------------------------------
dbgYieldFrom = (funcName) => {
  var doLog, level;
  assert(isFunctionName(funcName), `not a function name: ${OL(funcName)}`);
  doLog = logAll || debugStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgYieldFrom ${OL(funcName)}`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    level = debugStack.logLevel;
    if (!logYieldFrom(level, funcName)) {
      stdLogYieldFrom(level, funcName);
    }
  }
  debugStack.yield(funcName);
  return true;
};

// ---------------------------------------------------------------------------
export var dbgResume = (funcName) => {
  var doLog, level;
  assert(isFunctionName(funcName), "not a valid function name");
  debugStack.resume(funcName);
  doLog = logAll || debugStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgResume ${OL(funcName)}`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    level = debugStack.logLevel;
    if (!logResume(funcName, level - 1)) {
      stdLogResume(funcName, level - 1);
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var dbgCall = (func) => {
  var doLog;
  assert(isFunction(func), "not a function");
  doLog = logAll || debugStack.isLogging();
  if (doLog) {
    return func();
  } else {

  }
};

// ---------------------------------------------------------------------------
export var dbg = (...lArgs) => {
  if (!doDbg) {
    return;
  }
  if (lArgs.length === 1) {
    return dbgString(lArgs[0]);
  } else {
    return dbgValue(lArgs[0], lArgs[1]);
  }
};

// ---------------------------------------------------------------------------
export var dbgValue = (label, val) => {
  var doLog, level;
  assert(isString(label), "not a string");
  doLog = logAll || debugStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgValue ${OL(label)}, ${OL(val)}`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    level = debugStack.logLevel;
    if (!logValue(level, label, val)) {
      stdLogValue(level, label, val);
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
// --- str can be a multi-line string
export var dbgString = (str) => {
  var doLog, level;
  assert(isString(str), "not a string");
  doLog = logAll || debugStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgString(${OL(str)})`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    level = debugStack.logLevel;
    if (!logString(level, str)) {
      console.log("   - using stdLogString");
      stdLogString(level, str);
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
//    Only these 8 functions ever call LOG or LOGVALUE
export var stdLogEnter = (level, funcName, lArgs) => {
  var arg, i, idPre, itemPre, j, labelPre, len, str;
  assert(isFunctionName(funcName), "bad function name");
  assert(isArray(lArgs), "not an array");
  assert(isInteger(level), "level not an integer");
  labelPre = getPrefix(level, 'plain');
  if (lArgs.length === 0) {
    LOG(`enter ${funcName}`, labelPre);
  } else {
    str = `enter ${funcName} ${OLS(lArgs)}`;
    if (stringFits(`${labelPre}${str}`)) {
      LOG(str, labelPre);
    } else {
      idPre = getPrefix(level + 1, 'plain');
      itemPre = getPrefix(level + 2, 'noLastVbar');
      LOG(`enter ${funcName}`, labelPre);
      for (i = j = 0, len = lArgs.length; j < len; i = ++j) {
        arg = lArgs[i];
        LOGVALUE(`arg[${i}]`, arg, idPre, itemPre);
      }
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var stdLogReturn = (...lArgs) => {
  var funcName, labelPre, level, val;
  [level, funcName, val] = lArgs;
  if (lArgs.length === 3) {
    return stdLogReturnVal(level, funcName, val);
  }
  assert(isFunctionName(funcName), "bad function name");
  assert(isInteger(level), "level not an integer");
  labelPre = getPrefix(level, 'withArrow');
  LOG(`return from ${funcName}`, labelPre);
  return true;
};

// ---------------------------------------------------------------------------
stdLogReturnVal = (level, funcName, val) => {
  var labelPre, pre, str;
  assert(isFunctionName(funcName), "bad function name");
  assert(isInteger(level), "level not an integer");
  labelPre = getPrefix(level, 'withArrow');
  str = `return ${OL(val)} from ${funcName}`;
  if (stringFits(str)) {
    LOG(str, labelPre);
  } else {
    pre = getPrefix(level, 'noLastVbar');
    LOG(`return from ${funcName}`, labelPre);
    LOGVALUE("val", val, pre, pre);
  }
  return true;
};

// ---------------------------------------------------------------------------
export var stdLogYield = (...lArgs) => {
  var funcName, labelPre, level, pre, str, val, valStr;
  [level, funcName, val] = lArgs;
  if (lArgs.length === 2) {
    return stdLogYieldFrom(level, funcName);
  }
  labelPre = getPrefix(level, 'withYield');
  valStr = OL(val);
  str = `yield ${valStr}`;
  if (stringFits(str)) {
    LOG(str, labelPre);
  } else {
    pre = getPrefix(level, 'plain');
    LOG("yield", labelPre);
    LOGVALUE(undef, val, pre, pre);
  }
  return true;
};

// ---------------------------------------------------------------------------
export var stdLogYieldFrom = (level, funcName) => {
  var labelPre;
  labelPre = getPrefix(level, 'withFlat');
  LOG("yieldFrom", labelPre);
  return true;
};

// ---------------------------------------------------------------------------
export var stdLogResume = (funcName, level) => {
  var labelPre;
  assert(isInteger(level), "level not an integer");
  labelPre = getPrefix(level + 1, 'withResume');
  LOG("resume", labelPre);
  return true;
};

// ---------------------------------------------------------------------------
export var stdLogString = (level, str) => {
  var j, labelPre, len, part, ref;
  assert(isString(str), "not a string");
  assert(isInteger(level), "level not an integer");
  labelPre = getPrefix(level, 'plain');
  ref = blockToArray(str);
  for (j = 0, len = ref.length; j < len; j++) {
    part = ref[j];
    LOG(part, labelPre);
  }
  return true;
};

// ---------------------------------------------------------------------------
export var stdLogValue = (level, label, val) => {
  var labelPre;
  assert(isInteger(level), "level not an integer");
  labelPre = getPrefix(level, 'plain');
  LOGVALUE(label, val, labelPre);
  return true;
};

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
export var getType = (label, lValues = []) => {
  var lMatches;
  // --- returns [type, funcName]
  //     <type> is one of:
  //        'enter'      - funcName is set
  //        'returnFrom' - funcName is set
  //        'yield'      - funcName is set
  //        'resume'     - funcName is set
  //        'string'     - funcName is undef
  //        'value'      - funcName is undef
  if (lMatches = label.match(/^(enter|yield|resume)\s+([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)?)(?:\(\))?$/)) {
    return [lMatches[1], lMatches[2]];
  }
  if (lMatches = label.match(/^return\s+from\s+([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)?)(?:\(\))?$/)) {
    return ['returnFrom', lMatches[1]];
  }
  // --- if none of the above returned, then...
  if (lValues.length === 1) {
    return ['value', undef];
  } else if (lValues.length === 0) {
    return ['string', undef];
  } else {
    throw new Error("More than 1 object not allowed here");
  }
};

// ........................................................................
export var parseFunc = (str) => {
  var _, fullName, lMatches, modifier;
  // --- returns [fullName, modifier]
  if (lMatches = str.match(/^([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)?)(\+)?$/)) {
    [_, fullName, modifier] = lMatches;
    return [fullName, modifier];
  } else {
    return [undef, undef];
  }
};

// ---------------------------------------------------------------------------
resetDebugging();

//# sourceMappingURL=debug.js.map
