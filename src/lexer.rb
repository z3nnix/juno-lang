# lexer.rb

class Lexer
  def initialize(source)
    @source = source
  end

  def tokenize
    # Простой токенизатор, который разбивает строку на токены
    tokens = []
    if @source =~ /println "(.*)"/
      tokens << { type: :println, value: $1 }
    end
    tokens
  end
end

