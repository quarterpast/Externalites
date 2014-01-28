require! {
	through
	path
	escodegen.generate
	esprima
	falafel
	\find-parent-dir
	'./umd'
	'./makers'
}

is-require-assign = ->
	it.type is \AssignmentExpression
	and it.right.type is \CallExpression
	and it.right.callee.name is \require

is-require-decl = ->
	it.type is \VariableDeclarator
	and it.init.type is \CallExpression
	and it.init.callee.name is \require

get-module-id = (node)-> match node
	| is-require-assign => node.right.arguments.0.value
	| is-require-decl   => node.init.arguments.0.value

get-var-name = (node)-> match node
	| is-require-assign => node.left.name
	| is-require-decl   => node.id.name

remove-requires = (modules, src)-->
	removed = []
	vars = []

	code = falafel src, (node)->
		if (is-require-assign or is-require-decl) node and (get-module-id node) in modules
			node.remove!
			removed.push get-module-id node
			vars.push get-var-name node

	{removed, code, vars}

externalise = (bundle, conf)->
	for k,{commonjs, requirejs} of conf
		bundle.exclude requirejs
		bundle.exclude commonjs

end-through = (fn)->
	data = ''
	through do
		(data +=)
		->
			err <~ fn.call this, data
			@emit \error that if err?
			@queue null

catch-or-cb = (cb, fn)->
	(err, res)->
		if err?
			cb that
		else
			try
				cb null fn.call this, res
			catch
				cb err

confs = {}

exports.pre = (bundle, file)-->
	data, end <- end-through
	find-parent-dir file, 'package.json', catch-or-cb end, (dir)~>
		conf = (require path.join dir, 'package.json').externalities
		confs import conf
		externalise bundle, conf
		@queue data

exports.post = ->
	data, end <- end-through
	{removed, vars, code} = remove-requires (Object.keys confs), data
	module-confs = removed.map (confs.)
	{body}:x = esprima.parse code
	@queue generate umd do
		confs.global-export
		makers.params vars
		makers.requires module-confs.map (.commonjs)
		makers.defines  module-confs.map (.requirejs)
		makers.globals  module-confs.map (.globalvar)
		body
	end!