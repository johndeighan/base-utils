// peggy.coffee
var MyTracer, Tracer, hCodePreProcessors;

import peggy from 'peggy';

import {
  undef,
  defined,
  notdefined,
  pass,
  OL,
  getOptions,
  hasKey,
  isString,
  isFunction,
  isArray,
  isHash,
  isEmpty,
  nonEmpty,
  toArray,
  toBlock,
  isArrayOfStrings,
  removeEmptyLines,
  isNonEmptyString,
  untabify,
  centeredText
} from '@jdeighan/base-utils';

import {
  LOG
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

import {
  isIndented,
  undented,
  splitLine,
  indentLevel,
  indented
} from '@jdeighan/base-utils/indent';

import {
  isFile,
  slurp,
  barf,
  withExt,
  readTextFile
} from '@jdeighan/base-utils/fs';

import {
  brew
} from '@jdeighan/base-utils/coffee';

hCodePreProcessors = {
  coffee: (code) => {
    var _, jsCode;
    [jsCode, _] = brew(code);
    return jsCode;
  },
  javascript: (code) => {
    return code;
  }
};

// ---------------------------------------------------------------------------
export var addCodePreProcessor = (name, func) => {
  assert(isNonEmptyString(name), `Bad name: ${OL(name)}`);
  assert(!hasKey(hCodePreProcessors, name), `Exists: ${OL(name)}`);
  assert(isFunction(func), `Not a function: ${OL(func)}`);
  hCodePreProcessors[name] = func;
};

// ---------------------------------------------------------------------------
export var peggifyFile = (filePath) => {
  var hMetaData, jsCode, lLines, sourceMap;
  dbgEnter('peggifyFile', filePath);
  ({hMetaData, lLines} = readTextFile(filePath));
  dbg('hMetaData', hMetaData);
  [jsCode, sourceMap] = peggify(lLines, {
    source: filePath,
    hMetaData
  });
  barf(jsCode, withExt(filePath, '.js'));
  if (defined(sourceMap)) {
    barf(sourceMap, withExt(filePath, '.js.map'));
  }
  dbgReturn('peggifyFile');
};

// ---------------------------------------------------------------------------
// --- peggyCode can be a string or array of strings
//     Valid options:
//        source - relative or absolute path to source file
//        type - usually 'coffee', may also appear in hMetaData
//        hMetaData - may contain key 'type' (usually 'coffee')
export var peggify = (peggyCode, hOptions) => {
  var err, h, hMetaData, jsCode, result, source, srcNode, type;
  dbgEnter('peggify', peggyCode, hOptions);
  ({source, type, hMetaData} = getOptions(hOptions, {
    source: undef,
    type: undef,
    hMetaData: {}
  }));
  assert(isHash(hMetaData), `hMetaData not a hash: ${OL(hMetaData)}`);
  // --- determine type, if any
  if (defined(type)) {
    assert(notdefined(hMetaData.type) || (hMetaData.type === type), "Conflicting types");
  } else if (defined(hMetaData.type)) {
    type = hMetaData.type;
  }
  dbg(`type = ${OL(type)}`);
  // --- preprocess peggyCode if required
  //        - ensure peggyCode ends up as a string
  if (defined(type)) {
    if (isString(peggyCode)) {
      peggyCode = convertToJS(toArray(peggyCode), type, hMetaData);
    } else if (isArrayOfStrings(peggyCode)) {
      peggyCode = convertToJS(peggyCode, type, hMetaData);
    } else {
      croak("Bad peggy code");
    }
    dbg("JSified peggy code", peggyCode);
  } else if (isArray(peggyCode)) {
    peggyCode = toBlock(peggyCode);
  }
  try {
    if (defined(source)) {
      assert(isFile(source), `Not a file: ${OL(source)}`);
      srcNode = peggy.generate(peggyCode, {
        grammarSource: source,
        allowedStartRules: ['*'],
        format: 'es',
        output: 'source-and-map',
        trace: true // compile w/tracing capability
      });
      h = srcNode.toStringWithSourceMap();
      result = [h.code, h.map.toString()];
    } else {
      jsCode = peggy.generate(peggyCode, {
        allowedStartRules: ['*'],
        format: 'es',
        output: 'source',
        trace: true // compile w/tracing capability
      });
      result = [jsCode, undef];
    }
  } catch (error) {
    err = error;
    console.log(centeredText('peggy generate failed', 74, 'char=-'));
    console.log(untabify(peggyCode));
    console.log('-'.repeat(74));
    throw err;
  }
  dbgReturn('peggify', result);
  return result;
};

// ---------------------------------------------------------------------------
export var convertCodeToJS = (code, type) => {
  var err, jsCode;
  dbgEnter('convertCodeToJS', code, type);
  code = toBlock(code);
  try {
    jsCode = hCodePreProcessors[type](code);
  } catch (error) {
    err = error;
    console.log(`ERROR: Unable to convert ${type} code to JS`);
    console.log('-'.repeat(40));
    console.log(code);
    console.log('-'.repeat(40));
    jsCode = '';
  }
  dbgReturn('convertCodeToJS', jsCode);
  return jsCode;
};

// ---------------------------------------------------------------------------
// --- input may be a string or array of strings
// --- returns a block of JavaScript code
export var convertToJS = (lLines, type, hMetaData) => {
  var ch, get, getCodeLines, hRules, headerLine, jsCode, lCode, lExprLines, lPeggy, matchExpr, more, name, next, nextLevel, result, skip;
  dbgEnter('convertToJS', lLines, type, hMetaData);
  assert(isArray(lLines), `lLines = ${OL(lLines)}`);
  assert(isHash(hMetaData), `Not a hash: ${OL(hMetaData)}`);
  lLines = removeEmptyLines(lLines);
  assert(isArrayOfStrings(lLines), `not an array of strings: ${OL(lLines)}`);
  // --- NOTE: There are NO empty lines in lLines !!!
  //     We will remove lines from lLines as they're processed
  assert(isFunction(hCodePreProcessors[type]), `Unknown type: ${OL(type)}`);
  // --- Define some utility functions -----------------

  // --- are there more lines to process?
  more = () => {
    return lLines.length > 0;
  };
  // --- what is the next line?
  next = () => {
    return lLines[0];
  };
  // --- what is the level of the next line?
  nextLevel = () => {
    if (next() === undef) {
      return 0;
    }
    return indentLevel(lLines[0]);
  };
  // --- get the next line, removing it from lLines
  get = () => {
    return lLines.shift();
  };
  // --- remove the next line without returning it
  skip = () => {
    lLines.shift();
  };
  // --- get a block of code, as an array, undented
  getCodeLines = (minLevel) => {
    var lCodeLines, result;
    dbgEnter('getCodeLines', minLevel);
    lCodeLines = [];
    while (nextLevel() >= minLevel) {
      lCodeLines.push(get());
    }
    result = undented(lCodeLines);
    dbgReturn('getCodeLines', result);
    return result;
  };
  // --------------------------------------------
  lPeggy = []; // --- shift lines from lLines as processed
  if (next() === 'INITIALIZATION') {
    skip();
    dbg("Found INITIALIZATION section");
    lCode = getCodeLines(1);
    jsCode = convertCodeToJS(lCode, type);
    lPeggy.push("{{");
    lPeggy.push(jsCode);
    lPeggy.push("}}");
  }
  if (next() === 'EACH_PARSE') {
    skip();
    dbg("Found EACH_PARSE section");
    lCode = getCodeLines(1);
    jsCode = convertCodeToJS(lCode, type);
    lPeggy.push("{");
    lPeggy.push(jsCode);
    lPeggy.push("}");
  }
  hRules = {};
  while (more()) {
    // --- Get rule name - must be left aligned, no whitespace
    name = get();
    lPeggy.push(name);
    dbg(`RULE ${OL(name)}`);
    assert(!name.match(/\s/), `whitespace in rule name ${OL(name)}`);
    assert(!hasKey(hRules, name), `duplicate rule ${name}`);
    hRules[name] = 0; // number of options
    while (more() && (nextLevel() === 1)) {
      // --- Get match expression - 1 indent level, may be multi-line
      lExprLines = [];
      while (nextLevel() === 1) {
        lExprLines.push(get().trim());
      }
      assert(lExprLines.length > 0, `Bad rule ${name}`);
      matchExpr = lExprLines.join(' ');
      ch = (hRules[name] === 0) ? '=' : '/';
      headerLine = `${ch} ${matchExpr}`;
      dbg("");
      dbg(`OPTION ${hRules[name]}`, headerLine);
      lPeggy.push(`  ${headerLine}`);
      hRules[name] += 1;
      lCode = getCodeLines(2);
      if (nonEmpty(lCode)) {
        jsCode = convertCodeToJS(lCode, type);
        lPeggy.push("    {");
        lPeggy.push(indented(jsCode, 2, "  "));
        lPeggy.push("    }");
        lPeggy.push("");
      }
    }
  }
  result = toBlock(lPeggy);
  dbgReturn('convertToJS', result);
  return result;
};

// ---------------------------------------------------------------------------

  // --- Tracer object does not log
Tracer = class Tracer {
  trace({type, rule, location}) {
    return pass();
  }

};

MyTracer = class MyTracer extends Tracer {
  constructor() {
    super();
    this.level = 0;
  }

  prefix() {
    return "|  ".repeat(this.level);
  }

  trace({type, rule, location, match}) {
    switch (type) {
      case 'rule.enter':
        console.log(`${this.prefix()}? ${rule}`);
        this.level += 1;
        break;
      case 'rule.fail':
        this.level -= 1;
        console.log(`${this.prefix()}NO`);
        break;
      case 'rule.match':
        this.level -= 1;
        if (defined(match)) {
          console.log(`${this.prefix()}YES - ${OL(match)}`);
        } else {
          console.log(`${this.prefix()}YES`);
        }
        break;
      default:
        console.log(`UNKNOWN type: ${type}`);
    }
  }

};

// ---------------------------------------------------------------------------
export var pparse = (parseFunc, inputStr, hOptions = {}) => {
  var hParseOptions, result, start, tracer;
  dbgEnter('pparse', 'FUNC', inputStr, hOptions);
  ({start, tracer} = getOptions(hOptions, {
    start: undef, //     name of start rule
    tracer: 'none' // --- can be none/peggy/default/a function
  }));
  dbg(`tracer = ${OL(tracer)}`);
  hParseOptions = {};
  if (defined(start)) {
    hParseOptions.startRule = start;
  }
  switch (tracer) {
    case 'none':
      hParseOptions.tracer = new Tracer();
      break;
    case 'peggy':
      pass();
      break;
    case 'default':
      hParseOptions.tracer = new MyTracer();
      break;
    default:
      assert(isFunction(tracer), "tracer not a function");
      hParseOptions.tracer = tracer;
  }
  result = parseFunc(inputStr, hParseOptions);
  dbgReturn('pparse', result);
  return result;
};

//# sourceMappingURL=peggy.js.map
