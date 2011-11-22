require 'nagios_check'

module Matchers
  class Contain
    def initialize(expected)
      @expected = expected
    end

    def matches?(actual)
      @actual = actual
      @actual.include? @expected
    end

    def failure_message
      "expected #{@actual} to contain #{@expected}" 
    end

    def negative_failure_message
      "expected #{@actual} not to contain #{@expected}"
    end
  end

  def contain(value)
    Contain::new(value)
  end
end

RSpec.configure do |config|  
  config.include(Matchers)  
end
