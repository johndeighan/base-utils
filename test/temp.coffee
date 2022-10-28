# temp.coffee

import {OL} from '@jdeighan/exceptions/utils'
import {toTAML} from '@jdeighan/exceptions/taml'

hProc = {
	code:   (block) -> return "#{block};"
	html:   (block) -> return block.replace('<p>', '<p> ').replace('</p>', ' </p>')
	Script: (block) -> return elem('script', undef, block, "\t")
	}

str = toTAML(hProc)
console.log str
