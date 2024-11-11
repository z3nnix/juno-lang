class Lexer
  def initialize(source)
    @source = source
    @lines = @source.lines
  end

  def tokenize
    # Простой токенизатор, который разбивает строку на токены
    tokens = []

    @lines.each do |line|
      if line =~ /println "(.*)"/
        tokens << { type: :println, value: $1 }
      end
    end

    tokens
  end
end
