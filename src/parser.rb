class Parser
  def initialize(tokens)
    @tokens = tokens
  end

  def parse
    parsed_statements = []

    @tokens.each do |token|
      case token[:type]
      when :let_string, :let_int
        parsed_statements << { type: :variable_declaration, name: token[:name], value: token[:value], var_type: token[:type], mutable: token[:mutable] }
      when :assign_string, :assign_int
        parsed_statements << { type: :assignment, name: token[:name], value: token[:value], var_type: token[:type] }
      when :increment
        parsed_statements << { type: :increment, name: token[:name] }
      when :add
        parsed_statements << { type: :add, name: token[:name], value: token[:value] }
      when :print
        parsed_statements << { type: :print, value: token[:value] }
      end
    end

    parsed_statements
  end
end
