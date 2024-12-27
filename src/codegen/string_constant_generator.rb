module StringConstantGenerator
    def self.generate(ast, c_code, string_constants, string_counter, variables)
      ast.each_with_index do |node, index|
        case node[:type]
        when :variable_declaration
          generate_string_constant(node[:value], index, string_constants) if node[:var_type] == :let_string
        when :assignment
          generate_string_constant(node[:value], index, string_constants) if node[:var_type] == :assign_string
        when :print
          generate_string_constant(node[:value][1..-2], index, string_constants) if node[:value].start_with?('"') && node[:value].end_with?('"')
        end
      end
  
      # Add string constants to the generated C code.
      string_constants.each do |constant|
        c_code << "#{constant}\n"
      end
    end
  
    def self.generate_string_constant(value, index, string_constants)
      str_value = value.gsub('"', '').encode('UTF-8')
      string_constants << "const char* str#{index} = \"#{str_value}\";"
    end
end  