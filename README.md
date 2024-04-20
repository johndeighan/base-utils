Using `@jdeighan/base-utils`
============================

[CHANGELOG](CHANGELOG.md)
[How to debug](DEBUGGING.md)

```bash
$ npm install @jdeighan/base-utils
```

In the interest of getting some good documentation in place, I'm
going to let the unit tests serve as the most detailed documentation.
Each module will have a documentation page the gives a summary of
the main functions/classes/objects of the module, along with a link
to the unit tests for that module

Although I do all of my development using the CoffeeScript language
(coffeescript.org, install with `npm install coffeescript`)
that doesn't mean that you need to have CoffeeScript installed to
use these libraries. My projects always include both the CoffeeScript
and JavaScript versions of the libraries and, in fact, you'll see that
I always import the JavaScript files in my libraries.

The `/utest` module provides the following functions:

	`equal(x,y)`
		- tests for deep equality
	`like(x,y)`
		- tests if a hash has a key/value, but allows additional ones.
			when comparing lists of hashes,
			applies this test to the hashes in the list
	`notequal(x,y)`
		- tests for deep inequality
	`truthy(x)`
		- tests if a value is truthy
	`falsy(x)`
		- tests if a value is falsy
	`fails(() => code)`
		- when passed a function, tests that it throws an exception
	`throws(() => code, class)`
		- when passed a function, tests that it throws the given Error class
	`succeeds(() => code)`
		- when passed a function, tests that it doesn't throw an exception

it also exports a class named `UnitTester` and an object named `u`.
The `u` object is a UnitTester instance. In fact, the `u` object
is the object used by the functions above.

So, for example, here are a few unit tests from the `base-utils` library:

```coffee
u.truthy notdefined(undefined)
u.falsy  notdefined(12)
u.succeeds () => pass()
u.equal    {a:1, b:2}, {a:1, b:2}
u.notequal {a:1, b:2}, {a:1, b:3}
```

You might note that the tests are not named. The unit tester can determine
on which line the tests exist and will report that whether a test succeeds
or fails, thus allowing you to locate it quickly.

In addition, you can override methods `transformValue()` and/or
`transformExpected()` of the `u` object. These methods will be called on the
parameters passed to the methods above before the test is performed,
allowing you to avoid calling the same function on a series of unit tests
just to test the same function.

As an example, there is a function named `escapeStr()` that will take a
string and change TAB characters to `→`, space characters to `˳`,
newline characters to `▼` and carriage return characters to `◄`.
You might want to test a bunch of input strings like this:

```coffee
equal escapeStr("   XXX\n"),  "˳˳˳XXX▼"
equal escapeStr("\t ABC\n"),  "→˳ABC▼"
equal escapeStr("X\nX\nX\n"), "X▼X▼X▼"
equal escapeStr("XXX\n\t\t"), "XXX▼→→"
equal escapeStr("XXX\n  "),   "XXX▼˳˳"
```

But you could also define a `transformValue()` method, then simplify
the tests, e.g.:

```coffee
(() =>
	t = new UnitTester()
	t.transformValue = (str) => escapeStr(str)

	equal "   XXX\n",  "˳˳˳XXX▼"
	equal "\t ABC\n",  "→˳ABC▼"
	equal "X\nX\nX\n", "X▼X▼X▼"
	equal "XXX\n\t\t", "XXX▼→→"
	equal "XXX\n  ",   "XXX▼˳˳"
	)()
```

NOTE:

1. When you need to create a new variable in a unit test,
	it's best to wrap the test(s) in an anonymous function,
	then immediately call it. Since the variable is isolated
	from the rest of the code, you needn't worry about name
	clashes with variables that you might create later on.

2. In calls to the `equal()` and `like()` functions, the 1st
	argument is the **value**, and therefore transformed by
	the function passed to the `transformValue()` method, and
	the 2nd argument is the **expected** value and therefore
	transformed by the function passed to the `transformExpected()`
	method

3. `UnitTester` is a class exported by `@jdeighan/base-utils/utest`.
	Although I could have created a new class that extends UnitTester,
	then overridden the `transformValue()` method in the new class,
	for simple cases, I prefer to just assign a function to the
	`transformValue` property on the base class.

his project includes these libraries:

- [/](docs/base-utils.md) - basic utilities
- [/ll-fs](docs/ll-fs.md) - low-level file system utilities
- [/source-map](docs/source-map.md) - use source maps to map line numbers
- [/v8-stack](docs/v8-stack.md) - get JS call stack
- [/exceptions](docs/exceptions.md) - exception handling
- [/cmd-args](docs/cmd-args.md) - get command line arguments
- [/utest](docs/utest.md) - unit test utilities
- [/prefix](docs/prefix.md) - handle line prefixes, e.g. indentation
- [/named-logs](docs/named-logs.md) - save logs keyed by a name
- [/indent](docs/indent.md) - handle line indentations
- [/taml](docs/taml.md) - allow TABS in yaml-like strings, etc.
- [/log](docs/log.md) - advanced logging
- [/stack](docs/stack.md) - manage our own call stack
- [/debug](docs/debug.md) - advanced debugging
- [/state-machine](docs/state-machine.md) - finite state machine
- [/fs](docs/fs.md) - file system utilities
- [/FileProcessor](docs/FileProcessor.md) - read, then rewrite files

This project includes these binaries:

- [for-each-file](docs/for-each-file.md)
- [gen-bin-key](docs/gen-bin-key.md)
- [gen-parsers](docs/gen-parsers.md)
- [get-imports-from](docs/get-imports-from.md)

Building this project
=====================

Build this project using [these instructions](docs/BUILD.md)


How to get a screen shot in Windows 11
======================================

1. Press Windows-Shift-S
2. Select an area
3. Open Paint app
4. Paste
5. Save as PNG

