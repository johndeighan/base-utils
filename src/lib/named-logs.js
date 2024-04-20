// named-logs.coffee
var hasProp = {}.hasOwnProperty;

import {
  undef,
  defined,
  notdefined,
  hasKey,
  isFunction
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

// ---------------------------------------------------------------------------
export var NamedLogs = class NamedLogs {
  constructor() {
    // --- {
    //        <name>: [<str>, ...],
    //        ...
    //        }
    this.hLogs = {};
  }

  // ..........................................................
  dump() {
    console.log("hLogs:");
    console.log(JSON.stringify(this.hLogs, null, 3));
  }

  // ..........................................................
  log(name, str) {
    if (hasKey(this.hLogs, name)) {
      this.hLogs[name].push(str);
    } else {
      this.hLogs[name] = [str];
    }
  }

  // ..........................................................
  // --- func is a function to filter lines returned
  //     returns a block, i.e. multi-line string
  getLogs(name, func = undef) {
    var lLogs;
    if (!hasKey(this.hLogs, name)) {
      return '';
    }
    lLogs = this.hLogs[name];
    if (defined(func)) {
      assert(isFunction(func), "filter not a function");
      return lLogs.filter(func).join("\n");
    } else {
      return lLogs.join("\n");
    }
  }

  // ..........................................................
  getAllLogs(func = undef) {
    var h, lAllLogs, name, ref;
    lAllLogs = [];
    ref = this.hLogs;
    for (name in ref) {
      if (!hasProp.call(ref, name)) continue;
      h = ref[name];
      lAllLogs.push(this.getLogs(name, func));
    }
    return lAllLogs.join("\n");
  }

  // ..........................................................
  clear(name) {
    if (hasKey(this.hLogs, name)) {
      delete this.hLogs[name];
    }
  }

  // ..........................................................
  clearAllLogs() {
    this.hLogs = {};
  }

};
