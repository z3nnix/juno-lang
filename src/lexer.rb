class Lexer
  def initialize(source)
    @source = source
    @lines = @source.lines
  end

  def tokenize
    tokens = []

    handle_includes(tokens)

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
        tokens << { type: :input, name: $1 }
      end
    end

    tokens
  end

  private

  def handle_includes(tokens)
    new_source = ""

    @lines.each do |line|
      if line =~ /^include\s+"(.+)"$/
        file_name = $1.strip
        begin
          included_content = File.read(file_name)

          included_lexer = Lexer.new(included_content)
          included_tokens = included_lexer.tokenize
          tokens.concat(included_tokens)
        rescue Errno::ENOENT
          raise "File not found: #{file_name}"
        end
      else
        new_source << line
      end
    end

    @source = new_source
    @lines = @source.lines
  end
end