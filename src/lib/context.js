// context.coffee
var lBuiltins;

import {
  undef,
  deepCopy,
  words,
  OL,
  isString
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  LOG
} from '@jdeighan/base-utils/log';

import {
  dbg,
  dbgEnter,
  dbgReturn
} from '@jdeighan/base-utils/debug';

import {
  Scope
} from '@jdeighan/base-utils/scope';

lBuiltins = words("parseInt process JSON import console", "Function String Number Boolean Object Set", "Math Date");

// ---------------------------------------------------------------------------
export var Context = class Context {
  constructor() {
    this.globalScope = new Scope('global', lBuiltins);
    this.lScopes = [this.globalScope];
    this.currentScope = this.globalScope;
  }

  // ..........................................................
  atGlobalLevel() {
    var result;
    result = this.currentScope === this.globalScope;
    if (result) {
      assert(this.lScopes.length === 1, "more than one scope");
      return true;
    } else {
      return false;
    }
  }

  // ..........................................................
  add(...lSymbols) {
    var i, len, symbol;
    dbgEnter("Context.add", lSymbols);
    for (i = 0, len = lSymbols.length; i < len; i++) {
      symbol = lSymbols[i];
      assert(isString(symbol), `Not a string: ${symbol}`);
      this.currentScope.add(symbol);
    }
    dbgReturn("Context.add");
  }

  // ..........................................................
  addGlobal(symbol) {
    dbgEnter("Context.addGlobal", symbol);
    this.globalScope.add(symbol);
    dbgReturn("Context.addGlobal");
  }

  // ..........................................................
  has(symbol) {
    var i, len, ref, scope;
    ref = this.lScopes;
    for (i = 0, len = ref.length; i < len; i++) {
      scope = ref[i];
      if (scope.has(symbol)) {
        return true;
      }
    }
    return false;
  }

  // ..........................................................
  beginScope(name = undef, lSymbols = []) {
    var newScope;
    dbgEnter("beginScope", name, lSymbols);
    newScope = new Scope(name, lSymbols);
    this.lScopes.unshift(newScope);
    this.currentScope = newScope;
    dbgReturn("beginScope");
  }

  // ..........................................................
  endScope() {
    dbgEnter("endScope");
    this.lScopes.shift(); // remove ended scope
    this.currentScope = this.lScopes[0];
    dbgReturn("endScope");
  }

  // ..........................................................
  dump() {
    var i, len, ref, scope;
    ref = this.lScopes;
    for (i = 0, len = ref.length; i < len; i++) {
      scope = ref[i];
      LOG("   SCOPE:");
      scope.dump();
    }
  }

};
