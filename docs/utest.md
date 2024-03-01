@jdeighan/base-utils/utest
==========================

[unit tests](../test/utest.test.coffee)

Exports class UnitTester, which has methods:

```coffee
equal(value, expected)
like(value, expected)
notequal(value, expected)
truthy(value)
falsy(value)
throws(() => code)
succeeds(() => code)
```

It also has methods:

```coffee
transformValue(value)
transformExpected(expected)
```

which you can override to transform values and expected
values before the test is run.

Exports a single UnitTest instance named `u`

Exports the following functions, which use the instance
named `u` internally:

```coffee
equal(value, expected)
like(value, expected)
notequal(value, expected)
truthy(value)
falsy(value)
throws(() => code)
succeeds(() => code)
```
