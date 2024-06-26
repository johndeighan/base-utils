  // indent.coffee
import {
  undef,
  defined,
  notdefined,
  toArray,
  toBlock,
  OL,
  rtrim,
  isInteger,
  isString,
  isArray,
  isEmpty,
  isArrayOfStrings
} from '@jdeighan/base-utils';

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

// ---------------------------------------------------------------------------
export var getOneIndent = (str) => {
  var lMatches;
  if ((lMatches = str.match(/^\t+(?:\S|$)/))) {
    return "\t";
  } else if ((lMatches = str.match(/^(\x20+)(?:\S|$)/))) { // space char
    return lMatches[1];
  }
  assert(notdefined(str.match(/^\s/)), "Mixed indentation types");
  return undef;
};

// ---------------------------------------------------------------------------
export var splitPrefix = (line) => {
  var lMatches;
  assert(isString(line), `non-string ${OL(line)}`);
  line = rtrim(line);
  lMatches = line.match(/^(\s*)(.*)$/);
  return [lMatches[1], lMatches[2]];
};

// ---------------------------------------------------------------------------
//   splitLine - separate a line into [level, line]
export var splitLine = (line, oneIndent = undef) => {
  var prefix, str;
  [prefix, str] = splitPrefix(line);
  return [indentLevel(prefix, oneIndent), str];
};

// ---------------------------------------------------------------------------
//   indentLevel - determine indent level of a string
//                 it's OK if the string is ONLY indentation
export var indentLevel = (line, oneIndent = undef) => {
  var i, lMatches, len, level, nSpaces, nTabs, prefix, prefixLen, ref, str;
  assert(isString(line), `not a string: ${OL(line)}`);
  // --- This will always match, and it's greedy
  if (lMatches = line.match(/^\s*/)) {
    prefix = lMatches[0];
    prefixLen = prefix.length;
  }
  if (prefixLen === 0) {
    return 0;
  }
  // --- Match \t* followed by \x20* (error if no match)
  if (lMatches = prefix.match(/(\t*)(\x20*)/)) {
    nTabs = lMatches[1].length;
    nSpaces = lMatches[2].length;
  } else {
    croak("Invalid mix of TABs and spaces");
  }
  // --- oneIndent must be one of:
  //        undef
  //        a single TAB character
  //        some number of space characters
  switch (oneIndent) {
    case undef:
      if (nTabs > 0) {
        level = nTabs; // there may also be spaces, but we ignore them
        oneIndent = "\t"; // may be used at end
      } else {
        assert(nSpaces > 0, `There must be TABS or spaces in ${OL(line)}`);
        level = 1;
        oneIndent = ' '.repeat(nSpaces); // may be used at end
      }
      break;
    case "\t":
      assert(nTabs > 0, "Expecting TAB indentation, found spaces");
      // --- NOTE: there may be spaces, but they're not indentation
      level = nTabs;
      break;
    default:
      // --- oneIndent must be all space chars
      assert(nTabs === 0, `Indentation has TABs but oneIndent = ${OL(oneIndent)}`);
      assert(nSpaces % oneIndent.length === 0, `prefix ${OL(prefix)} not a mult of ${OL(oneIndent)}`);
      level = nSpaces / oneIndent.length;
  }
  // --- If a block, i.e. multi-line string, then all lines must be
  //     at least at this level
  if (line.indexOf("\n") >= 0) {
    ref = toArray(line);
    for (i = 0, len = ref.length; i < len; i++) {
      str = ref[i];
      assert(indentLevel(str, oneIndent) >= level, `indentLevel of ${OL(line)} can't be found`);
    }
  }
  return level;
};

// ---------------------------------------------------------------------------
//   indentation - return appropriate indentation string for given level
//   export only to allow unit testing
export var indentation = (level, oneIndent = "\t") => {
  assert(isInteger(level), `Not an integer: ${OL(level)}`);
  assert(level >= 0, "indentation(): negative level");
  return oneIndent.repeat(level);
};

// ---------------------------------------------------------------------------
//   isIndented - true iff indentLevel(line) > 0
export var isIndented = (line) => {
  return defined(line) && defined(line.match(/^\s/));
};

// ---------------------------------------------------------------------------
//   isUndented - true iff indentLevel(line) == 0
export var isUndented = (line) => {
  return defined(line) && notdefined(line.match(/^\s/));
};

// ---------------------------------------------------------------------------
//   indented - add indentation to each string in a block or array
//            - returns the same type as input, i.e. array or string
export var indented = (input, level = 1, oneIndent = "\t") => {
  var i, lLines, len, line, ref, toAdd;
  // --- input must be either a string or array of strings
  assert(isString(input) || isArrayOfStrings(input), `invalid input: ${OL(input)}`);
  // --- oneIndent must be a string
  assert(isString(oneIndent), `Not a string: ${OL(oneIndent)}`);
  // --- level can be a string, in which case it is
  //     pre-pended to each line of input
  if (isString(level)) {
    if (level === '') {
      return input;
    }
    toAdd = level;
  } else if (isInteger(level)) {
    if (level === 0) {
      return input;
    }
    assert(level > 0, `Invalid level ${OL(level)}`);
    toAdd = indentation(level, oneIndent);
  } else {
    croak(`Invalid level ${OL(level)}`);
  }
  // --- NOTE: toArray(input) just returns input if it's an array
  //           else it splits the string into an array of lines
  lLines = [];
  ref = toArray(input);
  for (i = 0, len = ref.length; i < len; i++) {
    line = ref[i];
    if (isEmpty(line)) {
      lLines.push('');
    } else {
      lLines.push(`${toAdd}${line}`);
    }
  }
  if (isArray(input)) {
    return lLines;
  } else if (isString(input)) {
    return toBlock(lLines);
  }
  return croak(`Invalid input; ${OL(input)}`);
};

// ---------------------------------------------------------------------------
//   undented - string with 1st line indentation removed for each line
//            - ignore leading empty lines
//            - returns same type as text, i.e. either string or array
export var undented = (input) => {
  var lLines, lMatches, nToRemove, toRemove;
  // --- If a string, convert to an array
  if (isString(input)) {
    lLines = toArray(input);
  } else if (isArray(input)) {
    lLines = input;
  } else {
    croak("input not a string or array");
  }
  // --- Remove leading blank lines
  while ((lLines.length > 0) && isEmpty(lLines[0])) {
    lLines.shift(); // remove
  }
  if (lLines.length === 0) {
    if (isString(input)) {
      return '';
    } else {
      return [];
    }
  }
  // --- determine what to remove from beginning of each line
  lMatches = lLines[0].match(/^\s*/);
  toRemove = lMatches[0];
  nToRemove = toRemove.length;
  if (nToRemove > 0) {
    lLines = lLines.map((line) => {
      if (isEmpty(line)) {
        return '';
      } else {
        assert(line.indexOf(toRemove) === 0, `can't remove ${OL(toRemove)} from ${OL(line)}`);
        return line.substr(nToRemove);
      }
    });
  }
  if (isString(input)) {
    return toBlock(lLines);
  } else {
    return lLines;
  }
};

// ---------------------------------------------------------------------------
//    enclose - indent text, surround with pre and post
export var enclose = (text, pre, post, oneIndent = "\t") => {
  return toBlock([pre, indented(text, 1, oneIndent), post]);
};
