// stack.test.coffee
var TEST, stack;

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  undef,
  defined,
  notdefined,
  words
} from '@jdeighan/base-utils';

import {
  clearAllLogs,
  echoLogs
} from '@jdeighan/base-utils/log';

import * as lib from '@jdeighan/base-utils/stack';

Object.assign(global, lib);

import {
  UnitTester,
  equal,
  like,
  notequal,
  truthy,
  falsy,
  fails,
  succeeds
} from '@jdeighan/base-utils/utest';

echoLogs(false);

// ---------------------------------------------------------------------------
TEST = (stack, curFunc, strActive, strNonActive, logging, level = undef, logLevel = undef) => {
  var i, j, len, len1, name, ref, ref1;
  if (defined(curFunc)) {
    equal(stack.curFuncName, curFunc);
  } else {
    equal(stack.curFuncName, '_MAIN_');
  }
  if (defined(strActive)) {
    ref = words(strActive);
    for (i = 0, len = ref.length; i < len; i++) {
      name = ref[i];
      truthy(stack.isActive(name));
    }
  }
  if (defined(strNonActive)) {
    ref1 = words(strNonActive);
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      name = ref1[j];
      falsy(stack.isActive(name));
    }
  }
  if (logging) {
    truthy(stack.isLogging());
  } else {
    falsy(stack.isLogging());
  }
  if (defined(level)) {
    equal(stack.level, level);
  }
  if (defined(logLevel)) {
    equal(stack.logLevel, logLevel);
  }
};

// ---------------------------------------------------------------------------
clearAllLogs();

stack = new CallStack();

stack.logCalls(true);

stack.enter('func');

// ---           cur    active  !active  isLogging
TEST(stack, 'func', "func", "func2", false);

stack.returnFrom('func');

truthy(stack.isEmpty());

equal(getStackLog(), `ENTER 'func'
RETURN FROM 'func'`);

// ---------------------------------------------------------------------------
fails(function() {
  suppressExceptionLogging(true);
  clearAllLogs();
  stack = new CallStack();
  stack.logCalls(true);
  stack.enter('func');
  return stack.returnFrom('func2'); // should throw an error
});


// ---------------------------------------------------------------------------
clearAllLogs();

stack = new CallStack();

stack.logCalls(true);

stack.enter('func', [], true);

// ---           cur    active  !active  isLogging
TEST(stack, 'func', "func", "func2", true);

stack.returnFrom('func');

// ---          cur     active  !active        isLogging
//              -----   ------  --------       ---------
TEST(stack, undef, undef, 'func func2', false);

truthy(stack.isEmpty());

equal(getStackLog(), `ENTER 'func'
RETURN FROM 'func'`);

// ---------------------------------------------------------------------------
clearAllLogs();

stack = new CallStack();

stack.logCalls(true);

stack.enter('func', [], true);

// ---          cur     active  !active    isLogging
//              -----   ------  --------   ---------
TEST(stack, 'func', 'func', 'func2', true);

stack.enter('func2');

// ---          cur      active        !active   isLogging
//              -----    ------        --------  ---------
TEST(stack, 'func2', 'func func2', undef, false);

stack.returnFrom('func2');

// ---          cur     active  !active    isLogging
//              -----   ------  --------   ---------
TEST(stack, 'func', 'func', 'func2', true);

stack.returnFrom('func');

// ---          cur     active  !active      isLogging
//              -----   ------  --------     ---------
TEST(stack, undef, undef, 'func func2', false);

equal(getStackLog(), `ENTER 'func'
	ENTER 'func2'
	RETURN FROM 'func2'
RETURN FROM 'func'`);

truthy(stack.isEmpty());

// ---------------------------------------------------------------------------
// --- Test yield / resume
clearAllLogs();

stack = new CallStack();

stack.logCalls(true);

// ---          cur     active  !active       isLogging
//              -----   ------  --------      ---------
TEST(stack, undef, undef, 'func gen', false, 0, 0);

stack.enter('func', [], true);

// ---          cur     active  !active   isLogging
//              -----   ------  --------  ---------
TEST(stack, 'func', 'func', 'gen', true, 1, 1);

stack.enter('gen', [], false);

// ---          cur     active        !active   isLogging
//              -----   ------        --------  ---------
TEST(stack, 'gen', 'func gen', undef, false, 2, 1);

stack.yield('gen', 13);

// ---          cur     active    !active   isLogging
//              -----   ------    --------  ---------
TEST(stack, 'func', 'func', 'gen', true, 1, 1);

stack.resume('gen');

// ---          cur     active    !active   isLogging
//              -----   ------    --------  ---------
TEST(stack, 'gen', 'func gen', undef, false, 2, 1);

stack.returnFrom('gen');

// ---          cur     active    !active   isLogging
//              -----   ------    --------  ---------
TEST(stack, 'func', 'func', 'gen', true, 1, 1);

stack.returnFrom('func');

// ---          cur     active  !active       isLogging
//              -----   ------  --------      ---------
TEST(stack, undef, undef, 'func gen', false, 0, 0);

truthy(stack.isEmpty());

// ---------------------------------------------------------------------------
// --- Test multiple generators
clearAllLogs();

stack = new CallStack();

stack.logCalls(true);

// ---          cur     active  !active       isLogging
//              -----   ------  --------      ---------
TEST(stack, undef, undef, 'func gen', false, 0, 0);

stack.enter('func', [], true);

// ---          cur     active  !active   isLogging
//              -----   ------  --------  ---------
TEST(stack, 'func', 'func', 'gen', true, 1, 1);

stack.enter('gen', [], false);

// ---          cur     active        !active   isLogging
//              -----   ------        --------  ---------
TEST(stack, 'gen', 'func gen', undef, false, 2, 1);

stack.yield('gen', 13);

// ---          cur     active    !active   isLogging
//              -----   ------    --------  ---------
TEST(stack, 'func', 'func', 'gen', true, 1, 1);

stack.resume('gen');

// ---          cur     active    !active   isLogging
//              -----   ------    --------  ---------
TEST(stack, 'gen', 'func gen', undef, false, 2, 1);

stack.returnFrom('gen');

// ---          cur     active    !active   isLogging
//              -----   ------    --------  ---------
TEST(stack, 'func', 'func', 'gen', true, 1, 1);

stack.returnFrom('func');

// ---          cur     active  !active       isLogging
//              -----   ------  --------      ---------
TEST(stack, undef, undef, 'func gen', false, 0, 0);

truthy(stack.isEmpty());

// ---------------------------------------------------------------------------
// test stack log
clearAllLogs();

stack = new CallStack();

stack.logCalls(true);

stack.reset();

stack.enter('func1', [13]);

stack.enter('func2', [
  'abc',
  {
    mean: 42
  }
]);

stack.yield('func2', 99);

stack.resume('func2');

stack.returnFrom('func2', 'def');

stack.returnFrom('func1');

equal(getStackLog(), `RESET STACK
ENTER 'func1' 13
	ENTER 'func2' 'abc',{"mean":42}
	YIELD FROM 'func2' 99
	RESUME 'func2'
	RETURN FROM 'func2' 'def'
RETURN FROM 'func1'`);