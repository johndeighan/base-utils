// parse-cmd-args.test.coffee
import {
  undef,
  defined,
  notdefined
} from '@jdeighan/base-utils';

import {
  LOG
} from '@jdeighan/base-utils/log';

import {
  setDebugging
} from '@jdeighan/base-utils/debug';

import * as lib from '@jdeighan/base-utils/parse-cmd-args';

Object.assign(global, lib);

import {
  UnitTester
} from '@jdeighan/base-utils/utest';

// ---------------------------------------------------------------------------
// --- test parseCmdArgs() without hExpect
(() => {
  var u;
  u = new UnitTester();
  u.transformValue = (argStr) => {
    return parseCmdArgs({argStr});
  };
  u.equal('-ab why', {
    a: true,
    b: true,
    _: ['why']
  });
  u.equal('-ab="a string" why not', {
    ab: "a string",
    _: ['why', 'not']
  });
  u.equal('-glob=**/*.coffee', {
    glob: '**/*.coffee'
  });
  return u.equal('-glob="**/*.coffee"', {
    glob: '**/*.coffee'
  });
})();

// ---------------------------------------------------------------------------
(() => {
  var u;
  u = new UnitTester();
  u.transformValue = (argStr) => {
    return parseCmdArgs({
      argStr,
      hExpect: {
        glob: 'string'
      }
    });
  };
  u.equal('-glob=**/*.coffee', {
    glob: '**/*.coffee'
  });
  return u.equal('-glob="**/*.coffee"', {
    glob: '**/*.coffee'
  });
})();

// ---------------------------------------------------------------------------
// --- test invalid 'hExpect' option
(() => {
  var u;
  u = new UnitTester();
  u.fails(() => {
    return parseCmdArgs({
      hExpect: {
        x: 'badtype'
      }
    });
  });
  u.fails(() => {
    return parseCmdArgs({
      hExpect: {
        _: 'non-array'
      }
    });
  });
  u.fails(() => {
    return parseCmdArgs({
      hExpect: {
        _: [3] // --- should have length 2
      }
    });
  });
  u.succeeds(() => {
    return parseCmdArgs({
      hExpect: {
        _: [
          undef,
          undef // --- OK
        ]
      }
    });
  });
  u.fails(() => {
    return parseCmdArgs({
      hExpect: {
        _: [
          'a',
          undef // --- non-integer
        ]
      }
    });
  });
  u.succeeds(() => {
    return parseCmdArgs({
      hExpect: {
        _: [
          0,
          3 // --- OK
        ]
      }
    });
  });
  u.fails(() => {
    return parseCmdArgs({
      hExpect: {
        _: [
          3,
          2 // --- min > max
        ]
      }
    });
  });
  return u.succeeds(() => {
    return parseCmdArgs({
      hExpect: {
        _: [
          0,
          3 // --- OK
        ],
        debug: /^full|list|json$/ // --- regexp OK
      }
    });
  });
})();

// ---------------------------------------------------------------------------
// --- test option 'hExpect'
(() => {
  var hExpect, u;
  hExpect = {
    f: 'boolean',
    vv: 'boolean',
    v: 'boolean',
    name: 'string',
    debug: /^full|list|json$/s, // --- a regexp
    i: 'integer',
    n: 'number',
    _: [1, 3]
  };
  u = new UnitTester();
  u.transformValue = (argStr) => {
    return parseCmdArgs({argStr, hExpect});
  };
  u.equal('-fv why', {
    f: true,
    v: true,
    _: ['why']
  });
  u.equal('-name="a string" nonoption', {
    name: "a string",
    _: ['nonoption']
  });
  u.equal('-f nonoption', {
    f: true,
    _: ['nonoption']
  });
  u.equal('-f=false nonoption', {
    f: false,
    _: ['nonoption']
  });
  u.equal('-f="false" nonoption', {
    f: false,
    _: ['nonoption']
  });
  // --- -vv is taken as 2 flags, flag 'v' is not expected
  u.fails(() => {
    return parseCmdArgs({
      argStr: '-vv nonoption',
      hExpect
    });
  });
  u.equal('-vv=false nonoption', {
    vv: false,
    _: ['nonoption']
  });
  u.equal('-vv="false" nonoption', {
    vv: false,
    _: ['nonoption']
  });
  // --- -name must be given a value
  u.fails(() => {
    return parseCmdArgs({
      argStr: '-name nonoption',
      hExpect
    });
  });
  // --- but value can be empty
  u.equal('-name="" nonoption', {
    name: '',
    _: ['nonoption']
  });
  u.equal('-name=frog nonoption', {
    name: 'frog',
    _: ['nonoption']
  });
  // --- there must be at least one non-option
  u.fails(() => {
    return parseCmdArgs({
      argStr: '-f',
      hExpect
    });
  });
  // --- there can't be more than 3 non-options
  u.fails(() => {
    return parseCmdArgs({
      argStr: 'a b c d',
      hExpect
    });
  });
  // --- set all options
  u.equal('-f -vv=false -name=John -i=3 -n=3.5 opt1 opt2 opt3', {
    f: true,
    vv: false,
    name: 'John',
    i: 3,
    n: 3.5,
    _: ['opt1', 'opt2', 'opt3']
  });
  // --- test numeric options
  u.fails(() => {
    return parseCmdArgs({
      argStr: 'slip -i=abc',
      hExpect
    });
  });
  // --- test numeric options
  u.fails(() => {
    return parseCmdArgs({
      argStr: 'slip -i=3.5',
      hExpect
    });
  });
  // --- test numeric options
  u.fails(() => {
    return parseCmdArgs({
      argStr: 'slip -n=abc',
      hExpect
    });
  });
  // --- test regexp
  u.succeeds(() => {
    return parseCmdArgs({
      argStr: 'nonoption -debug=json',
      hExpect
    });
  });
  // --- test regexp
  u.succeeds(() => {
    return parseCmdArgs({
      argStr: 'nonoption -debug=full',
      hExpect
    });
  });
  // --- test regexp
  u.fails(() => {
    return parseCmdArgs({
      argStr: 'nonoption -debug=abc',
      hExpect
    });
  });
  // --- test regexp
  return u.fails(() => {
    return parseCmdArgs({
      argStr: 'nonoption -debug=" full"',
      hExpect
    });
  });
})();

// ---------------------------------------------------------------------------
// --- test quoted non-options:
(() => {
  var hResult, u;
  hResult = parseCmdArgs({
    argStr: ' -m "coffee -c $file" ',
    hExpect: {
      _: [
        1,
        1 // the command to run
      ],
      m: 'boolean',
      dir: 'string',
      pattern: 'string'
    }
  });
  u = new UnitTester();
  return u.equal(hResult, {
    _: ["coffee -c $file"],
    m: true
  });
})();

// ---------------------------------------------------------------------------
// --- test JSON array:
(() => {
  var hResult, u;
  hResult = parseCmdArgs({
    argStr: ' -m -option=\'["a","b"]\' ',
    hExpect: {
      _: [
        0,
        0 // no non-options
      ],
      m: 'boolean',
      option: 'json'
    }
  });
  u = new UnitTester();
  return u.equal(hResult, {
    m: true,
    option: ['a', 'b']
  });
})();

// ---------------------------------------------------------------------------
// --- test JSON hash:
(() => {
  var hResult, u;
  hResult = parseCmdArgs({
    argStr: ' -option=\'{"a":1, "b":2}\' ',
    hExpect: {
      _: [
        0,
        0 // no non-options
      ],
      m: 'boolean',
      option: 'json'
    }
  });
  u = new UnitTester();
  return u.equal(hResult, {
    option: {
      a: 1,
      b: 2
    }
  });
})();