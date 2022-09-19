// Generated by CoffeeScript 2.7.0
  // exceptions.coffee
var doHaltOnError, doLog, getCallers, isString, sep_dash, sep_eq, toTAML, untabify,
  indexOf = [].indexOf;

import yaml from 'js-yaml';

sep_dash = '-'.repeat(42);

sep_eq = '='.repeat(42);

const undef = undefined;

isString = (x) => {
  return (typeof x === 'string') || (x instanceof String);
};

untabify = function(str) {
  return str.replace(/\t/g, ' '.repeat(3));
};

doHaltOnError = false;

doLog = true;

// ---------------------------------------------------------------------------
export var haltOnError = function(flag = true) {
  doHaltOnError = flag;
};

// ---------------------------------------------------------------------------
export var logErrors = function(flag = true) {
  doLog = flag;
};

// ---------------------------------------------------------------------------
toTAML = function(obj) {
  var str;
  str = yaml.dump(obj, {
    skipInvalid: true,
    indent: 3,
    sortKeys: true,
    lineWidth: -1
  });
  return "---\n" + str;
};

// ---------------------------------------------------------------------------
// This is useful for debugging
export var LOG = function(...lArgs) {
  var item, label;
  [label, item] = lArgs;
  if (lArgs.length > 1) {
    // --- There's both a label and an item
    if (item === undef) {
      console.log(`${label} = undef`);
    } else if (item === null) {
      console.log(`${label} = null`);
    } else {
      console.log(sep_dash);
      console.log(`${label}:`);
      if (isString(item)) {
        console.log(untabify(item));
      } else {
        console.log(toTAML(item));
      }
      console.log(sep_dash);
    }
  } else {
    console.log(label);
  }
  return true; // to allow use in boolean expressions
};


// --- Use this instead to make it easier to remove all instances
export var DEBUG = LOG; // synonym


// ---------------------------------------------------------------------------
//   error - throw an error
export var error = function(message) {
  if (doHaltOnError) {
    console.trace(`ERROR: ${message}`);
    process.exit();
  }
  throw new Error(message);
};

// ---------------------------------------------------------------------------
getCallers = function(stackTrace, lExclude = []) {
  var _, caller, iter, lCallers, lMatches;
  iter = stackTrace.matchAll(/at\s+(?:async\s+)?([^\s(]+)/g);
  if (!iter) {
    return ["<unknown>"];
  }
  lCallers = [];
  for (lMatches of iter) {
    [_, caller] = lMatches;
    if (caller.indexOf('file://') === 0) {
      break;
    }
    if (indexOf.call(lExclude, caller) < 0) {
      lCallers.push(caller);
    }
  }
  return lCallers;
};

// ---------------------------------------------------------------------------
//   assert - mimic nodejs's assert
//   return true so we can use it in boolean expressions
export var assert = function(cond, msg) {
  var caller, i, lCallers, len, stackTrace;
  if (!cond) {
    if (doLog) {
      stackTrace = new Error().stack;
      lCallers = getCallers(stackTrace, ['assert']);
      console.log('--------------------');
      console.log('JavaScript CALL STACK:');
      for (i = 0, len = lCallers.length; i < len; i++) {
        caller = lCallers[i];
        console.log(`   ${caller}`);
      }
      console.log('--------------------');
      console.log(`ERROR: ${msg} (in ${lCallers[0]}())`);
    }
    if (doHaltOnError) {
      process.exit();
    }
    error(msg);
  }
  return true;
};

// ---------------------------------------------------------------------------
//   croak - throws an error after possibly printing useful info
export var croak = function(err, label, obj) {
  var curmsg, newmsg;
  if (isString(err)) {
    curmsg = err;
  } else {
    curmsg = err.message;
  }
  newmsg = `ERROR (croak): ${curmsg}
${label}:
${JSON.stringify(obj)}`;
  // --- re-throw the error
  throw new Error(newmsg);
};
