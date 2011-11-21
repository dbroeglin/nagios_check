require "nagios_check/version"
require 'optparse'
require 'ostruct'

require 'nagios_check/range'

module NagiosCheck
  attr_reader :options

  def run
    parse_options
    check()
  end

  module ClassMethods
    def on(*args, &block)
      @ons << [args, args.delete(:required), block]
    end

    def store(name, opts = {})
      @defaults[name] = opts[:default] if opts.has_key?(:default)
      Proc::new do |value|
        self.options.send "#{name}=", value
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
    @opt_parse ||= OptionParser::new
  end

  def parse_options
    @options = OpenStruct::new(self.class.instance_variable_get("@defaults"))
    self.class.instance_variable_get("@ons").each do |args, req, block|
      opt_parse.on(*args) {|value| instance_exec(value, &block) }
    end 
    opt_parse.on("-w PATTERN") do |value|
      @warning = value
    end
    opt_parse.on("-c PATTERN") do |value|
      @critical = value
    end
    opt_parse.parse!
  end
end
