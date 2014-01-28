module.exports = umd = (global-var, params, requires, defines, globals, body)->
	type: \UnaryExpression
	operator: \!
	argument:
		type: \CallExpression
		callee:
			type: \FunctionExpression
			params: [
				type: \Identifier name: \definition
			]
			body:
				type: \BlockStatement
				body: [
					type: \ReturnStatement
					argument:
						type: \ConditionalExpression
						test:
							type: \BinaryExpression
							operator: "==="
							left:
								type: \UnaryExpression
								operator: \typeof
								argument: type: \Identifier name: \exports
								prefix: true
							right: type: \Literal value: \object
						consequent:
							type: \AssignmentExpression
							operator: "="
							left:
								type: \MemberExpression
								object: type: \Identifier name: \module
								property: type: \Identifier name: \exports
							right:
								type: \CallExpression
								callee: type: \Identifier name: \definition
								arguments: requires
						alternate:
							type: \ConditionalExpression
							test:
								type: \LogicalExpression
								operator: "&&"
								left:
									type: \BinaryExpression
									operator: "==="
									left:
										type: \UnaryExpression
										operator: \typeof
										argument: type: \Identifier name: \define
										prefix: true
									right: type: \Literal value: \function
								right:
									type: \MemberExpression
									object: type: \Identifier name: \define
									property: type: \Identifier name: \amd
							consequent:
								type: \CallExpression
								callee:
									type: \Identifier
									name: \define
								arguments:
									* type: \ArrayExpression elements: defines
									* type: \Identifier name: \definition
							alternate:
								type: \AssignmentExpression
								operator: "="
								left:
									type: \MemberExpression
									object: type: \Identifier name: \window
									property: type: \Identifier name: global-var
								right:
									type: \CallExpression
									callee: type: \Identifier name: \definition
									arguments: globals
				]
		arguments: [
			type: \FunctionExpression
			params: params
			body: type: \BlockStatement body: [type: \ReturnStatement argument:body]
		]
