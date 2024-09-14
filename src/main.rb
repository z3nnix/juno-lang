# main.rb

require_relative 'lexer'
require_relative 'parser'
require_relative 'semantic'
require_relative 'codegen'

# Проверка наличия аргумента командной строки
if ARGV.length != 1
  puts "Usage: juno <source file>"
  exit 1
end

# Путь до целевого файла
path = "out.ll"

# Считывание исходного кода из файла
source_code = File.read(ARGV[0])

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
