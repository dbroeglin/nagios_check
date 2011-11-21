require 'spec_helper'

require 'pp'

describe NagiosCheck::Range do
  subject { @range }
  before(:each) do 
    description = example.metadata[:example_group][:description_args].first 
    if /^when pattern is (.*)/ =~ description
      @range = NagiosCheck::Range::new($1)
    end
  end

  context "when pattern is 10" do
    it { should_not contain -1 } 
    it { should_not contain 0 } 
    it { should     contain 0.1 } 
    it { should     contain 1 } 
    it { should     contain 9 } 
    it { should     contain 9.9 } 
    it { should_not contain 10 } 
    it { should_not contain 10 } 
    it { should_not contain 10.0 } 
  end

  context "when pattern is :10" do
    it { should_not contain -1 } 
    it { should_not contain 0 } 
    it { should     contain 0.1 } 
    it { should     contain 1 } 
    it { should     contain 9 } 
    it { should     contain 9.9 } 
    it { should_not contain 10 } 
    it { should_not contain 10 } 
    it { should_not contain 10.0 } 
  end
  
  context "when pattern is @:10" do
    it { should_not contain -1 } 
    it { should     contain 0 } 
    it { should     contain 10 } 
    it { should     contain 10.0 } 
    it { should_not contain 11 } 
  end

  context "when pattern is 10:" do
    it { should_not contain -1 } 
    it { should_not contain 1 } 
    it { should_not contain 9.9 } 
    it { should_not contain 10 } 
    it { should_not contain 10.0 } 
    it { should     contain 10.1 } 
    it { should     contain 11 } 
  end
  
  context "when pattern is @10:" do
    it { should_not contain -1 } 
    it { should_not contain 1 } 
    it { should_not contain 9.9 } 
    it { should     contain 10 } 
    it { should     contain 10.0 } 
    it { should     contain 10.1 } 
    it { should     contain 11 } 
  end

  context "when pattern is 10:11" do
    it { should_not contain -1 } 
    it { should_not contain 1 } 
    it { should_not contain 9.9 } 
    it { should_not contain 10 } 
    it { should_not contain 10.0 } 
    it { should     contain 10.1 } 
    it { should     contain 10.9 } 
    it { should_not contain 11 } 
    it { should_not contain 11.1 } 
    it { should_not contain 12 } 
  end
  
  context "when pattern is @10:11" do
    it { should_not contain -1 } 
    it { should_not contain 1 } 
    it { should_not contain 9.9 } 
    it { should     contain 10 } 
    it { should     contain 10.0 } 
    it { should     contain 10.1 } 
    it { should     contain 11 } 
    it { should_not contain 11.1 } 
    it { should_not contain 12 } 
  end

  context "when pattern is @10.05:11.05" do
    it { should_not contain -1 } 
    it { should_not contain 1 } 
    it { should_not contain 9.9 } 
    it { should_not contain 10 } 
    it { should_not contain 10.0 } 
    it { should     contain 10.1 } 
    it { should     contain 11 } 
    it { should_not contain 11.1 } 
    it { should_not contain 12 } 
  end

  context "when pattern is -1:1" do
    it { should_not contain -2 } 
    it { should_not contain -1 } 
    it { should     contain -0.9 } 
    it { should     contain 0 } 
    it { should     contain 0.9 } 
    it { should_not contain 1 } 
    it { should_not contain 2 } 
  end
  
  context "when pattern is ~-1:1" do
    it { should     contain -2 } 
    it { should     contain -1 } 
    it { should_not contain 0 } 
    it { should     contain 1 } 
    it { should     contain 2 } 
  end
  
  context "when pattern is @~-1:1" do
    it { should     contain -2 } 
    it { should_not contain -1 } 
    it { should_not contain 0 } 
    it { should_not contain 1 } 
    it { should     contain 2 } 
  end
  
  context "when pattern is ~@-1:1" do
    it { should     contain -2 } 
    it { should_not contain -1 } 
    it { should_not contain 0 } 
    it { should_not contain 1 } 
    it { should     contain 2 } 
  end

  context "when pattern is ~:10" do
    it { should     contain -2 } 
    it { should     contain -1 } 
    it { should     contain 0 } 
    it { should_not contain 1 } 
    it { should_not contain 9 } 
    it { should     contain 10 } 
    it { should     contain 11 } 
  end

  context "when nil pattern" do 
    it "raises an error" do
      lambda { NagiosCheck::Range.new nil }.should raise_error
    end
  end
  
  context "when empty pattern" do 
    it "raises an error" do
      lambda { NagiosCheck::Range.new "" }.should raise_error
    end
  end
end
