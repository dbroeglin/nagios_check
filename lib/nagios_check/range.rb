module NagiosCheck
  class Range
    def initialize(string_range)
      if string_range.nil? || string_range.empty?
        raise RuntimeError, "Pattern should not be nil" 
      end
      @string_range = string_range
      tokens = string_range.scan(/^([~@])?([~@])?(([-.0-9]+)?:)?([-.0-9]+)?$/).first
      unless tokens
        raise RuntimeError, "Pattern should be of form [@][~][min]:max" 
      end
      @reversed = true if tokens.include? "~"
      @inclusive = true if tokens.include? "@"
      @min = tokens[3].nil? || tokens[3] == "" ? 0   : tokens[3].to_f
      @max = tokens[4].nil? || tokens[4] == "" ? nil : tokens[4].to_f
    end

    def include?(value)
      if @inclusive
        result = value >= @min && (@max.nil? || value <= @max)
      else
        result = value > @min && (@max.nil? || value < @max)
      end
      @reversed ? !result : result
    end

    def ===(value)
      include?(value)
    end

    def to_s
      "Range[#{@reversed ? "~" : ""}#{@inclusive ? "@" : ""}#{@min}:#{@max}]"
    end
  end
end
