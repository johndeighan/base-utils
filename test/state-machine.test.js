// state-machine.test.coffee
import {
  undef,
  defined,
  notdefined,
  pass,
  escapeStr
} from '@jdeighan/base-utils';

import {
  suppressExceptionLogging
} from '@jdeighan/base-utils/exceptions';

import {
  UnitTester,
  equal,
  like,
  notequal,
  truthy,
  falsy,
  throws,
  succeeds
} from '@jdeighan/base-utils/utest';

import {
  StateMachine
} from '@jdeighan/base-utils/state-machine';

suppressExceptionLogging();

// ---------------------------------------------------------------------------
(function() {
  var mach;
  mach = new StateMachine('init', {
    flag: true,
    str: 'a string'
  });
  truthy(mach.inState('init'));
  falsy(mach.inState('not'));
  equal(mach.state, 'init');
  succeeds(() => {
    return mach.expectState('init', 'not');
  });
  throws(() => {
    return mach.expectState('xxx', 'not');
  });
  succeeds(() => {
    return mach.expectDefined('flag', 'str');
  });
  throws(() => {
    return mach.expectDefined('flag', 'str', 'notdef');
  });
  equal(mach.getVar('flag'), true);
  return equal(mach.getVar('str'), 'a string');
})();

// ---------------------------------------------------------------------------
// A very simple machine with states and transitions:

//    init --FIRST--> middle --SECOND--> final
(function() {
  var SimpleStateMachine, mach1, mach2, mach3;
  SimpleStateMachine = class SimpleStateMachine extends StateMachine {
    constructor() {
      super('init');
    }

    setState() {
      return croak("Don't call this class's setState() method");
    }

    FIRST() {
      this.expectState('init');
      return super.setState('middle');
    }

    SECOND() {
      this.expectState('middle');
      return super.setState('final');
    }

  };
  mach1 = new SimpleStateMachine();
  mach2 = new SimpleStateMachine();
  mach2.FIRST();
  mach3 = new SimpleStateMachine();
  mach3.FIRST();
  mach3.SECOND();
  truthy(mach1.inState('init'));
  truthy(mach2.inState('middle'));
  truthy(mach3.inState('final'));
  throws(() => {
    return mach1.SECOND();
  });
  succeeds(() => {
    return mach1.FIRST();
  });
  return throws(() => {
    return mach1.setState('some state');
  });
})();