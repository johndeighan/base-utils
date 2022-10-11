// Generated by CoffeeScript 2.7.0
  // debug.coffee
var callStack, debug2, lFuncList, reMethod, strFuncList,
  indexOf = [].indexOf;

import {
  undef,
  pass,
  defined,
  notdefined,
  untabify,
  toTAML,
  escapeStr,
  OL,
  jsType,
  isString,
  isNumber,
  isInteger,
  isHash,
  isArray,
  isBoolean,
  isConstructor,
  isFunction,
  isRegExp,
  isObject,
  isEmpty,
  nonEmpty,
  blockToArray,
  arrayToBlock,
  chomp,
  words
} from '@jdeighan/exceptions/utils';

import {
  LOG,
  LOGVALUE,
  sep_dash,
  sep_eq
} from '@jdeighan/exceptions/log';

import {
  getPrefix
} from '@jdeighan/exceptions/prefix';

import {
  assert,
  croak
} from '@jdeighan/exceptions';

import {
  CallStack
} from '@jdeighan/exceptions/stack';

callStack = new CallStack();

// --- set in resetDebugging() and setDebugging()
//     returns undef for no logging, or a label to log
export var shouldLog = function() {
  return undef;
};

lFuncList = []; // names of functions being debugged

strFuncList = undef; // original string


// ---------------------------------------------------------------------------
export var interp = function(label) {
  return label.replace(/\$(\@)?([A-Za-z_][A-Za-z0-9_]*)/g, function(_, atSign, varName) {
    if (atSign) {
      return `\#{OL(@${varName})\}`;
    } else {
      return `\#{OL(${varName})\}`;
    }
  });
};

// ---------------------------------------------------------------------------
export var debug = function(orgLabel, ...lObjects) {
  var funcName, label, type;
  assert(isString(orgLabel), `1st arg ${OL(orgLabel)} should be a string`);
  [type, funcName] = getType(orgLabel, lObjects);
  label = shouldLog(orgLabel, type, funcName, callStack);
  if (defined(label)) {
    label = interp(label);
  }
  switch (type) {
    case 'enter':
      if (defined(label)) {
        doTheLogging(type, label, lObjects);
      }
      callStack.enter(funcName, lObjects, defined(label));
      debug2("enter debug()", orgLabel, lObjects);
      debug2(`type = ${OL(type)}, funcName = ${OL(funcName)}`);
      debug2("return from debug()");
      break;
    case 'return':
      debug2("enter debug()", orgLabel, lObjects);
      debug2(`type = ${OL(type)}, funcName = ${OL(funcName)}`);
      debug2("return from debug()");
      if (defined(label)) {
        doTheLogging(type, label, lObjects);
      }
      callStack.returnFrom(funcName);
      break;
    case 'string':
      debug2("enter debug()", orgLabel, lObjects);
      debug2(`type = ${OL(type)}, funcName = ${OL(funcName)}`);
      if (defined(label)) {
        doTheLogging(type, label, lObjects);
      }
      debug2("return from debug()");
  }
  return true; // allow use in boolean expressions
};


// ---------------------------------------------------------------------------
debug2 = function(orgLabel, ...lObjects) {
  var funcName, label, type;
  [type, funcName] = getType(orgLabel, lObjects);
  label = shouldLog(orgLabel, type, funcName, callStack);
  switch (type) {
    case 'enter':
      if (defined(label)) {
        doTheLogging('enter', label, lObjects);
      }
      callStack.enter(funcName, lObjects, defined(label));
      break;
    case 'return':
      if (defined(label)) {
        doTheLogging('return', label, lObjects);
      }
      callStack.returnFrom(funcName);
      break;
    case 'string':
      if (defined(label)) {
        doTheLogging('string', label, lObjects);
      }
  }
  return true; // allow use in boolean expressions
};


// ---------------------------------------------------------------------------
export var doTheLogging = function(type, label, lObjects) {
  var i, itemPre, j, k, len, len1, level, nVals, obj, pre;
  assert(isString(label), `non-string label ${OL(label)}`);
  level = callStack.getLevel();
  switch (type) {
    case 'enter':
      LOG(label, getPrefix(level));
      pre = getPrefix(level + 1, 'dotLastVbar');
      itemPre = getPrefix(level + 2, 'dotLast2Vbars');
      for (i = j = 0, len = lObjects.length; j < len; i = ++j) {
        obj = lObjects[i];
        LOGVALUE(`arg[${i}]`, obj, pre, itemPre);
      }
      break;
    case 'return':
      LOG(label, getPrefix(level, 'withArrow'));
      pre = getPrefix(level, 'noLastVbar');
      itemPre = getPrefix(level, 'noLast2Vbars');
      for (i = k = 0, len1 = lObjects.length; k < len1; i = ++k) {
        obj = lObjects[i];
        LOGVALUE(`ret[${i}]`, obj, pre, itemPre);
      }
      break;
    case 'string':
      pre = getPrefix(level, 'plain');
      itemPre = getPrefix(level + 1, 'noLastVbar');
      nVals = lObjects.length;
      if (nVals === 0) {
        LOG(label, pre);
      } else {
        assert(nVals === 1, `Only 1 value allowed, ${nVals} found`);
        LOGVALUE(label, lObjects[0], pre);
      }
  }
};

// ---------------------------------------------------------------------------
export var stdShouldLog = function(label, type, funcName, stack) {
  var result;
  // --- if type is 'enter', then funcName won't be on the stack yet
  //     returns the (possibly modified) label to log
  assert(isString(label), `label ${OL(label)} not a string`);
  assert(isString(type), `type ${OL(type)} not a string`);
  assert(stack instanceof CallStack, "not a call stack object");
  if ((type === 'enter') || (type === 'return')) {
    assert(isString(funcName), `func name ${OL(funcName)} not a string`);
  } else {
    assert(funcName === undef, `func name ${OL(funcName)} not undef`);
  }
  if (funcMatch(funcName || stack.curFunc())) {
    return label;
  }
  if ((type === 'enter') && !isMyFunc(funcName)) {
    // --- As a special case, if we enter a function where we will not
    //     be logging, but we were logging in the calling function,
    //     we'll log out the call itself
    if (funcMatch(stack.curFunc())) {
      result = label.replace('enter', 'call');
      return result;
    }
  }
  return undef;
};

// ---------------------------------------------------------------------------
export var isMyFunc = function(funcName) {
  return indexOf.call(words('debug debug2 doTheLogging stdShouldLog setDebugging resetDebugging getFuncList funcMatch getType dumpCallStack'), funcName) >= 0;
};

// ---------------------------------------------------------------------------
export var trueShouldLog = function(label, type, funcName, stack) {
  if (isMyFunc(funcName || stack.curFunc())) {
    return undef;
  } else {
    return label;
  }
};

// ---------------------------------------------------------------------------
export var setDebugging = function(option) {
  callStack.reset();
  if (isBoolean(option)) {
    if (option) {
      shouldLog = trueShouldLog;
    } else {
      shouldLog = function() {
        return undef;
      };
    }
  } else if (isString(option)) {
    lFuncList = getFuncList(option);
    shouldLog = stdShouldLog;
  } else if (isFunction(option)) {
    shouldLog = option;
  } else {
    croak(`bad parameter ${OL(option)}`);
  }
};

// ---------------------------------------------------------------------------
export var resetDebugging = function() {
  callStack.reset();
  shouldLog = function() {
    return undef;
  };
};

// ---------------------------------------------------------------------------
// --- export only to allow unit tests
export var getFuncList = function(str) {
  var _, ident1, ident2, j, lMatches, len, plus, ref, word;
  strFuncList = str; // store original string for debugging
  lFuncList = [];
  ref = words(str);
  for (j = 0, len = ref.length; j < len; j++) {
    word = ref[j];
    if (lMatches = word.match(/^([A-Za-z_][A-Za-z0-9_]*)(?:\.([A-Za-z_][A-Za-z0-9_]*))?(\+)?$/)) {
      [_, ident1, ident2, plus] = lMatches;
      if (ident2) {
        lFuncList.push({
          name: ident2,
          object: ident1,
          plus: plus === '+'
        });
      } else {
        lFuncList.push({
          name: ident1,
          plus: plus === '+'
        });
      }
    } else {
      croak(`Bad word in func list: ${OL(word)}`);
    }
  }
  return lFuncList;
};

// ---------------------------------------------------------------------------
// --- export only to allow unit tests
export var funcMatch = function(funcName) {
  var h, j, len, name, object, plus;
  assert(isArray(lFuncList), `not an array ${OL(lFuncList)}`);
  for (j = 0, len = lFuncList.length; j < len; j++) {
    h = lFuncList[j];
    ({name, object, plus} = h);
    if (name === funcName) {
      return true;
    }
    if (plus && callStack.isActive(name)) {
      return true;
    }
  }
  return false;
};

// ---------------------------------------------------------------------------
// --- type is one of: 'enter', 'return', 'string'
export var getType = function(str, lObjects) {
  var _, funcName, ident1, ident2, lMatches, type;
  if (lMatches = str.match(/^\s*(enter|(?:return.+from))\s+([A-Za-z_][A-Za-z0-9_]*)(?:\.([A-Za-z_][A-Za-z0-9_]*))?/)) {
    [_, type, ident1, ident2] = lMatches;
    if (ident2) {
      funcName = ident2;
    } else {
      funcName = ident1;
    }
    if (type === 'enter') {
      return ['enter', funcName];
    } else {
      return ['return', funcName];
    }
  } else {
    return ['string', undef];
  }
};

// ---------------------------------------------------------------------------
reMethod = /^([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)$/;

// ---------------------------------------------------------------------------
export var dumpDebugGlobals = function() {
  var funcName, j, len;
  LOG('='.repeat(40));
  LOG(callStack.dump());
  if (shouldLog === stdShouldLog) {
    LOG("using stdShouldLog");
  } else if (shouldLog === trueShouldLog) {
    LOG("using trueShouldLog");
  } else {
    LOG("using custom shouldLog");
  }
  LOG("lFuncList:");
  for (j = 0, len = lFuncList.length; j < len; j++) {
    funcName = lFuncList[j];
    LOG(`   ${OL(funcName)}`);
  }
  LOG('='.repeat(40));
};

// ---------------------------------------------------------------------------
