gen-bin-key
===========

[Back](./README.md)

This command will:

1. ensure that the current working directory contains
	a `package.json` file
2. exit if there is no `./src/bin` folder
3. For every *.coffee file in the `./src/bin folder:
	a. ensure that there is a corresponding `*.js` file
	b. ensure that the corresponding `*.js` file starts
		with `#!/usr/bin/env node`
	c. ensure that `package.json` contains a `bin` key,
		creating it if it does not
	d. add a subkey to `bin` with key = the file stub
		and value = a relative path to the `*.js` file.

**NOTE**: The coffee compiler must be executed before
this binary, usually as part of a build step.

**NOTE**: To ensure that 3b is satisfied, start your
`*.coffee` files with:

```coffee
`#!/usr/bin/env node
`
```
