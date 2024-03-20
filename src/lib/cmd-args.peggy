{{
	import {
		isEmpty, nonEmpty, hasKey, addNewKey,
		} from '@jdeighan/base-utils';
	import {assert} from '@jdeighan/base-utils/exceptions';
	let hOptions = {};

	// .........................................................

	function addOption(key, value) {

		addNewKey(hOptions, key, value);
		return;
		}

	// .........................................................

	function addNonOption(value) {

		if (hasKey(hOptions, '_')) {
			hOptions._.push(value);
			}
		else {
			hOptions._ = [value];
			}
		return;
		}
}}

{
	hOptions = {};
}

cmdArgs
	= ws? argList? ws?     { return hOptions; }

argList
	= arg (ws arg)*

arg
	= '-' lChars:[A-Za-z]+ value:(@'=' @stringVal)?
	{
		if (isEmpty(value)) {
			for (const ch of lChars) {
				addOption(ch, true);
				}
			}
		else {
			addOption(lChars.join(''), value[1]);
			}
		}
	/ val:stringVal   { addNonOption(val); }

stringVal
	= '"'  lChars:[^"]*  '"'    { return lChars.join(''); }
	/ "'"  lChars:[^']*  "'"    { return lChars.join(''); }
	/ !'-' lChars:[^ \t]+       { return lChars.join(''); }

ws
	= [ \t]+
