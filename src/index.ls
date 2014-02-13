require! {
	\end-through
	path
	escodegen.generate
	esprima
	falafel
	derequire
	\find-parent-dir
	'./umd'
	'./makers'
}

is-require-assign = ->
	it.type is \AssignmentExpression
	and it.left.type is \Identifier
	and it.right.type is \CallExpression
	and it.right.callee.name is \require

is-require-decl = ->
	it.type is \VariableDeclarator
	and it.init?
	and it.init.type is \CallExpression
	and it.init.callee.name is \require

is-empty-decl = ->
	it.type is \VariableDeclarator
	and it.id?
	and not it.init?

get-module-id = (node)-> match node
	| is-require-assign => node.right.arguments.0.value
	| is-require-decl   => node.init.arguments.0.value

get-var-name = (node)-> match node
	| is-require-assign => node.left.name
	| is-require-decl   => node.id.name
	| is-empty-decl     => node.id.name

remove-requires = (modules, src)-->
	removed = []
	vars = []

	code = falafel src, (node)->
		if (is-require-assign or is-require-decl) node and (get-module-id node) in modules
			node.remove!
			removed.push get-module-id node
			vars.push get-var-name node

	{removed, code, vars}

remove-vars = (src, vars)-->
	falafel src, (node)->
		node.remove! if is-empty-decl node and (get-var-name node) in vars

externalise = (bundle, conf)->
	for k,{commonjs, requirejs} of conf
		bundle.exclude requirejs
		bundle.exclude commonjs

dereq = ->
	data, end <- end-through
	@queue derequire data
	end!

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
var main-module

add-uniq = (xs, x)-> xs ++ if x in xs then [] else x
uniq = (.reduce add-uniq, [])

post = ->
	data, end <- end-through
	{removed, vars, code} = remove-requires (Object.keys confs), data
	final = remove-vars code.to-string!, vars
	module-confs = removed.map (confs.)
	{body} = esprima.parse final
	@queue generate umd do
		confs.global-export
		makers.params   uniq vars
		makers.requires uniq module-confs.map (.commonjs)
		makers.defines  uniq module-confs.map (.requirejs)
		makers.globals  uniq module-confs.map (.globalvar)
		body.0.expression
		main-module
	end!

module.exports = (b, opts)->
	b.on \row -> main-module ?:= it.index if it.entry
	b.transform (file)->
		data, end <- end-through
		find-parent-dir file, 'package.json', catch-or-cb end, (dir)~>
			conf = (require path.join dir, 'package.json').externalities
			confs import conf
			externalise b, conf
			@queue data

	piped = false
	bundle = b.bundle
	b.bundle = ->
		b = bundle ...
		unless piped
			piped := true
			b.pipe post! .pipe dereq!
		else b