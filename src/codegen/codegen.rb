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
    generate_header
    generate_string_constants
    generate_main_function

    File.write(@path, @c_code)

    compile_and_run
    return @c_code
  end

  private

  def generate_header
    HeaderGenerator.generate(@c_code)
  end

  def generate_string_constants
    StringConstantGenerator.generate(@ast, @c_code, @string_constants, @string_counter, @variables)
  end

  def generate_main_function
    MainFunctionGenerator.generate(@ast, @c_code, @variables)
  end

  def compile_and_run 
    Compiler.compile_and_run(@path, @c_code)
  end
end