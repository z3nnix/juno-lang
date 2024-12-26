class Lexer
  def initialize(source)
    @source = source
    @lines = @source.lines
  end

  def tokenize
    tokens = []

    @lines.each do |line|
      line_without_comment = line.split('//').first.strip
      next if line_without_comment.empty?

      case line_without_comment
      when /^let\s+(\w+)(?::mut)?\s*=\s*"(.+)"$/
        tokens << { type: :let_string, name: $1, value: $2, mutable: !!$&.include?(':mut') }
      when /^let\s+(\w+)(?::mut)?\s*=\s*(\d+)$/
        tokens << { type: :let_int, name: $1, value: $2.to_i, mutable: !!$&.include?(':mut') }
      when /^(\w+)\s*=\s*"(.+)"$/
        tokens << { type: :assign_string, name: $1, value: $2 }
      when /^(\w+)\s*=\s*(\d+)$/
        tokens << { type: :assign_int, name: $1, value: $2.to_i }
      when /^(\w+)\+\+$/
        tokens << { type: :increment, name: $1 }
      when /^(\w+)\s*\+\s*(\d+)$/
        tokens << { type: :add, name: $1, value: $2.to_i }
      when /^print\s*\((.*)\)$/
        tokens << { type: :print, value: $1 }
      when /^input\s*\((\w+)\)$/
        tokens << { type: :input, name: $1 } # New input token
      end
    end

    tokens
  end
end
