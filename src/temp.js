// temp.coffee
import {
  globSync
} from 'glob';

import {
  brewFile,
  withExt,
  normalize,
  createFakeFiles
} from './base-funcs.js';

// --- Compile src/bin/low-level-build.coffee
brewFile('./src/bin/low-level-build.coffee');