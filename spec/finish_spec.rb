require 'spec_helper'
def before_finish_test
  before(:each) do
    subject.prepare
    description = example.metadata[:example_group][:example_group][:description_args].first
    if description.kind_of?(String) && /^when options are '(.*)'$/ =~ description
      subject.send :parse_options, $1.split
    end

    description = example.metadata[:example_group][:description_args].first
    if description.kind_of?(String) && /^when value is (.*)$/ =~ description
      subject.store_value 'val', $1.to_f
    end
  end
end

class OkTestCheck
  include NagiosCheck
end

class WarningTestCheck
  include NagiosCheck
  enable_warning
end

class CriticalTestCheck
  include NagiosCheck
  enable_warning
  enable_critical
end

describe OkTestCheck do
  before_finish_test

  context "when options are ''" do
    it "should fail when no value is given" do
      lambda {
        subject.finish
      }.should raise_error(RuntimeError, "No value was provided")
    end

    context "when value is 0" do
      specify { subject.finish.should == [0, "OK"] }
    end
    context "when value is 5" do
      specify { subject.finish.should == [0, "OK"] }
    end
    context "when value is 10" do
      specify { subject.finish.should == [0, "OK"] }
    end

    context "when nil is given" do
      before { subject.store_value 'val', nil }
      specify { subject.finish.should == [3, "UNKNOWN"] }
    end
  end
end

describe WarningTestCheck do
  before_finish_test

  context "when options are '-w 10'" do
    context "when value is -1" do
      specify { subject.finish.should == [1, "WARNING"] }
    end
    context "when value is 0" do
      specify { subject.finish.should == [0, "OK"] }
    end
    context "when value is 5" do
      specify { subject.finish.should == [0, "OK"] }
    end
    context "when value is 10" do
      specify { subject.finish.should == [0, "OK"] }
    end
    context "when value is 11" do
      specify { subject.finish.should == [1, "WARNING"] }
    end
  end
end

describe CriticalTestCheck do
  before_finish_test

  context "when options are '-w 10 -c 20'" do
    context "when value is -1" do
      specify { subject.finish.should == [2, "CRITICAL"] }
    end
    context "when value is 0" do
      specify { subject.finish.should == [0, "OK"] }
    end
    context "when value is 5" do
      specify { subject.finish.should == [0, "OK"] }
    end
    context "when value is 10" do
      specify { subject.finish.should == [0, "OK"] }
    end
    context "when value is 15" do
      specify { subject.finish.should == [1, "WARNING"] }
    end
    context "when value is 20" do
      specify { subject.finish.should == [1, "WARNING"] }
    end
    context "when value is 21" do
      specify { subject.finish.should == [2, "CRITICAL"] }
    end
  end
end
