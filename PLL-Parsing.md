PLL Parsing
===========

This document serves as a description of software
to allow parsing of **Python-Like Languages**,
i.e. files that use indentation, by default via
TAB characters, to define structure.

Design goals:

1. The parser should allow the parser to be easily
	extended to allow parsing of new instances of
	Python-like languages.

2. Derived languages should be able to handle these
	non-terminals:

	- INDENT
	- UNDENT
	- LINE
	- COMMENT (beginning with '#') don't need to
		have the correct indentation)

