module AssignmentGenerator
    def self.generate(node, index, c_code, variables)
      if variables[node[:name]]
        if variables[node[:name]][:mutable]
          if node[:var_type] == :assign_int && variables[node[:name]][:type] == 'int'
            c_code << "  #{node[:name]} = #{node[:value]};\n"
          elsif node[:var_type] == :assign_string && variables[node[:name]][:type] == 'char*'
            c_code << "  #{node[:name]} = str#{index};\n"
          else
            puts "Fatal error".red + ": Type mismatch in assignment for variable #{node[:name]}"
            exit(1)
          end
        else
          puts "Fatal error".red + ": Cannot assign to non-mutable variable #{node[:name]}"
          exit(1)
        end
      else
        puts "Fatal error".red + ": Unknown variable in assignment: #{node[:name]}"
        exit(1)
      end 
    end 
end   