// stack.test.coffee
var TEST;

import test from 'ava';

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
  clearAllLogs
} from '@jdeighan/base-utils/log';

import {
  CallStack,
  getStackLog
} from '@jdeighan/base-utils/stack';

// ---------------------------------------------------------------------------
TEST = (t, stack, curFunc, strActive, strNonActive, logging, level = undef, logLevel = undef) => {
  var i, j, len, len1, name, ref, ref1;
  if (defined(curFunc)) {
    t.is(stack.curFuncName, curFunc);
  } else {
    t.is(stack.curFuncName, '_MAIN_');
  }
  if (defined(strActive)) {
    ref = words(strActive);
    for (i = 0, len = ref.length; i < len; i++) {
      name = ref[i];
      t.truthy(stack.isActive(name));
    }
  }
  if (defined(strNonActive)) {
    ref1 = words(strNonActive);
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      name = ref1[j];
      t.falsy(stack.isActive(name));
    }
  }
  if (logging) {
    t.truthy(stack.isLogging());
  } else {
    t.falsy(stack.isLogging());
  }
  if (defined(level)) {
    t.is(stack.level, level);
  }
  if (defined(logLevel)) {
    t.is(stack.logLevel, logLevel);
  }
};

// ---------------------------------------------------------------------------
test("line 39", (t) => {
  var stack;
  clearAllLogs();
  stack = new CallStack();
  stack.logCalls(true);
  stack.enter('func');
  // ---           cur    active  !active  isLogging
  TEST(t, stack, 'func', "func", "func2", false);
  stack.returnFrom('func');
  t.truthy(stack.isEmpty());
  return t.is(getStackLog(), `ENTER 'func'
RETURN FROM 'func'`);
});

// ---------------------------------------------------------------------------
test("line 58", (t) => {
  return t.throws(function() {
    var stack;
    suppressExceptionLogging(true);
    clearAllLogs();
    stack = new CallStack();
    stack.logCalls(true);
    stack.enter('func');
    return stack.returnFrom('func2'); // should throw an error
  });
});


// ---------------------------------------------------------------------------
test("line 69", (t) => {
  var stack;
  clearAllLogs();
  stack = new CallStack();
  stack.logCalls(true);
  stack.enter('func', [], true);
  // ---           cur    active  !active  isLogging
  TEST(t, stack, 'func', "func", "func2", true);
  stack.returnFrom('func');
  // ---          cur     active  !active        isLogging
  //              -----   ------  --------       ---------
  TEST(t, stack, undef, undef, 'func func2', false);
  t.truthy(stack.isEmpty());
  return t.is(getStackLog(), `ENTER 'func'
RETURN FROM 'func'`);
});

// ---------------------------------------------------------------------------
test("line 91", (t) => {
  var stack;
  clearAllLogs();
  stack = new CallStack();
  stack.logCalls(true);
  stack.enter('func', [], true);
  // ---          cur     active  !active    isLogging
  //              -----   ------  --------   ---------
  TEST(t, stack, 'func', 'func', 'func2', true);
  stack.enter('func2');
  // ---          cur      active        !active   isLogging
  //              -----    ------        --------  ---------
  TEST(t, stack, 'func2', 'func func2', undef, false);
  stack.returnFrom('func2');
  // ---          cur     active  !active    isLogging
  //              -----   ------  --------   ---------
  TEST(t, stack, 'func', 'func', 'func2', true);
  stack.returnFrom('func');
  // ---          cur     active  !active      isLogging
  //              -----   ------  --------     ---------
  TEST(t, stack, undef, undef, 'func func2', false);
  t.is(getStackLog(), `ENTER 'func'
	ENTER 'func2'
	RETURN FROM 'func2'
RETURN FROM 'func'`);
  return t.truthy(stack.isEmpty());
});

// ---------------------------------------------------------------------------
// --- Test yield / resume
test("line 131", (t) => {
  var stack;
  clearAllLogs();
  stack = new CallStack();
  stack.logCalls(true);
  // ---          cur     active  !active       isLogging
  //              -----   ------  --------      ---------
  TEST(t, stack, undef, undef, 'func gen', false, 0, 0);
  stack.enter('func', [], true);
  // ---          cur     active  !active   isLogging
  //              -----   ------  --------  ---------
  TEST(t, stack, 'func', 'func', 'gen', true, 1, 1);
  stack.enter('gen', [], false);
  // ---          cur     active        !active   isLogging
  //              -----   ------        --------  ---------
  TEST(t, stack, 'gen', 'func gen', undef, false, 2, 1);
  stack.yield('gen', 13);
  // ---          cur     active    !active   isLogging
  //              -----   ------    --------  ---------
  TEST(t, stack, 'func', 'func', 'gen', true, 1, 1);
  stack.resume('gen');
  // ---          cur     active    !active   isLogging
  //              -----   ------    --------  ---------
  TEST(t, stack, 'gen', 'func gen', undef, false, 2, 1);
  stack.returnFrom('gen');
  // ---          cur     active    !active   isLogging
  //              -----   ------    --------  ---------
  TEST(t, stack, 'func', 'func', 'gen', true, 1, 1);
  stack.returnFrom('func');
  // ---          cur     active  !active       isLogging
  //              -----   ------  --------      ---------
  TEST(t, stack, undef, undef, 'func gen', false, 0, 0);
  return t.truthy(stack.isEmpty());
});

// ---------------------------------------------------------------------------
// --- Test multiple generators
test("line 181", (t) => {
  var stack;
  clearAllLogs();
  stack = new CallStack();
  stack.logCalls(true);
  // ---          cur     active  !active       isLogging
  //              -----   ------  --------      ---------
  TEST(t, stack, undef, undef, 'func gen', false, 0, 0);
  stack.enter('func', [], true);
  // ---          cur     active  !active   isLogging
  //              -----   ------  --------  ---------
  TEST(t, stack, 'func', 'func', 'gen', true, 1, 1);
  stack.enter('gen', [], false);
  // ---          cur     active        !active   isLogging
  //              -----   ------        --------  ---------
  TEST(t, stack, 'gen', 'func gen', undef, false, 2, 1);
  stack.yield('gen', 13);
  // ---          cur     active    !active   isLogging
  //              -----   ------    --------  ---------
  TEST(t, stack, 'func', 'func', 'gen', true, 1, 1);
  stack.resume('gen');
  // ---          cur     active    !active   isLogging
  //              -----   ------    --------  ---------
  TEST(t, stack, 'gen', 'func gen', undef, false, 2, 1);
  stack.returnFrom('gen');
  // ---          cur     active    !active   isLogging
  //              -----   ------    --------  ---------
  TEST(t, stack, 'func', 'func', 'gen', true, 1, 1);
  stack.returnFrom('func');
  // ---          cur     active  !active       isLogging
  //              -----   ------  --------      ---------
  TEST(t, stack, undef, undef, 'func gen', false, 0, 0);
  return t.truthy(stack.isEmpty());
});

// ---------------------------------------------------------------------------
// test stack log
test("line 231", (t) => {
  var stack;
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
  return t.is(getStackLog(), `RESET STACK
ENTER 'func1' 13
	ENTER 'func2' 'abc',{"mean":42}
	YIELD FROM 'func2' 99
	RESUME 'func2'
	RETURN FROM 'func2' 'def'
RETURN FROM 'func1'`);
});
