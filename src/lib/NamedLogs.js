// NamedLogs.coffee
var hasProp = {}.hasOwnProperty;

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
  isNonEmptyString,
  isHash
} from '@jdeighan/base-utils';

// ---------------------------------------------------------------------------
export var NamedLogs = class NamedLogs {
  constructor(hDefaultKeys = {}) {
    this.hDefaultKeys = hDefaultKeys;
    // --- <name> must be undef or a non-empty string
    this.hLogs = {}; // --- { <name>: { lLogs: [<str>, ...], ... }}
  }

  
    // ..........................................................
  dump() {
    console.log("hDefaultKeys:");
    console.log(JSON.stringify(this.hDefaultKeys, null, 3));
    console.log("hLogs:");
    console.log(JSON.stringify(this.hLogs, null, 3));
  }

  // ..........................................................
  log(name, str) {
    var h;
    h = this.getHash(name);
    h.lLogs.push(str);
  }

  // ..........................................................
  getLogs(name) {
    var h;
    h = this.getHash(name);
    return h.lLogs.join("\n");
  }

  // ..........................................................
  getAllLogs() {
    var h, lAllLogs, name, ref;
    lAllLogs = [];
    ref = this.hLogs;
    for (name in ref) {
      if (!hasProp.call(ref, name)) continue;
      h = ref[name];
      lAllLogs.push(this.getLogs(name));
    }
    return lAllLogs.join("\n");
  }

  // ..........................................................
  clear(name) {
    var h;
    h = this.getHash(name);
    h.lLogs = [];
  }

  // ..........................................................
  clearAllLogs() {
    var h, name, ref;
    ref = this.hLogs;
    for (name in ref) {
      if (!hasProp.call(ref, name)) continue;
      h = ref[name];
      h.lLogs = [];
    }
  }

  // ..........................................................
  setKey(name, key, value) {
    var h;
    h = this.getHash(name);
    h[key] = value;
  }

  // ..........................................................
  getKey(name, key) {
    var h, result;
    h = this.getHash(name);
    assert(isHash(h), `in getKey(), h = ${OL(h)}`);
    if (h.hasOwnProperty(key)) {
      result = h[key];
      return result;
    } else if (this.hDefaultKeys.hasOwnProperty(key)) {
      result = this.hDefaultKeys[key];
      return result;
    } else {
      return undef;
    }
  }

  // ..........................................................
  getHash(name) {
    assert(name !== 'undef', "cannot use key 'undef'");
    if (notdefined(name)) {
      name = 'undef';
    }
    assert(isNonEmptyString(name), `name = '${OL(name)}'`);
    assert(name !== 'lLogs', "cannot use key 'lLogs'");
    if (!this.hLogs.hasOwnProperty(name)) {
      this.hLogs[name] = {
        lLogs: []
      };
    }
    return this.hLogs[name];
  }

};
