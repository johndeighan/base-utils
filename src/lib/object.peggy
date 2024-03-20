---
author: John Deighan
include: pll-parser
---
{{
	import {
		undef, defined, notdefined, OL, CWS,
		} from '@jdeighan/base-utils';
	import {
		LOG, LOGVALUE, LOGJSON, LOGSTRING,
		} from '@jdeighan/base-utils/log';
	const mkword = (lChars) => {
		return CWS(lChars.join(''));
		}
}}

{
	// --- add terminating newline if not present
	if ((notdefined(options.startRule)
				|| (options.startRule == 'object'))
			&& ! input.endsWith("\n")) {
		input += "\n";
		}
}

object
	= obj:primitive EOL
		{
		return obj;
		}

	/ lItems:item+
		{
		let lArray = []
		for (let item of lItems) {
			lArray.push(item);
			}
		return lArray;
		}

	/ lObjects:keyValPair+
		{
		let hObj = {};
		for (let result of lObjects) {
			hObj[result.key] = result.value;
			}
		return hObj;
		}

	/ str:bare_str EOL
		{
		return str;
		}

primitive
	= ".undef."
		{
		return undef;
		}

	/ ".null."
		{
		return null;
		}

	/ ".true."
		{
		return true;
		}

	/ ".false."
		{
		return false;
		}

	/ num:("-"? [0-9]+ ("." [0-9]*)? )
		{
		return parseFloat(num);
		}

	/ str:quoted_str
		{
		return str;
		}

keyValPair
	= key:key_str ":" " "+ value:bare_str EOL
		{
		return {key, value}
		}

item
	= "-" item:string EOL
		{
		return item
		}

string
	= str:( quoted_str / bare_str)
		{
		return str;
		}

quoted_str
	= '«' lChars:[^»]+ '»'
	{
	return mkword(lChars);
	}

key_str
	= lChars:[^:\n]+
		{
		return mkword(lChars);
		}

bare_str
	= lChars:[^\n]+
		{
		return mkword(lChars);
		}

ws
	= " "*

EOL
	= ws "\n"
