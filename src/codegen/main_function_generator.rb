module MainFunctionGenerator
    def self.generate(ast, c_code, variables)
      c_code << "int main() {\n"
  
      ast.each_with_index do |node, index|
        case node[:type]
        when :variable_declaration
          VariableDeclarationGenerator.generate(node, index, c_code, variables)
        when :assignment
          AssignmentGenerator.generate(node, index, c_code, variables)
        when :increment
          IncrementGenerator.generate(node, variables, c_code) 
        when :print
          PrintGenerator.generate(node, index, c_code, variables)
        end
      end
  
      c_code << "  return 0;\n}\n"
    end
end   