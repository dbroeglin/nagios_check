require "nagios_check/version"
require 'optparse'
require 'ostruct'
require 'timeout'

require 'nagios_check/range'

module NagiosCheck
  attr_reader :options
  attr_accessor :message

  def prepare
    @values = {}
    self.message = nil
  end

  def run
    prepare
    parse_options
    return_val, status = 3, "UNKNOWN"
    begin
      if @timeout
        check_with_timeout
      else
        check
      end
      return_val, status = finish
    rescue Timeout::Error
      store_message "TIMEOUT after #{@timeout}s"
    rescue => e
      store_message "INTERNAL ERROR: #{e}"
    end
    msg = status
    msg += ': ' + message if message
    if @values && !@values.empty? 
      msg += '|' + @values.map do |name, value|
        "#{name}=#{value};;;;"
      end.join(' ')
    end
    puts msg 
    exit return_val
  end

  def store_message(message)
    self.message = message
  end

  def finish
    value = @values.first.last
    if @critical_range && !@critical_range.include?(value)
      return [2, "CRITICAL"]
    end
    if @warning_range && !@warning_range.include?(value)
      return [1, "WARNING"]
    end
    return [0, "OK"]
  end

  def store_value(name, value, opts = {})
    @values[name] = value.to_f
  end

  module ClassMethods
    def on(*args, &block)
      @ons << [args, args.delete(:mandatory), block]
    end

    def store(name, opts = {})
      @defaults[name] = opts[:default] if opts.has_key?(:default)
      transform = opts[:transform]
      Proc::new do |value|
        value = value.send transform if transform
        self.options.send "#{name}=", value
      end
    end

    def defaults
      @defaults
    end

    def enable_warning(*args)
      on("-w RANGE", *args) do |value| 
        @warning_range = NagiosCheck::Range.new(value) 
      end
    end

    def enable_critical(*args)
      on("-c RANGE", *args) do |value| 
        @critical_range = NagiosCheck::Range.new(value) 
      end
    end
    
    def enable_timeout(*args)
      on("-t TIMEOUT", *args) do |value| 
        @timeout = value.to_f 
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.instance_eval do 
      @ons = []
      @defaults = {}
    end
  end

  private

  def opt_parse
    unless @opt_parse
      opt_parse = OptionParser::new
      self.class.instance_variable_get("@ons").each do |args, mand, block|
        opt_parse.on(*args) do |value| 
          instance_exec(value, &block) 
        end
      end 
      @opt_parse = opt_parse
    end
    @opt_parse 
  end

  def parse_options(argv = ARGV)
    @options = OpenStruct::new(self.class.defaults)
    opt_parse.parse!(argv)
  end


  def check_with_timeout
    Timeout.timeout(@timeout) { check } 
  end

  class MissingOption < StandardError
  end
end
