module HeaderGenerator
    def self.generate(c_code)
      c_code << <<-C
#include <stdio.h>
#include <stdlib.h>
  
  C
    end
end  