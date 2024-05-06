// state-machine.test.coffee
import {
  undef,
  defined,
  notdefined,
  pass,
  escapeStr,
  OL,
  isArray
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  LOG,
  LOGVALUE
} from '@jdeighan/base-utils/log';

import * as lib from '@jdeighan/base-utils/utest';

Object.assign(global, lib);

import * as lib2 from '@jdeighan/base-utils/state-machine';

Object.assign(global, lib2);

// ---------------------------------------------------------------------------
(function() {
  var mach;
  mach = new StateMachine();
  truthy(mach.inState('start'));
  equal(mach.state, 'start');
  falsy(mach.inState('not'));
  succeeds(() => {
    return mach.expectState('start', 'not');
  });
  fails(() => {
    return mach.expectState('xxx', 'not');
  });
  return falsy(mach.allDefined('flag', 'str'));
})();

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
  fails(() => {
    return mach.expectState('xxx', 'not');
  });
  truthy(mach.allDefined('flag', 'str'));
  falsy(mach.allDefined('flag', 'str', 'notdef'));
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
      return this.state = 'middle';
    }

    SECOND() {
      this.expectState('middle');
      return this.state = 'final';
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
  fails(() => {
    return mach1.SECOND();
  });
  succeeds(() => {
    return mach1.FIRST();
  });
  return fails(() => {
    return mach1.setState('some state');
  });
})();

// ---------------------------------------------------------------------------
// A more comples machine that simulates parsing CoffeeScript
(function() {
  var CoffeeStateMachine, mach;
  CoffeeStateMachine = class CoffeeStateMachine extends StateMachine {
    constructor() {
      super();
      this.setVar('lLines', []);
    }

    START_IMPORT() {
      this.expectState('start');
      this.setState('importing', {
        lIdents: []
      });
      return this;
    }

    IDENT(name) {
      this.expectState('importing');
      this.appendVar('lIdents', name);
      return this;
    }

    END_IMPORT(source) {
      var identStr, lIdents;
      this.expectState('importing');
      lIdents = this.getVar('lIdents');
      assert(isArray(lIdents), `Not an array: ${OL(lIdents)}`);
      identStr = lIdents.join(',');
      this.appendVar('lLines', `import {${identStr}} from '${source}';`);
      this.setState('start', {
        lIdents: undef
      });
      return this;
    }

    ASSIGN(name, num) {
      this.expectState('start');
      return this.appendVar('lLines', `${name} = ${num};`);
    }

    getCode() {
      return this.getVar('lLines').join("\n");
    }

  };
  mach = new CoffeeStateMachine();
  mach.START_IMPORT();
  mach.IDENT('x');
  mach.IDENT('y');
  mach.END_IMPORT('@jdeighan/base-utils');
  mach.ASSIGN('x', 42);
  mach.ASSIGN('y', 13);
  truthy(mach.inState('start'));
  return equal(mach.getCode(), `import {x,y} from '@jdeighan/base-utils';
x = 42;
y = 13;`);
})();