// stack.coffee
var mainName;

import {
  undef,
  defined,
  notdefined,
  OL,
  OLS,
  deepCopy,
  warn,
  oneof,
  isString,
  isArray,
  isBoolean,
  isInteger,
  isFunctionName,
  isEmpty,
  nonEmpty,
  isNonEmptyString,
  spaces,
  tabs,
  getOptions
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  LOG,
  LOGVALUE,
  getMyLogs
} from '@jdeighan/base-utils/log';

mainName = '_MAIN_';

// ---------------------------------------------------------------------------
// --- export only to allow unit tests
export var Node = class Node {
  constructor(id1, funcName1, lArgs1, caller1, doLog1 = false) {
    this.id = id1;
    this.funcName = funcName1;
    this.lArgs = lArgs1;
    this.caller = caller1;
    this.doLog = doLog1;
    assert(isInteger(this.id), "id not an integer");
    assert(isFunctionName(this.funcName), `not a function name: ${OL(this.funcName)}`);
    assert(isArray(this.lArgs), "not an array");
    assert(notdefined(this.caller) || (this.caller instanceof Node), "Bad caller");
    this.lCalling = [];
    this.isYielded = false;
  }

};

// ---------------------------------------------------------------------------
export var getStackLog = () => {
  return getMyLogs() || '';
};

export var CallStack = (function() {
  // ---------------------------------------------------------------------------
  class CallStack {
    constructor(arg = undef) {
      assert(notdefined(arg), "args no longer allowed");
      this.reset();
    }

    // ........................................................................
    logCalls(flag = true) {
      this.doLogCalls = flag;
    }

    // ........................................................................
    debug(flag = true) {
      this.doDebugStack = flag;
    }

    // ........................................................................
    throwErrors(flag = true) {
      this.doThrowErrors = flag;
    }

    // ........................................................................
    log(str) {
      LOG(`${tabs(this.level)}${str}`);
    }

    // ........................................................................
    reset() {
      if (this.doLogCalls) {
        this.log("RESET STACK");
      }
      this.level = 0;
      this.logLevel = 0;
      this.root = this.getNewNode(mainName, [], undef);
      this.setCurFunc(this.root);
    }

    // ........................................................................
    getNewNode(funcName, lArgs, caller, doLog = false) {
      var id;
      assert(isNonEmptyString(funcName), "funcName not a non-empty string");
      id = CallStack.nextID;
      CallStack.nextID += 1;
      return new Node(id, funcName, deepCopy(lArgs), caller, doLog);
    }

    // ........................................................................
    setCurFunc(node) {
      assert(defined(node), "node is undef");
      this.curFunc = node;
      this.curFuncName = node.funcName;
    }

    // ........................................................................
    isEmpty() {
      return this.curFunc === this.root;
    }

    // ........................................................................
    nonEmpty() {
      return !this.isEmpty();
    }

    // ........................................................................
    isActive(funcName, node = this.root) {
      var i, len, ref;
      if (node.funcName === funcName) {
        return true;
      }
      ref = node.lCalling;
      for (i = 0, len = ref.length; i < len; i++) {
        node = ref[i];
        if (this.isActive(funcName, node) && !node.isYielded) {
          return true;
        }
      }
      return false;
    }

    // ........................................................................
    isLogging() {
      return this.curFunc.doLog;
    }

    // ........................................................................
    // ........................................................................
    enter(funcName, lArgs = [], doLog = false) {
      var node;
      assert(isNonEmptyString(funcName), "funcName not a non-empty string");
      if (this.doLogCalls) {
        if (lArgs.length === 0) {
          this.log(`ENTER ${OL(funcName)}`);
        } else {
          this.log(`ENTER ${OL(funcName)} ${OLS(lArgs)}`);
        }
      }
      node = this.getNewNode(funcName, lArgs, this.curFunc, doLog);
      this.curFunc.lCalling.push(node);
      this.setCurFunc(node);
      this.level += 1;
      if (doLog) {
        this.logLevel += 1;
      }
      if (this.doDebugStack) {
        this.dump(this.level);
      }
    }

    // ........................................................................
    returnFrom(...lParms) {
      var funcName, nArgs, val;
      // --- Always returns from the current function
      //     parameter is just a check for correct function name
      // --- We must use spread operator to distinguish between
      //        returnFrom('func', undef)
      //        returnFrom('func')
      nArgs = lParms.length;
      [funcName, val] = lParms;
      // --- Adjust levels before logging
      assert(this.level > 0, "dec level when level is 0");
      this.level -= 1;
      if (this.isLogging()) {
        assert(this.logLevel > 0, "dec logLevel when logLevel is 0");
        this.logLevel -= 1;
      }
      if (this.doLogCalls) {
        if (nArgs === 1) {
          this.log(`RETURN FROM ${OL(funcName)}`);
        } else {
          this.log(`RETURN FROM ${OL(funcName)} ${OL(val)}`);
        }
      }
      assert((nArgs === 1) || (nArgs === 2), `Bad num args: ${nArgs}`);
      assert(isFunctionName(funcName), `Not a function name: ${funcName}`);
      assert(this.curFuncName !== mainName, `Return from ${mainName}`);
      assert(funcName === this.curFuncName, `return from ${funcName}, but cur func is ${this.curFuncName}`);
      this.setCurFunc(this.curFunc.caller);
      assert(this.curFunc.lCalling.length > 0, "calling stack empty");
      this.curFunc.lCalling.pop();
      if (this.doDebugStack) {
        this.dump(this.level);
      }
    }

    // ........................................................................
    yield(...lArgs) {
      var funcName, nArgs, newCurFunc, val;
      // --- We must use spread operator to distinguish between
      //        yield('func', undef)
      //        yield('func')
      nArgs = lArgs.length;
      assert((nArgs === 1) || (nArgs === 2), `Bad num args: ${nArgs}`);
      [funcName, val] = lArgs;
      // --- Adjust levels before logging
      this.level -= 1;
      if (this.isLogging()) {
        this.logLevel -= 1;
      }
      if (this.doLogCalls) {
        if (nArgs === 1) {
          this.log(`YIELD FROM ${OL(funcName)}`);
        } else {
          this.log(`YIELD FROM ${OL(funcName)} ${OL(val)}`);
        }
      }
      assert(isFunctionName(funcName), `Not a function name: ${funcName}`);
      assert(this.curFuncName !== mainName, `yield from ${mainName}`);
      assert(funcName === this.curFuncName, `yield ${funcName}, but cur func is ${this.curFuncName}`);
      this.curFunc.isYielded = true;
      newCurFunc = this.curFunc.caller;
      while (newCurFunc.isYielded) {
        newCurFunc = newCurFunc.caller;
      }
      this.setCurFunc(newCurFunc);
      if (this.doDebugStack) {
        this.dump(this.level);
      }
    }

    // ........................................................................
    resume(funcName) {
      if (this.doLogCalls) {
        this.log(`RESUME ${OL(funcName)}`);
      }
      assert(isFunctionName(funcName), "Not a function name");
      this.setCurFunc(this.curFunc.lCalling[this.curFunc.lCalling.length - 1]);
      assert(this.curFunc.funcName === funcName, `resume ${funcName} but resumed @curFunc.funcName`);
      assert(this.curFunc.isYielded, `resume ${funcName} but it's not yielded`);
      this.curFunc.isYielded = false;
      this.level += 1;
      if (this.curFunc.doLog) {
        this.logLevel += 1;
      }
      if (this.doDebugStack) {
        this.dump(this.level);
      }
    }

    // ........................................................................
    // ........................................................................
    decLevel(doLog) {
      this.level -= 1;
      if (doLog) {
        this.logLevel -= 1;
      }
    }

    // ........................................................................
    stackAssert(cond, msg) {
      if (!cond) {
        if (this.doThrowErrors) {
          croak(`${msg}\n${this.dumpStr(this.root)}`);
        } else {
          warn(`${msg}\n${this.dumpStr(this.root)}`);
        }
      }
    }

    // ........................................................................
    dump(level = 0, oneIndent = spaces(5)) {
      var prefix;
      prefix = oneIndent.repeat(level);
      console.log(prefix + '-------- CALL STACK --------');
      console.log(prefix + `(curFunc = ${this.curFuncName})`);
      console.log(this.dumpStr(this.root, level, oneIndent));
      console.log(prefix + '----------------------------');
    }

    // ........................................................................
    dumpStr(node, level, oneIndent) {
      var i, lLines, len, ref, str;
      assert(node instanceof Node, "not a Node obj in dump()");
      lLines = [];
      lLines.push(oneIndent.repeat(level) + this.callStr(node));
      assert(isArray(node.lCalling), "not an array");
      ref = node.lCalling;
      for (i = 0, len = ref.length; i < len; i++) {
        node = ref[i];
        lLines.push(this.dumpStr(node, level + 1, oneIndent));
      }
      str = lLines.join("\n");
      return str;
    }

    // ........................................................................
    callStr(hNode) {
      var caller, callerStr, callingStr, curSym, lCalling, str, sym;
      if (hNode === this.curFunc) {
        curSym = '> ';
      } else {
        curSym = '. ';
      }
      ({caller, lCalling} = hNode);
      assert(isArray(lCalling), "lCalling not an array");
      if (defined(caller)) {
        callerStr = caller.id.toString(10);
      } else {
        callerStr = '-';
      }
      callingStr = this.idStr(lCalling);
      if (hNode.doLog) {
        if (hNode.isYielded) {
          sym = ' LY';
        } else {
          sym = ' L';
        }
      } else {
        if (hNode.isYielded) {
          sym = ' Y';
        } else {
          sym = '';
        }
      }
      str = `${curSym}[${hNode.id}] ${hNode.funcName} ${callerStr} ${callingStr} ${sym}`;
      return str;
    }

    // ........................................................................
    idStr(lNodes) {
      var i, lIDs, len, node, str;
      assert(isArray(lNodes), "not an array in idStr()");
      if (lNodes.length === 0) {
        return '-';
      }
      lIDs = [];
      for (i = 0, len = lNodes.length; i < len; i++) {
        node = lNodes[i];
        lIDs.push(node.id.toString(10));
      }
      str = lIDs.join(',');
      assert(defined(str), "str not defined");
      assert(str !== 'undefined', "str is 'undefined'");
      return str;
    }

  };

  CallStack.nextID = 1;

  return CallStack;

}).call(this);
