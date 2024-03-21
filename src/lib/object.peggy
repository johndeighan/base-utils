---
author: John Deighan
include: pll-parser
---
{{
	import {
		undef, defined, notdefined, OL, CWS, escapeStr,
		mkword,
		} from '@jdeighan/base-utils';
	import {
		LOG, LOGVALUE, LOGJSON, LOGSTRING,
		} from '@jdeighan/base-utils/log';
}}

{
	// --- add terminating newline if not present
	//     when parsing an object
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

item
	= "-" ws item:(primitive / bare_str) EOL
		{
		return item
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

	/ num:number
		{
		return num;
		}

	/ str:quoted_str
		{
		return str;
		}

number
	= lChars:("-"? [0-9]+ ("." [0-9]*)? )
		{
		let num = mkword(lChars);
		return parseFloat(num);
		}

keyValPair
	= key:key_str ":" ws value:bare_str EOL
		{
		return {key, value}
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

	/ '"' lChars:[^"]+ '"'
	{
	return mkword(lChars);
	}

	/ "'" lChars:[^']+ "'"
	{
	return mkword(lChars);
	}

key_str
	= lChars:(quoted_str / [^:\n]+)
		{
		return CWS(mkword(lChars));
		}

bare_str
	= lChars:[^\n]+
		{
		return CWS(mkword(lChars));
		}

ws
	= " "*

EOL
	= ws "\n"
