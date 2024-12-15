class Parser

  def initialize(tokens)
    @tokens = tokens
    @current_token_index = 0
  end

  #Парсятся ли бинарные выражения?
  #Нет, не парсятся, считайте в уме
  def parse
    parsed_statements = []

    while current_token
      parsed_statements << parse_statement
    end

    parsed_statements
  end

  private

  def parse_statement
    case current_token[:type]
    when :let_string, :let_int
      parse_variable_declaration
    when :assign_string, :assign_int
      parse_assignment
    when :increment
      parse_increment
    when :add
      parse_addition
    when :print
      parse_print
    else
      raise "Unexpected token: #{current_token}"
    end
  end

  def parse_variable_declaration
    token = consume(:let_string, :let_int)
    {
      type: :variable_declaration,
      name: token[:name],
      value: token[:value],
      var_type: token[:type],
      mutable: token[:mutable]
    }
  end

  def parse_assignment
    token = consume(:assign_string, :assign_int)
    {
      type: :assignment,
      name: token[:name],
      value: token[:value],
      var_type: token[:type]
    }
  end

  def parse_increment
    token = consume(:increment)
    {
      type: :increment,
      name: token[:name]
    }
  end

  def parse_addition
    token = consume(:add)
    {
      type: :add,
      name: token[:name],
      value: token[:value]
    }
  end

  def parse_print
    token = consume(:print)
    {
      type: :print,
      value: token[:value]
    }
  end

  def consume(*expected_types)
    raise "Unexpected end of input" if @current_token_index >= @tokens.length

    token = current_token
    if expected_types.include?(token[:type])
      @current_token_index += 1
      token
    else
      raise "Expected one of #{expected_types}, got #{token[:type]}"
    end
  end

  def current_token
    @tokens[@current_token_index]
  end
end
