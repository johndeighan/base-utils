// peggy.coffee
var MyTracer, Tracer, generate, hPeggyOptions;

import peggy from 'peggy';

({generate} = peggy);

import {
  undef,
  defined,
  notdefined,
  pass,
  OL,
  toBlock,
  getOptions,
  isString,
  isEmpty,
  isFunction
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  isFile,
  slurp,
  barf,
  withExt,
  readTextFile
} from '@jdeighan/base-utils/fs';

hPeggyOptions = {
  allowedStartRules: ['*'],
  format: 'es',
  output: 'source-and-map',
  trace: true
};

// ---------------------------------------------------------------------------
export var peggify = (peggyCode, source) => {
  var err, h, srcNode;
  assert(isFile(source), `Not a file: ${OL(source)}`);
  try {
    hPeggyOptions.grammarSource = source;
    srcNode = generate(peggyCode, hPeggyOptions);
    h = srcNode.toStringWithSourceMap();
    return [h.code, h.map.toString()];
  } catch (error) {
    err = error;
    console.log(`ERROR: ${err.message}`);
    return [undef, undef];
  }
};

// ---------------------------------------------------------------------------
export var peggifyFile = (filePath) => {
  var jsCode, lLines, metadata, sourceMap;
  ({metadata, lLines} = readTextFile(filePath));
  [jsCode, sourceMap] = peggify(toBlock(lLines), filePath);
  barf(jsCode, withExt(filePath, '.js'));
  barf(sourceMap, withExt(filePath, '.js.map'));
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
  var hParseOptions, start, tracer;
  ({start, tracer} = getOptions(hOptions, {
    start: undef, //     name of start rule
    tracer: 'none' // --- can be 'none'/'peggy'/'default'/a function
  }));
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
  return parseFunc(inputStr, hParseOptions);
};

// ---------------------------------------------------------------------------

//# sourceMappingURL=peggy.js.map
