for-each-file
=============

The `for-each-file` command will execute a command for
each file in a list of files.
You can either let your command shell expand strings like
`*.coffee` into all matching files, or provide a `-glob`
option, which will expand into a list of files using the
npm package `glob` ([`glob`](https://www.npmjs.com/package/glob)).

As an example, if you want to find all `*.coffee` files
and compile each using the `coffee` command, producing
a JavaScript file with the same name, but extension `.js`,
you could do this:

```bash
$ for-each-file -glob="**/*.coffee" -cmd="coffee -cm <file>"
```

Note:

1. If you provide a `-glob` option, you will need to
	put quotes around the glob if it contains any
	whitespace characters.

2. You must provide the option `-cmd` to specify the
	command that you want to execute for each file found
	that matches the glob. In that command, any instance
	of the string `<file>` will be replaced by the full
	path to the file. One exception is that if you set
	the option `-d`, the `-cmd` option is not necessary
	(and will be ignored if provided) because with the
	`-d` (debug) option, matching files are simply listed
	to the console.
