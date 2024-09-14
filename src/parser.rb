# parser.rb

class Parser
  def initialize(tokens)
    @tokens = tokens
  end

  def parse
    # Простой парсер, который обрабатывает токены
    if @tokens[0][:type] == :println
      return { type: :println, value: @tokens[0][:value] }
    end
    nil
  end
end

