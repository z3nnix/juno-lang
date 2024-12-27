class Lexer
  def initialize(source)
    @source = source
    @lines = @source.lines
  end

  def tokenize
    tokens = []
    inside_insert_c = false
    insert_c_content = ""

    # Обработка директивы include
    handle_includes(tokens)

    @lines.each do |line|
      line.strip!

      if inside_insert_c
        if line == "}"
          tokens << { type: :insertC, content: insert_c_content.strip }
          inside_insert_c = false
          insert_c_content = ""
        else
          insert_c_content << line + "\n" # Сохраняем содержимое внутри insertC.
        end
      elsif line.start_with?("insertC {")
        inside_insert_c = true
      elsif line == "}"
        # Игнорируем отдельные закрывающие фигурные скобки вне insertC.
        next 
      elsif line.empty?
        next # Пропускаем пустые строки.
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

  private

  def handle_includes(tokens)
    new_source = ""

    @lines.each do |line|
      if line =~ /^include\s+"(.+)"$/
        file_name = $1.strip
        begin
          included_content = File.read(file_name)
          # Создаем новый лексер для включаемого содержимого и токенизируем его
          included_lexer = Lexer.new(included_content)
          included_tokens = included_lexer.tokenize
          tokens.concat(included_tokens) # Добавляем токены из включаемого файла
        rescue Errno::ENOENT
          raise "File not found: #{file_name}"
        end
      else
        new_source << line + "\n"
      end
    end

    @source = new_source.strip # Удаляем лишние пробелы в конце.
    @lines = @source.lines # Обновляем строки после обработки includes.
  end
end
