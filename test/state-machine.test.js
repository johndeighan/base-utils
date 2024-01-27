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
  utest
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
  utest.truthy(mach.inState('init'));
  utest.falsy(mach.inState('not'));
  utest.equal(mach.state, 'init');
  utest.succeeds(() => {
    return mach.expectState('init', 'not');
  });
  utest.throws(() => {
    return mach.expectState('xxx', 'not');
  });
  utest.succeeds(() => {
    return mach.expectDefined('flag', 'str');
  });
  utest.throws(() => {
    return mach.expectDefined('flag', 'str', 'notdef');
  });
  utest.equal(mach.getVar('flag'), true);
  return utest.equal(mach.getVar('str'), 'a string');
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
  utest.truthy(mach1.inState('init'));
  utest.truthy(mach2.inState('middle'));
  utest.truthy(mach3.inState('final'));
  utest.throws(() => {
    return mach1.SECOND();
  });
  utest.succeeds(() => {
    return mach1.FIRST();
  });
  return utest.throws(() => {
    return mach1.setState('some state');
  });
})();

//# sourceMappingURL=state-machine.test.js.map
