# source-map.test.coffee

# --- 3 files are used:
#        ./test/source-map/base-utils.coffee
#        ./test/source-map/base-utils.js
#        ./test/source-map/base-utils.js.map

import {hasKey} from '@jdeighan/base-utils'
import {mkpath} from '@jdeighan/base-utils/ll-fs'
import {
	getMap, mapSourcePos, mapLineNum,
	} from '@jdeighan/base-utils/source-map'
import {utest} from '@jdeighan/base-utils/utest'

jsPath = mkpath "./test/source-map/base-utils.test.js"
mapPath = jsPath + '.map'

hMap = getMap mapPath
utest.truthy hasKey(hMap, 'sourceRoot')
utest.truthy hasKey(hMap, 'sources')

hResult = mapSourcePos jsPath, 10, 0
utest.equal hResult.line, 6

utest.equal mapLineNum(jsPath, 10), 6
utest.equal mapLineNum(jsPath, 89), 27
utest.equal mapLineNum(jsPath, 99), 28
utest.equal mapLineNum(jsPath, 1361), 697
