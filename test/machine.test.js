  // machine.test.coffee
import {
  undef,
  defined,
  notdefined,
  pass,
  escapeStr
} from '@jdeighan/base-utils';

import {
  utest
} from '@jdeighan/base-utils/utest';

import {
  StateMachine
} from '@jdeighan/base-utils/machine';

// ---------------------------------------------------------------------------
(function() {
  var mach;
  mach = new StateMachine('init');
  utest.truthy(16, mach.inState('init'));
  utest.falsy(17, mach.inState('not'));
  return utest.equal(18, mach.state, 'init');
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

    FIRST() {
      this.expectState('init');
      return this.setState('middle');
    }

    SECOND() {
      this.expectState('middle');
      return this.setState('final');
    }

  };
  mach1 = new SimpleStateMachine();
  mach2 = new SimpleStateMachine();
  mach2.FIRST();
  mach3 = new SimpleStateMachine();
  mach3.FIRST();
  mach3.SECOND();
  utest.truthy(47, mach1.inState('init'));
  utest.truthy(48, mach2.inState('middle'));
  utest.truthy(49, mach3.inState('final'));
  utest.fails(51, () => {
    return mach1.SECOND();
  });
  return utest.succeeds(52, () => {
    return mach1.FIRST();
  });
})();
