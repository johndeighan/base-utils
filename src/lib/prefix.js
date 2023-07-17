// prefix.coffee
var setCharsAt;

import {
  assert,
  croak
} from '@jdeighan/base-utils/exceptions';

import {
  undef,
  OL
} from '@jdeighan/base-utils';

// --- We use spaces here because Windows Terminal handles TAB chars badly
export var vbar = '│'; // unicode 2502

export var hbar = '─'; // unicode 2500

export var corner = '└'; // unicode 2514

export var tee = '├'; // unicode 251C

export var arrowhead = '>';

export var backarrow = '<';

export var space = ' ';

export var dot = '.';

export var lI18N = '◄'; // unicode 25C4

export var rI18N = '►'; // unicode 25BA

export var fourSpaces = space + space + space + space;

export var oneIndent = vbar + space + space + space;

export var arrow = corner + hbar + arrowhead + space;

export var flat = tee + hbar + hbar + space;

export var resume = tee + hbar + arrowhead + space;

export var yieldSym = tee + backarrow + hbar + space;

// ---------------------------------------------------------------------------
export var getPrefix = (level, option = 'none') => {
  switch (option) {
    case 'plain':
      return oneIndent.repeat(level);
    case 'withArrow':
      if (level === 0) {
        return arrow;
      } else {
        return oneIndent.repeat(level - 1) + arrow;
      }
      break;
    case 'withResume':
      if (level === 0) {
        return resume;
      } else {
        return oneIndent.repeat(level - 1) + resume;
      }
      break;
    case 'withFlat':
      if (level === 0) {
        return flat;
      } else {
        return oneIndent.repeat(level - 1) + flat;
      }
      break;
    case 'withYield':
      if (level === 0) {
        return yieldSym;
      } else {
        return oneIndent.repeat(level - 1) + yieldSym;
      }
      break;
    case 'noLastVbar':
      assert(level >= 1, `getPrefix(), noLastVbar but level=${OL(level)}`);
      return oneIndent.repeat(level - 1) + fourSpaces;
    default:
      return fourSpaces.repeat(level);
  }
};

// ---------------------------------------------------------------------------
setCharsAt = (str, pos, str2) => {
  assert(pos >= 0, `negative pos ${pos} not allowed`);
  assert(pos < str.length, `pos ${pos} not in ${OL(str)}`);
  if (pos + str2.length >= str.length) {
    return str.substring(0, pos) + str2;
  } else {
    return str.substring(0, pos) + str2 + str.substring(pos + str2.length);
  }
};

// ---------------------------------------------------------------------------
export var addArrow = (prefix) => {
  var pos, result;
  pos = prefix.lastIndexOf(vbar);
  if (pos === -1) {
    result = prefix;
  } else {
    result = setCharsAt(prefix, pos, arrow);
  }
  return result;
};

// ---------------------------------------------------------------------------
export var removeLastVbar = (prefix) => {
  var pos, result;
  pos = prefix.lastIndexOf(vbar);
  if (pos === -1) {
    result = prefix;
  } else {
    result = setCharsAt(prefix, pos, ' ');
  }
  return result;
};
