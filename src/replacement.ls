module.exports = replacement = ({commonjs, requirejs, globalvar})->
	type: "ConditionalExpression"
	test:
		type: "BinaryExpression"
		operator: "==="
		left:
			type: "Literal"
			value: "object"
			raw: "'object'"
		right:
			type: "UnaryExpression"
			operator: "typeof"
			argument:
				type: "Identifier"
				name: "exports"
			prefix: true
	consequent:
		type: "CallExpression"
		callee:
			type: "Identifier"
			name: "require"
		arguments: [
			type: "Literal"
			value: commonjs
			raw: \' + commonjs + \'
		]
	alternate:
		type: "ConditionalExpression"
		test:
			type: "LogicalExpression"
			operator: "&&"
			left:
				type: "BinaryExpression"
				operator: "==="
				left:
					type: "Literal"
					value: "function"
					raw: "'function'"
				right:
					type: "UnaryExpression"
					operator: "typeof"
					argument:
						type: "Identifier"
						name: "define"
					prefix: true
			right:
				type: "MemberExpression"
				computed: false
				object:
					type: "Identifier"
					name: "define"
				property:
					type: "Identifier"
					name: "amd"
		consequent:
			type: "CallExpression"
			callee:
				type: "Identifier"
				name: "require"
			arguments: [
				type: "Literal"
				value: requirejs
				raw: \' + requirejs + \'
			]
		alternate:
			type: "MemberExpression"
			computed: false
			object:
				type: "Identifier"
				name: "window"
			property:
				type: "Identifier"
				name: globalvar