export params = (ids)-> [type:\Identifier name:id for id in ids]

export globals = (ids)->
	[{
		type: \MemberExpression
		object: type: \Identifier name: \window
		property: type: \Identifier name: id
	} for id in ids]

export defines = (ids)-> [type:\Literal value:id for id in ids]

export requires = (ids)->
	[{
		type: \CallExpression
		callee: type: \Identifier name: \require
		arguments: [type: \Literal value: id]
	} for id in ids]