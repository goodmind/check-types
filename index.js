#!/usr/bin/env node

let ts = require('typescript')
let path = require('path')
let fs = require('fs')

function isInterface(symbol) {
  return (symbol.flags & ts.TypeFlags.Interface) !== 0
}

function isVarStatement(node) {
  return node.kind === ts.SyntaxKind.VariableStatement
}

function isNodeExported(node) {
  return (node.flags & ts.NodeFlags.Export) !== 0 || (node.parent &&
node.parent.kind === ts.SyntaxKind.SourceFile)
}

function delint (filenames) {
  let types = {}
  let program = ts.createProgram(filenames, {
    target: ts.ScriptTarget.ES6,
    noLib: true,
    module: ts.ModuleKind.CommonJS
  })
  let checker = program.getTypeChecker()
  program.getSourceFiles().forEach(file => ts.forEachChild(file, delintNode))
  process.stdout.write(JSON.stringify(types))

  function delintNode (node) {
    if (!isNodeExported(node)) {
      return
    }

    processType(node, types)
    ts.forEachChild(node, delintNode)
  }

  function visitInterface (type, struct) {
    let c = type.checker
    c.getPropertiesOfType(type).forEach(prop => {
      let node = prop.valueDeclaration.type
      let type = c.getTypeAtLocation(node)
      struct.push(prop.name)
    })
  }

  function processType (node, types) {
    ts.forEachChild(node.declarationList, processStruct)

    function processStruct (node) {
      let struct = []
      ts.forEachChild(node.initializer, visitInitializer)
      types[node.name.text] = struct

      function visitInitializer (node) {
        if (node.kind === ts.SyntaxKind.TypeReference) {
          let type = checker.getTypeAtLocation(node)
          if (isInterface(type)) return visitInterface(type, struct)
        }
      }
    }
  }
}

let workdir = path.resolve(__dirname, process.argv[2])

fs.readdir(workdir, (err, files) => {
  let filenames = files.map((name) => path.resolve(workdir, name))
  delint(filenames)
})
