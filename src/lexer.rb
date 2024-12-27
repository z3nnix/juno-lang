class Lexer
  def initialize(source)
    @source = source
    @lines = @source.lines
  end

  def tokenize
    tokens = []
    inside_insert_c = false
    insert_c_content = ""

    @lines.each do |line|
      line.strip!

      if inside_insert_c
        if line == "}"
          tokens << { type: :insertC, content: insert_c_content.strip }
          inside_insert_c = false
          insert_c_content = ""
        else
          insert_c_content << line + "\n" # Capture content within insertC.
        end
      elsif line.start_with?("insertC {")
        inside_insert_c = true
      elsif line == "}"
        # We ignore standalone closing braces outside of insertC.
        next 
      elsif line =~ /^let\s+(\w+)(?::mut)?\s*=\s*"(.+)"$/
        tokens << { type: :let_string, name: $1, value: $2, mutable: !!$&.include?(':mut') }
      elsif line =~ /^let\s+(\w+)(?::mut)?\s*=\s*(\d+)$/
        tokens << { type: :let_int, name: $1, value: $2.to_i, mutable: !!$&.include?(':mut') }
      elsif line =~ /^(\w+)\s*=\s*"(.+)"$/
        tokens << { type: :assign_string, name: $1, value: $2 }
      elsif line =~ /^(\w+)\s*=\s*(\d+)$/
        tokens << { type: :assign_int, name: $1, value: $2.to_i }
      elsif line =~ /^(\w+)\+\+$/
        tokens << { type: :increment, name: $1 }
      elsif line =~ /^(\w+)\s*\+\s*(\d+)$/
        tokens << { type: :add, name: $1, value: $2.to_i }
      elsif line =~ /^print\s*\((.*)\)$/
        tokens << { type: :print, value: $1 }
      elsif line =~ /^input\s*\((\w+)\)$/
        tokens << { type: :input, name: $1 }
      end
    end

    tokens
  end
end
