  // parse-cmd-args.coffee
var lTypes,
  hasProp = {}.hasOwnProperty;

import {
  undef,
  defined,
  notdefined,
  getOptions,
  LOG,
  OL,
  hasKey,
  words,
  isHash,
  isArray,
  isNumber,
  isInteger,
  isString,
  isBoolean
} from '@jdeighan/base-utils';

import {
  dbgEnter,
  dbgReturn,
  dbg,
  debugDebug
} from '@jdeighan/base-utils/debug';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  parse
} from '@jdeighan/base-utils/cmd-args';

lTypes = words('boolean string number integer json');

// ---------------------------------------------------------------------------
export var argStrFromArgv = () => {
  var lQuoted, lTrueArgs, result;
  dbgEnter('argStrFromArgv');
  lTrueArgs = process.argv.slice(2);
  dbg('lTrueArgs', lTrueArgs);
  lQuoted = lTrueArgs.map((str) => {
    var _, lMatches, name, value;
    if (str.match(/\s/)) {
      if (lMatches = str.match(/^\-([A-Za-z_][A-Za-z0-9_]+)\=(.*)$/)) {
        [_, name, value] = lMatches;
        return `-${name}=\"${value}\"`;
      } else {
        return '"' + str + '"';
      }
    } else {
      return str;
    }
  });
  dbg('lQuoted', lQuoted);
  result = lQuoted.join(' ');
  dbgReturn('argStrFromArgv', result);
  return result;
};

// ---------------------------------------------------------------------------
// --- option 'expect' should be a hash, like:
//        {
//           <name>: <type>
//           _: [<int>, <int>]  # min, max
//           }
//        <type> can be:
//           boolean
//           string
//           number
//           integer
//           json
export var parseCmdArgs = (hOptions = {}) => {
  var argStr, hExpect, hResult, key, max, maxNonOptions, min, minNonOptions, name, numNonOptions, type, value;
  dbgEnter('parseCmdArgs', hOptions);
  ({argStr, hExpect} = getOptions(hOptions, {
    argStr: undef,
    hExpect: undef
  }));
  // --- Check if hExpect option is valid
  minNonOptions = 0;
  maxNonOptions = 2e308;
  if (defined(hExpect)) {
    assert(isHash(hExpect), "hExpect is not a hash");
    for (key in hExpect) {
      if (!hasProp.call(hExpect, key)) continue;
      value = hExpect[key];
      if (key === '_') {
        assert(isArray(value), `key '_', value = ${OL(value)}`);
        assert(value.length === 2, "Bad '_' key");
        [min, max] = value;
        if (defined(min)) {
          assert(isInteger(min, {
            min: 0
          }), `Bad '_' key, min = ${OL(min)}`);
          minNonOptions = min;
        }
        if (defined(max)) {
          assert(isInteger(max, {
            min: 0
          }), `Bad '_' key, max = ${OL(max)}`);
          maxNonOptions = max;
          if (defined(min)) {
            assert(min <= max, `min = ${OL(min)}, max = ${OL(max)}`);
          }
        }
      } else {
        assert(lTypes.includes(value), `Bad type for ${key}`);
      }
    }
  }
  if (notdefined(argStr)) {
    argStr = argStrFromArgv();
  }
  dbg(`arg str = '${argStr}'`);
  hResult = parse(argStr);
  dbg('hResult', hResult);
  assert(isHash(hResult), `hResult = ${OL(hResult)}`);
  if (hasKey(hResult, '_')) {
    numNonOptions = hResult._.length;
  } else {
    numNonOptions = 0;
  }
  assert(numNonOptions >= minNonOptions, `${numNonOptions} non options < min ${min}`, hResult, 'hResult');
  assert(numNonOptions <= maxNonOptions, `${numNonOptions} non options > max ${max}`, hResult, 'hResult');
  for (name in hResult) {
    if (!hasProp.call(hResult, name)) continue;
    value = hResult[name];
    dbg(`FOUND ${name} = ${OL(value)}`);
    if (name === '_') {
      continue;
    } else if (isBoolean(value)) {
      if (defined(hExpect)) {
        assert(hExpect[name] === 'boolean', `boolean ${name} not expected`);
      }
    } else {
      assert(isString(value), `value = ${OL(value)}`);
      if (defined(hExpect)) {
        type = hExpect[name];
        if (defined(type)) {
          hResult[name] = getVal(name, type, value);
        } else {
          croak(`Unexpected option: ${OL(name)}`);
        }
      }
    }
  }
  dbgReturn('parseCmdArgs', hResult);
  return hResult;
};

// ---------------------------------------------------------------------------
export var getVal = (name, type, value) => {
  switch (type) {
    case 'boolean':
      if (isBoolean(value)) {
        return value;
      } else if (value === 'true') {
        return true;
      } else if (value === 'false') {
        return false;
      } else {
        croak(`${name} should be 'true' or 'false' (${OL(value)})`);
      }
      break;
    case 'string':
      return value;
    case 'number':
      if (value.match(/^\d+(\.\d*)$/)) {
        return Number(value);
      } else {
        croak(`option ${name} not a number`);
      }
      break;
    case 'integer':
      if (value.match(/^\d+$/)) {
        return parseInt(value);
      } else {
        croak(`option ${name} not an integer`);
      }
      break;
    case 'json':
      return JSON.parse(value);
  }
};

//# sourceMappingURL=parse-cmd-args.js.map
