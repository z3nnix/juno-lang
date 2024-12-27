module PrintGenerator 
    def self.generate(node, index, c_code, variables) 
      if node[:value].start_with?('"') && node[:value].end_with?('"')
        # Printing string literal.
        c_code << "  printf(\"%s\\n\", str#{index});\n"
      elsif variables[node[:value]]
        # Printing variable.
        if variables[node[:value]][:type] == 'int'
          c_code << "  printf(\"%d\\n\", #{node[:value]});\n"
        elsif variables[node[:value]][:type] == 'const char*'
          # Use const char* for immutable strings.
          c_code << "  printf(\"%s\\n\", #{node[:value]});\n"
        end 
      else 
        if node[:value].nil?
          puts "Fatal error".red + ": print() cannot be empty"
          exit(1)
        else 
          puts "Fatal error".red + ": Unknown variable in print: #{node[:value]}"
          exit(1)
        end 
      end 
    end 
end