require_relative "colors.rb"
require_relative "lexer"
require_relative "parser"
require_relative "semantic"
require_relative "codegen/codegen"

# Check for correct usage
if ARGV.length < 1 || ARGV.length > 2
  puts "Usage: juno <source file> [--debug|-d]"
  exit 1
end

# Path for the output C source file
path = "out.c"

# Read the source code from the provided file
source_code = File.read(ARGV[0])

# Initialize the lexer and tokenize the source code
lexer = Lexer.new(source_code)
tokens = lexer.tokenize

# Initialize the parser and parse the tokens into an AST
parser = Parser.new(tokens)
ast = parser.parse

# Perform semantic analysis on the AST
analyzer = SemanticAnalyzer.new(ast)
analyzed_ast = analyzer.analyze

# Initialize the code generator with the analyzed AST and generate C code
codegen = CodeGenerator.new(analyzed_ast, path)

if ARGV.length == 2 && (ARGV[1] == "--debug" || ARGV[1] == "-d")
  puts("\nC-code:\n".yellow + codegen.generate)
  puts("\nAST:\n".yellow + "#{analyzed_ast}")
else
  codegen.generate
end