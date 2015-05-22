require "nagios_check/version"
require 'optparse'
require 'ostruct'
require 'timeout'

require 'nagios_check/range'
require 'nagios_check/chronometer'

module NagiosCheck
  include Chronometer

  attr_reader :options
  attr_accessor :message


  def prepare
    @values = {}
    self.message = nil
  end

  def run
    prepare
    return_val, status = 3, "UNKNOWN"
    begin
      parse_options
      if @options.t
        check_with_timeout
      else
        check
      end
      return_val, status = finish
    rescue Timeout::Error
      store_message "TIMEOUT after #{@options.t}s"
    rescue OptionParser::InvalidArgument, NagiosCheck::MissingOption => e
      store_message "CLI ERROR: #{e}"
    rescue => e
      store_message "INTERNAL ERROR: #{e.class.name}: #{(e.to_s || '').gsub(/[\r\n]+/, ' ')}"
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
    raise "No value was provided" if @values.empty?
    value = @values.first.last
    if @options.c && !@options.c.include?(value)
      return [2, "CRITICAL"]
    end
    if @options.w && !@options.w.include?(value)
      return [1, "WARNING"]
    end
    return [0, "OK"]
  end

  def store_value(name, value, opts = {})
    @values[name] = value.to_f
  end

  module ClassMethods
    def on(*args, &block)
      name = option_name(args.first)
      option_params = {
        :mandatory => args.delete(:mandatory) ? true : false
      }
      if args.last.respond_to? :has_key? 
        option_params.merge! args.pop
      end
      @defaults[name] = option_params[:default] if option_params.has_key? :default
      @option_specs[name] = [args, option_params,  block]
    end

    def defaults
      @defaults
    end

    def enable_warning(*args)
      on("-w RANGE", *args) do |value| 
        self.options.w = NagiosCheck::Range.new(value) 
      end
    end

    def enable_critical(*args)
      on("-c RANGE", *args) do |value| 
        self.options.c = NagiosCheck::Range.new(value) 
      end
    end

    def enable_timeout(*args)
      on("-t TIMEOUT", *args) do |value| 
        self.options.t = value.to_f 
      end
    end

    def check_options!(options)
      @option_specs.each do |name, spec|
        _, option_params, _ = spec
        if option_params[:mandatory] && options.send(name).nil? 
          raise MissingOption.new(name)
        end
      end
    end

    private

    def option_name(arg) 
      if arg =~ /^--\[no-\]([^-\s][^\s]*)/
        $1.to_sym
      elsif arg =~ /^--([^-\s][^\s]*)/
        $1.to_sym
      elsif arg =~ /^-([^-\s][^\s]*)/
        $1.to_sym
      else
        raise "Unable to parse option '#{arg}'" 
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.instance_eval do 
      @option_specs = {} 
      @defaults = {}
    end
  end

  private

  def opt_parse
    unless @opt_parse
      opt_parse = OptionParser::new
      self.class.instance_variable_get("@option_specs").each do |name, spec|
        args, option_params, block = spec
        if block.nil?
          block = Proc::new do |value|
            self.options.send "#{name}=", value
          end
        end
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
    self.class.check_options!(@options)
  end


  def check_with_timeout
    Timeout.timeout(@options.t) { check } 
  end

  class MissingOption < StandardError; 
    def initialize(name)
      @name = name
    end

    def to_s
      "missing option: '#{@name}'"
    end
  end
end
