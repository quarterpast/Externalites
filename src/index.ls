require! {
	grasp
	through
	path
	escodegen.generate
	\find-parent-dir
	'./replacement'
	'prelude-ls'.split-at
}

lines   = (.split '\n')
unlines = (.join '\n')

do-replace = (code, nodes)->
	c-lines = lines code
	for {loc}:node in nodes
		replacement = generate node
		line = c-lines[loc.start.line - 1]
		[start, end] = split-at loc.start.column, line
		[,end] = split-at loc.end.column, end
		c-lines[loc.start.line - 1] = "#start#replacement#end"

	unlines c-lines

create-replacements = (conf, nodes)->
	nodes.map (node)->
		id = node.arguments.0.value
		if conf[id]?
			(replacement that) import {node.loc}
		else node

replacer = (conf, code)->
	create-replacements conf, grasp.search do
		\equery
		'require(_str)'
		code

externalise = (bundle, conf)->
	for k,{commonjs, requirejs} of conf
		bundle.exclude requirejs
		bundle.exclude commonjs

module.exports = (bundle)->
	(file)->
		data = ''
		through do
			(data +=)
			->
				find-parent-dir file, 'package.json', (err, dir)~>
					if err?
						@emit \error that
					else
						try
							conf = (require path.join dir, 'package.json').externalities
							externalise bundle, conf
							nodes = replacer conf, data
							@queue do-replace data, nodes
						catch => @emit \error e
					@queue null

