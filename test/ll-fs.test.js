  // ll-fs.test.coffee
import {
  utest
} from '@jdeighan/base-utils/utest';

import {
  fixPath,
  mydir,
  mkpath,
  parsePath
} from '@jdeighan/base-utils/ll-fs';

// ---------------------------------------------------------------------------

// fixPath() should lower-case drive letters and replace \ with /
utest.equal(13, fixPath('C:\\test\\me'), 'c:/test/me');

utest.equal(15, mkpath("abc", "def"), "abc/def");

utest.equal(16, mkpath("c:\\Users", "johnd"), "c:/Users/johnd");

utest.equal(17, mkpath("C:\\Users", "johnd"), "c:/Users/johnd");

//# sourceMappingURL=ll-fs.test.js.map
