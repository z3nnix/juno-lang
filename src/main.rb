# main.rb
require_relative "colors.rb"

require_relative "lexer"
require_relative "parser"
require_relative "semantic"
require_relative "codegen"

if ARGV.length != 1
  puts "Usage: juno <source file>"
  exit 1
end

path = "out.ll"

source_code = File.read(ARGV[0])

lexer = Lexer.new(source_code)
tokens = lexer.tokenize

parser = Parser.new(tokens)
ast = parser.parse

analyzer = SemanticAnalyzer.new(ast)
analyzed_ast = analyzer.analyze

codegen = CodeGenerator.new(analyzed_ast, path)
codegen.generate

File.delete(path)
