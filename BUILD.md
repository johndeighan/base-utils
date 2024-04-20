Building from scratch
=====================

1. remove all *.js and *.map.js files (`startclean`)
2. `coffee -cmb --no-header ./src/base-build.coffee`
3. `node ./src/base-build.js`
	- all *.coffee files in src/lib and src/bin
		should be compiled to *.js and *.js.map
	- all *.peggy files in src/lib and src/bin
		should have a *.js file, but it's a fake!
4. `node ./src/bin/low-level-build.js`
