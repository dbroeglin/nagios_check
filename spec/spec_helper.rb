require 'nagios_check'

module Matchers
  class Contain
    def initialize(expected)
      @expected = expected
    end

    def matches?(actual)
      @actual = actual
      !@actual.include?(@expected)
    end

    def failure_message
      "expected #{@actual} to alert for value #{@expected}" 
    end

    def negative_failure_message
      "expected #{@actual} not to alert for value #{@expected}"
    end
  end

  def alert_if(value)
    Contain::new(value)
  end
end

RSpec.configure do |config|  
  config.include(Matchers)  
end
