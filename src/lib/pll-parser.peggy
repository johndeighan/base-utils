---
author: John Deighan
---
{{
	import {
		undef, defined, OL, isEmpty, nonEmpty,
		} from '@jdeighan/base-utils';
	import {LOG} from '@jdeighan/base-utils/log'
	import {assert} from '@jdeighan/base-utils/exceptions'
	import {
		dbgEnter, dbgReturn, dbg,
		} from '@jdeighan/base-utils/debug'

	let lTokens = [];
	let lLines = [];  // accumulate as long as >= double indent
	let level = 0;

	// ---------------------------------------------------------

	let reset = () => {

		dbgEnter('reset');
		lTokens = [];
		lLines = [];
		level = 0;
		dbgReturn('reset');
		return;
		}

	// ---------------------------------------------------------

	let flushToken = () => {

		dbgEnter('flushToken');
		if (isEmpty(lLines)) {
			dbg("empty line");
			}
		else {
			let text = lLines.join(' ');
			dbg("text = #{OL(text)}");
			lTokens.push({
				type: 'text',
				text
				});
			lLines = [];
			}
		dbgReturn('flushToken');
		return;
		}

}}

// --------------------------------------------------------------------------

{
	reset();
}

// --------------------------------------------------------------------------

block
	= line|.., eol| eol?
		{
		flushToken();  // --- check if there's left over text

		// --- generate undents for each remaining level
		while (level > 0) {
			lTokens.push({type: 'undent'});
			level -= 1;
			}
		return lTokens;
		}

line
	= tabs:"\t"*   spaces:" "*   text:text
		{
		assert (spaces.length == 0), "mixed indentation"

		let numTabs = tabs.length;
		dbgEnter('parseLine', numTabs, text);

		if (isEmpty(text)) {  // --- ignore empty lines
			dbg("line is empty");
			dbgReturn('parseLine');
			return;
			}

		// --- Handle continuation lines

		if (numTabs >= level+2) {
			lLines.push(text)
			dbgReturn('parseLine');
			return;
			}

		flushToken();

		// --- Adjust level, adding 'indent' or 'undent' tokens

		if (numTabs > level) {
			lTokens.push({type: 'indent'});
			level += 1;
			}
		else {
			while (numTabs < level) {
				lTokens.push({type: 'undent'});
				level -= 1;
				}
			}

		// --- Handle the text

		lLines.push(text)
		dbgReturn('parseLine');
		return;
		}

text
	= text:[^\r\n]*
		{
		text = text.join('');
		dbgEnter('handleText', text);
		if (text.includes("\t")) {
			throw new Error("TAB outside of indentation");
			}
		dbgReturn('handleText', text);
		return text;
		}

eol
	= "\r"? "\n"

