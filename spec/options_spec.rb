describe NagiosCheck do
  context "when no options specified" do
    subject do
      Class::new do
        include NagiosCheck
      end.new
    end

    specify { subject.send :parse_options, [] }
  end
  
  context "when warning is specified" do
    subject do
      Class::new do
        include NagiosCheck
        enable_warning
      end.new
    end

    it("works with no arguments"){ subject.send :parse_options, %w{} }
    specify { subject.send :parse_options, %w{-w 10} }
   
    it "fails if -w has no argument" do
      lambda {
        subject.send :parse_options, %w{-w} 
      }.should raise_error(OptionParser::MissingArgument)
    end
    it "fails if -c is given" do
      lambda {
        subject.send :parse_options, %w{-c} 
      }.should raise_error(OptionParser::InvalidOption)
    end
  end
  
  context "when critical is specified" do
    subject do
      Class::new do
        include NagiosCheck
        enable_critical
      end.new
    end

    it("works with no arguments"){ subject.send :parse_options, %w{} }
    specify { subject.send :parse_options, %w{-c 10} }
   
    it "fails if -c has no argument" do
      lambda {
        subject.send :parse_options, %w{-c} 
      }.should raise_error(OptionParser::MissingArgument)
    end
   
    it "fails if -w is given" do
      lambda {
        subject.send :parse_options, %w{-w} 
      }.should raise_error(OptionParser::InvalidOption)
    end
  end
  
  context "when a non mandatory option is specified" do
    subject do
      Class::new do
        include NagiosCheck
        on "-a VALUE"
        on "-b VALUE", Integer
      end.new
    end

    it("works with no arguments"){ subject.send :parse_options, %w{} }

    it "works with '-a 10'" do
      subject.send :parse_options, %w{-a 10}
      subject.options.a.should == "10"
    end   
    
    it "works with '-b 20' and converts to int" do
      subject.send :parse_options, %w{-b 20}
      subject.options.b.should == 20
    end   

    it "fails if -a has no argument" do
      lambda {
        subject.send :parse_options, %w{-a} 
      }.should raise_error(OptionParser::MissingArgument)
    end
   
    it "fails if -w is given" do
      lambda {
        subject.send :parse_options, %w{-w} 
      }.should raise_error(OptionParser::InvalidOption)
    end
  end
  
  context "when a mandatory option is specified in arg list" do
    subject do
      Class::new do
        include NagiosCheck
        on "-a VALUE", :mandatory, Float
      end.new
    end

    it "fails if -a is not given" do
      lambda {
        subject.send :parse_options, %w{} 
      }.should raise_error(NagiosCheck::MissingOption)
    end

    it "parses option a 3.14" do 
      subject.send :parse_options, %w{-a 3.14} 
      subject.options.a.should == 3.14
    end
  end

  context "when a mandatory option is specified in option params hash" do
    subject do
      Class::new do
        include NagiosCheck
        on "-a VALUE", Float, mandatory: true
      end.new
    end

    it "fails if -a is not given" do
      lambda {
        subject.send :parse_options, %w{} 
      }.should raise_error(NagiosCheck::MissingOption)
    end

    it "parses option a 3.14" do 
      subject.send :parse_options, %w{-a 3.14} 
      subject.options.a.should == 3.14
    end
  end

  shared_examples_for "default provided" do
    it "defaults to 3.14" do
      subject.send :parse_options, %w{} 
      subject.options.a.should == 3.14 
    end

    it "parses option a at 1.4142" do 
      subject.send :parse_options, %w{-a 1.4142}
      subject.options.a.should == 1.4142
    end
  end

  context "when a default is provided" do
    subject do
      Class::new do
        include NagiosCheck
        on "-a VALUE", Float, default: 3.14
      end.new
    end

    it_behaves_like "default provided"
  end

  context "when a default is provided and option is mandatory" do
    subject do
      Class::new do
        include NagiosCheck
        on "-a VALUE", Float, default: 3.14, mandatory: true
      end.new
    end

    it_behaves_like "default provided"
  end
end
