class Parser
  def initialize(tokens)
    @tokens = tokens
  end

  def parse
    parsed_statements = []

    @tokens.each do |token|
      case token[:type]
      when :println
        parsed_statements << { type: :println, value: token[:value] }
      end
    end

    parsed_statements
  end
end
