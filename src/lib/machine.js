  // machine.coffee
import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  undef,
  defined,
  notdefined,
  OL,
  isString,
  isHash,
  isNonEmptyString
} from '@jdeighan/base-utils';

import {
  dbgEnter,
  dbgReturn,
  dbg
} from '@jdeighan/base-utils/debug';

// ---------------------------------------------------------------------------
export var Machine = class Machine {
  constructor(initialState) {
    dbgEnter('Machine', initialState);
    assert(isNonEmptyString(initialState), "not a non-empty string");
    this.state = initialState;
    this.hData = {};
    dbgReturn('Machine', this);
  }

  // ..........................................................
  inState(x) {
    return this.state === x;
  }

  // ..........................................................
  setState(newState, hNewData = {}) {
    assert(isHash(hNewData), "new data not a hash");
    Object.assign(this.hData, hNewData);
    this.state = newState;
  }

  // ..........................................................
  expectState(...lStates) {
    if (!lStates.includes(this.state)) {
      if (lStates.length === 1) {
        croak(`state is '${this.state}', expected ${lStates[0]}`);
      } else {
        croak(`state is '${this.state}', expected one of ${OL(lStates)}`);
      }
    }
  }

  // ..........................................................
  expectDefined(...lVarNames) {
    var i, len, varname;
    for (i = 0, len = lVarNames.length; i < len; i++) {
      varname = lVarNames[i];
      assert(defined(this.hData[varname]), `${varname} should be defined`);
    }
  }

  // ..........................................................
  var(varname) {
    return this.hData[varname];
  }

};
