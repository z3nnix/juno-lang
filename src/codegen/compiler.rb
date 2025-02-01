module Compiler 
    def self.compileRun(path, c_code) 
      system("tcc #{path} -o a.out")
      
      if File.exist?("a.out")
        system("./a.out")
        
        File.delete("out.c") if File.exist?("out.c")
      else 
        puts "Compiler error".red + ":a.out file was not created."
      end 
    end 
end