module NagiosCheck
  class Range
    def initialize(string_range)
      if string_range.nil? || string_range.empty?
        raise RuntimeError, "Pattern should not be nil" 
      end
      @string_range = string_range
      tokens = string_range.scan(/^(@)?(([-.0-9]+|~)?:)?([-.0-9]+)?$/).first
      unless tokens
        raise RuntimeError, "Pattern should be of form [@][~][min]:max" 
      end
      @inverse = true if tokens.include? "@"
      case tokens[2]
      when nil, "" then @min = 0
      when '~' then @min = nil
      else @min = tokens[2].to_f
      end
      @max = tokens[3].nil? || tokens[3] == "" ? nil : tokens[3].to_f
    end

    def include?(value)
      if @inverse
        if @max.nil?
          (@min.nil? || value < @min)
        elsif @min.nil?
          (@max.nil? || value > @max)
        elsif @min == @max
          false
        else
          (@min.nil? || value < @min) || (@max.nil? || value > @max)
        end
      else
        (@min.nil? || value >= @min) && (@max.nil? || value <= @max)
      end
    end

    def ===(value)
      include?(value)
    end

    def to_s
      "Range[#{@reversed ? "~" : ""}#{@inclusive ? "@" : ""}#{@min}:#{@max}]"
    end
  end
end
