// parse-utils.coffee
import {
  undef,
  defined
} from '@jdeighan/base-utils';

import {
  LOG,
  LOGVALUE
} from '@jdeighan/base-utils/log';

import {
  toTAML
} from '@jdeighan/base-utils/taml';

import {
  toAST
} from '@jdeighan/base-utils/coffee';

import {
  parseCmdArgs
} from '@jdeighan/base-utils/parse-cmd-args';

// ---------------------------------------------------------------------------
export var getExpr = () => {
  var hCmdArgs, lNonArgs;
  hCmdArgs = parseCmdArgs();
  // LOGVALUE 'hCmdArgs', hCmdArgs
  lNonArgs = hCmdArgs._;
  if (defined(lNonArgs)) {
    return lNonArgs.join(' ');
  } else {
    return '';
  }
};

// ---------------------------------------------------------------------------