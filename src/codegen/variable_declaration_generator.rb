module VariableDeclarationGenerator
    def self.generate(node, index, c_code, variables)
      if node[:var_type] == :let_int
        variables[node[:name]] = { type: 'int', mutable: node[:mutable] }
        c_code << "  int #{node[:name]} = #{node[:value]};\n"
      elsif node[:var_type] == :let_string
        if node[:mutable]
          variables[node[:name]] = { type: 'char*', mutable: true }
          c_code << "  char* #{node[:name]} = str#{index};\n"
        else
          variables[node[:name]] = { type: 'const char*', mutable: false }
          c_code << "  const char* #{node[:name]} = str#{index};\n"
        end
      end
    end 
end