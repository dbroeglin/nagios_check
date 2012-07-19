require 'benchmark'

module NagiosCheck
  module Chronometer
    def time(opts = {}, &block)
      raise ArgumentError, "block is mandatory for method time" if block.nil?
      time = Benchmark.realtime { block.call }
      if opts[:value_name]
        store_value(opts[:value_name], time)
      end
      time
    end
  end
end
