# ast-walker.coffee

import {
	undef, pass, defined, notdefined, OL, deepCopy,
	isString, nonEmpty, isArray, isHash, isArrayOfHashes,
	toBlock, getOptions, removeKeys, words,
	} from '@jdeighan/base-utils'
import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	LOG, LOGVALUE,
	} from '@jdeighan/base-utils/log'
import {
	dbg, dbgEnter, dbgReturn,
	} from '@jdeighan/base-utils/debug'
import {slurp, barf, isDir} from '@jdeighan/base-utils/fs'
import {fromTAML, toTAML} from '@jdeighan/base-utils/taml'
import {indented} from '@jdeighan/base-utils/indent'

import {toAST} from '@jdeighan/base-utils/coffee'
import {Context} from '@jdeighan/base-utils/context'

lBuiltins = words(
	'global clearImmediate setImmediate clearInterval',
	'clearTimeout setInterval setTimeout',
	'queueMicrotask structuredClone atob btoa',
	'performance navigator fetch crypto',
	)

hAllHandlers = fromTAML('''
	---
	File:
		lWalkTrees:
			- program
	Program:
		lWalkTrees:
			- body
	ArrayExpression:
		lWalkTrees:
			- elements
	AssignmentExpression:
		lDefined:
			- left
		lUsed:
			- right
	AssignmentPattern:
		lDefined:
			- left
		lWalkTrees:
			- right
	BinaryExpression:
		lUsed:
			- left
			- right
	BlockStatement:
		lWalkTrees:
			- body
	ClassBody:
		lWalkTrees:
			- body
	ClassDeclaration:
		lWalkTrees:
			- body
	ClassMethod:
		lWalkTrees:
			- body
	ExpressionStatement:
		lWalkTrees:
			- expression
	IfStatement:
		lWalkTrees:
			- test
			- consequent
			- alternate
	LogicalExpression:
		lWalkTrees:
			- left
			- right
	SpreadElement:
		lWalkTrees:
			- argument
	SwitchStatement:
		lWalkTrees:
			- cases
	SwitchCase:
		lWalkTrees:
			- test
			- consequent
	TemplateLiteral:
		lWalkTrees:
			- expressions
	TryStatement:
		lWalkTrees:
			- block
			- handler
			- finalizer
	UnaryExpression:
		lWalkTrees:
			- argument
	WhileStatement:
		lWalkTrees:
			- test
			- body
	''')

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------

export class ASTWalker

	constructor: (from) ->
		# --- from can be an AST or CoffeeScript code

		dbgEnter "ASTWalker", from

		if isString(from)
			@ast = toAST(from)
		else
			@ast = from

		# --- @ast can be a hash or array of hashes
		if isHash(@ast)
			dbg "tree was hash - constructing list from it"
			@ast = [@ast]
		assert isArrayOfHashes(@ast), "not array of hashes: #{OL(@ast)}"

		# --- Info to accumulate
		@lImportedSymbols = []
		@lExportedSymbols = []
		@lUsedSymbols     = []
		@lMissingSymbols  = []

		@context = new Context()
		dbgReturn "ASTWalker"

	# ..........................................................

	addImport: (name, lib) ->

		dbgEnter "addImport", name, lib
		@check name
		if @lImportedSymbols.includes(name)
			LOG "Duplicate import: #{name}"
		else
			@lImportedSymbols.push(name)
		@context.addGlobal(name)
		dbgReturn "addImport"
		return

	# ..........................................................

	addExport: (name, lib) ->

		dbgEnter "addExport", name
		@check name
		if @lExportedSymbols.includes(name)
			LOG "Duplicate export: #{name}"
		else
			@lExportedSymbols.push(name)
		dbgReturn "addExport"
		return

	# ..........................................................

	addDefined: (name, value={}) ->

		dbgEnter "addDefined", name
		@check name
		if @context.atGlobalLevel()
			@context.addGlobal name
		else
			@context.add name
		dbgReturn "addDefined"
		return

	# ..........................................................

	addUsed: (name, value={}) ->

		dbgEnter "addUsed", name
		@check name
		if ! lBuiltins.includes(name)
			if ! @lUsedSymbols.includes(name)
				@lUsedSymbols.push(name)
			if ! @context.has(name) \
					&& ! @lMissingSymbols.includes(name)
				@lMissingSymbols.push name
		dbgReturn "addUsed"
		return

	# ..........................................................

	walkTree: (tree, level=0) ->

		dbgEnter "walkTree"
		if isArray(tree)
			for node in tree
				@walkTree node, level
		else
			assert isHash(tree, ['type']), "bad tree: #{OL(tree)}"
			@visit tree, level
		dbgReturn "walkTree"
		return

	# ..........................................................

	getHandlers: (node, level) ->

		{type} = node
		hHandlers = hAllHandlers[type]
		if defined(hHandlers)
			{lWalkTrees, lDefined, lUsed} = hHandlers
			result = [type, lWalkTrees, lDefined, lUsed]
		else
			result = [undef]
		# console.log result
		return result

	# ..........................................................
	# --- return true if handled, false if not

	handle: (node, level) ->

		dbgEnter "handle", node, level
		[type, lWalkTrees, lDefined, lUsed] = @getHandlers(node, level)
		if notdefined(type)
			dbgReturn "handle", false
			return false

		if defined(lDefined)
			for key in lDefined
				subnode = node[key]
				if subnode.type == 'Identifier'
					@addDefined subnode.name
				else
					@walkTree subnode, level+1

		if defined(lUsed)
			for key in lUsed
				subnode = node[key]
				if subnode.type == 'Identifier'
					@addUsed subnode.name
				else
					@walkTree subnode, level+1

		if defined(lWalkTrees)
			for key in lWalkTrees
				subnode = node[key]
				if isArray(subnode)
					for tree in subnode
						@walkTree tree, level+1
				else if defined(subnode)
					@walkTree subnode, level+1

		dbgReturn "handle", true
		return true

	# ..........................................................

	visit: (node, level) ->

		dbgEnter "ASTWalker.visit", node, level
		assert defined(node), "node is undef"

		if @handle(node, level)
			dbgReturn "ASTWalker.visit"
			return

		switch node.type

			when 'CallExpression'
				{callee} = node
				if (callee.type == 'Identifier')
					@addUsed callee.name
				else
					@walkTree callee, level+1
				for arg in node.arguments
					if (arg.type == 'Identifier')
						@addUsed arg.name
					else
						@walkTree arg, level+1

			when 'CatchClause'
				param = node.param
				if defined(param) && (param.type=='Identifier')
					@addDefined param.name
				@walkTree node.body, level+1

			when 'ExportNamedDeclaration'
				{specifiers, declaration} = node
				if defined(declaration)
					{type, id, left, body} = declaration
					switch type
						when 'ClassDeclaration'
							if defined(id)
								@addExport id.name
							else if defined(body)
								@walkTree node.body, level+1
						when 'AssignmentExpression'
							if (left.type == 'Identifier')
								@addExport left.name
					@walkTree declaration, level+1

				if defined(specifiers)
					for spec in specifiers
						name = spec.exported.name
						@addExport name

			when 'For'
				if defined(node.name) && (node.name.type=='Identifier')
					@addDefined node.name.name

				if defined(node.index) && (node.name.type=='Identifier')
					@addDefined node.index.name
				@walkTree node.source, level+1
				@walkTree node.body, level+1

			when 'FunctionExpression','ArrowFunctionExpression'
				lParmNames = []
				if defined(node.params)
					for parm in node.params
						switch parm.type
							when 'Identifier'
								lParmNames.push parm.name
							when 'AssignmentPattern'
								{left, right} = parm
								if left.type == 'Identifier'
									lParmNames.push left.name
								if right.type == 'Identifier'
									@addUsed right.name
								else
									@walkTree right, level+1
				@context.beginScope '<unknown>', lParmNames
				@walkTree node.params, level+1
				@walkTree node.body, level+1
				@context.endScope()

			when 'ImportDeclaration'
				{specifiers, source, importKind} = node
				if (importKind == 'value') && (source.type == 'StringLiteral')
					lib = source.value     # e.g. '@jdeighan/coffee-utils'

					for hSpec in specifiers
						{type, imported, local, importKind} = hSpec
						if (type == 'ImportSpecifier') \
								&& defined(imported) \
								&& (imported.type == 'Identifier')
							@addImport imported.name, lib

			when 'NewExpression'
				if node.callee.type == 'Identifier'
					@addUsed node.callee.name
				for arg in node.arguments
					if arg.type == 'Identifier'
						@addUsed arg.name
					else
						@walkTree arg     # --- ???

			when 'MemberExpression'
				# --- has keys:
				#        type = 'MemberExpression'
				#        computed: boolean
				#        object
				#        optional: boolean
				#        property
				#        shorthand: boolean
				#
				# NOTE: Because we need to treat it differently
				#       depending on whether computes is true or false,
				#       we cannot handle this in hAllHandlers

				{object, property, computed} = node
				if object.type == 'Identifier'
					@addUsed object.name
				else
					@walkTree object
				if computed    # --- e.g hItem[expr], not hItem.name
					if property.type == 'Identifier'
						@addUsed property.name
					else
						@walkTree property

			when 'ReturnStatement'
				{argument} = node
				if defined(argument)
					if (argument.type == 'Identifier')
						@addUsed argument.name
					else
						@walkTree argument

		dbgReturn "ASTWalker.visit"
		return

	# ..........................................................

	walk: () ->

		dbgEnter "walk", @ast
		for node in @ast
			@visit node, 0

		# --- get symbols to return

		# --- not needed if:
		#        1. in lImported
		#        2. not in lUsedSymbols
		#        3. not in lExportedSymbols
		lNotNeeded = @lImportedSymbols.filter (name) =>
			return ! @lUsedSymbols.includes(name) \
					&& ! @lExportedSymbols.includes(name)

		hInfo = {
			lImported:  @lImportedSymbols.sort()
			lExported:  @lExportedSymbols.sort()
			lUsed:      @lUsedSymbols.sort()
			lMissing:   @lMissingSymbols.sort()
			lNotNeeded: lNotNeeded.sort()
			}
		dbgReturn "walk", hInfo
		return hInfo

	# ..........................................................

	check: (name) ->

		assert nonEmpty(name), "empty name"
		return

	# ..........................................................

	barfAST: (filePath, hOptions={}) ->

		{full} = getOptions(hOptions)
		lSortBy = words("type params body left right")
		if full
			barf toTAML(@ast, {sortKeys: lSortBy}), filepath
		else
			astCopy = deepCopy @ast
			removeKeys astCopy, words(
				'start end extra declarations loc range tokens comments',
				'assertions implicit optional async generate hasIndentedBody'
				)
			barf toTAML(astCopy, {sortKeys: lSortBy}), filepath

# ---------------------------------------------------------------------------

export analyzeCoffeeCode = (code) =>

	walker = new ASTWalker(code)
	return walker.walk()

# ---------------------------------------------------------------------------

export analyzeCoffeeFile = (filePath) =>

	walker = new ASTWalker(slurp(filePath))
	return walker.walk()
