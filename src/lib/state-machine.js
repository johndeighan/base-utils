// state-machine.coffee
var hasProp = {}.hasOwnProperty;

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
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  dbgEnter,
  dbgReturn,
  dbg
} from '@jdeighan/base-utils/debug';

// ---------------------------------------------------------------------------
// You should override this class, adding methods (uppercase by convention)
//    that expect one or more states and assign a new state
// then only use those methods, not setState() directly
export var StateMachine = class StateMachine {
  constructor(state, hData = {}) {
    this.state = state;
    this.hData = hData;
    dbgEnter('StateMachine', this.state, this.hData);
    assert(isNonEmptyString(this.state), "not a non-empty string");
    assert(isHash(this.hData), "data not a hash");
    dbgReturn('StateMachine', this);
  }

  // ..........................................................
  inState(x) {
    return this.state === x;
  }

  // ..........................................................
  setState(newState, hNewData = {}) {
    var key, val;
    assert(isHash(hNewData), "new data not a hash");
    for (key in hNewData) {
      if (!hasProp.call(hNewData, key)) continue;
      val = hNewData[key];
      if (defined(val)) {
        this.hData[key] = val;
      } else {
        delete this.hData[key];
      }
    }
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
  getVar(varname) {
    this.expectDefined(varname);
    return this.hData[varname];
  }

  // ..........................................................
  setVar(varname, value) {
    this.hData[varname] = value;
  }

};
