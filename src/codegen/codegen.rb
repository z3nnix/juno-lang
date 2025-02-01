require_relative "header_generator"
require_relative "string_constant_generator"
require_relative "main_function_generator"
require_relative "variable_declaration_generator"
require_relative "assignment_generator"
require_relative "increment_generator"
require_relative "print_generator"
require_relative "insertc_generator"
require_relative "compiler"

class CodeGenerator
  def initialize(ast, path)
    @ast = ast
    @path = path
    @string_counter = 0
    @c_code = ""
    @string_constants = []
    @variables = {}
  end

  def generate
    genHeader
    genStringConst
    genMainFn

    File.write(@path, @c_code)

    compileRun
    return @c_code
  end

  private

  def genHeader
    HeaderGenerator.generate(@c_code)
  end

  def genStringConst
    StringConstantGenerator.generate(@ast, @c_code, @string_constants, @string_counter, @variables)
  end

  def genMainFn
    MainFunctionGenerator.generate(@ast, @c_code, @variables)
  end

  def compileRun
    Compiler.compileRun(@path, @c_code)
  end
end