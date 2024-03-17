// indent.test.coffee
import {
  undef,
  isInteger
} from '@jdeighan/base-utils';

import {
  assert
} from '@jdeighan/base-utils/exceptions';

import {
  indentLevel,
  isUndented,
  indentation,
  undented,
  splitLine,
  indented,
  enclose,
  getOneIndent
} from '@jdeighan/base-utils/indent';

import {
  UnitTester,
  equal,
  like,
  notequal,
  succeeds,
  throws,
  truthy,
  falsy
} from '@jdeighan/base-utils/utest';

// ---------------------------------------------------------------------------
equal(getOneIndent("abc"), undef);

equal(getOneIndent(""), undef);

equal(getOneIndent("\tabc"), "\t");

equal(getOneIndent("\t\tabc"), "\t");

equal(getOneIndent(" abc"), " ");

equal(getOneIndent("   abc"), "   ");

throws(function() {
  return getOneIndent(" \tabc");
});

throws(function() {
  return getOneIndent("\t abc");
});

// ---------------------------------------------------------------------------
equal(indentLevel("abc"), 0);

equal(indentLevel("\tabc"), 1);

equal(indentLevel("\t\tabc"), 2);

// ---------------------------------------------------------------------------
truthy(isUndented("abc"));

falsy(isUndented("\tabc"));

falsy(isUndented("\t\tabc"));

// ---------------------------------------------------------------------------
equal(indentation(0), '');

equal(indentation(1), "\t");

equal(indentation(2), "\t\t");

// ---------------------------------------------------------------------------
equal(undented("abc"), "abc");

equal(undented("\tabc"), "abc");

equal(undented("\t\tabc"), "abc");

equal(undented([]), []);

equal(undented(['abc']), ['abc']);

equal(undented(['\tabc']), ['abc']);

equal(undented(['\t\tabc']), ['abc']);

equal(undented('\n\n\t\tabc\n\t\t\t\tdef'), `abc
		def`);

// ---------------------------------------------------------------------------
// --- test with spaces
equal(undented("abc"), "abc");

equal(undented("   abc"), "abc");

equal(undented("      abc"), "abc");

equal(undented([]), []);

equal(undented(['abc']), ['abc']);

equal(undented(['   abc']), ['abc']);

equal(undented(['      abc']), ['abc']);

// ---------------------------------------------------------------------------
// --- test with multiple lines
equal(undented(['abc', '\txyz', 'mmm']), ['abc', '\txyz', 'mmm']);

equal(undented(['\t\tabc', '\t\t\txyz', '\t\tmmm']), ['abc', '\txyz', 'mmm']);

// ---------------------------------------------------------------------------
(function() {
  var block, expected;
  block = "\t\tfirst\n\t\tsecond\n\t\t\tthird\n";
  expected = "first\nsecond\n\tthird\n";
  return equal(undented(block), expected);
})();

// ---------------------------------------------------------------------------
(function() {
  var array, expected;
  array = ["\t\tfirst", "\t\tsecond", "\t\t\tthird"];
  expected = ["first", "second", "\tthird"];
  return equal(undented(array), expected);
})();

// ---------------------------------------------------------------------------
equal(splitLine("abc"), [0, "abc"]);

equal(splitLine("\tabc"), [1, "abc"]);

equal(splitLine("\t\tabc"), [2, "abc"]);

equal(splitLine(""), [0, ""]);

equal(splitLine("\t\t\t"), [0, ""]);

equal(splitLine("\t \t"), [0, ""]);

equal(splitLine("   "), [0, ""]);

// ---------------------------------------------------------------------------
equal(indented("abc", 0), "abc");

equal(indented("abc", 1), "\tabc");

equal(indented("abc", 2), "\t\tabc");

equal(indented("abc", 0, '  '), "abc");

equal(indented("abc", 1, '  '), "  abc");

equal(indented("abc", 2, '  '), "    abc");

// --- empty lines, indented, should just be empty lines
equal(indented("abc\n\ndef", 2), "\t\tabc\n\n\t\tdef");

(function() {
  var block, exp;
  // --- test indenting multi-line strings
  block = `main
\toverflow: auto

nav
\toverflow: auto`;
  exp = `\tmain
\t\toverflow: auto

\tnav
\t\toverflow: auto`;
  return equal(indented(block, 1), exp);
})();

// --- indented also handles arrays, so test them, too

// --- empty lines, indented, should just be empty lines
equal(indented(['abc', '', 'def'], 2), ['\t\tabc', '', '\t\tdef']);

(function() {
  var lExp, lLines;
  lLines = ['main', '\toverflow: auto', '', 'nav', '\toverflow: auto'];
  lExp = ['\tmain', '\t\toverflow: auto', '', '\tnav', '\t\toverflow: auto'];
  return equal(indented(lLines, 1), lExp);
})();

// --- make sure ALL internal lines are indented
equal(indented(['abc\ndef', '', 'ghi'], 1), ['\tabc', '\tdef', '', '\tghi']);

// ---------------------------------------------------------------------------
equal(indented("export name = undef", 1), "\texport name = undef");

equal(indented("export name = undef", 2), "\t\texport name = undef");

// ---------------------------------------------------------------------------
// make sure indentLevel() works for blocks
equal(indentLevel("\t\tabc\n\t\tdef\n\t\t\tghi"), 2);

// ---------------------------------------------------------------------------
(function() {
  var block;
  block = `x = 42
callme(x)`;
  equal(enclose(block, '<script>', '</script>'), `<script>
	x = 42
	callme(x)
</script>`);
  return equal(enclose(block, 'pre', 'post', '...'), `pre
...x = 42
...callme(x)
post`);
})();