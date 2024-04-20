  // scope.coffee
import {
  undef,
  deepCopy
} from '@jdeighan/base-utils';

import {
  LOG
} from '@jdeighan/base-utils/log';

// ---------------------------------------------------------------------------
export var Scope = class Scope {
  constructor(name, lSymbols = []) {
    this.name = name;
    this.lSymbols = deepCopy(lSymbols);
  }

  // ..........................................................
  add(symbol) {
    if (!this.lSymbols.includes(symbol)) {
      this.lSymbols.push(symbol);
    }
  }

  // ..........................................................
  has(symbol) {
    return this.lSymbols.includes(symbol);
  }

  // ..........................................................
  dump() {
    var i, len, ref, symbol;
    ref = this.lSymbols;
    for (i = 0, len = ref.length; i < len; i++) {
      symbol = ref[i];
      LOG(`      ${symbol}`);
    }
  }

};
