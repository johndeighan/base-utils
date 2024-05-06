// state-machine.coffee
var hasProp = {}.hasOwnProperty;

import {
  undef,
  defined,
  notdefined,
  OL,
  isString,
  isHash,
  isArray,
  isNonEmptyString
} from '@jdeighan/base-utils';

import {
  LOG,
  LOGVALUE
} from '@jdeighan/base-utils/log';

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
// You should override this class,
//    adding methods (uppercase by convention)
//    that expect one or more states and assign a new state
// then only use those methods, not setState() directly
export var StateMachine = class StateMachine {
  constructor(state = 'start', hData = {}) {
    this.state = state;
    this.hData = hData;
    dbgEnter('StateMachine', this.state, this.hData);
    assert(isNonEmptyString(this.state), `not a non-empty string: ${OL(this.state)}`);
    assert(isHash(this.hData), "data not a hash");
    dbgReturn('StateMachine');
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
  defined(name) {
    return defined(this.hData[name]);
  }

  // ..........................................................
  allDefined(...lNames) {
    var i, len, name;
    for (i = 0, len = lNames.length; i < len; i++) {
      name = lNames[i];
      if (notdefined(this.hData[name])) {
        return false;
      }
    }
    return true;
  }

  // ..........................................................
  anyDefined(...lNames) {
    var i, len, name;
    for (i = 0, len = lNames.length; i < len; i++) {
      name = lNames[i];
      if (defined(this.hData[name])) {
        return true;
      }
    }
    return false;
  }

  // ..........................................................
  setVar(name, value) {
    this.hData[name] = value;
  }

  // ..........................................................
  appendVar(name, value) {
    var lItems;
    assert(this.defined(name), `${name} not defined`);
    lItems = this.hData[name];
    assert(isArray(lItems), `Not an array: ${OL(lItems)}`);
    lItems.push(value);
  }

  // ..........................................................
  getVar(name) {
    assert(this.allDefined(name), `${name} is not defined`);
    return this.hData[name];
  }

};
