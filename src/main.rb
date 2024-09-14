# main.rb

require_relative 'lexer.rb'
require_relative 'parser.rb'
require_relative 'semantic.rb'
require_relative 'codegen.rb'

# Путь до целевого файла
path = "hello_program.ll"

# Программа на вашем языке
source_code = File.read("#{ARGV[0]}")

# Лексический анализ
lexer = Lexer.new(source_code)
tokens = lexer.tokenize

# Синтаксический анализ
parser = Parser.new(tokens)
ast = parser.parse

# Семантический анализ
analyzer = SemanticAnalyzer.new(ast)
analyzed_ast = analyzer.analyze

# Генерация кода
codegen = CodeGenerator.new(analyzed_ast, path)
codegen.generate

File.delete(path)
