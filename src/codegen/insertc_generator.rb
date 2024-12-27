module InsertcGenerator 
    def self.generate(node, c_code) 
      # Directly append the content of the insertC block to c_code.
      if node[:type] == :insertC
        c_code << node[:content] + "\n" # Append the content from the insertC node.
      else
        puts "Fatal error: Expected an insertC node, got #{node[:type]}"
        exit(1)
      end
    end
end