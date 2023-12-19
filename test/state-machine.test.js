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
  utest.truthy(17, mach.inState('init'));
  utest.falsy(18, mach.inState('not'));
  utest.equal(19, mach.state, 'init');
  utest.succeeds(20, () => {
    return mach.expectState('init', 'not');
  });
  utest.fails(21, () => {
    return mach.expectState('xxx', 'not');
  });
  utest.succeeds(22, () => {
    return mach.expectDefined('flag', 'str');
  });
  utest.fails(23, () => {
    return mach.expectDefined('flag', 'str', 'notdef');
  });
  utest.equal(24, mach.getVar('flag'), true);
  return utest.equal(25, mach.getVar('str'), 'a string');
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
  utest.truthy(56, mach1.inState('init'));
  utest.truthy(57, mach2.inState('middle'));
  utest.truthy(58, mach3.inState('final'));
  utest.fails(60, () => {
    return mach1.SECOND();
  });
  utest.succeeds(61, () => {
    return mach1.FIRST();
  });
  return utest.fails(65, () => {
    return mach1.setState('some state');
  });
})();

//# sourceMappingURL=state-machine.test.js.map
