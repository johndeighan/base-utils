// Generated by CoffeeScript 2.7.0
// debug.coffee
var internalDebugging, lDebugLog, lFuncList, logAll, logEnter, logResume, logReturn, logReturnVal, logString, logType, logValue, logYield, logYieldFrom;

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  undef,
  defined,
  notdefined,
  OL,
  OLS,
  isIdentifier,
  isFunctionName,
  isString,
  isFunction,
  isArray,
  isHash,
  isBoolean,
  isInteger,
  isEmpty,
  nonEmpty,
  words,
  firstWord,
  inList,
  oneof,
  arrayToBlock
} from '@jdeighan/base-utils/utils';

import {
  getPrefix
} from '@jdeighan/base-utils/prefix';

import {
  LOG,
  LOGVALUE,
  stringFits,
  setLogger,
  debugLogging
} from '@jdeighan/base-utils/log';

import {
  toTAML
} from '@jdeighan/base-utils/taml';

import {
  CallStack,
  debugStack
} from '@jdeighan/base-utils/stack';

export {
  debugStack,
  debugLogging
};

export var callStack = new CallStack();

lFuncList = []; // array of {funcName, plus}

logAll = false; // if true, always log

internalDebugging = false;

logEnter = undef;

logReturn = undef;

logReturnVal = undef;

logYield = undef;

logYieldFrom = undef;

logResume = undef;

logValue = undef;

logString = undef;

// ---------------------------------------------------------------------------
export var debugDebug = (debugFlag = true) => {
  internalDebugging = debugFlag;
};

// ---------------------------------------------------------------------------
export var dumpDebugLoggers = function(label = undef) {
  var lLines;
  lLines = [];
  if (nonEmpty(label)) {
    lLines.push(`LOGGERS (${label})`);
  } else {
    lLines.push("LOGGERS");
  }
  lLines.push(`   enter      - ${logType(logEnter, stdLogEnter)}`);
  lLines.push(`   return     - ${logType(logReturn, stdLogReturn)}`);
  lLines.push(`   return val - ${logType(logReturnVal, stdLogReturnVal)}`);
  lLines.push(`   yield      - ${logType(logYield, stdLogYield)}`);
  lLines.push(`   yield from - ${logType(logYieldFrom, stdLogYieldFrom)}`);
  lLines.push(`   resume     - ${logType(logResume, stdLogResume)}`);
  lLines.push(`   string     - ${logType(logString, stdLogString)}`);
  lLines.push(`   value      - ${logType(logValue, stdLogValue)}`);
  return console.log(arrayToBlock(lLines));
};

// ---------------------------------------------------------------------------
logType = function(cur, std) {
  if (cur === std) {
    return 'std';
  } else if (defined(cur)) {
    return 'custom';
  } else {
    return 'undef';
  }
};

// ---------------------------------------------------------------------------
export var setDebugging = function(...lParms) {
  var customSet, i, j, key, len, parm, value;
  // --- pass a hash to set custom loggers
  if (internalDebugging) {
    console.log(`setDebugging() with ${lParms.length} parms`);
  }
  callStack.reset();
  lFuncList = [];
  logAll = false;
  logEnter = stdLogEnter;
  logReturn = stdLogReturn;
  logReturnVal = stdLogReturnVal;
  logYield = stdLogYield;
  logYieldFrom = stdLogYieldFrom;
  logResume = stdLogResume;
  logValue = stdLogValue;
  logString = stdLogString;
  customSet = false;
  for (i = j = 0, len = lParms.length; j < len; i = ++j) {
    parm = lParms[i];
    if (isBoolean(parm)) {
      logAll = parm;
    } else if (isString(parm)) {
      logAll = false;
      if (internalDebugging) {
        console.log(`lParms[${i}] is string ${OL(parm)}`);
      }
      lFuncList = lFuncList.concat(getFuncList(parm));
    } else if (isHash(parm)) {
      if (internalDebugging) {
        console.log(`lParms[${i}] is hash ${OL(parm)}`);
      }
      customSet = true;
      for (key in parm) {
        value = parm[key];
        setCustomDebugLogger(key, value);
      }
    } else {
      croak(`Invalid parm to setDebugging(): ${OL(parm)}`);
    }
  }
  if (internalDebugging) {
    console.log('lFuncList:');
    console.log(toTAML(lFuncList));
    if (customSet) {
      dumpDebugLoggers();
    }
  }
};

// ---------------------------------------------------------------------------
export var setCustomDebugLogger = function(type, func) {
  assert(isFunction(func), "Not a function");
  switch (type) {
    case 'enter':
      logEnter = func;
      break;
    case 'returnFrom':
      logReturn = func;
      break;
    case 'returnVal':
      logReturnVal = func;
      break;
    case 'yield':
      logYield = func;
      break;
    case 'yieldFrom':
      logYieldFrom = func;
      break;
    case 'resume':
      logResume = func;
      break;
    case 'value':
      logValue = func;
      break;
    case 'string':
      logString = func;
      break;
    default:
      throw new Error(`Unknown type: ${OL(type)}`);
  }
};

// ---------------------------------------------------------------------------
export var getFuncList = function(str) {
  var fullName, j, lFuncs, len, modifier, ref, word;
  lFuncs = [];
  ref = words(str);
  for (j = 0, len = ref.length; j < len; j++) {
    word = ref[j];
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
// simple redirect to an array - useful in unit tests
lDebugLog = undef;

export var dbgReset = () => {
  lDebugLog = [];
};

export var dbgGetLog = () => {
  var result;
  result = arrayToBlock(lDebugLog);
  lDebugLog = undef;
  return result;
};

// ---------------------------------------------------------------------------
// Stack is only modified in these 8 functions (it is reset in setDebugging())
// ---------------------------------------------------------------------------
export var dbgEnter = function(funcName, ...lValues) {
  var doLog, level, nVals, orgLogger;
  assert(isFunctionName(funcName), "not a valid function name");
  doLog = logAll || funcMatch(funcName);
  if (internalDebugging) {
    nVals = lValues.length;
    console.log(`dbgEnter ${OL(funcName)}, ${OL(nVals)} vals`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    if (defined(lDebugLog)) {
      orgLogger = setLogger((str) => {
        return lDebugLog.push(str);
      });
    }
    level = callStack.logLevel;
    if (!logEnter(funcName, lValues, level)) {
      stdLogEnter(funcName, lValues, level);
    }
    if (defined(lDebugLog)) {
      setLogger(orgLogger);
    }
  }
  callStack.enter(funcName, lValues, doLog);
  return true;
};

// ---------------------------------------------------------------------------
export var dbgReturn = function(funcName) {
  var doLog, level, orgLogger;
  assert(isFunctionName(funcName), "not a valid function name");
  doLog = logAll || callStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgReturn ${OL(funcName)}`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    if (defined(lDebugLog)) {
      orgLogger = setLogger((str) => {
        return lDebugLog.push(str);
      });
    }
    level = callStack.logLevel;
    if (!logReturn(funcName, level)) {
      stdLogReturn(funcName, level);
    }
    if (defined(lDebugLog)) {
      setLogger(orgLogger);
    }
  }
  callStack.returnFrom(funcName);
  return true;
};

// ---------------------------------------------------------------------------
export var dbgReturnVal = function(funcName, val) {
  var doLog, level, orgLogger;
  assert(isFunctionName(funcName), "not a valid function name");
  doLog = logAll || callStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgReturn ${OL(funcName)}, ${OL(val)}`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    if (defined(lDebugLog)) {
      orgLogger = setLogger((str) => {
        return lDebugLog.push(str);
      });
    }
    level = callStack.logLevel;
    if (!logReturnVal(funcName, val, level)) {
      stdLogReturnVal(funcName, val, level);
    }
    if (defined(lDebugLog)) {
      setLogger(orgLogger);
    }
  }
  callStack.returnVal(funcName, val);
  return true;
};

// ---------------------------------------------------------------------------
export var dbgYield = function(funcName, val) {
  var doLog, level, orgLogger;
  assert(isFunctionName(funcName), "not a function name");
  doLog = logAll || callStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgYield ${OL(val)}`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    if (defined(lDebugLog)) {
      orgLogger = setLogger((str) => {
        return lDebugLog.push(str);
      });
    }
    level = callStack.logLevel;
    if (!logYield(funcName, val, level)) {
      stdLogYield(funcName, val, level);
    }
    if (defined(lDebugLog)) {
      setLogger(orgLogger);
    }
  }
  callStack.yield(funcName, val);
  return true;
};

// ---------------------------------------------------------------------------
export var dbgYieldFrom = function(funcName) {
  var doLog, level, orgLogger;
  assert(isFunctionName(funcName), "not a function name");
  doLog = logAll || callStack.isLogging();
  if (internalDebugging) {
    console.log("dbgYieldFrom");
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    if (defined(lDebugLog)) {
      orgLogger = setLogger((str) => {
        return lDebugLog.push(str);
      });
    }
    level = callStack.logLevel;
    if (!logYieldFrom(funcName, level)) {
      stdLogYieldFrom(funcName, level);
    }
    if (defined(lDebugLog)) {
      setLogger(orgLogger);
    }
  }
  callStack.yieldFrom(funcName);
  return true;
};

// ---------------------------------------------------------------------------
export var dbgResume = function(funcName) {
  var doLog, level, orgLogger;
  assert(isFunctionName(funcName), "not a valid function name");
  doLog = logAll || callStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgResume(${OL(funcName)})`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    if (defined(lDebugLog)) {
      orgLogger = setLogger((str) => {
        return lDebugLog.push(str);
      });
    }
    level = callStack.logLevel;
    if (!logResume(funcName, level)) {
      stdLogResume(funcName, level);
    }
    if (defined(lDebugLog)) {
      setLogger(orgLogger);
    }
  }
  callStack.resume(funcName);
  return true;
};

// ---------------------------------------------------------------------------
export var dbgValue = function(label, val) {
  var doLog, level, orgLogger;
  assert(isString(label), "not a string");
  doLog = logAll || callStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgValue ${OL(label)}, ${OL(val)}`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    if (defined(lDebugLog)) {
      orgLogger = setLogger((str) => {
        return lDebugLog.push(str);
      });
    }
    level = callStack.logLevel;
    if (!logValue(label, val, level)) {
      stdLogValue(label, val, level);
    }
    if (defined(lDebugLog)) {
      setLogger(orgLogger);
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var dbgString = function(str) {
  var doLog, level, orgLogger;
  assert(isString(str), "not a string");
  doLog = logAll || callStack.isLogging();
  if (internalDebugging) {
    console.log(`dbgString(${OL(str)})`);
    console.log(`   - doLog = ${OL(doLog)}`);
  }
  if (doLog) {
    if (defined(lDebugLog)) {
      orgLogger = setLogger((str) => {
        return lDebugLog.push(str);
      });
    }
    level = callStack.logLevel;
    if (!logString(str, level)) {
      stdLogString(str, level);
    }
    if (defined(lDebugLog)) {
      setLogger(orgLogger);
    }
  }
  return true;
};

// ---------------------------------------------------------------------------
export var dbg = function(...lArgs) {
  if (lArgs.length === 1) {
    return dbgString(lArgs[0]);
  } else {
    return dbgValue(lArgs[0], lArgs[1]);
  }
};

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
//    Only these 8 functions ever call LOG or LOGVALUE
export var stdLogEnter = function(funcName, lArgs, level) {
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
      itemPre = getPrefix(level + 2, 'dotLast2Vbars');
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
export var stdLogReturn = function(funcName, level) {
  var labelPre;
  assert(isFunctionName(funcName), "bad function name");
  assert(isInteger(level), "level not an integer");
  labelPre = getPrefix(level, 'withArrow');
  LOG(`return from ${funcName}`, labelPre);
  return true;
};

// ---------------------------------------------------------------------------
export var stdLogReturnVal = function(funcName, val, level) {
  var idPre, itemPre, labelPre, str;
  assert(isFunctionName(funcName), "bad function name");
  assert(isInteger(level), "level not an integer");
  labelPre = getPrefix(level, 'withArrow');
  str = `return ${OL(val)} from ${funcName}`;
  if (stringFits(str)) {
    LOG(str, labelPre);
  } else {
    idPre = getPrefix(level, 'noLastVbar');
    itemPre = getPrefix(level, 'noLast2Vbars');
    LOG(`return from ${funcName}`, labelPre);
    LOGVALUE("val", val, idPre, itemPre);
  }
  return true;
};

// ---------------------------------------------------------------------------
export var stdLogYield = function(funcName, val, level) {
  var idPre, itemPre, labelPre, str, valStr;
  labelPre = getPrefix(level, 'withFlat');
  valStr = OL(val);
  str = `yield ${valStr}`;
  if (stringFits(str)) {
    LOG(str, labelPre);
  } else {
    idPre = getPrefix(level + 1, 'plain');
    itemPre = getPrefix(level + 2, 'dotLast2Vbars');
    LOG("yield", labelPre);
    LOGVALUE("val", val, idPre, itemPre);
  }
  return true;
};

// ---------------------------------------------------------------------------
export var stdLogYieldFrom = function(funcName, level) {
  var labelPre;
  labelPre = getPrefix(level, 'withFlat');
  LOG("yieldFrom", labelPre);
  return true;
};

// ---------------------------------------------------------------------------
export var stdLogResume = function(funcName, level) {
  var labelPre;
  assert(isInteger(level), "level not an integer");
  labelPre = getPrefix(level, 'plain');
  // LOG "resume", labelPre  # no need to log it
  return true;
};

// ---------------------------------------------------------------------------
export var stdLogString = function(str, level) {
  var labelPre;
  assert(isString(str), "not a string");
  assert(isInteger(level), "level not an integer");
  labelPre = getPrefix(level, 'plain');
  LOG(str, labelPre);
  return true;
};

// ---------------------------------------------------------------------------
export var stdLogValue = function(label, val, level) {
  var labelPre;
  assert(isInteger(level), "level not an integer");
  labelPre = getPrefix(level, 'plain');
  LOGVALUE(label, val, labelPre);
  return true;
};

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
export var getType = function(label, lValues = []) {
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
  // --- Check for deprecated forms
  assert(!oneof(firstWord(label), 'enter', 'returnFrom', 'yield', 'resume'), `deprecated form for debug(): ${OL(label)}`);
  // --- if none of the above returned, then...
  if (lValues.length === 1) {
    return ['value', undef];
  } else if (lValues.length === 0) {
    return ['string', undef];
  } else {
    throw new Error("More than 1 object not allowed here");
  }
};

// ---------------------------------------------------------------------------
export var funcMatch = function(fullName) {
  var h, j, len;
  // --- fullName came from a call to dbgEnter()
  if (internalDebugging) {
    console.log(`funcMatch(${OL(fullName)})`);
  }
  for (j = 0, len = lFuncList.length; j < len; j++) {
    h = lFuncList[j];
    if (h.fullName === fullName) {
      return true;
    }
    if (h.plus && callStack.isActive(fullName)) {
      return true;
    }
  }
  return false;
};

// ........................................................................
export var parseFunc = function(str) {
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
setDebugging();
