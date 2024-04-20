@jdeighan/base-utils
====================


This library contains many useful functions and synonyms.
A complete listing appears at the bottom of this page.

Note that the following synopsis uses CoffeeScript. In
CoffeeScript, you never declare variables - they exist
upon first assignment. One downside is that there's no
equivalent to the JavaScript statement `let x;` - to
create variable x, you'll have to assign it a value.
CoffeeScript is very "Python like" in that structure is
indicated by indentation, not curly braces as in C, Perl,
JavaScript, etc. That makes semicolons superfluous -
though they're allowed, there's really no point. Also,
the parens around a functions arguments are optional.
My advice is to not use them at the top level, but
use them to avoid ambiguity at lower levels. For example:

```coffee
result = getValue pad('abc'), repeat('-', 20)
```

`undef` - a synonym for JavaScript's undefined value

```coffee example-good
import {undef} from '@jdeighan/base-utils'

# --- define a new function say()
say = (x) =>
	if defined(x)
		console.log 'YES'
	else if notdefined(x)
		console.log 'NO'
	else
		console.log 'Maybe'

say undef
say null
say 42
say 'abc'
say ['a','b','c']
say {a: 1, b: 2}
```

OUTPUT:
<pre style="background-color: antiquewhite">
NO
NO
YES
YES
YES
YES
</pre>

```coffee
import {undef, jsType} from '@jdeighan/base-utils'

sayType = (label, x) =>
	[type, subtype] = jsType(x)
	console.log "#{label} = type: #{type}, subtype: #{subtype}"
	return

sayType 'undef', undef
sayType 'null', null
sayType 'string', 'abc'
sayType 'number', 42
sayType 'array', ['a','b']
sayType 'hash', {a:1, b:2}
```

OUTPUT:
<pre style="background-color: antiquewhite">
ABC
DEF
</pre>

This library includes the following symbols:

- [isString](../test/base-utils.test.coffee#:~:text=#symbol%20isString,%29%28%29)
- [isNumber](../test/base-utils.test.coffee#:~:text=#symbol%20isNumber,%29%28%29)

