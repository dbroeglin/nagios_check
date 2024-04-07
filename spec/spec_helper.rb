require 'nagios_check'

RSpec::Matchers.define :alert_if do |expected|
  match do |actual|
    !actual.include?(expected)
  end

  failure_message do |actual|
    "expected that #{actual} would alert for value #{expected}"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not alert for value #{expected}"
  end
end
