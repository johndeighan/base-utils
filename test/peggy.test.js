// peggy.test.coffee
import {
  undef,
  OL
} from '@jdeighan/base-utils';

import {
  LOG
} from '@jdeighan/base-utils/log';

import {
  equal,
  truthy,
  falsy,
  succeeds,
  throws
} from '@jdeighan/base-utils/utest';

import {
  peggify,
  peggifyFile
} from '@jdeighan/base-utils/peggy';

import {
  parse
} from '@jdeighan/base-utils/object';

// ---------------------------------------------------------------------------
truthy(parse);

equal(parse(".undef.", {
  startRule: 'primitive'
}), undef);

equal(parse(".null.", {
  startRule: 'primitive'
}), null);

equal(parse(".true.", {
  startRule: 'primitive'
}), true);

equal(parse(".false.", {
  startRule: 'primitive'
}), false);

equal(parse(".undef."), undef);

equal(parse(".null."), null);

equal(parse(".true."), true);

equal(parse(".false."), false);

equal(parse(`fName: John
lName: Deighan`), {
  fName: 'John',
  lName: 'Deighan'
});

equal(parse(`first name:   John
last name:    Deighan
full name  :  John    Deighan`), {
  "first name": 'John',
  "last name": 'Deighan',
  "full name": 'John Deighan'
});

equal(parse(`- John
- Deighan`), ['John', 'Deighan']);

equal(parse(`-   John
-  Deighan
-    John    Deighan`), ['John', 'Deighan', 'John Deighan']);

equal(parse("«\"Hello\", that's what she said.»"), "\"Hello\", that's what she said.");