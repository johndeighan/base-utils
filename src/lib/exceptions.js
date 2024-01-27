// exceptions.coffee
var EXLOG, debug, doHaltOnError, doLog, lExceptionLog;

import {
  undef,
  defined,
  notdefined,
  isEmpty
} from '@jdeighan/base-utils';

import {
  getV8Stack,
  nodeStr
} from '@jdeighan/base-utils/v8-stack';

doHaltOnError = false;

doLog = true;

debug = false;

// ---------------------------------------------------------------------------
export var doDebug = () => {
  debug = true;
};

// ---------------------------------------------------------------------------
// simple redirect to an array - useful in unit tests
lExceptionLog = undef;

export var exReset = () => {
  lExceptionLog = [];
};

export var exGetLog = () => {
  var result;
  result = lExceptionLog.join("\n");
  lExceptionLog = undef;
  return result;
};

// ---------------------------------------------------------------------------
/** prevents logging of exceptions */;

export var suppressExceptionLogging = () => {
  doLog = false;
  exReset();
};

// ---------------------------------------------------------------------------
export var haltOnError = (flag = true) => {
  var save;
  // --- return existing setting
  save = doHaltOnError;
  doHaltOnError = flag;
  return save;
};

// ---------------------------------------------------------------------------
EXLOG = (str) => {
  if (lExceptionLog) {
    return lExceptionLog.push(str);
  } else if (doLog) {
    return console.log(str);
  }
};

// ---------------------------------------------------------------------------
//   assert - mimic nodejs's assert
//   return true so we can use it in boolean expressions
export var assert = (cond, msg, condStr = undef) => {
  var boolStr, i, lFrames, len, node;
  if (debug) {
    boolStr = cond.toString();
    if (condStr) {
      console.log(`ASSERT: cond is ${condStr} (${boolStr})`);
    } else {
      console.log(`ASSERT: cond is ${boolStr}`);
    }
  }
  if (!cond) {
    lFrames = getV8Stack();
    EXLOG('-------------------------');
    EXLOG('JavaScript CALL STACK:');
    for (i = 0, len = lFrames.length; i < len; i++) {
      node = lFrames[i];
      EXLOG(`   ${nodeStr(node)}`);
    }
    EXLOG('-------------------------');
    EXLOG(`ERROR: ${msg}`);
    croak(msg);
  }
  return true;
};

// ---------------------------------------------------------------------------
//   croak - throws an error after possibly printing useful info
//           err can be a string or an Error object
export var croak = (err = "unknown error", label = undef, obj = undef) => {
  var curmsg, newmsg;
  if ((typeof err === 'string') || (err instanceof String)) {
    curmsg = err;
  } else {
    curmsg = err.message || "unknown error";
  }
  if (isEmpty(label)) {
    newmsg = `ERROR (croak): ${curmsg}`;
  } else {
    newmsg = `ERROR (croak): ${curmsg}
${label}:
${JSON.stringify(obj)}`;
  }
  if (doHaltOnError) {
    EXLOG(newmsg);
    return process.exit();
  } else {
    // --- re-throw the error
    doLog = true; // reset for next error
    throw new Error(newmsg);
  }
};

//# sourceMappingURL=exceptions.js.map
