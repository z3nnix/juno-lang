module IncrementGenerator 
    def self.generate(node, variables, c_code) 
      if variables[node[:name]] && 
        variables[node[:name]][:type] == 'int' && 
        variables[node[:name]][:mutable]
        
        c_code << "  #{node[:name]}++;\n" 
        
      else 
        puts "Fatal error".red + ": Cannot increment non-mutable or non-integer variable - #{node[:name]}"
        exit(1)
      end 
    end 
end  