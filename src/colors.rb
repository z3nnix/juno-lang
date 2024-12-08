class String
    COLORS = {
      black: 30, red: 31, green: 32, yellow: 33,
      blue: 34, purple: 35, cyan: 36, white: 37
    }.freeze
  
    BACKGROUNDS = {
      default: 49, black: 40, red: 41, green: 42,
      yellow: 43, blue: 44, purple: 45, cyan: 46, white: 47
    }.freeze
  
    def txtformat(textcl, backcl = :default)
      textc = COLORS[textcl]
      backc = BACKGROUNDS[backcl]
  
      "\e[#{textc};#{backc}m#{self}\e[0m"
    end
  
    COLORS.each do |textcl, _|
      define_method(textcl) do
        txtformat(textcl)
      end
  
      BACKGROUNDS.each do |backcl, _|
        define_method("#{textcl}_on_#{backcl}") do
          txtformat(textcl, backcl)
        end
      end
    end
  end