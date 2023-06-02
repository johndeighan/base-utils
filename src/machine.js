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
    this.curState = initialState;
    this.hTransitions = {}; // <state> -> <event> -> {nextState, callback}
    this.anyCallback = undef;
    this.addState(initialState);
    dbgReturn('Machine', this);
  }

  // ..........................................................
  on(state, event, nextState, callback = undef) {
    assert(this.isState(state), `not a state: ${state}`);
    this.addState(nextState);
    if (defined(this.hTransitions[state][event])) {
      croak(`transition for (${state},${event} already defined`);
    } else {
      this.hTransitions[state][event] = {nextState, callback};
    }
  }

  // ..........................................................
  onAny(callback) {
    assert(isFunction(callback), "callback not a function");
    this.anyCallback = callback;
  }

  // ..........................................................
  addState(state) {
    assert(isNonEmptyString(state), "not a non-empty string");
    if (notdefined(this.hTransitions[state])) {
      this.hTransitions[state] = {};
    }
  }

  // ..........................................................
  isState(state) {
    return defined(this.hTransitions[state]);
  }

  // ..........................................................
  emit(event) {
    var hTrans;
    hTrans = this.hTransitions[this.curState][event];
    assert(defined(hTrans), `bad event ${event} in state ${this.curState}`);
    this.curState = hTrans.nextState;
    if (defined(hTrans.callback)) {
      hTrans.callback(this.curState, event);
    }
    if (defined(this.anyCallback)) {
      this.anyCallback(this.curState, event);
    }
  }

};
