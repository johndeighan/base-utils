BOOTSTRAP
=========

`npm run build` does the following:

1. Compile files `src/bootstrap-utils.coffee` and
	`src/bootstrap.coffee`.

2. Use the `node` command to execute the resulting file
	`src/bootstrap.js` using a version of brewFile() that
	only recognizes YAML metadata bracketed by '---'. Only
	the key **shebang** is used. This version of brewFile()
	is used to compile all files in `src/lib` and also `src/
	bin/low-level-build.coffee`.

3. Use the `node` command to run low-level-build.js,
	which compiles all remaining coffee files and
	fake peggy files.
